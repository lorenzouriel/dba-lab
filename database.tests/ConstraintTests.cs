namespace FinPulse.DatabaseTests;

/// <summary>Unit tests for table-level logic: defaults, CHECK, UNIQUE, NOT NULL, FK and computed columns.</summary>
[TestClass]
public class ConstraintTests : DatabaseTestBase
{
    // ---------- defaults ----------

    [TestMethod]
    public void NewUser_DefaultsStatusToActive()
    {
        var id = NewUser();
        Assert.AreEqual(1, Scalar<int>("SELECT status FROM dbo.users WHERE id = @i", ("@i", id)));
    }

    [TestMethod]
    public void NewHabit_DefaultsToDailyAndActive()
    {
        var habit = NewHabit(NewUser());
        Assert.AreEqual("Daily", Scalar<string>("SELECT target_frequency FROM body.habits WHERE id = @i", ("@i", habit)));
        Assert.AreEqual(1, Scalar<int>("SELECT status FROM body.habits WHERE id = @i", ("@i", habit)));
    }

    [TestMethod]
    public void NewHabitLog_DefaultsToNotCompleted()
    {
        var user = NewUser();
        var habit = NewHabit(user);
        Execute("INSERT body.habit_logs (user_id, habit_id, log_date) VALUES (@u, @h, '2026-01-01')", ("@u", user), ("@h", habit));
        Assert.AreEqual(0, Scalar<int>("SELECT CAST(is_completed AS int) FROM body.habit_logs WHERE habit_id = @h", ("@h", habit)));
    }

    // ---------- computed column ----------

    [TestMethod]
    public void SleepLog_ComputesTotalHours()
    {
        var user = NewUser();
        Execute("INSERT body.sleep_logs (user_id, bed_time, wake_time) VALUES (@u, '2026-01-01 23:00', '2026-01-02 06:30')", ("@u", user));
        Assert.AreEqual(7.5m, Scalar<decimal>("SELECT total_hours FROM body.sleep_logs WHERE user_id = @u", ("@u", user)));
    }

    [TestMethod]
    public void SleepLog_RejectsDirectWriteToComputedColumn() =>
        AssertSqlError(ComputedColumnWrite,
            "INSERT body.sleep_logs (user_id, bed_time, wake_time, total_hours) VALUES (@u, '2026-01-01 23:00', '2026-01-02 06:30', 9)",
            ("@u", NewUser()));

    // ---------- negative tests: CHECK ----------

    [TestMethod]
    public void SleepLog_RejectsWakeBeforeBed() =>
        AssertSqlError(ConstraintViolation,
            "INSERT body.sleep_logs (user_id, bed_time, wake_time) VALUES (@u, '2026-01-02 06:00', '2026-01-01 23:00')",
            ("@u", NewUser()));

    [TestMethod]
    [DataRow(-1)]
    [DataRow(7)]
    public void WeeklyRoutine_RejectsDayOutsideZeroToSix(int day) =>
        AssertSqlError(ConstraintViolation,
            "INSERT body.weekly_routines (user_id, day_of_week, routine_name) VALUES (@u, @d, 'Push')",
            ("@u", NewUser()), ("@d", day));

    [TestMethod]
    [DataRow(0)]
    [DataRow(6)]
    public void WeeklyRoutine_AcceptsBoundaryDays(int day) =>
        Assert.AreEqual(1, Execute(
            "INSERT body.weekly_routines (user_id, day_of_week, routine_name) VALUES (@u, @d, 'Push')",
            ("@u", NewUser()), ("@d", day)));

    [TestMethod]
    [DataRow(0)]
    [DataRow(6)]
    public void JournalEntry_RejectsMoodOutsideOneToFive(int mood) =>
        AssertSqlError(ConstraintViolation,
            "INSERT mind.journal_entries (user_id, entry_date, content, mood) VALUES (@u, '2026-01-01', @c, @m)",
            ("@u", NewUser()), ("@m", mood), JournalContent("@c", "x"));

    [TestMethod]
    public void JournalEntry_AllowsNullMood() =>
        Assert.AreEqual(1, Execute(
            "INSERT mind.journal_entries (user_id, entry_date, content) VALUES (@u, '2026-01-01', @c)",
            ("@u", NewUser()), JournalContent("@c", "x")));

