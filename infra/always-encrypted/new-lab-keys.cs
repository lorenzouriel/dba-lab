// Generates the LAB Always Encrypted column master key (RSA-2048 PFX) and the matching column
// encryption key value for database/Security/ae.cek.sql.
//
//   $env:AE_CMK_PFX_PASSWORD = '<password>'
//   dotnet run infra/always-encrypted/new-lab-keys.cs        # run from the repo root
//
// Refuses to overwrite an existing PFX: re-keying makes already-encrypted rows unreadable.
// The PFX is gitignored; only the CEK ciphertext (useless without the PFX) is committed.
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;

var password = Environment.GetEnvironmentVariable("AE_CMK_PFX_PASSWORD");
if (string.IsNullOrEmpty(password)) { Console.Error.WriteLine("Set AE_CMK_PFX_PASSWORD first."); return 1; }

var pfxPath = Path.Combine("infra", "always-encrypted", "lab-cmk.pfx");
var cekPath = Path.Combine("database", "Security", "ae.cek.sql");
if (File.Exists(pfxPath)) { Console.Error.WriteLine($"{pfxPath} already exists; delete it only if you accept re-keying."); return 1; }
if (!Directory.Exists("database")) { Console.Error.WriteLine("Run from the repo root."); return 1; }

using var rsa = RSA.Create(2048);
var req = new CertificateRequest("CN=fin_pulse lab column master key", rsa, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
using var cert = req.CreateSelfSigned(DateTimeOffset.UtcNow.AddDays(-1), DateTimeOffset.UtcNow.AddYears(10));
File.WriteAllBytes(pfxPath, cert.Export(X509ContentType.Pfx, password));

var rootKey = RandomNumberGenerator.GetBytes(32);
var encrypted = rsa.Encrypt(rootKey, RSAEncryptionPadding.OaepSHA1);

File.WriteAllText(cekPath, $"""
    -- Lab column encryption key. ENCRYPTED_VALUE is the CEK wrapped by the lab CMK (infra/always-encrypted/lab-cmk.pfx,
    -- not in git), so it is safe to commit. Regenerate with infra/always-encrypted/new-lab-keys.cs; rotate in
    -- real environments with ALTER COLUMN ENCRYPTION KEY ... ADD VALUE / DROP VALUE against that environment's CMK.
    CREATE COLUMN ENCRYPTION KEY [CEK_fin_pulse]
    WITH VALUES
    (
        COLUMN_MASTER_KEY = [CMK_fin_pulse],
        ALGORITHM = 'RSA_OAEP',
        ENCRYPTED_VALUE = 0x{Convert.ToHexString(encrypted)}
    );
    GO

    """.Replace("\r\n", "\n"));

Console.WriteLine($"Wrote {pfxPath} (keep it secret) and {cekPath}.");
return 0;
