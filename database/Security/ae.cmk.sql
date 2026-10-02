-- Always Encrypted column master key metadata. The key itself never reaches the server: clients resolve it
-- through the registered key-store provider (infra/always-encrypted/PfxKeyStoreProvider.cs) using KEY_PATH.
-- Real environments: publish a CMK with KEY_STORE_PROVIDER_NAME = 'AZURE_KEY_VAULT' and the vault key URL.
CREATE COLUMN MASTER KEY [CMK_fin_pulse]
WITH
(
    KEY_STORE_PROVIDER_NAME = 'FIN_PULSE_PFX',
    KEY_PATH = 'fin_pulse_lab_cmk'
);
GO
