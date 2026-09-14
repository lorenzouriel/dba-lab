# RAG Without Leaving the Database: Building Retrieval-Augmented Generation in T-SQL

*How SQL Server 2025 and Azure SQL turn your tables into a grounded AI service, one stored procedure at a time.*

---

A language model can write you a sonnet about bicycle pedals. What it can't do is tell a customer which pedals fit the Mountain-500 they bought last month. That fact lives in your database, and the model has never seen it.

Most teams reach for an external service to bridge that gap: a Python app that queries the database, stuffs the results into a prompt, calls an API, and parses the response. It works. It's also a second system to deploy, secure, and monitor, sitting next to data that already has a perfectly good query engine.

This Microsoft Learn module makes a different argument: keep the whole Retrieval-Augmented Generation (RAG) loop inside T-SQL. Retrieve with vector search, format with `FOR JSON`, call the model with `sp_invoke_external_rest_endpoint`, parse with `JSON_VALUE`. No middleware. Below is the module distilled section by section, with the parts a senior engineer actually cares about pulled to the front.

---

## 1. What RAG is, and why it beats "the model should just know"

An LLM only knows its training data. Your catalog, your orders, your policies, your schema: none of it is in there. Ask a domain question and you get a confident guess.

RAG fixes this by injecting your data at query time instead of training time. Three steps, and the acronym is the workflow:

1. **Retrieve** the relevant rows from your database.
2. **Augment** the prompt by adding those rows as context.
3. **Generate** a response grounded in what you supplied.

The contrast worth internalizing is RAG versus fine-tuning. Fine-tuning bakes knowledge into the weights permanently and ships your data to the model provider to do it. RAG leaves the data in your tables and sends only the slice each request needs. So the decision rule is straightforward:

- **Data changes often?** RAG wins. A fine-tuned model is stale the moment inventory updates; RAG reads current rows every call.
- **Need traceability?** RAG wins. You control retrieval, so you know exactly which records produced an answer.
- **Privacy-sensitive?** RAG wins. Context goes out per request; the corpus never leaves your database.

If your questions are generic ("what's a good cadence for climbing?") the base model is fine. The moment the answer depends on *your* rows, you need retrieval.

Where SQL fits: the database stores the products, orders, documents, and embeddings, and T-SQL orchestrates the flow. The model itself runs elsewhere (Azure OpenAI, for example). Your database never hosts a model. It retrieves, formats, calls out, and returns.

---

## 2. Retrieval: turn relational rows into context a model can read

Retrieval is the "R," and the goal is not "get the data" but "get the data in a shape the model can use." Models read text, not result sets. Hand a model raw columns and it has no idea what the values mean. JSON solves this by keeping field names attached to values, which is why `FOR JSON` is the workhorse here.

Two flavors:

`FOR JSON AUTO` infers structure from the query. Fast, zero ceremony, column names become field names.

```sql
select Name, ListPrice, Color
from Production.Product
where ProductID = @ProductID
for json auto;
-- [{"Name":"Mountain-500 Black, 48","ListPrice":564.99,"Color":"Black"}]
```

`FOR JSON PATH` gives you explicit control over field names and nesting through column aliases. Reach for it when the shape matters.

```sql
select
    Name      as 'product.name',
    ListPrice as 'product.price',
    Size      as 'product.size'
from Production.Product
where ProductID = @ProductID
for json path;
-- [{"product":{"name":"Mountain-500 Black, 48","price":564.99,"size":"48"}}]
```

Three modifiers earn their keep in RAG:

- `WITHOUT_ARRAY_WRAPPER` drops the outer brackets when you're retrieving a single record. You retrieve one customer or one order more often than you'd think.
- `INCLUDE_NULL_VALUES` keeps nulls when their absence is itself meaningful.
- `ROOT('name')` wraps the output in a named element so the model knows what it's looking at.

