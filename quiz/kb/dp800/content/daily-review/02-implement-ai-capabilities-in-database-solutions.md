# DP-800 — Implement AI Capabilities in Database Solutions

## 1. Intelligent search

### Remember

- **Full-text search** finds words.
- **Vector search** finds meaning.
- **Hybrid search** combines both.
- **RRF** combines rankings instead of trying to normalize incompatible scores.

### Full-text vs vector vs hybrid

| Search | Best for |
|---|---|
| Full-text | Exact words, phrases, product codes, error codes |
| Vector | Meaning and natural-language similarity |
| Hybrid | Users may search by either words or meaning |

### Full-text search

Requires a full-text index.

Main tools:
- `CONTAINS` → precise word/phrase matching
- `FREETEXT` → broader linguistic matching
- `CONTAINSTABLE` / `FREETEXTTABLE` → ranked results

Use full-text when literal wording matters.

### Vector search

Text is converted into an **embedding**, which is a numerical vector representing meaning.

Similar meaning → vectors are closer together.

Main choices:

**Exact search**
- `VECTOR_DISTANCE`
- compares against all candidates
- more accurate
- better for smaller datasets

**Approximate search**
- `VECTOR_SEARCH`
- uses a vector index
- much faster for large datasets
- may trade a small amount of recall for speed

Common distance metric: **cosine distance**.

Lower distance usually means greater similarity.

### Vector indexes

Remember these limitations from the review:
- integer clustered primary key is required
- partitioning is not supported
- indexed behavior has preview-related limitations

### Hybrid search

Typical flow:

```text
Full-text results ─┐
                   ├─> RRF ─> final ranking
Vector results ────┘
```

**RRF = Reciprocal Rank Fusion**

It uses each document's ranking position instead of the raw scores.

Basic idea:

```text
score = 1 / (k + rank)
```

A document that ranks well in both searches gets a stronger final score.

---

## 2. Models and embeddings

### Remember

An external model is a **database reference to an AI endpoint**. The model does not run inside SQL Server.

### External models

`CREATE EXTERNAL MODEL` stores information such as:
- endpoint
- model name/type
- credentials
- configuration

SQL calls the external AI service when it needs the model.

Prefer Managed Identity when available instead of storing API keys.

### Embeddings

Good content to embed:
- descriptions
- titles
- documentation
- natural-language text

Usually do **not** embed:
- IDs
- internal timestamps
- operational metadata with no semantic value

### Chunking

Long documents should be split into smaller chunks before embedding.

Too large:
- more noise
- may exceed token limits

Too small:
- loses useful context

Goal: each chunk should contain one useful semantic unit.

### Keeping embeddings updated

Embeddings become stale when source text changes.

Possible strategies:
- triggers
- Change Tracking
- CDC
- Azure Functions
- Logic Apps
- event streaming

Choose based on:
- data volume
- update frequency
- required latency
- operational complexity

---

## 3. RAG with SQL

### Remember

**RAG does not retrain the model.**  
It gives the model relevant data at request time.

RAG means:

```text
Retrieve → Augment → Generate
```

### Retrieve

Find the most relevant records using:
- full-text search
- vector search
- hybrid search

Only return useful context.

### Augment

Convert the retrieved SQL data into model-friendly context, often JSON.

Useful tools:
- `FOR JSON PATH`
- `JSON_OBJECT`
- `JSON_ARRAY`

The prompt should tell the model:
- use the provided context
- do not invent missing facts
- follow the required format

### Generate

SQL can call an external LLM endpoint with:

```sql
sp_invoke_external_rest_endpoint
```

Typical end-to-end flow:

```text
User question
   ↓
Create question embedding
   ↓
Find relevant SQL rows
   ↓
Convert rows to JSON
   ↓
Build prompt
   ↓
Call LLM
   ↓
Return answer
```

### RAG vs fine-tuning

| RAG | Fine-tuning |
|---|---|
| Retrieves current data at request time | Changes model behavior/knowledge through training |
| Easy to update when data changes | Requires another training cycle |
| Can show which records were used | Less directly traceable to individual source rows |
| Good for changing/private enterprise data | Good for specialized behavior/style/tasks |

### Important exam reminders

- SQL stores the data and embeddings; the LLM runs externally.
- Keep retrieved context small and relevant.
- Use low temperature for factual RAG responses.
- Handle API errors such as authentication failures and throttling.
- `EXECUTE ANY EXTERNAL ENDPOINT` permission is important when calling external endpoints.
