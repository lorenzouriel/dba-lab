namespace FinPulse.DatabaseTests;

/// <summary>Beyond build validation: the deployed database has the shape the project promises.</summary>
[TestClass]
public class SchemaTests : DatabaseTestBase
{
    [TestMethod]
    [DataRow("finance")]
    [DataRow("plan")]
    [DataRow("reporting")]
    [DataRow("body")]
    [DataRow("mind")]
    public void ProjectSchemaExists(string schema) =>
        Assert.AreEqual(1, Scalar<int>("SELECT COUNT(*) FROM sys.schemas WHERE name = @s", ("@s", schema)));

    [TestMethod]
    public void TableCountMatchesProject() =>
        // Keep in sync with the <Build Include="Tables\..."> items in database.sqlproj.
        Assert.AreEqual(20, Scalar<int>("SELECT COUNT(*) FROM sys.tables"));

    [TestMethod]
    public void EveryTableHasAPrimaryKey() =>
        Assert.AreEqual(0, Scalar<int>(
            "SELECT COUNT(*) FROM sys.tables t WHERE OBJECTPROPERTY(t.object_id, 'TableHasPrimaryKey') = 0"));

    [TestMethod]
    public void EveryUserIdColumnIsAForeignKeyToUsers()
    {
        var orphans = Scalar<string>("""
            SELECT STRING_AGG(SCHEMA_NAME(t.schema_id) + '.' + t.name, ', ')
            FROM sys.columns c
            JOIN sys.tables t ON t.object_id = c.object_id
            WHERE c.name = 'user_id'
              AND NOT EXISTS (
                SELECT 1 FROM sys.foreign_key_columns fkc
                JOIN sys.foreign_keys fk ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id
                  AND fk.referenced_object_id = OBJECT_ID('dbo.users'))
            """);
        Assert.IsNull(orphans, $"user_id without FK to dbo.users: {orphans}");
    }

    [TestMethod]
    public void UsersHasExpectedSchema()
    {
        var actual = Scalar<string>("""
            SELECT STRING_AGG(c.name + ':' + ty.name, ',') WITHIN GROUP (ORDER BY c.column_id)
            FROM sys.columns c JOIN sys.types ty ON ty.user_type_id = c.user_type_id
            WHERE c.object_id = OBJECT_ID('dbo.users')
            """);
        Assert.AreEqual(
            "id:int,username:varchar,phone_number:varchar,email:varchar,password:nvarchar,created_at:datetime,status:tinyint",
            actual);
    }
}
