# Part 1: Relational Databases and SQL

Before writing a single SELECT, the book makes the case that SQL only makes sense on top of two things: a sound theoretical model (relational), and a sound implementation of that model (your table structures). Get either wrong and later SQL chapters get much harder to apply.

## Chapter 1 — What Is Relational?

Relational == based on Codd's 1969-70 model, itself grounded in set theory (a *relation* is a set-theory term, not a reference to tables relating to each other — common misconception). Covers the vocabulary everything else depends on: tables/rows/columns, primary vs. foreign keys, views as virtual tables, and the three relationship types (one-to-one, one-to-many, many-to-many — the last always needing a linking table).

## Chapter 2 — Ensuring Your Database Structure Is Sound

A lightweight, checklist-driven pass at normalization — not a full design methodology, just enough to avoid the structural mistakes that make SQL painful: multipart columns (values bundling more than one fact), multivalued columns and repeating-group columns (both really disguised many-to-many relationships), missing/unsound primary keys, and relationships missing explicit deletion rules and participation constraints.

## Chapter 3 — A Concise History of SQL

Traces SQL from IBM's SEQUEL (1974) through Oracle's first-to-market RDBMS (1979), the ANSI/ISO standardization effort (SQL/86 → SQL/92 → SQL:2016), and why vendor dialects diverge despite a shared standard. Useful context for why SQL sometimes feels inconsistent across products — it evolved as a negotiated "least common denominator" long before it became the comprehensive language it is today.

## Why it matters

1. The relational model explains *why* SQL's clauses exist in the shapes they do (JOINs mirror relationships; GROUP BY mirrors set-based thinking).
2. A poorly normalized schema turns straightforward questions into contorted, error-prone queries — fixing structure is cheaper before you start writing SQL against it, not after.
3. Knowing SQL's standardization history explains why "the same" query sometimes needs tweaks between Access, SQL Server, MySQL, and PostgreSQL — a running theme for the rest of the book.
