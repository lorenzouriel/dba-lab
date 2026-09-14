# A Guide to Performance Tips
No one likes dealing with slow queries. Besides being tiresome to wait for, they can cause significant damage to your database.

Some simpler approaches can help resolve this.

To start, I want to begin with basic techniques that work - sometimes just making changes to the query is enough.

All examples use the AdventureWorks2019 database, which you can [download here.](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms)

*Before making any changes, I should mention that the recommendation is to read the Query Execution Plan and understand why the slowness occurs. This way we can take appropriate action to solve the problem.*

### Use TOP (SELECT TOP)
Helps limit the number of rows returned by the query, which can improve performance and reduce system load.

Useful for quick checks or viewing only the most recent records without scanning the entire table.

Can prevent LOCKS and database freezing by limiting the query so it doesn't read the entire table.

**Example of last 100 records:**
```sql
SELECT TOP 100
	*
FROM [AdventureWorks2019].[Production].[TransactionHistory]
ORDER BY [TransactionDate] DESC
```

### Avoid Using DISTINCT
Using DISTINCT can be costly for performance. To avoid duplicate data, it's better to redefine table structures or indexes by adding columns that prevent duplicates.

When using DISTINCT, understand what you're querying and develop the query efficiently.

If DISTINCT is necessary, try to query indexed fields.

**DISTINCT example:**
```sql
SELECT DISTINCT
	[ProductID]
FROM [AdventureWorks2019].[Production].[TransactionHistory]
```

### Avoid OR in WHERE, Use IN Instead
The IN operator is more efficient than OR, especially with large datasets.

The OR operator combines conditions in a WHERE clause (e.g., column = value1 OR column = value2).

The IN operator lets you specify multiple values in a single condition (e.g., column IN (value1, value2)), which is more efficient.

**IN example:**
```sql
SELECT TOP 100
	*
FROM [AdventureWorks2019].[Production].[TransactionHistory]
WHERE [ProductID] IN (358, 378)
-- Instead of: WHERE [ProductID] = 358 or [ProductID] = 378
```

### Avoid SELECT *, Specify Columns
Specifying only needed columns is a good performance practice. SELECT * retrieves all available information for each record, generating more traffic.

Also, specifying columns makes code clearer and less prone to errors when table structure changes.

**Example with selected columns:**
```sql
SELECT TOP 1000
	[ProductID],
	[TransactionDate],
	[ActualCost],
	[Quantity]
FROM [AdventureWorks2019].[Production].[TransactionHistory]
WHERE [ProductID] IN (358, 378)
```

### Use HAVING Carefully
Filtering results in WHERE is more efficient than HAVING when possible.

WHERE filters rows before grouping and returning results, reducing data the database must process.

HAVING filters results after grouping, which can be more costly. Use HAVING when filtering aggregated values.

**HAVING example:**
```sql
SELECT TOP 1000
    [ProductID],
    [TransactionDate],
    [ActualCost],
    [Quantity],
    SUM([ActualCost] * [Quantity]) AS TotalCost
FROM [AdventureWorks2019].[Production].[TransactionHistory]
WHERE [ProductID] IN (358, 378)
GROUP BY [ProductID], [TransactionDate], [ActualCost], [Quantity]
HAVING SUM([ActualCost] * [Quantity]) > 300
```

### Check if WHERE/JOIN Columns Have Indexes
When filtering with WHERE, an index on that column improves performance by helping the database access records faster.

Columns used in JOIN operations also benefit from indexes, making joins more efficient.

**Example to check table indexes:**
```sql
EXEC sp_helpindex '[Production].[TransactionHistoryArchive]';
```

### Use DESC in Nonclustered Indexes for Date Columns
Descending order in nonclustered indexes on date columns allows faster access to recent data.

Queries requesting recent data benefit directly from this organization.

**Sorting example:**
```sql
CREATE NONCLUSTERED INDEX IX_TransactionHistory_TransactionDate_Desc
ON [Production].[TransactionHistory] ([TransactionDate] DESC);
```

### Create Nonclustered Indexes on Frequently Accessed Fields
Particularly useful for queries filtering data based on specific values in these columns.

Monitor most executed queries to identify frequently accessed columns that need indexes.

You can add multiple fields in the same index creation, and dependent fields in INCLUDE.

**Nonclustered index example with multiple fields and INCLUDE:**
```sql
CREATE NONCLUSTERED INDEX [IX_TransactionHistory_Fields_Include]
ON [Production].[TransactionHistory] ([TransactionDate] DESC, [ModifiedDate] DESC)
INCLUDE ([Quantity], [ActualCost])
```

This approach is better than creating an index per field.

For more on index creation, revisit the indexes chapter!

### Maintain Index Routines
Creating indexes isn't enough - they need maintenance too.

With heavy use, indexes fragment and statistics become outdated.

A routine to reorganize indexes and update statistics is essential for maintaining query performance.

**REBUILD and REORGANIZE examples:**
```sql
ALTER INDEX cix_your_table_id ON [your_table] REBUILD; -- CLUSTERED
ALTER INDEX ncix_your_table_name_date ON [your_table] REBUILD; -- NONCLUSTERED

ALTER INDEX cix_your_table_id ON [your_table] REORGANIZE; -- CLUSTERED  
ALTER INDEX ncix_your_table_name_date ON [your_table] REORGANIZE; -- NONCLUSTERED
```

Additionally, run maintenance queries/routines during off-peak hours to avoid resource conflicts.

### Partition Your Tables
Partitioning lets operations like inserts/updates/deletes affect only part of the table, resulting in less impact and faster operations.

Partitions can be distributed across different storage locations, disks, or even servers.

Imagine recent, frequently accessed data on SSD partitions while older data stays on HDD partitions. Brilliant, right?

An advanced technique but very useful for large data volumes.

### Create Stored Procedures for Report/Dashboard Queries
Standard queries are compiled and optimized each execution. Stored Procedures have optimized execution plans created once, saving processing time.

Besides performance, Stored Procedures offer security, organization, and easier maintenance.

**Stored Procedure example:**
```sql
CREATE PROCEDURE GetTransactionByDate
    @date DATETIME 
AS
BEGIN
    SELECT 
           [ProductID],
           [TransactionDate],
           [TransactionType],
           [Quantity],
           [ActualCost],
           [ModifiedDate]
    FROM [AdventureWorks2019].[Production].[TransactionHistoryArchive]
    WHERE [TransactionDate] = @date;
END;
```

Remember we created nonclustered indexes on these fields? This Procedure will run beautifully.

### Use In-Memory OLTP for Stagings
In-Memory OLTP stores tables in main memory instead of disk.

Using it for temporary report data provides significant performance gains since memory access is faster than disk.

Particularly useful for reports and processing using large data volumes.

### Check MAXDOP (Degree of Parallelism) Usage
Adjusting MAXDOP can optimize parallel queries, balancing server load.

You can set it directly in queries or change SGBD settings (recommended).

**MAXDOP example:**
```sql
SELECT [TransactionID]
      ,[ProductID]
      ,[ReferenceOrderID]
      ,[ReferenceOrderLineID]
      ,[TransactionDate]
      ,[TransactionType]
      ,[Quantity]
      ,[ActualCost]
      ,[ModifiedDate]
FROM [AdventureWorks2019].[Production].[TransactionHistoryArchive]
OPTION (MAXDOP 8);
```

I recommend understanding your environment better, but this MAXDOP has saved my weekend before.