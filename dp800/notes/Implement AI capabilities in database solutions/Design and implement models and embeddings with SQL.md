## Introduction

- Module theme = **AI/embeddings integration inside Azure SQL DB / Fabric SQL DB** — model evaluation → external model objects → embedding design (chunking) → generation → maintenance strategies, all done via T-SQL rather than moving data to external systems
- Core value prop: AI processing stays **close to the data** — no separate vector DB/search service needed; combine vector similarity with regular SQL in one query (**hybrid search**)
- **Exam angle**: newer/lighter-weight content area than the DP-800 core, but expect direct terminology and function-name recall (`AI_GENERATE_EMBEDDINGS`, `AI_GENERATE_CHUNKS`, `CREATE EXTERNAL MODEL`) plus matching maintenance-mechanism-to-scenario questions

## Understand and evaluate models for SQL database workloads

- Model evaluation factors for SQL-integrated AI — **know all four**:
    - **Modalities** — text-only vs multimodal (images, structured data) — depends on what's actually stored
    - **Language support** — multilingual needs for regional/multi-language content
    - **Model size/capacity** — bigger = stronger reasoning but more tokens/latency/cost; smaller models often sufficient for **embedding generation** specifically (a narrow, focused task)
    - **Structured output** — models that reliably produce JSON are easier to integrate into SQL workflows that need to process responses programmatically
- **RAG (Retrieval Augmented Generation)** pattern: retrieve relevant DB content → supply as context to the model → grounds responses in actual application data rather than only the model's pretrained knowledge
- Core vocabulary: **tokens** (units of text processing — words/subwords/punctuation), **embeddings** (vector representation of data), **vector search** (compares embeddings for semantic similarity)
- **Hybrid search** — the signature Azure SQL capability: combine vector similarity with standard SQL in a single query (WHERE filters, JOINs to related tables, blending vector cosine ranking with **full-text BM25 scores**) — avoids needing a separate search service + result reconciliation
- **Token economics** — two practical constraints:
    - **Input limits**: models cap tokens per request (e.g., 8K or 128K) — directly constrains how much DB content fits as RAG context
    - **Cost**: providers typically bill per token processed — token efficiency = cost efficiency; influences chunking strategy design
- **Microsoft Foundry Models** = the model catalog for evaluating/selecting models (capabilities, benchmarks, version, lifecycle status) before integrating with Azure SQL/Fabric SQL DB workflows
- **Exam angle**: the four model-evaluation factors, the RAG pattern definition, and hybrid search as "vector + SQL predicates in one query" are the most testable conceptual points

## Create and manage external models in SQL

- **External model** = a database object storing **metadata about an AI endpoint** (URL, auth, config) — it does NOT run the model inside SQL Server; it's a managed reference that lets SQL call an external AI service
- Creating an external model **doesn't invoke it** — just establishes a reusable definition that AI functions reference later
- **Prerequisite**: a **database scoped credential** for authenticating to the AI endpoint — **two auth options**:
    - **Managed Identity** (recommended for Azure SQL DB) — grant the DB's managed identity the **Cognitive Services OpenAI User** role on the Azure OpenAI resource:

```sql
CREATE DATABASE SCOPED CREDENTIAL [https://<resource>.cognitiveservices.azure.com/]
    WITH IDENTITY = 'Managed Identity', SECRET = '{"resourceid":"https://cognitiveservices.azure.com"}';
```

- **API key** (works for both Azure SQL DB and SQL Server 2025) — stored via `IDENTITY = 'HTTPEndpointHeaders'`, key passed in HTTP headers — **avoid hardcoding keys in T-SQL**, prefer managed identity when possible
- **Required permission**: `GRANT EXECUTE ANY EXTERNAL ENDPOINT TO [user_or_role];` — needed for anyone/anything calling external endpoints
- **`CREATE EXTERNAL MODEL`** syntax — key parameters to recognize:

```sql
CREATE EXTERNAL MODEL my_external_model
WITH (
    LOCATION   = 'https://<resource>.cognitiveservices.azure.com/openai/deployments/<deployment>/embeddings?api-version=<ver>',
    API_FORMAT = 'Azure OpenAI',
    MODEL_TYPE = EMBEDDINGS,
    MODEL      = 'text-embedding-3-small',
    CREDENTIAL = [https://<resource>.cognitiveservices.azure.com/],
    PARAMETERS = '{"dimensions":<n>}'
);
```

- **`ALTER EXTERNAL MODEL`** — updates endpoint/credential/config metadata **without requiring dependent queries to be rewritten** — decouples app logic from AI service configuration changes
- Referenced by AI functions via `USE MODEL`:

