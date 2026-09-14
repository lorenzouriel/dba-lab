# Full-Text, Vector, and Hybrid

A customer types *"lightweight hiking backpack"* into your product search. Your best-selling item is listed as *"ultralight trail bag."* A `like '%...%'` scan returns nothing, the customer assumes you don't sell it, and you lose the sale to whoever's catalog happened to use the customer's words.

That gap — between how people describe what they want and how your data is actually written — is the whole problem. SQL Server 2025 and Azure SQL Database now give you three tools to close it, all queryable from T-SQL without bolting on a separate search engine:

- **Full-text search** — linguistic keyword matching
- **Vector search** — semantic similarity over embeddings
- **Hybrid search** — both, merged with Reciprocal Rank Fusion

This walks through each one: what it does, the T-SQL that drives it, the tradeoffs, and when to reach for which. By the end you'll be able to pick the right approach per query type, stand up full-text and vector indexes, write the queries, and fuse the results.

---

## Choosing an approach: match the tool to the intent

Before any code, the design question: *how do your users actually search?* The answer dictates the tool, because each one optimizes for a different kind of query.

**Full-text search looks for words.** Search for `ride` and it also finds `riding`, `rides`, `rode` — it understands inflection. It does *not* know that "MTB" means "mountain bike" unless you configure a thesaurus. Use it when the user knows the exact term: a part number, an error string, a product name.

**Vector search looks for meaning.** Search for *"something to keep me visible on evening rides"* and it surfaces *"reflective cycling vest"* and *"LED bike lights"* — none of which share a single keyword with the query. It works by comparing embeddings (numeric representations of meaning), so it shines when users *describe* a need instead of naming a product.

**Hybrid search runs both and merges.** The user who types *"XR-500 portable cooler"* gets the exact model-number hit *and* the conceptually-related results. When you can't predict whether users will name things or describe them, hybrid covers both.

A quick way to internalize it:

| Query | Best fit | Why |
|---|---|---|
| `"Model XR-500"` | Full-text | Exact token, user knows it |
| `"something to keep drinks cold on a hike"` | Vector | A described need, no obvious keyword |
| `"XR-500 portable cooler"` | Hybrid | Mixed — a token *and* a concept |

### The tradeoffs you're actually buying

This isn't "which is best" — it's what you're willing to pay:

- **Precision vs. recall.** Full-text returns fewer results that tightly match the query terms. Vector returns more, including conceptually-related items in different words. Need exact matches? Lean full-text. Need discovery? Lean vector.
- **Data prep.** Full-text needs a full-text index on text columns. Vector needs embeddings stored in a vector column — which means an embedding model in the loop. Different setup cost.
- **Performance.** Full-text indexes are tuned for fast keyword lookup. Vector latency scales with how many vectors you compare and whether you go exact or approximate. Hybrid runs both, so it's always the slowest of the three.

---

## Full-text search: linguistic, not pattern-matching

The mental shift from `like` is that full-text search understands language. `like '%ride%'` matches the character sequence `ride` — including inside "stride" and "rident" — and misses "rode" entirely. Full-text works on words and their forms.

It needs two things: a **full-text index** on your text columns, and **predicates** to query it. Under the hood the index tokenizes your text, strips stopwords (`the`, `is`, `and`), and builds an inverted index mapping words to the rows containing them — so lookups don't scan every row.

### CONTAINS vs. FREETEXT

Two predicates, two philosophies:

```sql
-- CONTAINS: exact words/phrases, precise control
select ProductID, Name, ListPrice
from Production.Product
where CONTAINS(Name, 'mountain')
  and ListPrice < 500;
```

```sql
-- FREETEXT: meaning-oriented, auto-expands inflections
select ProductID, Name
from Production.Product
where FREETEXT(Name, 'riding bikes');
```

`CONTAINS` gives you control and demands precision. `FREETEXT` is forgiving — it handles `riding` → `ride`/`rides`/`biking` and drops stopwords automatically — but a broad phrase can pull in noise, so pair it with `top`.

When you want results *ranked* by relevance, use the table-valued versions `CONTAINSTABLE` / `FREETEXTTABLE`, which return a `[KEY]` column and a `RANK` (BM25-based):

```sql
select p.ProductID, p.Name, ft.RANK
from Production.Product as p
inner join CONTAINSTABLE(Production.Product, Name, 'NEAR((mountain, bike))') as ft
    on p.ProductID = ft.[KEY]
order by ft.RANK desc;
```

Hold onto that `RANK` — it's what feeds the hybrid query later.

### The query patterns worth knowing

