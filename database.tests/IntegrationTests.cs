namespace FinPulse.DatabaseTests;

/// <summary>Scenarios that span several tables, run against the deployed database.</summary>
[TestClass]
public class IntegrationTests : DatabaseTestBase
{
    [TestMethod]
    public void HabitLogs_AggregateCompletedVersusTotal()
    {
        var user = NewUser();
        var habit = NewHabit(user, "Meditate");
        NewHabitLog(user, habit, "2026-01-01", completed: true);
        NewHabitLog(user, habit, "2026-01-02", completed: true);
        NewHabitLog(user, habit, "2026-01-03", completed: false);

        Assert.AreEqual(2, Scalar<int>(
            "SELECT COUNT(*) FROM body.habit_logs WHERE habit_id = @h AND is_completed = 1", ("@h", habit)));
        Assert.AreEqual(3, Scalar<int>(
            "SELECT COUNT(*) FROM body.habit_logs WHERE habit_id = @h", ("@h", habit)));
    }

    [TestMethod]
    public void UserLifecycle_FinanceRowsBlockDeletion_ThenCascadeCleansTheRest()
    {
        var user = NewUser();
        Execute("INSERT mind.journal_entries (user_id, entry_date, content, mood) VALUES (@u, '2026-01-01', @c, 4)", ("@u", user), JournalContent("@c", "ok"));
        Execute("INSERT mind.meditation_sessions (user_id, session_date, duration_minutes, meditation_type) VALUES (@u, '2026-01-01', 10, 'Breath')", ("@u", user));
        NewExpense(user);

        // finance.* has no cascade, so the user is protected while financial rows exist...
        AssertSqlError(ConstraintViolation, "DELETE dbo.users WHERE id = @u", ("@u", user));

        // ...and once those are gone, the cascading schemas go with the user.
        Execute("DELETE finance.expenses WHERE user_id = @u", ("@u", user));
        Execute("DELETE dbo.users WHERE id = @u", ("@u", user));
        Assert.AreEqual(0, Scalar<int>("SELECT COUNT(*) FROM mind.journal_entries WHERE user_id = @u", ("@u", user)));
        Assert.AreEqual(0, Scalar<int>("SELECT COUNT(*) FROM mind.meditation_sessions WHERE user_id = @u", ("@u", user)));
    }
}