The discipline that separates good RAG from token-burning RAG: **include only what answers the question.** `rowguid`, audit timestamps, warehouse codes, the discontinued flag. None of it helps the model and all of it costs tokens and adds noise. A focused context with four useful columns outperforms a wide one with twenty. Every token you send counts against the context window and the bill.

When the answer spans tables (product details plus specs plus compatible components), you build the picture with joins and let `FOR JSON PATH` serialize the whole thing into one `@context` variable. That variable is your retrieval result, ready to drop into a prompt.

---

## 3. Augmentation: a JSON blob is not an instruction

Retrieval hands you data. Augmentation (the "A") tells the model what to do with it. Skip this and you've got a pile of JSON and no answer.

Chat models expect messages with roles. Three matter:

- **system** sets behavior and ground rules.
- **user** carries the question plus your retrieved context.
- **assistant** holds prior turns in a multi-turn conversation (optional).

You can assemble this payload in app code, but keeping it in T-SQL means retrieval, formatting, and prompt construction live in one place. `JSON_OBJECT` and `JSON_ARRAY` build valid JSON without string concatenation gymnastics.

```sql
declare @userQuestion nvarchar(1000) = 'Which pedals are compatible with the Mountain-500?';
-- @context holds the retrieved product data as JSON

declare @systemMessage nvarchar(max) =
    'You are an Adventure Works product assistant. Answer using only the provided product data. Be concise.';

declare @userMessage nvarchar(max) =
    'Product information: ' + @context + char(10) + char(10) + 'Customer question: ' + @userQuestion;

declare @payload nvarchar(max) = json_object(
    'messages': json_array(
        json_object('role': 'system', 'content': @systemMessage),
        json_object('role': 'user',   'content': @userMessage)
    ),
    'max_tokens': 500,
    'temperature': 0.5
);
```

Two knobs control behavior. **Grounding** lives in the system message and is where you earn accurate answers. Set scope ("use only the provided data"), demand honesty ("if information is missing, say so"), and constrain format ("under 100 words"). Without it, the model happily falls back to training data and hands your customer generic warranty terms scraped off the internet.

**Temperature** controls creativity on a 0 to 2 scale. For RAG you want consistency, not flair, so keep it low (0.3 to 0.5). Pair it with `max_tokens` to cap response length.

The mental model: the system message is the contract, the user message is the evidence plus the question. Get the contract right and the model stays inside your data.

---

## 4. Generation: call the model from SQL and parse what comes back

The "G." This is the step people assume forces them into application code, and it doesn't. SQL Server 2025 and Azure SQL Database can hit an HTTPS endpoint directly with `sp_invoke_external_rest_endpoint`.

```sql
declare @response nvarchar(max);
declare @returnValue int;

execute @returnValue = sp_invoke_external_rest_endpoint
    @url        = N'https://<endpoint>.openai.azure.com/openai/deployments/<model>/chat/completions?api-version=2024-10-21',
    @method     = 'POST',
    @payload    = @payload,
    @credential = [https://<endpoint>.openai.azure.com],
    @response   = @response output;
```

**One operational gotcha worth flagging up front:** the proc is enabled by default *only* in Azure SQL Database. On SQL Server 2025 you turn it on with `sp_configure`. Authentication rides on a database-scoped credential (managed identity is the clean option), and the same credential serves both `CREATE EXTERNAL MODEL` and these REST calls.

The response arrives wrapped in an envelope: HTTP metadata at the top, the actual API payload nested under `result`. The answer you want sits at `$.result.choices[0].message.content`, and `JSON_VALUE` extracts it.

```sql
if @returnValue = 0
begin
    declare @answer nvarchar(max);
    set @answer = json_value(@response, '$.result.choices[0].message.content');
    select @answer as AssistantResponse;
end
```

Use `JSON_VALUE` for scalars, `JSON_QUERY` when you need to pull an object or array. For most RAG, scalar content is all you touch.