| Pattern | Syntax | Matches |
|---|---|---|
| Term | `CONTAINS(col, 'aluminum')` | rows with that word |
| Phrase | `CONTAINS(col, '"mountain bike"')` | the exact phrase, in order |
| Prefix | `CONTAINS(col, '"light*"')` | light, lights, lighter, lightweight |
| Inflectional | `CONTAINS(col, 'FORMSOF(INFLECTIONAL, "ride")')` | ride, rides, riding, rode |
| Proximity | `CONTAINS(col, 'NEAR((light, aluminum))')` | the two words close together |

### When full-text starts failing

Three signals tell you you've outgrown it. **Precision problems** — searching `brake` surfaces "brake-resistant coatings" when you wanted bike brakes (tighten with phrases or `NEAR`). **Noise** — common domain words flood results (custom stoplists help). And the big one, **query-intent mismatch** — users searching *"something for rainy commutes"* expecting waterproof gear get nothing, because full-text matches words, not meaning. That third signal is your cue to add vectors.

---

## Preparing SQL for vector search

Vector search finds rows by mathematical similarity. Before the first query, you make three decisions: how to store the vectors, which distance metric to use, and whether to search exactly or approximately.

### The VECTOR data type

SQL Server has a native `VECTOR(n)` type, where `n` is the dimensionality of your embedding model's output:

```sql
create table dbo.Products
(
    ProductID INT primary key,
    Name NVARCHAR(100),
    Description NVARCHAR(MAX),
    DescriptionVector VECTOR(1536) not null
);
```

`text-embedding-3-small` produces 1,536 dimensions, so `VECTOR(1536)`. Max supported is **1,998**. Each element is a 4-byte float, so a 1,536-dim vector runs ~6 KB per row — non-trivial once you're at millions of rows, so size your storage and memory accordingly.

### Distance metrics

Three options, and the choice should follow how your embeddings were trained:

- **Cosine** — angle between vectors, ignores magnitude. Range 0 (identical) to 2 (opposite). The default for most modern embedding models.
- **Euclidean** — straight-line distance, considers magnitude. Range 0 to ∞.
- **Dot product** — element-wise products summed; SQL Server returns the *negative* so smaller still means more similar, consistent with the others.

Most embedding models are tuned for cosine, so unless you have a reason, use cosine.

### Exact vs. approximate — the real architectural fork

**Exact (ENN)** via `VECTOR_DISTANCE` compares your query vector against every row. Guaranteed-correct nearest neighbors, but it's a full scan:

```sql
declare @query VECTOR(1536) = '[0.1, 0.2, ...]';

select top 10 ProductID, Name,
    VECTOR_DISTANCE('cosine', @query, DescriptionVector) as Distance
from dbo.Products
order by Distance;
```

Fine under ~50,000 vectors, or when a `where` clause already cuts candidates down to a handful.

**Approximate (ANN)** via a DiskANN index plus `VECTOR_SEARCH` trades a sliver of accuracy for speed. DiskANN builds a navigable graph so you don't scan every row:

```sql
create vector index idx_Products_DescriptionVector
on dbo.Products(DescriptionVector)
with (METRIC = 'cosine', TYPE = 'DiskANN');
```

This is for hundreds of thousands to millions of vectors, where recall close to 1 is good enough. (Recall = how many of the true nearest neighbors the approximate search actually found. DiskANN typically lands high.)

### The index limitations that bite

Read these before you design the table, because they're real constraints:

