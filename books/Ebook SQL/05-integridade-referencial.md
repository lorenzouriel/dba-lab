# A Guide to Referential Integrity

Referential integrity is a fundamental concept in relational databases, ensuring the integrity of relationships between tables and preventing null values.

It is implemented through the use of foreign keys, which ensure that primary keys from other tables cannot have values that do not exist in these foreign keys, preventing orphaned records.

## Foreign Key:
A foreign key is a field or set of fields in one table that refers to the primary key of another table. It establishes a relationship between two tables, where the table containing the foreign key is called the "child" table, and the table referenced by the primary key is called the "parent" table.

Our relationship occurs between these "child" tables and "parent" tables. With referential integrity, we avoid orphaned records in both.

**Example:** If a "parent" table has two "child" tables, with referential integrity enabled, deleting a record from the "parent" table will automatically delete the corresponding records from the child tables.

If referential integrity is disabled, orphaned fields will exist in the "child" tables.

## Rules
In summary, referential integrity ensures that relationships between tables are valid and consistent.

It enforces the following rules:
- **Non-null Foreign Keys:** Values in a foreign key cannot be null unless the relationship is optional (using `NULL`).
- **Foreign Key Constraint:** A foreign key must always correspond to an existing primary key in the referenced table (or be `NULL` if permitted).
- **Update and Delete Operations:** Update (`UPDATE`) or delete (`DELETE`) operations on the parent table must be handled consistently to maintain referential integrity. For example, you can specify actions such as `CASCADE` (cascade update or delete), `SET NULL` (set to null), or `RESTRICT` (restrict) to handle these operations.

## Benefits and Real Example
I believe the greatest benefit is the ease of maintaining tables; you don't need to worry about null or orphaned records interfering with your database.

The downside, however, is that referential integrity can also be problematic.

Let's suppose your database is huge, and you have a table with billions of records. This table is probably related to another table with fewer records, often being the "parent" table.

If you need to delete records from the "parent" table, you must first delete all records from the "child" table. This can be very resource-intensive and might even crash your database.

Let me share an example from my own experience that may help.

I had to clean up several records from a database, but the issue was that I couldn't just delete them using referential integrity.

Why not?

Well, I tested it in a dev environment, and it took over 3 hours to clean the table *(granted, it was a server with fewer resources than production)*.

After discussing the solution, we decided to clean each table individually using cleanup routines. To do this, we had to disable referential integrity.

### How to Disable Referential Integrity:
To temporarily disable Referential Integrity in an SQL Server database, you can follow these steps:

**1. Disable Referential Integrity Constraints:**
```sql
ALTER TABLE TableName NOCHECK CONSTRAINT ALL;
```
- This will disable all referential integrity constraints on the table.

**2. Re-enable Referential Integrity Constraints:**
After completing the necessary operations, it’s important to re-enable referential integrity constraints to ensure data consistency:
```sql
ALTER TABLE TableName WITH CHECK CHECK CONSTRAINT ALL;
```
- This will re-enable all referential integrity constraints on the table.

This is how I managed the cleanup routine: I disabled the constraints, cleaned what was needed, and then re-enabled them.

I recommend understanding your database structure first—it's always the best step before any initiative.
