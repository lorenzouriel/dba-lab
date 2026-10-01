-- app_user: what the application/API connects as. Sees masked PII and only its own rows (RLS).
CREATE ROLE [app_user] AUTHORIZATION [dbo];
GO

-- pii_reader: trusted readers (support, DBAs) allowed to see unmasked values.
-- Still subject to RLS: they need SESSION_CONTEXT user_id set, or db_owner membership.
CREATE ROLE [pii_reader] AUTHORIZATION [dbo];
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[dbo] TO [app_user];
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[finance] TO [app_user];
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[plan] TO [app_user];
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[body] TO [app_user];
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[mind] TO [app_user];
GO

GRANT SELECT ON SCHEMA::[reporting] TO [app_user];
GO

ALTER ROLE [app_user] ADD MEMBER [pii_reader];
GO

-- Always Encrypted drivers call sp_describe_parameter_encryption, which needs to see the key metadata.
GRANT VIEW ANY COLUMN MASTER KEY DEFINITION TO [app_user];
GO

GRANT VIEW ANY COLUMN ENCRYPTION KEY DEFINITION TO [app_user];
GO

-- Dynamic data masking is bypassed only with UNMASK (db_owner/dbo implicitly have it).
GRANT UNMASK TO [pii_reader];
GO