- The table needs a **single-column integer primary key with a clustered index**.
- The table goes **read-only while the vector index exists** — you drop it, write, and rebuild. (`ALLOW_STALE_VECTOR_INDEX = ON` in Azure SQL / Fabric keeps it writable but the index won't reflect new rows until rebuilt; not available in SQL Server 2025.)
- Vector indexes **can't be partitioned**, and they're **in preview**.

Practical consequence: for tables that churn constantly, run exact search until the data stabilizes, then add the index.

---

## Vector query patterns

Four functions do the work: `VECTOR_DISTANCE`, `VECTOR_SEARCH`, `VECTOR_NORMALIZE`, `VECTORPROPERTY`. The pattern is always the same — get a query vector, compute distances, return the closest.

Generate the query embedding in-database with `AI_GENERATE_EMBEDDINGS` and the same model you used for the stored vectors:

```sql
declare @searchVector VECTOR(1536);
select @searchVector = AI_GENERATE_EMBEDDINGS('lightweight hiking boots' use model MyEmbeddingModel);

select top 10 ProductID, Name,
    VECTOR_DISTANCE('cosine', @searchVector, DescriptionVector) as Distance
from dbo.Products
order by Distance;
```

You can also threshold instead of taking a fixed `top n` — useful when you want everything above a quality bar:

```sql
where VECTOR_DISTANCE('cosine', @searchVector, DescriptionVector) < 0.3
```

The `0.3` is illustrative. There's no universal cutoff — run test queries, look at where your real distances cluster, and find the point where relevance turns to noise for *your* data and model.

### VECTOR_SEARCH and the post-filtering trap

For large tables, `VECTOR_SEARCH` uses the DiskANN index. If no matching index exists it falls back to exact search and raises a warning.

```sql
select t.ProductID, t.Name, s.distance
from VECTOR_SEARCH(
    TABLE = dbo.Products as t,
    COLUMN = DescriptionVector,
    SIMILAR_TO = @searchVector,
    METRIC = 'cosine',
    TOP_N = 10
) as s
order by s.distance;
```

Here's the gotcha that'll burn you: **`VECTOR_SEARCH` applies your `where` clause *after* finding the neighbors, not before.** Ask for the top 10 nearest, then filter to `CategoryID = 5`, and if none of those 10 happen to be in category 5, you get **zero rows**. The fix is to over-fetch:

```sql
select top 10 t.ProductID, t.Name, s.distance
from VECTOR_SEARCH(
    TABLE = dbo.Products as t,
    COLUMN = DescriptionVector,
    SIMILAR_TO = @searchVector,
    METRIC = 'cosine',
    TOP_N = 50          -- pull 50, filter, then take 10
) as s
where t.CategoryID = 5
order by s.distance;
```

### Normalize and inspect

`VECTOR_NORMALIZE(vector, norm_type)` scales a vector to unit length (`'norm2'` is the usual choice). Most production models — OpenAI's included — already emit normalized vectors, so you rarely need this. It matters when you mix embeddings from sources that *don't* normalize, otherwise cosine and dot-product comparisons go inconsistent. `VECTOR_NORM` gives you the magnitude itself.

`VECTORPROPERTY(vector, 'Dimensions' | 'BaseType')` is your debugging tool — when a query throws a dimension mismatch (classic symptom of two different embedding models sneaking into the same column), this is how you confirm what you've actually got stored.

---

## Hybrid search: running both, merging with RRF

Neither approach is complete alone. Full-text misses the synonym; vector returns semantically-close items that drop a term the user explicitly required. Hybrid runs both in parallel and fuses the ranked lists.

The merge is the interesting part. Full-text hands you BM25 scores; vector hands you cosine distances. **Those scales are incomparable** — you can't just add them. The answer is **Reciprocal Rank Fusion**, which throws away the raw scores and works purely on rank position:

```
RRF_score = 1/(k + rank_fulltext) + 1/(k + rank_vector)
```

`k` is a smoothing constant, **60** by convention (from the original RRF paper, and what Azure AI Search uses). Two properties make this work:

1. **No normalization needed** — ranks are ranks, regardless of underlying score scale.
2. **Neither source dominates** — even if vector scores always look "bigger," RRF treats both lists equally.

The payoff: a document that ranks decently in *both* lists beats one that ranks #1 in only one. Appearing in both lists sums two contributions. Concretely — "Bike Seat Comfort Pro" at rank 1 full-text *and* rank 3 vector scores `1/61 + 1/63 ≈ 0.0323`, beating "Ergonomic Touring Saddle" which topped vector alone at `1/61 ≈ 0.0164`. Broad relevance wins.

### The implementation

Three CTEs — keyword, vector, combine — joined with a `full outer join` so anything in either list survives, and `COALESCE` to zero-out the missing side:

```sql
declare @searchText NVARCHAR(1000) = 'lightweight hiking boots';
declare @searchVector VECTOR(1536);
declare @topN INT = 50;
declare @rrfK INT = 60;

select @searchVector = AI_GENERATE_EMBEDDINGS(@searchText use model MyEmbeddingModel);

with keyword_search as (
    select top(@topN)
        p.ProductID,
        RANK() over (order by ftt.[RANK] desc) as keyword_rank
    from dbo.Products p
    inner join FREETEXTTABLE(dbo.Products, Description, @searchText) as ftt
        on p.ProductID = ftt.[KEY]
),
vector_search as (
    select top(@topN)
        ProductID,
        RANK() over (order by distance) as vector_rank
    from (
        select ProductID,
            VECTOR_DISTANCE('cosine', @searchVector, DescriptionVector) as distance
        from dbo.Products
    ) as similar_products
),
combined as (
    select top(@topN)
        COALESCE(ks.ProductID, vs.ProductID) as ProductID,
        ks.keyword_rank,
        vs.vector_rank,
        COALESCE(1.0 / (@rrfK + ks.keyword_rank), 0.0) +
        COALESCE(1.0 / (@rrfK + vs.vector_rank), 0.0) as rrf_score
    from keyword_search ks
    full outer join vector_search vs on ks.ProductID = vs.ProductID
)
select p.ProductID, p.Name, c.keyword_rank, c.vector_rank, c.rrf_score
from combined c
inner join dbo.Products p on c.ProductID = p.ProductID
order by c.rrf_score desc;
```

For large tables, swap the exact `VECTOR_DISTANCE` subquery in `vector_search` for a `VECTOR_SEARCH(... TOP_N = @topN)` call against the DiskANN index — same shape, ANN performance.

### Knobs to turn

- **`@topN`** — candidates pulled from each side. More gives RRF more to work with, at latency cost. Start at 50, tune against real relevance tests.
- **`@rrfK`** — bigger `k` smooths rank differences; smaller `k` amplifies the top-ranked items. 60 is the standard starting point.
- **Weighting** — bias one source by multiplying its term, e.g. `2.0 / (@rrfK + vs.vector_rank)` to favor semantics 2:1.
- **Filtering** — apply filters *before* the fusion where you can; filtering after RRF can strip out results that deserved to rank.

Measure with **precision** (how many returned results are relevant), **recall** (how many of all relevant docs you found), and **MRR** (how high the first good result lands). Build a small labeled test set, run full-text-only / vector-only / hybrid, and compare. Hybrid usually lifts recall noticeably with little precision loss — but verify it on your data rather than taking that on faith.

---

## Building it end to end (the short version)

If you want to stand this up on the AdventureWorksLT sample, the moving parts are:

1. **An Azure SQL Database** (Hyperscale serverless keeps cost down) with the sample data loaded.
2. **A Foundry project** deploying two models — a chat model and `text-embedding-3-small` for embeddings — and the **OpenAI-tab** endpoint URL (not the Foundry-tab `.services.ai.azure.com` one, which won't work with these T-SQL features).
3. **Managed identity**, not API keys: enable the system-assigned identity on the *logical server*, then grant it **Cognitive Services OpenAI User** on the OpenAI resource.
4. **A database scoped credential** (`identity = 'Managed Identity'`) plus a **`create external model`** reference so `AI_GENERATE_EMBEDDINGS` works inline.
5. **A vector column** populated in batches — embed in chunks of ~30 with a short `waitfor delay` and a retry loop, because you *will* hit rate limits otherwise.
6. **A DiskANN vector index** and a **full-text catalog + index**, then run the three approaches against the same question and read the result sets side by side.

That last step is the one that makes it click. Ask all three *"comfortable bike for long weekend rides with the family"*: full-text returns reviews literally containing "comfortable," "weekend," "family"; vector returns reviews about relaxed-geometry recreational bikes that never use those words; hybrid scores the ones appearing in both lists to the top. Seeing the same query produce three different result sets is worth more than any amount of theory.

---

## When to use what

Strip away the syntax and it comes down to one decision — **how do users phrase what they want, and what can you trade?**

- Users type exact terms (part numbers, error strings, product names) → **full-text**. Fast, precise, cheap to set up.
- Users describe a need in natural language → **vector**. Captures meaning across different wording, at the cost of an embedding pipeline and heavier queries.
- You can't predict, or you want maximum recall → **hybrid** with RRF. Best coverage, slowest, most moving parts.

The features are in preview and the index constraints are real — single-column integer PK, read-only-while-indexed, no partitioning — so design the table and your rebuild workflow around them from the start rather than discovering them in production. But the headline is that semantic search now lives *inside* the database, next to your transactional data, queryable in plain T-SQL. For a lot of workloads that removes an entire external search tier from the architecture. That's the part worth paying attention to.

---

*Further reading: [Full-text search overview](https://learn.microsoft.com/en-us/sql/relational-databases/search/full-text-search) · [Vector data type](https://learn.microsoft.com/en-us/sql/t-sql/data-types/vector-data-type) · [VECTOR_DISTANCE](https://learn.microsoft.com/en-us/sql/t-sql/functions/vector-distance-transact-sql) · [VECTOR_SEARCH](https://learn.microsoft.com/en-us/sql/t-sql/functions/vector-search-transact-sql) · [RRF in hybrid search](https://learn.microsoft.com/en-us/azure/search/hybrid-search-ranking)*
