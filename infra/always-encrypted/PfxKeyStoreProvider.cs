using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using Microsoft.Data.SqlClient;

namespace FinPulse.Encryption;

/// <summary>
/// Always Encrypted column-master-key provider backed by an RSA key (a PFX file, or any RSA instance).
/// Works on Windows and Linux, unlike SqlClient's built-in certificate-store provider (Windows only).
/// The CEK "encrypted value" is the raw RSA-OAEP(SHA-1) ciphertext of the 32-byte root key, which is
/// what infra/always-encrypted/new-lab-keys.cs writes into database/Security/ae.cek.sql.
/// Register once per process, before opening any connection with Column Encryption Setting=Enabled.
/// </summary>
public sealed class PfxKeyStoreProvider : SqlColumnEncryptionKeyStoreProvider
{
    /// <summary>Must match KEY_STORE_PROVIDER_NAME in database/Security/ae.cmk.sql.</summary>
    public const string ProviderName = "FIN_PULSE_PFX";

    private readonly RSA _rsa;

    public PfxKeyStoreProvider(RSA rsa) => _rsa = rsa;

    public static PfxKeyStoreProvider FromPfx(string path, string password)
    {
        var cert = X509CertificateLoader.LoadPkcs12FromFile(path, password);
        return new PfxKeyStoreProvider(cert.GetRSAPrivateKey()
            ?? throw new InvalidOperationException($"{path} has no RSA private key."));
    }

    /// <summary>Registers this provider globally for SqlClient under <see cref="ProviderName"/>.</summary>
    public void Register() =>
        SqlConnection.RegisterColumnEncryptionKeyStoreProviders(
            new Dictionary<string, SqlColumnEncryptionKeyStoreProvider> { [ProviderName] = this });

    public override byte[] DecryptColumnEncryptionKey(string masterKeyPath, string encryptionAlgorithm, byte[] encryptedColumnEncryptionKey) =>
        _rsa.Decrypt(encryptedColumnEncryptionKey, RSAEncryptionPadding.OaepSHA1);

    public override byte[] EncryptColumnEncryptionKey(string masterKeyPath, string encryptionAlgorithm, byte[] columnEncryptionKey) =>
        _rsa.Encrypt(columnEncryptionKey, RSAEncryptionPadding.OaepSHA1);
}