Now the part local queries let you ignore: **failure modes.** A network call can be throttled, time out, or fail auth. The return value tells you which: `0` means a 2xx succeeded, otherwise you get the HTTP status code itself. `429` is throttling, `401`/`403` is a credential problem. Handle them explicitly rather than letting a null answer leak to the caller.

```sql
if @returnValue = 0
    set @answer = json_value(@response, '$.result.choices[0].message.content');
else if @returnValue = 429
    raiserror('Service is busy. Try again later.', 16, 1);
else if @returnValue in (401, 403)
    raiserror('Authentication failed. Check the credential configuration.', 16, 1);
else
    raiserror('API call failed.', 16, 1);
```

For transient failures, `@retry_count` lets the proc retry automatically (three attempts in this example) before giving up:

```sql
execute @returnValue = sp_invoke_external_rest_endpoint
    @url         = @url,
    @payload     = @payload,
    @credential  = @credentialName,
    @retry_count = 3,
    @response    = @response output;
```

Wrap all three steps in one procedure and you've got an endpoint your application calls like any other:

```sql
create procedure dbo.AskProductQuestion
    @Question nvarchar(1000),
    @Answer   nvarchar(max) output
as
begin
    set nocount on;

    declare @questionVector vector(1536);
    declare @context        nvarchar(max);
    declare @payload        nvarchar(max);
    declare @response       nvarchar(max);
    declare @returnValue    int;

    -- 1. Question to embedding
    select @questionVector = AI_GENERATE_EMBEDDINGS(@Question use model my_embedding_model);

    -- 2. Retrieve relevant products
    set @context = (
        select top 3
            p.Name as ProductName,
            p.Color,
            p.Size,
            pm.Name as Model
        from Production.Product as p
        inner join Production.ProductModel as pm
            on p.ProductModelID = pm.ProductModelID
        order by VECTOR_DISTANCE('cosine', p.DescriptionVector, @questionVector)
        for json path
    );

    -- 3. Build the augmented prompt
    set @payload = json_object(
        'messages': json_array(
            json_object('role': 'system', 'content': 'You are an Adventure Works product assistant. Answer using only the provided product data.'),
            json_object('role': 'user',   'content': 'Products: ' + @context + ' Question: ' + @Question)
        ),
        'max_tokens': 500,
        'temperature': 0.5
    );

    -- 4. Call the model
    execute @returnValue = sp_invoke_external_rest_endpoint
        @url        = N'https://adventureworks-openai.openai.azure.com/openai/deployments/gpt-5.4-mini/chat/completions?api-version=2024-10-21',
        @method     = 'POST',
        @payload    = @payload,
        @credential = [https://adventureworks-openai.openai.azure.com],
        @response   = @response output;

    -- 5. Extract or fail clearly
    if @returnValue = 0
        set @Answer = json_value(@response, '$.result.choices[0].message.content');
    else
        set @Answer = 'Unable to process your question. Please try again.';
end;
```

A customer asks a question, the proc embeds it, finds the closest products, grounds the model, and returns an answer based on real inventory. No external app in the path.

---

## 5. The hands-on build: vector search the right way

The lab is where the retrieval step gets serious, because it swaps a hardcoded `WHERE` clause for semantic search over 140 customer reviews. Two pieces matter here, and one of them is a performance decision a senior engineer should not miss.

**Storing embeddings.** Add a `VECTOR(1536)` column (1536 matches `text-embedding-3-small`), then populate it. The lab generates embeddings in batches of 30 with a `WAITFOR DELAY` between batches and a retry loop on rate-limit errors. That batching is not decoration. Hit an embeddings endpoint with an unthrottled `UPDATE` across a real table and you'll meet `429` fast.

```sql
alter table dbo.ProductReview
add ReviewVector vector(1536);

update top (30) r
set r.ReviewVector = AI_GENERATE_EMBEDDINGS(
    p.Name + ' - ' + r.ReviewTitle + ': ' + r.ReviewText
    use model my_embedding_model)
from dbo.ProductReview as r
inner join SalesLT.Product as p
    on r.ProductID = p.ProductID
where r.ReviewVector is null;
```

