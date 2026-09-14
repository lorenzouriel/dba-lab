# Introduction

"SQL Queries for Mere Mortals" == a practical, vendor-neutral guide to writing SQL. Based on ISO/IEC 9075-2:2016 (SQL/Foundation), not tied to any one product.

## Who this book is for

Anyone who has to use a database system that supports SQL: app users poking at query tools, desktop-database dabblers, programmers solving "outside the box" problems, and gurus migrating data between systems. Beginner-friendly but useful as a reference for complex problems too.

## What it covers (book structure)

1. **Part I - Relational Databases and SQL**: relational model basics, database design soundness, brief history of SQL.
2. **Part II - SQL Basics**: SELECT, expressions, ORDER BY, WHERE.
3. **Part III - Working with Multiple Tables**: INNER/OUTER JOIN, UNION, subqueries.
4. **Part IV - Summarizing and Grouping Data**: GROUP BY, HAVING.
5. **Part V - Modifying Sets of Data**: UPDATE, INSERT, DELETE.
6. **Part VI - Introduction to Solving Tough Problems**: compound conditions, CASE, Cartesian products, subtotals/roll-ups, partitioned results.

Appendices: full SQL syntax diagrams, sample-database schemas, a cross-vendor date/time function reference, further reading.

## What it is NOT

1. Not a full database-design manual — one chapter (Ch. 2) covers only the basics of sound structure.
2. Not a query-optimization guide — multiple solutions to a problem are shown, but "fastest" is left to vendor-specific tuning.
3. Not a complete SQL:2016 reference — the standard is ~5,000 pages; this book teaches the core that's broadly implemented.

## Reading the syntax diagrams

Diagrams are the book's recurring visual language for SQL grammar. Two diagram kinds:

1. **Statement** diagram — a full SQL operation (e.g., SELECT). Main line starts/ends at a statement start/end point.
2. **Defined term** diagram — a reusable grammar piece referenced inside statements (e.g., *value expression*, *search condition*, *predicate*). Starts/ends at a defined-term start/end point.

Diagram element conventions:

1. **Keywords** — CAPS + bold, required as literally shown (SELECT, FROM, WHERE).
2. **Literal entry** — lowercase word/phrase standing in for a value you supply (`table_name`).
3. **Defined term** — italic; a sub-diagram you can expand elsewhere.
4. Main syntax line read left-to-right == required elements. Anything below the line == optional.
5. Sub-optional elements hang below an optional element (fine-tuning within an option).
6. Comma below a line == you may repeat that element, separated by commas.
7. An alternate line bypassing other options == a keyword/term usable instead of them.

✨ **Side learning**: chapter-body diagrams are deliberately simplified versions of the full diagrams collected in Appendix A — same elements, less clutter, so the author can focus discussion on one piece at a time.

## Sample databases used throughout

Nine sample databases ship with the book (in Access, SQL Server, MySQL, and PostgreSQL formats), but five recur constantly in examples:

1. **Sales Orders** — order-entry database for a bicycle/accessories store. The classic order-entry example.
2. **Entertainment Agency** — entertainers, agents, customers, bookings. Same shape you'd use for event bookings or hotel reservations.
3. **School Scheduling** — student registration, class/instructor assignment, grades.
4. **Bowling League** — teams, team members, matches, results.
5. **Recipes** — recipe management (ingredients, steps).

Each ships in two flavors: an "Example" version (read-only, used for SELECT-focused Parts II/III/IV/VI) and a "Modify" version (extra columns/tables, used for Part V's UPDATE/INSERT/DELETE examples).

🤯 A "record" in these databases can be both an object and an event at once — e.g., a sales order is a physical document (object) but also represents a shipment happening at a point in time (event). Worth remembering when classifying subjects for table design in Chapter 2.
