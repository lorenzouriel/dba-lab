using System.Data;
using Microsoft.Data.SqlClient;

namespace FinPulse.DatabaseTests;

/// <summary>
/// Pre-test / post-test plumbing. Every test runs inside a transaction that is rolled back,
/// so tests never leak rows into each other (the "post-test cleanup" of an SSDT unit test).
/// </summary>
public abstract class DatabaseTestBase
{
    // SQL Server error numbers the negative tests expect.
    protected const int NullViolation = 515;
    protected const int ConstraintViolation = 547;   // CHECK and FOREIGN KEY
    protected const int UniqueViolation = 2627;
    protected const int ComputedColumnWrite = 271;

    private SqlConnection _conn = null!;
    private SqlTransaction _tx = null!;

    [TestInitialize]
    public void BeginTest()
    {
        _conn = new SqlConnection(DatabaseFixture.ConnectionString);
        _conn.Open();
        _tx = _conn.BeginTransaction();
    }

    [TestCleanup]
    public void RollbackTest()
    {
        _tx.Rollback();
        _conn.Dispose();
    }

    protected int Execute(string sql, params (string Name, object? Value)[] args)
    {
        using var cmd = Command(sql, args);
        return cmd.ExecuteNonQuery();
    }

    protected T Scalar<T>(string sql, params (string Name, object? Value)[] args)
    {
        using var cmd = Command(sql, args);
        var v = cmd.ExecuteScalar();
        return v is null or DBNull
            ? default!
            : (T)Convert.ChangeType(v, Nullable.GetUnderlyingType(typeof(T)) ?? typeof(T));
    }

    /// <summary>Inserts a user and returns its id.</summary>
    protected int NewUser()
    {
        var name = "u_" + Guid.NewGuid().ToString("N")[..12];
        return Scalar<int>(
            "INSERT dbo.users (username, email) OUTPUT INSERTED.id VALUES (@n, @e)",
            ("@n", name), ("@e", name + "@test.local"));
    }

    protected int NewHabit(int userId, string name = "Stretch") =>
        Scalar<int>(
            "INSERT body.habits (user_id, habit_name) OUTPUT INSERTED.id VALUES (@u, @n)",
            ("@u", userId), ("@n", name));

    protected void NewHabitLog(int userId, int habitId, string date, bool completed = false) =>
        Execute(
            "INSERT body.habit_logs (user_id, habit_id, log_date, is_completed) VALUES (@u, @h, @d, @c)",
            ("@u", userId), ("@h", habitId), ("@d", date), ("@c", completed));

    protected void NewExpense(int userId) =>
        Execute("""
            INSERT finance.expenses (user_id, category, payment_method, amount, currency_code, expense_date)
            VALUES (@u, 'Food', 'Card', 10, 'BRL', '2026-01-01')
            """, ("@u", userId));

    /// <summary>
    /// Negative test, the analogue of SSDT's [ExpectedSqlException]: passes only if the statement
    /// raises the given error number. A statement that succeeds silently fails the test.
    /// </summary>
    protected void AssertSqlError(int expectedNumber, string sql, params (string Name, object? Value)[] args)
    {
        var ex = Assert.ThrowsException<SqlException>(() => Execute(sql, args));
        Assert.AreEqual(expectedNumber, ex.Number, ex.Message);
    }

    /// <summary>
    /// Always Encrypted columns need a parameter whose type and size match the column exactly
    /// (a plain AddWithValue string infers NVARCHAR(len) and is rejected). These mirror
    /// mind.journal_entries.content and body.symptom_logs.notes.
    /// </summary>
    protected static (string Name, object? Value) JournalContent(string name, string value) =>
        (name, new SqlParameter(name, SqlDbType.NVarChar, -1) { Value = value });

    protected static (string Name, object? Value) SymptomNotes(string name, string? value) =>
        (name, new SqlParameter(name, SqlDbType.VarChar, 500) { Value = (object?)value ?? DBNull.Value });

    /// <summary>Runs a query on the test transaction with Always Encrypted off, so encrypted columns come back as ciphertext.</summary>
    protected byte[] RawCiphertext(string sql, params (string Name, object? Value)[] args)
    {
        using var cmd = Command(sql, args, SqlCommandColumnEncryptionSetting.Disabled);
        return (byte[])cmd.ExecuteScalar()!;
    }

    private SqlCommand Command(string sql, (string Name, object? Value)[] args,
        SqlCommandColumnEncryptionSetting encryption = SqlCommandColumnEncryptionSetting.UseConnectionSetting)
    {
        var cmd = new SqlCommand(sql, _conn, _tx, encryption);
        foreach (var (name, value) in args)
        {
            if (value is SqlParameter p) cmd.Parameters.Add(p);
            else cmd.Parameters.AddWithValue(name, value ?? DBNull.Value);
        }
        return cmd;
    }
}
