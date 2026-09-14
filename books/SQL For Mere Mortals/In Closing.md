# In Closing

The book's own wrap-up. Short, so the notes here are short too.

## The arc of the book, as the author frames it

1. Simple and complex `SELECT` statements.
2. Working with various data types.
3. Filtering with search conditions.
4. Multi-table queries via `JOIN`.
5. Statistical summaries via grouping.
6. `UPDATE`/`INSERT`/`DELETE` — changing data, not just reading it.
7. "Thinking out of the box": NOT/AND problems, condition testing, unlinked tables, complex grouping, window functions ("windows into your data").

That's the whole book in one paragraph — useful as a self-check: if any of those seven don't ring a bell, that's the part to revisit.

## Where the book deliberately stopped

The author is explicit that this book covers **only the data manipulation portion of SQL** (DML: querying and changing data). Left untouched, on purpose:
1. Creating data structures (DDL — `CREATE TABLE`, etc.).
2. Views, functions, stored procedures.
3. Embedding SQL inside an application program.

Appendix D ("Suggested Reading") is the pointer to where to go for those.

## Parting advice

1. Standard SQL syntax and your actual database's SQL dialect will differ — always check platform docs (this is exactly why Appendix C exists, for one narrow but painful example: dates).
2. If your database has a graphical query builder, it should make a lot more sense now that the underlying SQL is legible.
3. Learning SQL is not a "read once" activity — "there's always more to learn," in the author's words.

✨ **Side learning:** the closing epigraph is a Doris Lessing quote — "That is what learning is. You suddenly understand something you've understood all your life, but in a new way." Not a bad description of how a lot of these SQL concepts land: the syntax was memorized long before the *why* clicked.
