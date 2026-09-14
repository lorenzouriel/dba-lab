# Chapter 5: Getting More Than Simple Columns

Expression == an operation on numbers, strings, or dates that returns a value. Built from column references, literals, or a mix of both. Expressions let a SELECT clause do more than just echo raw column values — they compute, reformat, and combine data into new (calculated) columns.

## Data Types (SQL Standard categories)

1. **Character** / **National Character** — CHAR/VARCHAR (fixed/varying length); overflow beyond the system max needs CLOB/TEXT. National character variants pull from ISO foreign-language charsets (NCHAR/NVARCHAR/NCLOB).
2. **Binary** — BLOB, for images/sound/video/documents.
3. **Exact numeric** — NUMERIC/DECIMAL/INTEGER/SMALLINT/BIGINT (whole + fixed-decimal numbers, precision/scale defined).
4. **Approximate numeric** — FLOAT/REAL/DOUBLE PRECISION (decimal + exponential, no fixed scale).
5. **Boolean** — true/false, often backed by a single bit or an INT/TINYINT depending on vendor.
6. **Datetime** — DATE, TIME, TIMESTAMP.
7. **Interval** — duration between two datetime values; not universally supported.

Plus common **extended types** beyond the Standard: MONEY/CURRENCY, SERIAL/ROWID/IDENTITY/AUTOINCREMENT for surrogate keys.

## CAST: Changing Data Types

```sql
CAST(expression AS data_type)
```

Use CAST whenever an expression mixes incompatible types — e.g. you can't blindly add a string to a number, but if the string actually holds a numeric value, CAST bridges the gap.

