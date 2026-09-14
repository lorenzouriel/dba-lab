# Chapter 2: Ensuring Your Database Structure Is Sound

Why this chapter exists: a poorly structured database makes even simple SQL painful (or impossible) to write well. This is not a full design methodology — just enough fine-tuning checklists to get an existing or in-progress structure into decent shape before writing queries against it.

## Fine-tuning columns

### Naming columns

Checklist for a good column name:

1. Descriptive + meaningful org-wide (not just to one department).
2. Clear and unambiguous — `PhoneNumber` is bad; prefer `HomePhone` / `WorkPhone` / `CellPhone` if you truly need to distinguish them (though see multivalued columns below — that's often the *better* fix).
3. No acronyms/abbreviations (`CAD_SW` tells you nothing).
4. Doesn't bundle more than one characteristic — words like "and"/"or", or characters `\ - &` in a name (e.g. `Phone/Fax`) are a tell.
5. Singular, not plural — `Category`, not `Categories`. Plural column name usually means it secretly holds more than one value.
6. Unique across the whole database, except when the column is deliberately a foreign key linking two tables. Disambiguate generic names with a short table-based prefix: `VendCity`, `CustCity`, `EmpCity` instead of three unrelated `City` columns.

✨ **Side learning**: the SQL Standard defines a *regular identifier* (starts with a letter, only letters/digits/underscore, no spaces) vs. a *delimited identifier* (quoted, allows spaces/special chars). Stick to regular identifiers — not every SQL implementation honors delimited ones consistently.

### Structural column checklist

1. Column belongs to *this* table's subject — if not germane, move or drop it (except FK columns, or columns added for an app-specific reason).
2. Single value only — no **multivalued** columns (multiple instances of the same kind of value, e.g. a comma-separated list of certifications) and no **multipart** columns (multiple distinct values crammed into one, e.g. `"Suzanne Viescas, 15127 NE 24th, Redmond, WA 98052"`).
3. Never store a **calculated** value — a column isn't a spreadsheet cell; it won't auto-update when its inputs change. Compute it in the SELECT instead.
4. No unnecessary duplicate columns across tables (e.g., `CompanyName` copy-pasted into three tables) — causes inconsistent data when only one copy gets updated.

### Resolving multipart columns

Test: "Can I break this value into smaller, more distinct parts?" If yes, split it into separate columns.

```sql
-- Before: multipart CustomerName, StreetAddress
-- CustomerName = "Suzanne Viescas", StreetAddress = "15127 NE 24th, #383, Redmond, WA 98052"

-- After: split into atomic columns
CREATE TABLE Customers (
    CustomerID   INT PRIMARY KEY,
    CustFirstName VARCHAR(20),
    CustLastName  VARCHAR(30),
    CustAddress   VARCHAR(60),
    CustCity      VARCHAR(30),
    CustState     CHAR(2),
    CustZipCode   VARCHAR(10)
);
```

Multipart columns can be subtle — e.g. an `InstrumentID` value like `GUIT2201` secretly encodes a category (`GUIT`) plus a serial number (`2201`). If the category code ever changes, you're stuck parsing and rewriting every row.

### Resolving multivalued columns

Values in a multivalued column (e.g. `Certifications = "727, 737, 757"`) have an implicit **many-to-many relationship** with the parent row. Resolve exactly like any many-to-many: with a **linking table**.

```sql
-- Before: Pilots.Certifications = "727, 737, 757" (comma-separated)

-- After: linking table
CREATE TABLE Pilot_Certifications (
    PilotID         INT REFERENCES Pilots(PilotID),
    CertificationID INT REFERENCES Certifications(CertificationID),
    PRIMARY KEY (PilotID, CertificationID)
);
```
This makes "which pilots can fly a 747" or "list all certifications for pilot 25100" trivial to query and sort — impossible to do cleanly against the comma-separated version.

✨ **Side learning**: some products (older Microsoft Access versions) let you declare a column as natively "multivalued," but under the hood they just create a hidden linking table identical in spirit to the one above. Building it yourself keeps you in control of the design.

## Fine-tuning tables

### Naming tables

Same spirit as column naming, applied at the table level:

1. Unique + descriptive org-wide.
2. Unambiguous single subject — `Dates` is meaningless; split into `Client_Meetings` and `Entertainer_Schedules` if that's really what it holds.
3. Avoid words like *File*, *Record*, *Table* in the name — `Employee_Record` hints the table secretly covers employees + departments + payroll, three subjects that should be three tables.
4. No acronyms (`SC` means different things to different departments).
5. No "and"/"or"/`\ - &` compound names — split into separate tables instead.
6. **Plural** form (`Employees`, not `Employee`) — a table holds a collection of instances, and pluralizing also visually distinguishes table names from column names.

### Structural table checklist

1. Single subject per table (object or event).
2. Every table has a primary key.
3. No multipart/multivalued columns left over (double-check after the column pass).
4. No calculated columns left over.
5. No unnecessary duplicate columns.

### Resolving duplicate columns

Two flavors show up in practice:

**1. Duplicated reference data.** E.g. `Classes` storing `StaffFirstName`/`StaffLastName` when it already has `StaffID` linking to `Staff`. The relationship already gives you that data via a join — drop the copies.

**2. Repeating-group columns simulating multiple values.** E.g. `Committee1`, `Committee2`, `Committee3` columns on `Employees`, or `EmpHomePhone`/`EmpWorkPhone`/`EmpCellPhone`. Problems: arbitrary cap on how many values you can store, painful multi-column search ("is anyone on ISO 9000?" needs 3 OR'd conditions), and no clean way to sort by the repeated value.

Fix: pull the repeating attribute into its own related table, keyed by a copy of the parent's primary key.

```sql
-- Before: Employees has Committee1, Committee2, Committee3 columns

-- After: linking table + real Committees table
CREATE TABLE Committees (
    CommitteeID   INT PRIMARY KEY,
    CommitteeName VARCHAR(30),
    MeetingRoom   VARCHAR(10),
    MeetingDay    VARCHAR(10)
);

CREATE TABLE Committee_Members (
    EmployeeID   INT REFERENCES Employees(EmployeeID),
    CommitteeID  INT REFERENCES Committees(CommitteeID),
    PRIMARY KEY (EmployeeID, CommitteeID)
);
```

Same pattern for phone numbers — instead of fixed `Home`/`Work`/`Cell` columns, use a `Phone_Numbers` table with `EmployeeID`, `PhoneID`, `PhoneType`, `PhoneNumber`. Now an employee can have zero, one, or five phone numbers of any type, with no wasted NULL columns and no arbitrary cap.

### Choosing a sound primary key

Checklist — a candidate column (or column set) must pass ALL of these:

1. Uniquely identifies each row.
2. Values are actually unique (no duplicates ever).
3. Never unknown (no NULLs, ever).
4. Never optional.
5. Not itself a multipart column.
6. Value never needs to change once set.

If no natural column qualifies (common — e.g. an `Employees` table where every column can legitimately duplicate or go blank), create an **artificial primary key**: an arbitrary, meaningless ID column (`EmployeeID`) added purely to serve as the PK.

1. **Simple primary key** — a single column. Prefer this when possible; it's more efficient and simpler to use as an FK elsewhere.
2. **Composite primary key** — two or more columns together. Normal for linking tables (e.g., `PilotID` + `CertificationID`).

🤯 An artificial key solves *uniqueness* but not *duplication*: nothing stops someone from adding a second "John Kennedy" row with a different `EmployeeID`. That requires separate validation logic (e.g. a trigger), not the primary key itself.

⚠️ Related columns used to link two tables must share the same underlying data type (an Int PK only links to an Int FK). The one exception: auto-generated PKs (AutoNumber / Identity / Serial / Auto_Increment) can link to a plain column of their underlying numeric type.

## Establishing solid relationships

Diagram notation used throughout the book (from Hernandez's *Database Design for Mere Mortals*): **PK** = primary key column, **FK** = foreign key column, **CPK** = column that's part of a composite primary key.

1. **One-to-one**: PK of the primary table copied into the secondary table, where it usually doubles as that table's own PK.
2. **One-to-many**: PK of the "one" side copied into the "many" side as an FK.
3. **Many-to-many**: resolved via a linking table whose composite PK is built from copies of both sides' PKs (each also acting individually as an FK).

### Deletion rules

Governs what happens when you try to delete a row on the "one" (or primary) side of a relationship that still has related rows on the other side.

1. **Restrict** — refuse the delete until related rows are removed first. The safe default; often the only option available.
2. **Cascade** — automatically delete related rows too. Powerful, and dangerous if applied carelessly — you can wipe out data you meant to keep.

Test question to decide which: *"If a row in [one-side table] is deleted, should related rows in [many-side table] be deleted as well?"* — "No" → restrict; "Yes" → cascade.

```sql
-- SQL Server / PostgreSQL: cascading FK
CREATE TABLE Committee_Members (
    CommitteeID INT REFERENCES Committees(CommitteeID) ON DELETE CASCADE,
    EmployeeID  INT REFERENCES Employees(EmployeeID),
    PRIMARY KEY (CommitteeID, EmployeeID)
);
```

### Type of participation

Whether at least one row must already exist on one side before you can add a row referencing it on the other side.

1. **Mandatory** — a related row must exist first.
2. **Optional** — no such requirement.

Example: a `Departments` row must exist (mandatory) before you can assign employees to it via `Department_Employees` (optional on the employee side) — you create the new department first, *then* start staffing it.

### Degree of participation

The min/max number of related rows allowed on each side, written as `(min,max)`. E.g. `(1,1)` means exactly one; `(0,6)` means zero up to six. Example from the book: an entertainment agency capping each agent at 6 entertainers — `Agents (1,1)` to `Entertainers (0,6)`.

Most real "many" sides are effectively `(0,∞)` — degree-of-participation limits matter only when a real business rule caps the count (e.g., max students per class).

✨ **Side learning**: enforcing degree-of-participation limits (as opposed to just the relationship's existence) generally requires triggers or check constraints — the plain foreign-key mechanism alone won't cap "at most 6 related rows."

## Summary

- Fixing a database's structure is a two-level pass: **columns first**, then **tables** — most table-level duplicate-column and multivalued problems trace back to a column that wasn't atomic to begin with.
- Column checklist: clear singular name, single characteristic, single value, never calculated, never duplicated elsewhere (except FKs).
- Table checklist: clear plural name, single subject, has a primary key, no leftover multipart/multivalued/calculated/duplicate columns.
- **Multivalued** and repeating-group columns are really disguised many-to-many relationships — resolve both with a linking table.
- Every table needs a primary key that's unique, never null, never optional, not multipart, and stable; use an artificial key when no natural column qualifies.
- Relationships need three characteristics defined explicitly: **deletion rule** (restrict/cascade), **type of participation** (mandatory/optional), and **degree of participation** (min,max) — these aren't automatic, they reflect actual business rules and must be deliberately chosen.
- This chapter is deliberately partial — full database design methodology is a separate, deeper topic (see Hernandez, *Database Design for Mere Mortals*).
