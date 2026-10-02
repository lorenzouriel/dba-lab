namespace FinPulse.DatabaseTests;

/// <summary>Row-level security and dynamic data masking behave as the project promises.</summary>
[TestClass]
public class SecurityTests : DatabaseTestBase
{
    private const string Email = "alice@example.com";

    /// <summary>Two users, one expense each, plus a login-less principal in app_user (or pii_reader).</summary>
    private (int Alice, int Bob) Arrange(string role = "app_user")
    {
        var alice = Scalar<int>(
            "INSERT dbo.users (username, email, phone_number) OUTPUT INSERTED.id VALUES ('alice', @e, '5511987654321')",
            ("@e", Email));
        var bob = NewUser();
        NewExpense(alice);
        NewExpense(bob);
        Execute($"CREATE USER [sec_probe] WITHOUT LOGIN; ALTER ROLE [{role}] ADD MEMBER [sec_probe];");
        return (alice, bob);
    }

    private void AsAppUser(int? userId)
    {
        Execute("EXECUTE AS USER = 'sec_probe';");
        if (userId is not null)
            Execute("EXEC sp_set_session_context @key = N'user_id', @value = @u;", ("@u", userId));
    }

    private void Revert() => Execute("REVERT;");

    [TestMethod]
    public void RowLevelSecurityPolicyCoversEveryUserOwnedTable()
    {
        var unprotected = Scalar<string>("""
            SELECT STRING_AGG(SCHEMA_NAME(t.schema_id) + '.' + t.name, ', ')
            FROM sys.tables t
            WHERE NOT EXISTS (
                SELECT 1 FROM sys.security_predicates p
                JOIN sys.security_policies sp ON sp.object_id = p.object_id AND sp.is_enabled = 1
                WHERE p.target_object_id = t.object_id AND p.predicate_type_desc = 'FILTER')
            """);
        Assert.IsNull(unprotected, $"tables without an RLS filter predicate: {unprotected}");
    }

    [TestMethod]
    public void AppUserOnlySeesItsOwnRows()
    {
        var (alice, _) = Arrange();
        AsAppUser(alice);
        try
        {
            Assert.AreEqual(1, Scalar<int>("SELECT COUNT(*) FROM finance.expenses"));
            Assert.AreEqual(1, Scalar<int>("SELECT COUNT(*) FROM dbo.users"));
        }
        finally { Revert(); }
    }

    [TestMethod]
    public void AppUserWithoutSessionContextSeesNothing()
    {
        Arrange();
        AsAppUser(null);
        try { Assert.AreEqual(0, Scalar<int>("SELECT COUNT(*) FROM finance.expenses")); }
        finally { Revert(); }
    }

    [TestMethod]
    public void AppUserCannotWriteRowsForAnotherUser()
    {
        var (alice, bob) = Arrange();
        AsAppUser(alice);
        try
        {
            var ex = Assert.ThrowsException<Microsoft.Data.SqlClient.SqlException>(() => Execute("""
                INSERT finance.expenses (user_id, category, payment_method, amount, currency_code, expense_date)
                VALUES (@b, 'Food', 'Card', 10, 'BRL', '2026-01-01')
                """, ("@b", bob)));
            Assert.AreEqual(33504, ex.Number, ex.Message);   // block predicate violation
        }
        finally { Revert(); }
    }

    [TestMethod]
    public void DbOwnerBypassesRowLevelSecurity()
    {
        Arrange();
        Assert.AreEqual(2, Scalar<int>("SELECT COUNT(*) FROM finance.expenses"));
    }

    [TestMethod]
    public void AppUserSeesMaskedPii()
    {
        var (alice, _) = Arrange();
        AsAppUser(alice);
        try
        {
            var email = Scalar<string>("SELECT email FROM dbo.users");
            Assert.AreNotEqual(Email, email);
            Assert.IsTrue(email.StartsWith('a') && email.EndsWith(".com") && email.Contains("XXX@"), email);
            Assert.AreEqual("XXXXXX4321", Scalar<string>("SELECT phone_number FROM dbo.users"));
        }
        finally { Revert(); }
    }

    [TestMethod]
    public void PiiReaderSeesUnmaskedPii()
    {
        var (alice, _) = Arrange("pii_reader");
        AsAppUser(alice);
        try
        {
            Assert.AreEqual(Email, Scalar<string>("SELECT email FROM dbo.users"));
            Assert.AreEqual("5511987654321", Scalar<string>("SELECT phone_number FROM dbo.users"));
        }
        finally { Revert(); }
    }
}
