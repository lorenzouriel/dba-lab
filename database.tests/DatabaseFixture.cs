using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using FinPulse.Encryption;
using Microsoft.Data.SqlClient;

namespace FinPulse.DatabaseTests;

/// <summary>
/// Deploys database/database.sqlproj into a throwaway database before any test runs
/// (the equivalent of SSDT's "automatically deploy the database project before unit tests are run").
/// Build order comes straight from the sqlproj, so the tests never drift from the project.
/// </summary>
[TestClass]
public static partial class DatabaseFixture
{
    public const string TestDatabase = "fin_pulse_test";

    /// <summary>Connection string pointing at the deployed test database.</summary>
    public static string ConnectionString { get; private set; } = "";

    private static RSA? _cmk;

    [AssemblyInitialize]
    public static void Deploy(TestContext _)
    {
        var server = new SqlConnectionStringBuilder(ResolveServerConnectionString())
        {
            InitialCatalog = "master",
        };

        using (var master = new SqlConnection(server.ConnectionString))
        {
            master.Open();
            Run(master, $"""
                IF DB_ID('{TestDatabase}') IS NOT NULL
                BEGIN
                    ALTER DATABASE [{TestDatabase}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
                    DROP DATABASE [{TestDatabase}];
                END
                CREATE DATABASE [{TestDatabase}];
                """);
        }

        server.InitialCatalog = TestDatabase;

        // Always Encrypted: the committed CEK is wrapped by the lab CMK (a PFX that is not in git), so each
        // run generates a throwaway CMK key pair, registers it as the client-side key provider, and swaps
        // its wrapped CEK into ae.cek.sql. Tables still reference the real CEK/CMK names from the project.
        _cmk = RSA.Create(2048);   // must outlive Deploy(): the provider decrypts with it during every test
        new PfxKeyStoreProvider(_cmk).Register();
        var wrappedCek = "0x" + Convert.ToHexString(_cmk.Encrypt(RandomNumberGenerator.GetBytes(32), RSAEncryptionPadding.OaepSHA1));

        using var db = new SqlConnection(server.ConnectionString);
        db.Open();
        foreach (var file in BuildOrder(FindDatabaseProjectDir()))
        {
            var script = File.ReadAllText(file);
            if (Path.GetFileName(file) == "ae.cek.sql")
                script = EncryptedValue().Replace(script, wrappedCek);

            foreach (var batch in SplitBatches(script))
            {
                try { Run(db, batch); }
                catch (SqlException ex)
                {
                    throw new InvalidOperationException($"Deploy failed in {Path.GetFileName(file)}: {ex.Message}", ex);
                }
            }
        }

        // Test connections resolve encrypted columns transparently.
        server.ColumnEncryptionSetting = SqlConnectionColumnEncryptionSetting.Enabled;
        ConnectionString = server.ConnectionString;
    }

    [AssemblyCleanup]
    public static void Drop()
    {
        _cmk?.Dispose();
        if (ConnectionString == "" || Environment.GetEnvironmentVariable("KEEP_TEST_DB") == "1") return;

        var master = new SqlConnectionStringBuilder(ConnectionString) { InitialCatalog = "master" };
        using var conn = new SqlConnection(master.ConnectionString);
        conn.Open();
        Run(conn, $"""
            ALTER DATABASE [{TestDatabase}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
            DROP DATABASE [{TestDatabase}];
            """);
    }

    /// <summary>TEST_SQL_CONNECTION wins; otherwise the lab's dev instance using MSSQL_SA_PASSWORD.</summary>
    private static string ResolveServerConnectionString()
    {
        var explicitCs = Environment.GetEnvironmentVariable("TEST_SQL_CONNECTION");
        if (!string.IsNullOrWhiteSpace(explicitCs)) return explicitCs;

        var password = Environment.GetEnvironmentVariable("MSSQL_SA_PASSWORD")
            ?? throw new InvalidOperationException(
                "Set TEST_SQL_CONNECTION, or MSSQL_SA_PASSWORD to use the lab dev instance (localhost,1403).");
        var port = Environment.GetEnvironmentVariable("DEV_PORT") ?? "1403";
        return $"Server=localhost,{port};User Id=sa;Password={password};TrustServerCertificate=True;Encrypt=True";
    }

    private static string FindDatabaseProjectDir()
    {
        for (var dir = new DirectoryInfo(AppContext.BaseDirectory); dir != null; dir = dir.Parent)
        {
            var candidate = Path.Combine(dir.FullName, "database", "database.sqlproj");
            if (File.Exists(candidate)) return Path.GetDirectoryName(candidate)!;
        }
        throw new DirectoryNotFoundException("database/database.sqlproj not found above " + AppContext.BaseDirectory);
    }

    private static IEnumerable<string> BuildOrder(string projectDir) =>
        XDocument.Load(Path.Combine(projectDir, "database.sqlproj"))
            .Descendants()
            .Where(e => e.Name.LocalName == "Build")
            .Select(e => (string)e.Attribute("Include")!)
            .Select(p => Path.Combine(projectDir, p.Replace('\\', Path.DirectorySeparatorChar)));

    private static IEnumerable<string> SplitBatches(string script) =>
        GoLine().Split(script).Where(b => !string.IsNullOrWhiteSpace(b));

    private static void Run(SqlConnection conn, string sql)
    {
        using var cmd = new SqlCommand(sql, conn) { CommandTimeout = 120 };
        cmd.ExecuteNonQuery();
    }

    [GeneratedRegex(@"^\s*GO\s*$", RegexOptions.Multiline | RegexOptions.IgnoreCase)]
    private static partial Regex GoLine();

    [GeneratedRegex(@"0x[0-9A-Fa-f]+")]
    private static partial Regex EncryptedValue();
}
