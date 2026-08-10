## Introduction
- Module theme = **RAG (Retrieval Augmented Generation) implemented entirely in T-SQL**: retrieve → augment → generate, all inside the DB layer without a separate retrieval service or middleware
- Builds directly on the prior two modules (embeddings module for retrieval mechanics, search module for vector/hybrid search) — this module is the "put it all together into a working pipeline" capstone
- **Exam angle**: expect end-to-end scenario questions tracing a single RAG request through all three steps, plus specific function/proc syntax recall (`FOR JSON`, `JSON_OBJECT`, `sp_invoke_external_rest_endpoint`, `JSON_VALUE`)

## Identify RAG use cases and architecture
- **RAG = three steps**: **Retrieve** (pull relevant data from DB) → **Augment** (add that data as context to the prompt) → **Generate** (model produces a response grounded in the supplied data, not just training knowledge)
- **RAG vs fine-tuning — the central conceptual contrast:**
    - Fine-tuning **retrains** the model on your data — knowledge is baked in permanently, can't keep pace with frequently changing data, and requires sending your data **to the model provider for training**
    - RAG keeps data **in your database**, supplies only per-request context — reflects changes **immediately** (no retraining needed), and only sends the specific context needed per request (cleaner privacy separation)
- **When RAG fits** — three signals: data changes frequently (inventory, pricing), you need **traceable/auditable answers** (you control retrieval, so you know exactly which records informed each response), and privacy requires keeping data under your control rather than sent for training
- **Five example scenario categories** (all follow the same retrieve→augment→generate shape, differing only in _what_ is retrieved): customer support (order history + return policy), product configuration (compatible components within budget), internal knowledge base (policy documents), sales enablement (order history + support tickets → personalized email), technical documentation (schema definitions → migration script)
- **SQL's specific role**: the database **does not host the model** — it handles retrieval (full-text/vector/hybrid search from prior modules), formats results as **JSON**, constructs the prompt, calls the LLM via **`sp_invoke_external_rest_endpoint`**, and parses the response — all in T-SQL; the LLM itself runs externally (e.g., Azure OpenAI)
- **Platform note**: both SQL Server 2025 and Azure SQL DB support RAG, but **`sp_invoke_external_rest_endpoint` is enabled by default only in Azure SQL Database** — in SQL Server 2025 you must enable it via `sp_configure`
- **Exam angle**: RAG-vs-fine-tuning tradeoffs (data currency, traceability, privacy) and the SQL-Server-2025-requires-sp_configure gotcha for `sp_invoke_external_rest_endpoint` are the top testable points

## Prepare retrieval context for augmentation
- Why JSON specifically: LLMs process **text, not relational structures** — JSON preserves field-name-to-value association and relationships in a text format the model can actually interpret; also keeps output **predictable** (you know exactly which fields the model saw)
- **`FOR JSON AUTO`** vs **`FOR JSON PATH`** — know the distinction:
    - **AUTO**: automatic structure based on query shape, column names become field names directly — fast/simple
    - **PATH**: explicit control over structure/nesting via column aliases with dot notation (e.g., `'product.name'` → nested `{"product":{"name":...}}`)