Note what gets embedded: product name plus review title plus review text, concatenated. That way a search can match on both the product and the lived experience the customer described.

**The retrieval performance call.** Here's the distinction the lab quietly makes and you should make loudly. `VECTOR_DISTANCE` with `ORDER BY` scans every row to find the nearest neighbors. Fine for 140 reviews, a problem at scale. The fix is a DiskANN index plus the `VECTOR_SEARCH` function, which navigates a graph instead of scanning.

```sql
alter database scoped configuration set PREVIEW_FEATURES = ON;
alter database scoped configuration set ALLOW_STALE_VECTOR_INDEX = ON;

create vector index IX_Review_ReviewVector
on dbo.ProductReview(ReviewVector)
with (METRIC = 'cosine', TYPE = 'DISKANN');
```

`ALLOW_STALE_VECTOR_INDEX = ON` is the setting to remember: without it, the table goes read-only once a vector index exists. With it, you trade a possibly-stale index for a writable table, which is what you want in nearly every operational scenario.

Retrieval then becomes an approximate nearest-neighbor search that uses the index:

```sql
declare @userQuestion  nvarchar(1000) = 'What mountain bike handles technical rocky trails?';
declare @questionVector vector(1536);

select @questionVector = AI_GENERATE_EMBEDDINGS(@userQuestion use model my_embedding_model);

select
    p.Name as ProductName,
    p.ListPrice,
    pc.Name as Category,
    r.Rating,
    r.ReviewTitle,
    r.ReviewText,
    vs.distance as Distance
from VECTOR_SEARCH(
    TABLE      = dbo.ProductReview as r,
    COLUMN     = ReviewVector,
    SIMILAR_TO = @questionVector,
    METRIC     = 'cosine',
    TOP_N      = 5
) as vs
inner join SalesLT.Product as p
    on r.ProductID = p.ProductID
inner join SalesLT.ProductCategory as pc
    on p.ProductCategoryID = pc.ProductCategoryID
for json path;
```

Lower distance, higher relevance. The reviews give the model richer grounding than product descriptions ever could, because every review is a distinct customer experience rather than boilerplate repeated across sizes. Ask about "problems" and vector search surfaces the one-star reviews on its own, no sentiment column required.

From there the lab assembles the full pipeline (embed, search, augment, call, parse) into the same `dbo.AskProductQuestion` shape shown above, with `ISNULL(@context, '[]')` guarding the empty-result case and tiered handling for `429` and auth failures.

---

## 6. The takeaway

RAG is not a model trick. It's a retrieval pattern, and retrieval is something SQL has done well for decades. The module's real point is architectural: search, format, prompt, call, and parse can all live in T-SQL, which means you can add grounded AI to an existing application by shipping a stored procedure instead of standing up a service.

The pieces, in order:

- **Identify the fit.** RAG when data changes, when you need traceability, when privacy rules out fine-tuning.
- **Prepare context** with `FOR JSON`, lean on columns, ruthless on tokens.
- **Augment** with `JSON_OBJECT`/`JSON_ARRAY`, a strict system message, and low temperature.
- **Generate** with `sp_invoke_external_rest_endpoint` (remember to enable it on SQL Server 2025), then `JSON_VALUE` the answer out and handle the HTTP failure codes.
- **At scale**, store embeddings in a `VECTOR` column, index with DiskANN, retrieve with `VECTOR_SEARCH`, and keep the table writable with `ALLOW_STALE_VECTOR_INDEX`.

Your database stops being a place data sits and starts being a service that answers questions about it. The model supplies fluency. Your tables supply the truth.

---

*Further reading: `sp_invoke_external_rest_endpoint` (Transact-SQL), Format query results as JSON with `FOR JSON`, and Microsoft's Intelligent applications and AI docs for Azure SQL.*
