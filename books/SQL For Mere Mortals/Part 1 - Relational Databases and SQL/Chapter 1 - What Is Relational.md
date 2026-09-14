# Chapter 1: What Is Relational?

## Types of databases

1. **Operational database** — day-to-day, dynamic data, constantly changing. Retail, hospitals, manufacturing.
2. **Analytical database** — historical/time-dependent, mostly static (rarely modified, often appended to). Used for trends and strategic decisions. Usually populated from an operational database (e.g., monthly sales history rolled up).

## A brief history of the relational model

1. **1969-1970**: Dr. Edgar F. Codd (IBM) invented the relational model. Published "A Relational Model of Data for Large Shared Databanks" (June 1970).
2. Model is grounded in **set theory** + **first-order predicate logic** — that's where the name "relational" actually comes from (a *relation* is set-theory terminology).

🤯 Common misconception: "relational" does NOT refer to tables being related to each other via foreign keys. It refers to the mathematical term *relation*, which is what a relational database calls a table.

3. Timeline of RDBMS evolution: mainframe era (System R at IBM, INGRES at Berkeley, early 1970s) → commercial mainframe RDBMS (Oracle, IBM, 1980s) → PC-based RDBMS (Ashton-Tate, Microrim, mid-1980s) → client/server RDBMS (Microsoft, Oracle, late 1980s/90s) → data warehousing (IBM's concept, Bill Inmon as "father of the data warehouse") → Internet/XML → cloud.

## Anatomy of a relational database

Data lives in **relations** (perceived by users as **tables**), made of **tuples** (rows/records) and **attributes** (columns/fields).

### Tables

1. Represents a single, specific subject — either an **object** (tangible: person, place, thing) or an **event** (something that happens at a point in time with recordable characteristics, e.g. a doctor's appointment).
2. Row/column order is meaningless.
3. Every table needs a **primary key** — one or more columns that uniquely identify each row.
4. Data is logically independent of physical storage — you never need to know *where* a row lives to retrieve it.

### Columns

Smallest structure in the database. Represents one characteristic of the table's subject. Rule of thumb: one column == one value, name says exactly what it holds (`FirstName`, `ZipCode`, not `Misc`).

### Rows

A unique instance of the table's subject — the full set of column values for one entity, identified throughout the database by its primary key value.

### Keys

1. **Primary key** — uniquely identifies each row in a table; composite when it spans 2+ columns. Enforces table-level integrity, enables relationships. Every table should have one.
2. **Foreign key** — a copy of another table's primary key, inserted to establish a relationship. Prevents "orphaned rows" (e.g., an order with no matching customer).

```sql
-- AgentID is PK in Agents, and reappears as FK in Entertainers
CREATE TABLE Agents (
    AgentID INT PRIMARY KEY,
    AgentLastName VARCHAR(30)
);

CREATE TABLE Entertainers (
    EntertainerID INT PRIMARY KEY,
    AgentID INT REFERENCES Agents(AgentID),
    EntertainerName VARCHAR(60)
);
```

### Views

A **view** == a virtual table built from columns of one or more **base tables**. Only the view's *structure* (its defining query) is stored — not its data; it's computed from base tables on the fly.

Many RDBMS products call a view a "query" or "saved query" instead — same concept, different marketing.

```sql
CREATE VIEW Customer_Engagements AS
SELECT e.EngagementNumber, c.CustFirstName, c.CustLastName, e.StartDate, e.EndDate
FROM Engagements e
JOIN Customers c ON c.CustomerID = e.CustomerID;
```
This view joins Customers with Engagements so you can see each booking alongside the customer's name without repeating that data in the Engagements table itself.

### Relationships

Three kinds, defined by how rows in one table associate with rows in another:

1. **One-to-one** — one row in table A relates to exactly one row in table B, and vice versa. Rare; usually used to split a table for confidentiality (e.g., `Agents` / `Compensation`). Established by copying the primary key of the *primary* table into the *secondary* table as its own primary key (and foreign key).
2. **One-to-many** — one row in the "one" table relates to many rows in the "many" table, but each "many"-side row relates to only one "one"-side row. PK of the "one" side becomes an FK on the "many" side.
3. **Many-to-many** — rows on both sides can relate to many rows on the other side. Cannot be represented directly (an "unresolved" many-to-many); must be resolved with a **linking table** that holds a copy of both primary keys, together forming its composite primary key.

```sql
-- Linking table resolving Customers <-> Entertainers many-to-many
CREATE TABLE Engagements (
    EngagementID INT PRIMARY KEY,
    CustomerID INT REFERENCES Customers(CustomerID),
    EntertainerID INT REFERENCES Entertainers(EntertainerID),
    StartDate DATE
);
```
This lets one customer book many entertainers and one entertainer play for many customers, while also storing per-booking data (dates, cost) that doesn't belong to either side alone.

✨ **Side learning**: theory purists like C. J. Date and Fabian Pascal have argued that no commercial database is *truly* relational in the strict Codd sense — most take practical liberties (duplicate rows without a declared key, NULLs, etc.).

## What's in it for you?

Relational databases have dominated commercial data management for 40+ years and aren't going anywhere. Learning the relational model pays off because it's the substrate SQL sits on — understanding it makes RDBMS tools, error messages, and query design far more intuitive. Database *theory* (the math/rules) is distinct from database *design* (the process of applying those rules) — this book leans toward practical design basics, deferring deep theory/design study to dedicated books (e.g., Hernandez's *Database Design for Mere Mortals*).

## Summary

- Two broad database types: **operational** (dynamic, day-to-day) and **analytical** (static, historical).
- The relational model, invented by Codd in 1969-70, is grounded in set theory and predicate logic — "relational" refers to *relations* (tables), not table-to-table relationships.
- A relational database is built from **tables** (object or event subjects), **columns** (single-valued characteristics), **rows** (unique subject instances), and **keys** (primary keys identify rows; foreign keys link tables).
- **Views** are virtual tables computed from base tables — no data of their own.
- Table relationships come in three flavors: **one-to-one**, **one-to-many**, **many-to-many** (the last always needs a linking table to resolve).
- Knowing the relational model well is foundational — it's what makes SQL make sense.