Conversion rules to keep in mind:
1. Character → shorter character type: truncates if it doesn't fit (with a warning, ideally).
2. Character → numeric/datetime: source string must actually be convertible ("square peg in round hole" — a ZIP code with letters won't cast to a number).
3. Numeric → smaller numeric type: must fit the target range; decimal fractions get truncated or rounded (database-dependent) when converting to an integer type.
4. Numeric → character: converts, pads with blanks if shorter than the target length, or errors if it overflows the target length.

```sql
CAST('2016-11-22' AS DATE)
CAST(RetailPrice AS CHARACTER(8))
```

✨ **Side learning:** MySQL historically required an explicit `CAST(... AS DATE)` / `CAST(... AS DATETIME)` around any date/time string literal before you could use it in date arithmetic — most other systems let you use a quoted date literal directly.

## Literals

Constant values you can drop into an expression alongside (or instead of) column references.

1. **Character string literal** — single-quoted (`'Seattle'`); embed a literal quote by doubling it (`'The Vendor''s name'`).
2. **Numeric literal** — optional sign, digits, optional decimal point, optional exponent (`427`, `-11.253`, `.554`, `0.3E-3`).
3. **Datetime literal** — `'yyyy-mm-dd'`, `'hh:mm:ss'`, `'yyyy-mm-dd hh:mm:ss'`. The Standard technically wants a `DATE`/`TIME`/`TIMESTAMP` keyword before the string, but nearly every vendor accepts the bare quoted string.

✨ **Side learning:** Microsoft Access uses `#` as its date/time literal delimiter instead of quotes — one of several small vendor deviations from the Standard's literal syntax.

## Types of Expressions

### Concatenation

Standard operator is `||`. Combines character values into one string.

```sql
SELECT CompanyName || ' is based in ' || City FROM Vendors
```

Concatenating a number or date with a string usually needs an explicit `CAST(... AS CHARACTER(n))` — some systems auto-cast for you, but don't rely on it.

✨ **Side learning:** concatenation syntax is one of the least portable bits of SQL — DB2, Informix, Oracle, and PostgreSQL use the Standard `||`; Access uses `&` or `+`; SQL Server and Ingres use `+`; MySQL requires a `CONCAT()` function call instead of an operator at all.

### Mathematical

Standard defines `+ - * /` plus functions like `ABS`, `MOD`, `POWER`, `SQRT`, `FLOOR`, `CEILING`.

Order of precedence: `*` and `/` before `+` and `-`, evaluated left to right otherwise — this matches most programming languages, not the strict PEMDAS taught in school. Always parenthesize non-trivial expressions; nested parens evaluate innermost-to-outermost, left-most group first when two groups are at the same level.

```sql
SELECT Salary + (50000 * CommissionRate) AS ProjectedIncome
FROM   Agents
```

🤯 Converting a decimal to an integer with CAST usually **truncates**, not rounds, in most implementations — `CAST(138.65 AS INTEGER)` gives you 138, not 139. The Standard leaves rounding-vs-truncation up to the vendor, so always check.

### Date and Time Arithmetic

Standard-defined results:
```
DATE ± INTERVAL  → DATE
DATE  - DATE     → INTERVAL
TIME ± INTERVAL  → TIME
TIME  - TIME     → INTERVAL
```

Most real-world systems don't fully implement INTERVAL, so the book's convention throughout: assume you can add/subtract a plain integer number of days to/from a DATE, and that subtracting two DATEs yields an integer day count.

```sql
SELECT OrderNumber,
       CAST(ShipDate - OrderDate AS INTEGER) AS DaysToShip
FROM   Orders
```

## Using Expressions in SELECT

Naming a calculated column with `AS` (also usable to alias a plain column):

```sql
SELECT EmpFirstName || ' ' || EmpLastName AS EmployeeName,
       DOB AS DateOfBirth
FROM   Employees
```

Most engines *require* a name for a calculated column (some auto-generate one if you don't supply it) — name yours explicitly, especially if you'll reference the result elsewhere.

## Value Expressions

The Standard's umbrella term for "column reference, literal, or expression" is **value expression** — anything that can appear where a value is expected. Value expressions nest: a value expression can be built out of other value expressions (with parens forcing evaluation order), and later chapters extend the concept to include function calls, CASE expressions, and scalar subqueries.

```sql
SELECT AgtFirstName || ' has a projected income of ' ||
       CAST(Salary + (50000 * CommissionRate) AS CHARACTER) AS ProjectedIncome
FROM   Agents
```

## Null

Null == a missing or unknown value. Explicitly **not**:
1. Zero — a zero is a real, meaningful numeric value in most contexts.
2. A string of blank spaces — spaces are legitimate characters as far as SQL cares.
3. A zero-length string (`''`) — can be meaningful (e.g., "no middle initial").

Why Nulls happen:
1. Human error — the data exists but wasn't captured.
2. Genuinely unknown — nobody, including the source, knows the value yet.
3. Doesn't apply — e.g. Salary is Null for an hourly employee, HourlyRate is Null for a salaried one.

The book draws a fine but real line between "does not apply" and "not applicable" — for the latter (e.g., HairColor for a bald patient), prefer an explicit sentinel value like `'N/A'` over Null, since it's clearer downstream.

🤯 Any expression touching a Null returns Null — always. `(25 * 3) + Null` is `Null`, not 79. This cascades: one missing value silently nullifies an entire calculated column for that row.

✨ **Side learning:** Oracle treats a zero-length VARCHAR literal (`''`) as Null internally — a deviation from the Standard that trips up people porting code from other databases.

## Summary

- Expression == operation on numbers/strings/dates, built from literals and/or column references, returning a single value.
- Know your data types before writing expressions — mismatches force you to reach for CAST.
- CAST converts between types but has real limits (truncation, invalid conversions, range overflow).
- Three main expression families: concatenation (`||`), mathematical (`+ - * /` with standard precedence), and date/time arithmetic.
- Always parenthesize non-trivial mathematical expressions — precedence rules aren't the ones from grade school.
- A calculated column needs (or benefits from) an explicit name via `AS`.
- Value expression is the umbrella term for "literal, column reference, or expression" — used throughout the rest of the book.
- Null means missing/unknown — never confuse it with zero, blank, or empty string — and any expression touching a Null yields Null.
