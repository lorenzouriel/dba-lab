/*  10-ai-model.sql
    Wire an embedding model into the lab database. Two paths — pick one.
    Run against your lab DB, not master.

    Prereqs already handled by 00-bootstrap.sql:
      sp_configure 'external rest endpoint enabled' = 1
*/
SET NOCOUNT ON;
GO

ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO

/*  A database master key is required before any database-scoped credential. */
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE [name] = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'Ch4nge_This_Too!';
GO

GRANT EXECUTE ANY EXTERNAL ENDPOINT TO [public];  -- lab only; scope this properly in real work
GO

/* ------------------------------------------------------------------ *
 * PATH A — Azure OpenAI (least friction; matches the exam wording)
 * The credential NAME must be the base URL of the resource, bracketed,
 * no query string. CREATE EXTERNAL MODEL matches credentials by name.
 * ------------------------------------------------------------------ */
/*
CREATE DATABASE SCOPED CREDENTIAL [https://<resource>.openai.azure.com]
WITH IDENTITY = 'HTTPEndpointHeaders',
     SECRET   = '{"api-key":"<your-key>"}';
GO

CREATE EXTERNAL MODEL AzureEmbed
WITH (
    LOCATION      = 'https://<resource>.openai.azure.com/openai/deployments/text-embedding-3-small/embeddings?api-version=2024-08-01-preview',
    API_FORMAT    = 'Azure OpenAI',
    MODEL_TYPE    = EMBEDDINGS,
    MODEL         = 'text-embedding-3-small',
    CREDENTIAL    = [https://<resource>.openai.azure.com]
);
GO
*/

/* ------------------------------------------------------------------ *
 * PATH B — local Ollama behind Caddy (offline, free)
 * Requires: docker compose --profile ai up -d  &&  make pull-model  &&  make trust-ca
 * ------------------------------------------------------------------ */
/*
CREATE EXTERNAL MODEL LocalEmbed
WITH (
    LOCATION   = 'https://ollama.lab/api/embed',
    API_FORMAT = 'Ollama',
    MODEL_TYPE = EMBEDDINGS,
    MODEL      = 'nomic-embed-text'
);
GO
*/

/* ------------------------------------------------------------------ *
 * Smoke test — connectivity before you debug T-SQL syntax.
 * ------------------------------------------------------------------ */
/*
DECLARE @ret int, @response nvarchar(max);
EXEC @ret = sp_invoke_external_rest_endpoint
     @url     = N'https://ollama.lab/api/tags',
     @method  = N'GET',
     @response = @response OUTPUT;
SELECT @ret AS return_code, @response AS response;
*/

/* ------------------------------------------------------------------ *
 * Vector column + index pattern (SQL Server 2025)
 * ------------------------------------------------------------------ */
/*
ALTER TABLE dbo.invoice ADD description_vec vector(768);

UPDATE dbo.invoice
SET description_vec = AI_GENERATE_EMBEDDINGS(description USE MODEL LocalEmbed)
WHERE description IS NOT NULL;

CREATE VECTOR INDEX ix_invoice_vec ON dbo.invoice (description_vec)
WITH (METRIC = 'cosine', TYPE = 'diskann');

-- ANN search
SELECT TOP (10) i.invoice_id, i.description, s.distance
FROM VECTOR_SEARCH(
        TABLE      = dbo.invoice AS i,
        COLUMN     = description_vec,
        SIMILAR_TO = AI_GENERATE_EMBEDDINGS(N'overdue telecom charge' USE MODEL LocalEmbed),
        METRIC     = 'cosine',
        TOP_N      = 10
     ) AS s
ORDER BY s.distance;
*/
