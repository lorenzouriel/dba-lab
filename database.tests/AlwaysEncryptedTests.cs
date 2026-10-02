using System.Text;

namespace FinPulse.DatabaseTests;

/// <summary>journal_entries.content and symptom_logs.notes are Always Encrypted (randomized), and nothing else is.</summary>
[TestClass]
public class AlwaysEncryptedTests : DatabaseTestBase
{
    private const string Secret = "Felt anxious before the audit, skipped lunch.";

    private int NewJournalEntry(int user, string content = Secret) =>
        Scalar<int>(
            "INSERT mind.journal_entries (user_id, entry_date, content) OUTPUT INSERTED.id VALUES (@u, '2026-01-01', @c)",
            ("@u", user), JournalContent("@c", content));

    [TestMethod]
    public void OnlyTheTwoFreeTextColumnsAreEncrypted_AllRandomized()
    {
        var encrypted = Scalar<string>("""
            SELECT STRING_AGG(CAST(SCHEMA_NAME(t.schema_id) + '.' + t.name + '.' + c.name + ':' + c.encryption_type_desc AS NVARCHAR(200)) COLLATE DATABASE_DEFAULT, ', ')
                   WITHIN GROUP (ORDER BY t.name, c.name)
            FROM sys.columns c JOIN sys.tables t ON t.object_id = c.object_id
            WHERE c.column_encryption_key_id IS NOT NULL
            """);
        Assert.AreEqual("mind.journal_entries.content:RANDOMIZED, body.symptom_logs.notes:RANDOMIZED", encrypted);
    }

    [TestMethod]
    public void JournalContentRoundTripsThroughTheDriver()
    {
        var id = NewJournalEntry(NewUser());
        Assert.AreEqual(Secret, Scalar<string>("SELECT content FROM mind.journal_entries WHERE id = @i", ("@i", id)));
    }

    [TestMethod]
    public void SymptomNotesRoundTripAndAllowNull()
    {
        var user = NewUser();
        Execute("INSERT body.symptom_logs (user_id, log_date, symptom, severity, notes) VALUES (@u, '2026-01-01', 'Headache', 3, @n)",
            ("@u", user), SymptomNotes("@n", "after screens"));
        Execute("INSERT body.symptom_logs (user_id, log_date, symptom, severity, notes) VALUES (@u, '2026-01-02', 'Headache', 3, @n)",
            ("@u", user), SymptomNotes("@n", null));

        Assert.AreEqual("after screens", Scalar<string>("SELECT notes FROM body.symptom_logs WHERE log_date = '2026-01-01' AND user_id = @u", ("@u", user)));
        Assert.IsNull(Scalar<string>("SELECT notes FROM body.symptom_logs WHERE log_date = '2026-01-02' AND user_id = @u", ("@u", user)));
    }

    [TestMethod]
    public void ServerOnlyStoresCiphertext()
    {
        var id = NewJournalEntry(NewUser());
        var raw = RawCiphertext("SELECT content FROM mind.journal_entries WHERE id = @i", ("@i", id));

        Assert.AreEqual(1, raw[0], "AEAD ciphertext version byte");
        Assert.IsFalse(Encoding.Unicode.GetString(raw).Contains("anxious") || Encoding.UTF8.GetString(raw).Contains("anxious"));
        Assert.IsTrue(raw.Length > Encoding.Unicode.GetByteCount(Secret));
    }

    [TestMethod]
    public void RandomizedEncryptionGivesDifferentCiphertextForEqualPlaintext()
    {
        var user = NewUser();
        var a = RawCiphertext("SELECT content FROM mind.journal_entries WHERE id = @i", ("@i", NewJournalEntry(user)));
        var b = RawCiphertext("SELECT content FROM mind.journal_entries WHERE id = @i", ("@i", NewJournalEntry(user)));
        CollectionAssert.AreNotEqual(a, b);
    }

    [TestMethod]
    public void LiteralPlaintextCannotBeWrittenToAnEncryptedColumn() =>
        AssertSqlError(206,
            "INSERT mind.journal_entries (user_id, entry_date, content) VALUES (@u, '2026-01-01', N'plain')",
            ("@u", NewUser()));

    [TestMethod]
    public void EncryptedColumnCannotBeFiltered()
    {
        var id = NewJournalEntry(NewUser());
        Assert.IsNotNull(id);
        var ex = Assert.ThrowsException<Microsoft.Data.SqlClient.SqlException>(() =>
            Scalar<int>("SELECT COUNT(*) FROM mind.journal_entries WHERE content = @c", JournalContent("@c", Secret)));
        Assert.AreEqual(33277, ex.Number, ex.Message);
    }
}
