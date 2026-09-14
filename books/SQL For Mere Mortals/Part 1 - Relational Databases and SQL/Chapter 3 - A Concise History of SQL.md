# Chapter 3: A Concise History of SQL

## Origins

1. **1970**: Codd publishes the relational model.
2. **Early 1970s**: IBM's Santa Teresa/San Jose lab starts **System/R**, a research project to prove the relational model viable.
3. **1974**: Dr. Donald Chamberlin (IBM) develops **SEQUEL** (Structured English Query Language) — English-style query syntax, first implemented in a prototype called SEQUEL-XRM.
4. **1976-1977**: SEQUEL revised into **SEQUEL/2**, then renamed **SQL** for legal/trademark reasons (someone else already held "SEQUEL").

🤯 Because of that renaming, people still argue over pronunciation — many say "sequel" out of habit, but the standard's own official pronunciation is "es-cue-el."

✨ **Side learning**: SQL's syntax actually traces back further, to a 1975 research language called **SQUARE** (Specifying Queries As Relational Expressions), which predates System R and tried to express relational algebra in English-style sentences.

5. IBM closed the System R project in 1979 — concluded the relational model was commercially viable, but contemporary hardware made even simple queries take minutes.

## Early vendor implementations

1. **1977**: Relational Software, Inc. founded → shipped **Oracle** in 1979, beating IBM to market by two years (ran on cheaper VAX minicomputers vs. IBM mainframes). Company later renamed Oracle Corporation.
2. Meanwhile at Berkeley: Michael Stonebraker, Eugene Wong, et al. built **Ingres**, with its own query language **QUEL** (more structured, less English-like than SQL). Ingres later converted to SQL once SQL became the de facto standard. Ingres lives on today under Actian.
3. IBM itself: **SQL/DS** (1981/1982) → **DB2** (1985), IBM's flagship RDBMS ever since.

## Standardization

