# Chapter 16: Inserting Sets of Data

INSERT == add new rows to a table. Two distinct forms: `INSERT ... VALUES` (one literal row) and `INSERT ... SELECT` (copy/derive one or more rows from another query) — the latter is what actually earns this chapter its "sets of data" title.

## Inserting Values

```sql
INSERT INTO table_name (column_name [, column_name ...])
VALUES (value_expression [, value_expression ...])
```

1. Column list is technically optional if you supply a value for *every* column in table-definition order.
2. **Always write the column list anyway.** If you omit it and someone later adds a column or reorders the table definition, the INSERT breaks (or worse, silently misassigns values) — the same defensive habit as spelling out SELECT columns instead of `*`.
3. Value expressions line up positionally with the column list, left to right.
4. `DEFAULT` uses the column's defined default value (errors if none exists); `NULL` inserts a null (errors if the column disallows nulls).

```sql
INSERT INTO Employees
    (EmpFirstName, EmpLastName, EmpStreetAddress, EmpCity, EmpState, EmpZipCode, EmpAreaCode, EmpPhoneNumber)
VALUES
    ('Susan', 'Metters', '16547 NE 132nd St', 'Woodinville', 'WA', '98072', 425, '555-7825')
```

Notice `EmployeeID` (the primary key) isn't in the list at all.

## Generating the Next Primary Key Value

Most engines let you mark a primary key column as self-generating so INSERT never has to supply it:

| System | Feature |
|---|---|
| Microsoft Access | AutoNumber |
| SQL Server / DB2 | Identity |
| PostgreSQL | serial |
| MySQL | AUTO_INCREMENT |
| Oracle | Sequence pseudo-column, referenced explicitly via `.NEXTVAL` |

```sql
-- Oracle: no auto-assigning column type, so you reference the sequence yourself
INSERT INTO Employees (EmployeeID, EmpFirstName, ...)
VALUES (EmpID.NEXTVAL, 'Susan', ...)
```

✨ **Side learning**: you *can* write `VALUES ((SELECT MAX(EmployeeID) FROM Employees) + 1, ...)` per the Standard, but several major engines don't actually support a subquery inside a VALUES clause — check before relying on it. It's also race-prone under concurrent inserts compared to a real auto-increment/sequence.

⚠️ If you insert your own explicit value into an Identity/AutoNumber/AUTO_INCREMENT column: SQL Server requires `SET IDENTITY_INSERT table_name ON` first (and you should turn it back `OFF` after); PostgreSQL's `serial` does **not** auto-adjust its underlying sequence when you supply an explicit value, so you must manually catch it up afterward:

```sql
SELECT setval('tablename_serialcolname_seq', <last_value_you_inserted>)
```
Forget this step and the next auto-generated insert can collide with a value you already used by hand.

## Inserting Data via SELECT

```sql
INSERT INTO table_name (column_name [, column_name ...])
SELECT ...
```

Same column-list rules as the VALUES form. The SELECT can be a full SELECT expression (including UNION/INTERSECT/EXCEPT, per Chapter 7) — this is genuinely a set operation: however many rows the SELECT returns, that many rows get inserted.

Copy a single row using a lookup:

```sql
INSERT INTO Employees
    (EmpFirstName, EmpLastName, EmpStreetAddress, EmpCity, EmpState, EmpZipCode, EmpAreaCode, EmpPhoneNumber)
SELECT CustFirstName, CustLastName, CustStreetAddress, CustCity, CustState, CustZipCode, CustAreaCode, CustPhoneNumber
FROM Customers
WHERE CustFirstName = 'David' AND CustLastName = 'Smith'
```

Archive a whole batch of rows in one shot — the actual "set" use case:

```sql
INSERT INTO Engagements_Archive
    (EngagementNumber, StartDate, EndDate, StartTime, StopTime, ContractPrice, CustomerID, AgentID, EntertainerID)
SELECT EngagementNumber, StartDate, EndDate, StartTime, StopTime, ContractPrice, CustomerID, AgentID, EntertainerID
FROM Engagements
WHERE EndDate < '2018-01-01'
```

You can also mix literals with looked-up values in the SELECT list, useful when only *some* of the values you need come from a lookup:

```sql
INSERT INTO Products (ProductName, RetailPrice, CategoryID)
SELECT 'Hot Dog Spinner' AS ProductName, 895 AS RetailPrice, CategoryID
FROM Categories
WHERE CategoryDescription = 'Bikes'
```

⚠️ Multi-table Cartesian product as a deliberate INSERT technique: listing several tables in FROM with no JOIN condition, relying on a tight WHERE to reduce the cross product down to exactly one row per table (one customer, one entertainer, one agent) before it lands in the target. Works, but fragile — if any of those WHERE conditions ever matches more than one row, you silently insert one row *per combination* instead of one.

## Order of Operations Across Related Tables

⚠️ When an INSERT ... SELECT populates a table whose rows will be referenced by foreign keys elsewhere (an archive scheme, for instance), insert into the **parent** table first, then the child/detail table — the reverse order can violate referential integrity if the child rows' foreign keys must already exist in the parent:

```sql
-- 1. Parent table first
INSERT INTO Orders_Archive
SELECT OrderNumber, OrderDate, ShipDate, CustomerID, EmployeeID, OrderTotal
FROM Orders WHERE OrderDate < '2018-01-01'

-- 2. Then the child table, filtered by the same parent rows
INSERT INTO Order_Details_Archive
SELECT OrderNumber, ProductNumber, QuotedPrice, QuantityOrdered
FROM Order_Details
WHERE OrderNumber IN (SELECT OrderNumber FROM Orders WHERE OrderDate < '2018-01-01')
```

Wrap both statements in a transaction (Chapter 15) — if the second INSERT fails partway, roll back rather than leave the parent rows archived with no matching details.

## Summary

- Two INSERT forms: `VALUES` for one literal row, `SELECT` for copying/deriving one or more rows — the SELECT form is where INSERT genuinely becomes a set-based operation.
- Always spell out the column list, even when supplying every column — protects the query against later schema changes.
- Auto-generating primary keys is nearly universal (Identity / AutoNumber / serial / AUTO_INCREMENT / Sequence), but PostgreSQL's `serial` needs a manual `setval` catch-up if you ever insert an explicit value into it yourself.
- `INSERT ... SELECT` accepts anything a SELECT expression can produce, including literal values mixed with looked-up ones in the same SELECT list.
- ⚠️ For related parent/child tables, insert parents before children to respect referential integrity — same ordering concern resurfaces (in reverse) for DELETE in the next chapter.
- A Cartesian-product INSERT (multiple tables, no JOIN, narrow WHERE) is a real technique but only safe when every filter is guaranteed to match exactly one row per table.