```sql
SELECT Name, ListPrice FROM Production.Product WHERE ProductID = @ProductID FOR JSON AUTO;
SELECT Name AS 'product.name', ListPrice AS 'product.price' FROM Production.Product FOR JSON PATH;
```
- **Output-shaping options** — memorize each:
    - **`WITHOUT_ARRAY_WRAPPER`** — strips the outer `[ ]` for single-record results (common in RAG since you're often retrieving one customer/product/order)
    - **`INCLUDE_NULL_VALUES`** — keeps null fields instead of omitting them, use when absence-of-value itself is meaningful
    - **`ROOT('name')`** — wraps output in a named root element, helps the model understand what kind of data it's receiving
- **Column selection principle**: exclude internal IDs, audit timestamps, warehouse codes — they consume tokens and add noise without helping the model answer; only include what's directly relevant to the question (product name/description/specs/pricing, not rowguid/modified date)
- **Token economics reminder**: every token sent costs money and counts against the model's context window — keep JSON **lean**, especially when retrieving multiple rows
- **Combining multiple sources for richer context** — typical pattern: generate an embedding for the user's question → `VECTOR_DISTANCE` to find closest matches → JOIN related tables (category, model, etc.) → wrap the whole thing in `FOR JSON PATH`, store in a variable for the prompt-building step:

```sql
SET @context = (
    SELECT TOP 3 p.Name AS ProductName, p.Color, pc.Name AS Category
    FROM Production.Product p
    INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    ORDER BY VECTOR_DISTANCE('cosine', p.DescriptionVector, @questionVector)
    FOR JSON PATH
);
```

- **Exam angle**: `FOR JSON AUTO` vs `PATH` distinction, `WITHOUT_ARRAY_WRAPPER`'s specific use case (single-record RAG retrieval), and the column-selection/token-cost principle are the top testable specifics

## Augment prompts with database context
- **Chat message structure** (Azure OpenAI pattern, generalizes to most chat-based LLM APIs) — **three roles**:
    - **`system`** — defines assistant behavior/ground rules (persistent across the conversation)
    - **`user`** — contains the retrieved database context **plus** the actual question
    - **`assistant`** (optional) — holds prior responses for multi-turn conversations

```json
{"messages": [
  {"role": "system", "content": "You are a helpful assistant... Use only the provided context..."},
  {"role": "user", "content": "Context: {retrieved_data}\n\nQuestion: {user_question}"}
]}
```

- **Build the payload directly in T-SQL** using **`JSON_OBJECT`** and **`JSON_ARRAY`** — keeps retrieval, context formatting, and prompt construction all together in the database layer:
```sql
DECLARE @payload NVARCHAR(MAX) = JSON_OBJECT(
    'messages': JSON_ARRAY(
        JSON_OBJECT('role': 'system', 'content': @systemMessage),
        JSON_OBJECT('role': 'user', 'content': @userMessage)
    ),
    'max_tokens': 500,
    'temperature': 0.7
);
```

- **Grounding** = instructing the model to treat your supplied data as the source of truth rather than falling back on (potentially outdated/wrong) training knowledge. Good grounding instructions do three things: **set scope** ("use only the provided data"), **encourage honesty** ("if information is missing, say so" — prevents hallucination), **specify format** (length limits, tone)
- **Two key generation-control parameters:**
    - **`max_tokens`** — caps response length (500-1000 typical for detailed product answers)
    - **`temperature`** (0 to 2 scale) — **lower (0.3-0.5) = more consistent/factual** (what you want for RAG); higher = more creative (usually undesirable for grounded answers)
- **Exam angle**: the three message roles and their purposes, `JSON_OBJECT`/`JSON_ARRAY` for in-T-SQL payload construction, and **low temperature = factual/consistent** (the specific direction matters — this is a common reversed-distractor exam pattern) are the top testable points

## Generate and process RAG responses
- **`sp_invoke_external_rest_endpoint`** — the stored proc that sends the actual HTTPS request to the LLM endpoint from T-SQL:
```sql
EXECUTE @returnValue = sp_invoke_external_rest_endpoint
    @url = N'https://<endpoint>.openai.azure.com/openai/deployments/<model>/chat/completions?api-version=<ver>',
    @method = 'POST',
    @payload = @payload,
    @credential = [https://<endpoint>.openai.azure.com],
    @response = @response OUTPUT;
```

- `@credential` references the **same database scoped credential** set up for external models (managed identity or API key) — one credential setup serves both `CREATE EXTERNAL MODEL` calls and direct REST calls
- **Return value semantics**: **`0` = success (2xx HTTP status)**; any other value = **the actual HTTP status code** of the failure (e.g., `429` = rate-limited/throttled, `401`/`403` = credential/auth problem)
- **Response envelope structure** — the proc wraps the actual API response inside a `result` property alongside HTTP metadata:

```json
{"response": {"status": {"http": {"code": 200}}}, "result": {"choices": [{"message": {"content": "..."}}]}}
```

- Extract the answer with **`JSON_VALUE(@response, '$.result.choices[0].message.content')`** — `JSON_VALUE` for the scalar text; `JSON_QUERY` if you needed to extract a nested object/array instead
- **Error handling pattern** — branch on the return value:
```sql
IF @returnValue = 0
    SET @answer = JSON_VALUE(@response, '$.result.choices[0].message.content');
ELSE IF @returnValue = 429
    RAISERROR('Service is busy. Try again later.', 16, 1);
ELSE IF @returnValue = 401 OR @returnValue = 403
    RAISERROR('Authentication failed.', 16, 1);
```

- **`@retry_count`** parameter — built-in automatic retry for transient failures (timeouts, temporary unavailability); e.g., `@retry_count = 3` retries up to 3 times before giving up — handles the common "failed once, succeeds on retry" case without custom retry logic
- **Full pipeline shape** (the capstone pattern — expect this exact five-step structure to be tested): (1) `AI_GENERATE_EMBEDDINGS` on the question → (2) `VECTOR_DISTANCE` + JOIN + `FOR JSON PATH` to build context → (3) `JSON_OBJECT`/`JSON_ARRAY` to build the grounded prompt payload → (4) `sp_invoke_external_rest_endpoint` to call the model → (5) `JSON_VALUE` to extract the answer, with a fallback message if `@returnValue <> 0`
- **Exam angle**: the return-value semantics (0=success, else=actual HTTP status code — and specifically knowing 429 vs 401/403 meanings), the response envelope path (`$.result.choices[0].message.content`), and `@retry_count` as the built-in transient-failure handling mechanism are the top testable specifics — also expect a "put these five steps in order" style question given how explicitly the material numbers them