1. **1982**: ANSI commissions committee **X3H2** to draft an official relational database language standard. Considered basing it on QUEL, but market momentum (and IBM's commitment) pushed it toward SQL — specifically IBM's DB2 dialect.
2. **1986**: ANSI ratifies **SQL/86** ("ANSI X3.135-1986"). Deliberately a "least common denominator" — just codified the overlap that vendors already agreed on.
3. **1987**: ISO adopts the equivalent as **ISO 9075-1987**, giving it international standing.

### Filling the gaps

1. **1989**: **SQL/89** — both ANSI and ISO add referential integrity support.
2. **1989**: ANSI-only **"Embedded SQL"** standard (X3.168-1989), addressing government concern that embedding SQL in host languages was only an appendix, not an enforced requirement. ISO didn't bother — no equivalent international pressure at the time.
3. Neither SQL/86 nor SQL/89 defined **ALTER**, **DROP**, or **REVOKE** — you could `CREATE` a table or `GRANT` access, but the standard said nothing about undoing either. Vendors implemented these anyway, just inconsistently.

### SQL/92 — the big one

Published **October 1992** (finished late 1991) by both ANSI (X3.135-1992) and ISO (ISO/IEC 9075:1992). Vastly larger scope than SQL/89: structural ALTER support, string/date/time operations, expanded security.

Defined in **three conformance levels** so vendors could adopt incrementally:

1. **Entry SQL** — close to SQL/89 plus error corrections; easiest to implement, most widely supported first.
2. **Intermediate SQL** — most of the new standard's features; balances "better matches the relational model" against "vendors can realistically build this."
3. **Full SQL** — the entire SQL/92 spec, including the hardest/most demanding features. Not required, so real-world Full SQL compliance lagged for years.

Vendors kept adding their own non-standard **extensions** on top (e.g., extra data types) — useful for differentiation, but it fragments dialects and hurts application portability.

### Other, adjacent standards

1. **X/OPEN** — European vendor group; portable UNIX application environment; SQL support deviates from ANSI/ISO in places.
2. **SAA** (IBM's Systems Application Architecture) — IBM's own attempt to unify SQL across its product line (never fully realized).
3. **FIPS** — SQL became a U.S. Federal Information Processing Standard in 1987 (FIPS PUB 127); U.S. government RDBMS purchases had to conform.
4. **ODBC** — grew out of the SQL Access group's 1992 Call-Level Interface (CLI) spec; Microsoft's **ODBC** (also 1992) became the de facto cross-vendor data-access standard.

## Evolution since SQL/92

1. **1997**: ANSI's X3 renamed to **NCITS** (later **INCITS**); the SQL committee eventually became INCITS DM32.2.
2. Standard split into **12 numbered parts + an addendum** so work could proceed in parallel (dubbed **SQL3**, the third major revision). Two more parts added later.

Key parts still active as of SQL:2016 (this book's baseline):

| Part | Covers |
|---|---|
| 1 - Framework | Shared definitions/terms across all parts |
| 2 - Foundation | The core: DDL + DML syntax and semantics (by far the largest part — 1,707 pages in SQL:2016) |
| 3 - SQL/CLI | Call-Level Interface, corresponds to ODBC |
| 4 - SQL/PSM | Persistent Stored Modules — stored procedures/functions, CALL |
| 9 - SQL/MED | Management of External Data — querying non-SQL data sources |
| 10 - SQL/OLB | Embedding SQL in Java |
| 11 - SQL/Schemata | Information/definition schemas |
| 13 - SQL/JRT | Java routines and types |
| 14 - SQL/XML | XML support, aligned with W3C XQuery |

Named revisions since 92: **SQL:1999, SQL:2003, SQL:2008, SQL:2011, SQL:2016** — each round adding more (window functions, recursive queries, JSON/XML handling, temporal features attempted-then-withdrawn, etc.).

✨ **Side learning**: a `SQL/Temporal` part (support for time-versioned data) was actually withdrawn in 2003 after the committee couldn't agree on the details — a rare case of a standards effort stalling out rather than shipping something imperfect.

## Commercial implementations, in brief

Mainframe era (DB2, Ingres, Oracle since 1979) → PC desktop RDBMS (R:BASE, dBase IV, Super Base in the 1980s, mostly pre-SQL file managers) → **SQL hits the desktop for real with Microsoft Access 1.0 in 1992** → client/server era (SQL Server, Informix-SE, early 1990s) → Internet/e-commerce-driven demand from 2000 onward → cloud databases (Amazon, Microsoft, IBM) — virtually all of which speak SQL.

## Why learn SQL

SQL knowledge transfers across vendors — the dialects differ (think British vs. American spelling), but the core concepts and most syntax carry over directly. Since SQL underpins the query tools/GUIs in most RDBMS products, understanding it also demystifies what those tools are doing under the hood and helps you troubleshoot when the generated query doesn't do what you expected.

## Which version does this book cover?

Grounded in **SQL:2016** (ISO/IEC 9075-2:2016), specifically the **Framework** and **Foundation** parts — the subset implemented broadly across commercial products. Examples and solutions are validated against four concrete systems: Microsoft Access 2016, Microsoft SQL Server 2016, MySQL 5.7, and PostgreSQL 9.6. Where a product deviates from the standard, the book calls it out and offers a portable alternative.

## Summary

- SQL descends from IBM's SEQUEL (1974), itself inspired by the earlier SQUARE research language; renamed SQL for trademark reasons.
- Oracle beat IBM to market with the first commercial RDBMS (1979); IBM's own line (SQL/DS → DB2) and Berkeley's Ingres were the other early major players.
- ANSI/ISO standardization started as a "least common denominator" (SQL/86, SQL/89) and only became genuinely comprehensive with **SQL/92**, which introduced the Entry/Intermediate/Full conformance levels.
- The standard has since split into many numbered parts (Foundation being the core) and gone through SQL:1999 → SQL:2016, adding capability well beyond what SQL/92 covered.
- Vendor extensions add power but fragment portability — a recurring tension throughout SQL's history.
- SQL is worth learning precisely because it's the one skill that transfers across virtually every relational product — this book teaches the SQL:2016 Framework/Foundation core, validated against Access, SQL Server, MySQL, and PostgreSQL.