```sql
SELECT id, AI_GENERATE_EMBEDDINGS(description USE MODEL my_external_model) AS embedding FROM dbo.documents;
```

- Being a **database-scoped object**, external models get standard permission management, deployment-pipeline inclusion, and lifecycle management alongside other schema objects
- **Exam angle**: "external model = metadata/reference object, doesn't run the model" is the single most important conceptual distinction; also know the two credential types (Managed Identity vs API key/HTTPEndpointHeaders) and the `EXECUTE ANY EXTERNAL ENDPOINT` permission requirement

## Design embeddings for SQL database workloads

- **Vectors are created by the model, not by SQL** — SQL sends text to the embedding model, receives back a numeric vector, stores it for later comparison. Semantically similar text → numerically similar vectors (even with different wording)
- **What to embed**: text carrying **semantic meaning** — descriptions, titles, free-form text. **Exclude** identifiers, numeric values, operational metadata — they add no semantic value, waste tokens, and can dilute similarity results
- **Chunking** — dividing large text into smaller segments before embedding:
    - Too large → risks exceeding token limits, **dilutes semantic focus** (embedding captures a blurred mix of ideas)
    - Too small → **loses important context**
    - Goal: preserve meaning while staying efficient to process
- **`AI_GENERATE_CHUNKS`** function — defines chunking rules directly in SQL near the source table:

```sql
SELECT id, c.chunk
FROM dbo.documents
CROSS APPLY AI_GENERATE_CHUNKS(SOURCE = description, CHUNK_TYPE = FIXED, CHUNK_SIZE = 500) AS c;
```

- `CHUNK_TYPE = FIXED` + `CHUNK_SIZE` (in characters) — each chunk becomes a **separate output row**
- Advantage of defining chunking in SQL: adjust chunk size/splitting behavior via query change, **no application code changes needed**
- **Design tip**: store vectors in a **separate dedicated embeddings table** from the source text — makes it easier to track vector storage footprint and to rebuild/regenerate embeddings independently without touching source data
- **Exam angle**: `AI_GENERATE_CHUNKS` syntax (`SOURCE`/`CHUNK_TYPE`/`CHUNK_SIZE`) and the too-large-vs-too-small chunking tradeoff are the top testable specifics; also the exclude-non-semantic-columns principle

## Generate and maintain embeddings for SQL database workloads

- **`AI_GENERATE_EMBEDDINGS`** — the core generation function, references an external model via `USE MODEL`:

```sql
CREATE TABLE dbo.documents (
    id INT PRIMARY KEY,
    description NVARCHAR(MAX),
    embedding VECTOR(1536)
);

UPDATE dbo.documents
SET embedding = AI_GENERATE_EMBEDDINGS(description USE MODEL my_embedding_model);
```

- Note the **`VECTOR(n)`** data type for storing the embedding, sized to the model's output dimensionality
- Common pattern: generate during initial load / batch process, store alongside source data or in a related table
- **Embedding maintenance is required** — stored vectors go stale as source text is inserted/updated/deleted; need a strategy to detect changes and regenerate
- **Seven maintenance approaches — know the tradeoffs of each (mirrors the change-capture mechanisms from the DAB module):**
    - **Table triggers** — fire immediately on INSERT/UPDATE, mark rows for regeneration or regenerate inline — **fastest reflection of change, but adds overhead to every write operation**
    - **Change Tracking** — records _that_ a row changed (not the values); background process batches regeneration — balances latency and performance
    - **CDC (Change Data Capture)** — full before/after values via CDC tables; regenerate asynchronously — suited for **high-volume workloads**
    - **Azure Functions with SQL trigger binding** — reacts to changes (via Change Tracking, per the earlier DAB module) but runs embedding generation **outside the database engine**, scales independently
    - **Azure Logic Apps** — low-code orchestration, e.g., periodic check for changed rows + call embedding service, integrates with other Azure workflows
    - **Change Event Streaming (CES)** — streams DML changes to Event Hubs in **near real-time**, fully decouples embedding generation from the DB transaction, supports **multiple independent consumers** of the same change stream
    - **Microsoft Foundry** — in a maintenance context, handles **model selection/hosting** rather than change detection itself — a complementary piece, not a change-capture mechanism
- **No single "correct" approach** — choice depends on data volume, update frequency/latency requirements, and where in the architecture embedding generation should live (in-DB vs external service)
- **Exam angle**: matching maintenance mechanism → tradeoff (triggers=fastest+most write overhead; CDC=high-volume+historical; CES=most decoupled+real-time+multi-consumer; Change Tracking=balanced/lightweight) is the top testable pattern here — same underlying mechanisms as the earlier "event-driven patterns" module, now applied specifically to embedding freshness