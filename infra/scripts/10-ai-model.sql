/*  10-ai-model.sql
    Wire an Azure OpenAI embedding model into the lab database.
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
 * Azure OpenAI embeddings
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
 * Smoke test — connectivity before you debug T-SQL syntax.
 * ------------------------------------------------------------------ */
/*
DECLARE @ret int, @response nvarchar(max);
EXEC @ret = sp_invoke_external_rest_endpoint
     @url     = N'https://<resource>.openai.azure.com/openai/deployments/text-embedding-3-small/embeddings?api-version=2024-08-01-preview',
     @method  = N'POST',
     @credential = [https://<resource>.openai.azure.com],
     @payload = N'{"input":"hello world"}',
     @response = @response OUTPUT;
SELECT @ret AS return_code, @response AS response;
*/

/* ------------------------------------------------------------------ *
 * Vector column + index pattern (SQL Server 2025)
 * ------------------------------------------------------------------ */
/*
ALTER TABLE dbo.invoice ADD description_vec vector(1536);

UPDATE dbo.invoice
SET description_vec = AI_GENERATE_EMBEDDINGS(description USE MODEL AzureEmbed)
WHERE description IS NOT NULL;

CREATE VECTOR INDEX ix_invoice_vec ON dbo.invoice (description_vec)
WITH (METRIC = 'cosine', TYPE = 'diskann');

-- ANN search
SELECT TOP (10) i.invoice_id, i.description, s.distance
FROM VECTOR_SEARCH(
        TABLE      = dbo.invoice AS i,
        COLUMN     = description_vec,
        SIMILAR_TO = AI_GENERATE_EMBEDDINGS(N'overdue telecom charge' USE MODEL AzureEmbed),
        METRIC     = 'cosine',
        TOP_N      = 10
     ) AS s
ORDER BY s.distance;
*/