    [TestMethod]
    public void Meditation_RejectsZeroDuration() =>
        AssertSqlError(ConstraintViolation,
            "INSERT mind.meditation_sessions (user_id, session_date, duration_minutes, meditation_type) VALUES (@u, '2026-01-01', 0, 'Breath')",
            ("@u", NewUser()));

    [TestMethod]
    [DataRow("mood_before")]
    [DataRow("mood_after")]
    public void Meditation_RejectsMoodOutOfRange(string column) =>
        AssertSqlError(ConstraintViolation,
            $"INSERT mind.meditation_sessions (user_id, session_date, duration_minutes, meditation_type, {column}) VALUES (@u, '2026-01-01', 10, 'Breath', 9)",
            ("@u", NewUser()));

    [TestMethod]
    public void SymptomLog_RejectsSeverityOutOfRange() =>
        AssertSqlError(ConstraintViolation,
            "INSERT body.symptom_logs (user_id, log_date, symptom, severity) VALUES (@u, '2026-01-01', 'Headache', 6)",
            ("@u", NewUser()));

    // ---------- negative tests: UNIQUE ----------

    [TestMethod]
    public void Habit_RejectsDuplicateNamePerUser()
    {
        var user = NewUser();
        NewHabit(user, "Read");
        AssertSqlError(UniqueViolation, "INSERT body.habits (user_id, habit_name) VALUES (@u, 'Read')", ("@u", user));
    }

    [TestMethod]
    public void Habit_AllowsSameNameForDifferentUsers()
    {
        NewHabit(NewUser(), "Read");
        Assert.AreEqual(1, Execute("INSERT body.habits (user_id, habit_name) VALUES (@u, 'Read')", ("@u", NewUser())));
    }

    [TestMethod]
    public void HabitLog_RejectsSecondLogForSameDay()
    {
        var user = NewUser();
        var habit = NewHabit(user);
        NewHabitLog(user, habit, "2026-01-01");
        AssertSqlError(UniqueViolation,
            "INSERT body.habit_logs (user_id, habit_id, log_date) VALUES (@u, @h, '2026-01-01')", ("@u", user), ("@h", habit));
    }

    [TestMethod]
    public void WeeklyRoutine_RejectsTwoRoutinesOnSameDay()
    {
        var user = NewUser();
        Execute("INSERT body.weekly_routines (user_id, day_of_week, routine_name) VALUES (@u, 1, 'Push')", ("@u", user));
        AssertSqlError(UniqueViolation,
            "INSERT body.weekly_routines (user_id, day_of_week, routine_name) VALUES (@u, 1, 'Pull')", ("@u", user));
    }

    // ---------- negative tests: NOT NULL / FK ----------

    [TestMethod]
    public void User_RequiresEmail() =>
        AssertSqlError(NullViolation, "INSERT dbo.users (username) VALUES ('no_email')");

    [TestMethod]
    public void Expense_RejectsUnknownUser() =>
        AssertSqlError(ConstraintViolation, """
            INSERT finance.expenses (user_id, category, payment_method, amount, currency_code, expense_date)
            VALUES (-1, 'Food', 'Card', 10, 'BRL', '2026-01-01')
            """);

    [TestMethod]
    public void UserWithExpenses_CannotBeDeleted()
    {
        var user = NewUser();
        NewExpense(user);
        AssertSqlError(ConstraintViolation, "DELETE dbo.users WHERE id = @u", ("@u", user));
    }

    // ---------- cascades ----------

    [TestMethod]
    public void DeletingUser_CascadesToHabitsAndLogs()
    {
        var user = NewUser();
        var habit = NewHabit(user);
        NewHabitLog(user, habit, "2026-01-01");

        Execute("DELETE dbo.users WHERE id = @u", ("@u", user));

        Assert.AreEqual(0, Scalar<int>("SELECT COUNT(*) FROM body.habits WHERE user_id = @u", ("@u", user)));
        Assert.AreEqual(0, Scalar<int>("SELECT COUNT(*) FROM body.habit_logs WHERE user_id = @u", ("@u", user)));
    }

    [TestMethod]
    public void DeletingHabit_WithLogs_IsBlocked()
    {
        // habit_logs -> habits has no cascade (it would create two cascade paths from users).
        var user = NewUser();
        var habit = NewHabit(user);
        NewHabitLog(user, habit, "2026-01-01");
        AssertSqlError(ConstraintViolation, "DELETE body.habits WHERE id = @h", ("@h", habit));
    }
}
