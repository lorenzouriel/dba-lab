# Always Encrypted

`mind.journal_entries.content` and `body.symptom_logs.notes` are encrypted client-side
(randomized, `AEAD_AES_256_CBC_HMAC_SHA_256`, key `CEK_fin_pulse`). The server only ever sees
ciphertext; the column master key (CMK) never reaches it.

| Piece | Where | In git |
|-------|-------|--------|
| CMK / CEK metadata | `database/Security/ae.cmk.sql`, `ae.cek.sql` (CEK is the root key wrapped by the CMK) | yes |
| CMK private key (lab) | `infra/always-encrypted/lab-cmk.pfx`, password in `infra/.env` as `AE_CMK_PFX_PASSWORD` | **no** |
| Client key provider | `PfxKeyStoreProvider.cs` (`FIN_PULSE_PFX`, cross-platform) | yes |
| Key generator | `new-lab-keys.cs` — `dotnet run infra/always-encrypted/new-lab-keys.cs` from the repo root | yes |

## Using it from a client
```csharp
PfxKeyStoreProvider.FromPfx("infra/always-encrypted/lab-cmk.pfx", password).Register(); // once, before connecting
// connection string: Column Encryption Setting=Enabled
// parameters for these columns must match the column type exactly:
new SqlParameter("@c", SqlDbType.NVarChar, -1)   // journal_entries.content  NVARCHAR(MAX)
new SqlParameter("@n", SqlDbType.VarChar, 500)   // symptom_logs.notes       VARCHAR(500)
```
The app role needs `VIEW ANY COLUMN MASTER KEY DEFINITION` and `VIEW ANY COLUMN ENCRYPTION KEY DEFINITION`
(granted to `app_user` in `roles.sql`).

## What it rules out
- No filtering, sorting, `LIKE` or aggregation on these columns (randomized). Query by `user_id`/`entry_date`.
- No literals: `INSERT ... VALUES (N'text')` fails (error 206); always use typed parameters.
- No dynamic data masking on them (the server can't mask ciphertext).
- pyodbc in the datagen container can't write them, so datagen skips journal entries and omits `notes`.
- DAB (`api/dab-config.json`) doesn't expose either column, so the API is unaffected.

## Tests and CI
`database.tests` generates a throwaway CMK per run and swaps its wrapped CEK into `ae.cek.sql`, so CI needs no
secrets and the real table definitions are still exercised.

## Other environments
The lab CMK is a PFX. For a real environment, publish a CMK with `KEY_STORE_PROVIDER_NAME = 'AZURE_KEY_VAULT'`
and the vault key URL, create that environment's CEK value with the `SqlServer` PowerShell module, and register the
Azure Key Vault provider in the client. Encrypt existing rows with `Set-SqlColumnEncryption` (or an enclave); a
dacpac publish can't encrypt a column that already holds data.
Never regenerate `lab-cmk.pfx` while encrypted rows exist: they become unreadable.
