// DP-800 practice quiz questions.
// Auto-assembled from domain drafts; each item's `source` cites the exact
// dp800/ lesson file the answer/explanation comes from.
const QUIZ_QUESTIONS = [
{
  "id": "easy-01",
  "tier": "easy",
  "domain": "Design and develop database solutions",
  "module": "Design and implement database objects with SQL",
  "question": "Which Azure SQL Database service tier removes the practical storage-size limits of a single node, letting storage expand with no predefined maximum size?",
  "options": [
    "Serverless compute tier",
    "Hyperscale service tier",
    "Business Critical tier",
    "General Purpose tier"
  ],
  "correctIndex": 1,
  "explanation": "Hyperscale eliminates the single-node storage ceiling other tiers face, scaling storage automatically with no fixed maximum, while serverless instead focuses on auto-pausing and scaling compute.",
  "source": {
    "path": "dp800/Design and develop database solutions/Design and implement database objects with SQL/02-understand-your-sql-server-based-platform-choices.md",
    "heading": "Develop using Azure SQL Database",
    "quote": "With its flexible storage architecture, storage expands as needed, and there's no predefined maximum size."
  }
},
{
  "id": "easy-02",
  "tier": "easy",
  "domain": "Design and develop database solutions",
  "module": "Design and implement database objects with SQL",
  "question": "How many clustered indexes can a single table have?",
  "options": [
    "Exactly one",
    "Up to four",
    "One per column",
    "Zero — clustered indexes require a separate table"
  ],
  "correctIndex": 0,
  "explanation": "A clustered index determines the physical storage order of the data rows themselves, and since rows can only be physically sorted one way, a table can have only one clustered index.",
  "source": {
    "path": "dp800/Design and develop database solutions/Design and implement database objects with SQL/04-optimize-with-indexes.md",
    "heading": "Use rowstore indexes",
    "quote": "There can be only one clustered index per table, because the data rows themselves can be stored in only one order."
  }
},
{
  "id": "easy-03",
  "tier": "easy",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "What is true about a SQL Server view?",
  "options": [
    "It physically stores a copy of the data at the time it's created",
    "It's a virtual table based on a SELECT statement that retrieves data from underlying tables each time it's queried",
    "It accepts input parameters like a scalar function",
    "It automatically creates a unique index on all of its columns"
  ],
  "correctIndex": 1,
  "explanation": "A view doesn't store data itself; it re-executes its underlying SELECT statement against the base tables every time it's queried, which is why it can't accept parameters the way functions do.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/02-create-views.md",
    "heading": "Understand views in SQL Server",
    "quote": "A view is a virtual table based on a SELECT statement. Unlike physical tables, views don't store data themselves."
  }
},
{
  "id": "easy-04",
  "tier": "easy",
  "domain": "Design and develop database solutions",
  "module": "Write advanced T-SQL code",
  "question": "Which ranking window function assigns a unique sequential number to every row, even when multiple rows share the same ORDER BY value?",
  "options": [
    "RANK()",
    "DENSE_RANK()",
    "ROW_NUMBER()",
    "NTILE()"
  ],
  "correctIndex": 2,
  "explanation": "ROW_NUMBER() always produces distinct sequential numbers with no duplicates, unlike RANK() and DENSE_RANK() which assign the same number to tied rows.",
  "source": {
    "path": "dp800/Design and develop database solutions/Write advanced T-SQL code/03-apply-window-functions-for-analytics.md",
    "heading": "Use ranking functions",
    "quote": "assigns a unique sequential number to each row, with no duplicates even for tied values"
  }
},
{
  "id": "easy-05",
  "tier": "easy",
  "domain": "Design and develop database solutions",
  "module": "Write advanced T-SQL code",
  "question": "Which JSON function is designed to extract a scalar value, such as a string or number, from a JSON document?",
  "options": [
    "JSON_QUERY()",
    "JSON_VALUE()",
    "OPENJSON()",
    "JSON_ARRAYAGG()"
  ],
  "correctIndex": 1,
  "explanation": "JSON_VALUE() returns a single scalar value from a JSON path, whereas JSON_QUERY() is used when you need to preserve a nested object or array structure.",
  "source": {
    "path": "dp800/Design and develop database solutions/Write advanced T-SQL code/04-process-json-data-with-built-in-functions.md",
    "heading": "Extract values with JSON_VALUE and JSON_QUERY",
    "quote": "extracts a scalar value (string, number, boolean) from a JSON string"
  }
},
{
  "id": "easy-06",
  "tier": "easy",
  "domain": "Design and develop database solutions",
  "module": "Implement SQL solutions by using AI-assisted tools",
  "question": "What does the Model Context Protocol (MCP) allow an AI assistant to do?",
  "options": [
    "Automatically encrypt database backups",
    "Connect directly to external data sources so it can query actual schema and data",
    "Replace the need for a database administrator",
    "Convert T-SQL queries into Python code"
  ],
  "correctIndex": 1,
  "explanation": "MCP is a protocol that lets an AI assistant connect to data sources directly, so it can query real schema and metadata rather than relying only on visible editor context.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement SQL solutions by using AI-assisted tools/02-describe-ai-assisted-development-tools.md",
    "heading": "The role of Model Context Protocol (MCP)",
    "quote": "Model Context Protocol (MCP) extends AI assistant capabilities by allowing them to connect directly to your data sources."
  }
},
{
  "id": "easy-07",
  "tier": "easy",
  "domain": "Design and develop database solutions",
  "module": "Implement SQL solutions by using AI-assisted tools",
  "question": "Where should a copilot-instructions.md file be stored so it applies to everyone working in a repository?",
  "options": [
    "Directly in the repository root",
    "In a .github folder at the repository root",
    "In each developer's personal user profile folder",
    "In a .vscode folder named mcp.json"
  ],
  "correctIndex": 1,
  "explanation": "Repository-wide instruction files are placed in the .github folder at the repository root so Copilot applies them for all contributors, unlike prompt files which live in .github/prompts.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement SQL solutions by using AI-assisted tools/06-create-and-configure-github-copilot-instruction-files.md",
    "heading": "What are custom instruction files?",
    "quote": "Apply to everyone working in a specific repository. Stored in the .github folder at the repository root."
  }
},
{
  "id": "medium-01",
  "tier": "medium",
  "domain": "Design and develop database solutions",
  "module": "Design and implement database objects with SQL",
  "question": "A table must support fast single-row lookups for an OLTP application AND fast aggregate queries for reporting, on the same table. Which columnstore index type preserves both capabilities?",
  "options": [
    "Clustered Columnstore Index (CCI)",
    "Nonclustered Columnstore Index (NCCI)",
    "A clustered rowstore index alone",
    "An external table pointing to a data lake copy"
  ],
  "correctIndex": 1,
  "explanation": "An NCCI adds a columnar structure alongside the existing clustered rowstore index, so the table keeps fast transactional access while gaining columnar analytics; a CCI instead replaces the rowstore entirely.",
  "source": {
    "path": "dp800/Design and develop database solutions/Design and implement database objects with SQL/04-optimize-with-indexes.md",
    "heading": "Use Clustered Columnstore Index (CCI)",
    "quote": "an NCCI allows you to maintain rowstore indexes for transactional queries while providing a columnar structure for analytical queries on the same table"
  }
},
{
  "id": "medium-02",
  "tier": "medium",
  "domain": "Design and develop database solutions",
  "module": "Design and implement database objects with SQL",
  "question": "An application needs to reserve a block of several sequential numbers at once, before any rows are inserted. Which feature supports this directly?",
  "options": [
    "An IDENTITY column",
    "A sequence object, using sp_sequence_get_range",
    "A UNIQUE constraint",
    "A persisted computed column"
  ],
  "correctIndex": 1,
  "explanation": "Sequence objects support retrieving several numbers ahead of time via sp_sequence_get_range, something identity columns cannot do since they're only generated at insert time for a single table.",
  "source": {
    "path": "dp800/Design and develop database solutions/Design and implement database objects with SQL/06-enforce-data-integrity-with-constraints.md",
    "heading": "Understand when to use sequences",
    "quote": "Calling sp_sequence_get_range retrieves several numbers in the sequence at once."
  }
},
{
  "id": "medium-03",
  "tier": "medium",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "A view filters to only rows where TotalAmount > 1000 and is defined WITH CHECK OPTION. What happens if a user tries to INSERT a row through this view with TotalAmount = 500?",
  "options": [
    "The insert succeeds and is added to the base table only",
    "The insert is rejected because the new row wouldn't satisfy the view's WHERE condition",
    "The insert succeeds but TotalAmount is silently changed to 1000",
    "The view is automatically dropped"
  ],
  "correctIndex": 1,
  "explanation": "WITH CHECK OPTION enforces that any INSERT or UPDATE performed through the view must still satisfy the view's WHERE clause, so a row that wouldn't appear in the view is rejected.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/02-create-views.md",
    "heading": "Apply design considerations",
    "quote": "The database rejects the operation because the new row wouldn't meet the view's WHERE condition."
  }
},
{
  "id": "medium-04",
  "tier": "medium",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "A team needs a reusable calculation for shipping cost that must be embedded directly inside a SELECT statement's column list. Which programmability object best fits this need?",
  "options": [
    "A stored procedure",
    "A DML trigger",
    "A scalar function",
    "A DDL trigger"
  ],
  "correctIndex": 2,
  "explanation": "Scalar functions return a single value and can be called directly inside SELECT, WHERE, or JOIN expressions, while stored procedures cannot be embedded in a SELECT column list this way.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/07-choose-when-to-use-each-option.md",
    "heading": "Apply decision scenarios",
    "quote": "Calculate shipping cost based on weight and destination | Scalar function | Reusable calculation in queries"
  }
},
{
  "id": "medium-05",
  "tier": "medium",
  "domain": "Design and develop database solutions",
  "module": "Write advanced T-SQL code",
  "question": "A recursive CTE used to traverse an employee-manager hierarchy is built from two parts. What does the anchor member do?",
  "options": [
    "It sets the maximum recursion depth allowed for the query",
    "It provides the initial starting result set for the recursion",
    "It performs a final aggregation once recursion completes",
    "It joins the CTE to itself to build each subsequent level"
  ],
  "correctIndex": 1,
  "explanation": "The anchor member supplies the starting rows for the recursion, while the recursive member (which joins back to the CTE) builds each subsequent level from there.",
  "source": {
    "path": "dp800/Design and develop database solutions/Write advanced T-SQL code/02-organize-queries-with-common-table-expressions.md",
    "heading": "Create recursive CTEs",
    "quote": "an anchor member that provides the initial result set, and a recursive member that references the CTE to build upon previous results"
  }
},
{
  "id": "medium-06",
  "tier": "medium",
  "domain": "Design and develop database solutions",
  "module": "Write advanced T-SQL code",
  "question": "Why is EXISTS with a correlated subquery generally more efficient than an IN subquery for checking existence in a large table?",
  "options": [
    "EXISTS always builds a temporary index before evaluating any rows",
    "The engine can stop as soon as it finds the first matching row with EXISTS, while IN may need to retrieve all matching values",
    "EXISTS doesn't support correlated subqueries, so it only runs once total",
    "IN automatically creates a covering index while EXISTS does not"
  ],
  "correctIndex": 1,
  "explanation": "EXISTS only needs to confirm that at least one matching row is present and can short-circuit on the first hit, whereas IN may need the full set of matching values from the subquery.",
  "source": {
    "path": "dp800/Design and develop database solutions/Write advanced T-SQL code/08-compare-rows-with-correlated-subqueries.md",
    "heading": "Use EXISTS with correlated subqueries",
    "quote": "The optimizer can stop after finding the first match with EXISTS, while IN may need to retrieve all matching values."
  }
},
{
  "id": "medium-07",
  "tier": "medium",
  "domain": "Design and develop database solutions",
  "module": "Implement SQL solutions by using AI-assisted tools",
  "question": "When you use GitHub Copilot or Fabric Copilot, what happens to the prompts and code context you provide?",
  "options": [
    "They're permanently stored and used to retrain the underlying AI models",
    "They're sent to cloud-based AI models for processing, but aren't used to train the underlying models",
    "They're processed only locally and never leave your machine",
    "They're discarded immediately and never reach any AI model"
  ],
  "correctIndex": 1,
  "explanation": "Copilot processing happens in the cloud, but the documented data-handling practice is that prompts and responses aren't used to train the underlying models, and data is encrypted in transit and at rest.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement SQL solutions by using AI-assisted tools/03-interpret-security-impact-of-using-ai-assisted-tools.md",
    "heading": "How AI assistants process your data",
    "quote": "Prompts and responses are not used to train the underlying AI models, and data is encrypted in transit and at rest."
  }
},
{
  "id": "hard-01",
  "tier": "hard",
  "domain": "Design and develop database solutions",
  "module": "Design and implement database objects with SQL",
  "question": "Which limitation applies specifically to memory-optimized (in-memory) tables in SQL Server?",
  "options": [
    "They cannot have a primary key defined",
    "They don't support large object types such as VARCHAR(MAX), NVARCHAR(MAX), or VARBINARY(MAX)",
    "They can never be recovered after a server restart",
    "They require a nonclustered columnstore index to function"
  ],
  "correctIndex": 1,
  "explanation": "In-memory optimized tables specifically can't use LOB types like VARCHAR(MAX); they still write to the transaction log for durability, so committed data does survive a restart.",
  "source": {
    "path": "dp800/Design and develop database solutions/Design and implement database objects with SQL/05-use-specialized-table-types.md",
    "heading": "Consider trade-offs",
    "quote": "these tables don't support large object types like VARCHAR(MAX), NVARCHAR(MAX), or VARBINARY(MAX)"
  }
},
{
  "id": "hard-02",
  "tier": "hard",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "Why do multi-statement table-valued functions often produce less accurate query plans than inline table-valued functions?",
  "options": [
    "Multi-statement TVFs require a RETURNS TABLE clause that disables statistics collection",
    "The optimizer treats multi-statement TVFs as black boxes it can't see inside, leading to inaccurate row estimates",
    "Multi-statement TVFs can only ever return a single row",
    "Inline TVFs cache plans, but multi-statement TVFs cannot be called from a SELECT statement at all"
  ],
  "correctIndex": 1,
  "explanation": "The optimizer expands inline TVFs directly into the query plan, but it can't see inside multi-statement TVFs (or scalar functions), so it treats them as black boxes and often produces inaccurate row estimates.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/07-choose-when-to-use-each-option.md",
    "heading": "Compare options",
    "quote": "treated as \"black boxes\"—the optimizer can't see inside them, which often leads to inaccurate row estimates and suboptimal plans."
  }
},
{
  "id": "hard-03",
  "tier": "hard",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "During an UPDATE statement that fires a DML trigger, which statement about the inserted and deleted pseudo-tables is correct?",
  "options": [
    "Only inserted is populated; deleted stays empty for updates",
    "Only deleted is populated; inserted stays empty for updates",
    "Both tables are populated: deleted holds the old values and inserted holds the new values",
    "Neither table is populated until the transaction commits"
  ],
  "correctIndex": 2,
  "explanation": "For UPDATE operations, SQL Server populates both pseudo-tables simultaneously: deleted contains the pre-update row values and inserted contains the post-update values, letting triggers compare old vs. new.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/06-create-triggers.md",
    "heading": "Create DML triggers for data modifications",
    "quote": "UPDATE operations populate both tables with old values in deleted and new values in inserted."
  }
},
{
  "id": "hard-04",
  "tier": "hard",
  "domain": "Design and develop database solutions",
  "module": "Write advanced T-SQL code",
  "question": "What is the correct parameter order for the REGEXP_SUBSTR function signature in T-SQL?",
  "options": [
    "REGEXP_SUBSTR(source, pattern, start_position, occurrence, flags, capture_group)",
    "REGEXP_SUBSTR(pattern, source, occurrence, start_position, capture_group, flags)",
    "REGEXP_SUBSTR(source, pattern, capture_group, flags, occurrence, start_position)",
    "REGEXP_SUBSTR(source, occurrence, pattern, start_position, flags, capture_group)"
  ],
  "correctIndex": 0,
  "explanation": "REGEXP_SUBSTR takes the source string and pattern first, followed by start_position, occurrence, flags, and finally capture_group, in that exact order.",
  "source": {
    "path": "dp800/Design and develop database solutions/Write advanced T-SQL code/05-match-patterns-with-regular-expressions.md",
    "heading": "Extract substrings with REGEXP_SUBSTR",
    "quote": "REGEXP_SUBSTR(source, pattern, start_position, occurrence, flags, capture_group)"
  }
},
{
  "id": "hard-05",
  "tier": "hard",
  "domain": "Design and develop database solutions",
  "module": "Write advanced T-SQL code",
  "question": "Which category of error can a TRY...CATCH block NOT catch within the same session?",
  "options": [
    "Constraint violations such as duplicate key errors",
    "Division-by-zero errors",
    "Compilation errors and errors with severity 20 or higher that close the connection",
    "Custom errors raised with THROW at severity 16"
  ],
  "correctIndex": 2,
  "explanation": "TRY...CATCH is documented as unable to catch compilation errors (like syntax errors or missing objects) or severity-20-plus errors that terminate the connection; ordinary runtime errors like divide-by-zero or constraint violations are caught normally.",
  "source": {
    "path": "dp800/Design and develop database solutions/Write advanced T-SQL code/09-handle-errors-with-try-catch.md",
    "heading": "Implement T-SQL error handling",
    "quote": "Compilation errors (syntax errors, missing objects) and errors with severity 20 or higher that close the connection can't be caught within the same session."
  }
},
{
  "id": "hard-06",
  "tier": "hard",
  "domain": "Design and develop database solutions",
  "module": "Write advanced T-SQL code",
  "question": "A MATCH pattern needs to traverse the same KNOWS edge table twice in one query, to find friends-of-friends. What must the query do to make this valid?",
  "options": [
    "Use two separate aliases for the edge table, since each edge alias can appear only once per MATCH pattern",
    "Wrap the query in a CTE, since edges can never be reused within MATCH",
    "Add the FOR PATH keyword so the same alias can repeat",
    "Use SHORTEST_PATH instead, since a plain MATCH clause can't do multi-hop traversal at all"
  ],
  "correctIndex": 0,
  "explanation": "SQL Graph requires a distinct alias for every appearance of an edge table within a single MATCH pattern, so traversing the same relationship type twice means using two separate aliases like k1 and k2.",
  "source": {
    "path": "dp800/Design and develop database solutions/Write advanced T-SQL code/07-traverse-relationships-with-graph-queries.md",
    "heading": "Traverse multiple relationships",
    "quote": "Each edge table alias can only appear once in a single MATCH pattern. To traverse the same edge type multiple times, use separate aliases."
  }
},
{
  "id": "hard-07",
  "tier": "hard",
  "domain": "Design and develop database solutions",
  "module": "Implement SQL solutions by using AI-assisted tools",
  "question": "When configuring authentication for an MCP server that only needs to expose schema information to an AI assistant, what is the recommended practice?",
  "options": [
    "Use the database owner (dbo) account for simplicity",
    "Create dedicated service accounts with read-only access, following least privilege",
    "Disable authentication entirely, since only schema is exposed",
    "Grant the AI assistant sysadmin rights so it can always see everything it needs"
  ],
  "correctIndex": 1,
  "explanation": "The recommended security practice is least-privilege access: a dedicated, read-only service account when the AI assistant only needs schema information, not broad administrative rights.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement SQL solutions by using AI-assisted tools/03-interpret-security-impact-of-using-ai-assisted-tools.md",
    "heading": "MCP server security considerations",
    "quote": "Create dedicated service accounts with read-only access when the AI only needs to query schema information."
  }
},
{
  "id": "hard-08",
  "tier": "hard",
  "domain": "Design and develop database solutions",
  "module": "Implement SQL solutions by using AI-assisted tools",
  "question": "What is a minimum licensing prerequisite for enabling Fabric Copilot, according to the setup guidance?",
  "options": [
    "Any free Power BI account",
    "A Microsoft Fabric capacity of F2 or higher, or Power BI Premium capacity of P1 or higher",
    "A GitHub Enterprise Cloud subscription",
    "SQL Server Management Studio 22 or later"
  ],
  "correctIndex": 1,
  "explanation": "Fabric Copilot requires at least an F2 Fabric capacity or a P1 Power BI Premium capacity, plus tenant-level enablement by an administrator; GitHub Enterprise Cloud and SSMS 22 relate to GitHub Copilot, not Fabric Copilot.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement SQL solutions by using AI-assisted tools/04-enable-github-copilot-and-fabric-copilot.md",
    "heading": "Prerequisites for AI assisted tools",
    "quote": "A Microsoft Fabric capacity (F2 or higher) or Power BI Premium capacity (P1 or higher)"
  }
},
{
  "id": "usecase-01",
  "tier": "usecase",
  "domain": "Design and develop database solutions",
  "module": "Design and implement database objects with SQL",
  "question": "A financial services firm must give external auditors cryptographic proof that transaction records were never altered after being posted, and the records must never be updatable — only appended. Which table type should the firm use?",
  "options": [
    "A temporal table",
    "An append-only ledger table",
    "An in-memory optimized table",
    "An external table"
  ],
  "correctIndex": 1,
  "explanation": "Append-only ledger tables allow only INSERT operations, creating truly immutable, cryptographically verifiable records, which fits the requirement for records that can never be updated and must be provably tamper-evident.",
  "source": {
    "path": "dp800/Design and develop database solutions/Design and implement database objects with SQL/05-use-specialized-table-types.md",
    "heading": "Choose between updatable and append-only ledgers",
    "quote": "Append-only ledger tables only allow INSERT operations, creating truly immutable records for scenarios requiring absolute data integrity."
  }
},
{
  "id": "usecase-02",
  "tier": "usecase",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "An application must validate stock levels, insert a new order row, and update inventory counts, all as a single all-or-nothing operation with full transaction control. Which programmability object should the team implement?",
  "options": [
    "A view with WITH CHECK OPTION",
    "A scalar function",
    "A stored procedure",
    "An AFTER trigger defined on the Orders table"
  ],
  "correctIndex": 2,
  "explanation": "Stored procedures support multiple statements, explicit transaction control, and modifications across multiple tables in one unit of work, which is exactly what this multi-step order-processing scenario needs.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/07-choose-when-to-use-each-option.md",
    "heading": "Apply decision scenarios",
    "quote": "Process an order: validate stock, insert order, update inventory | Stored procedure | Multiple modifications in a transaction"
  }
},
{
  "id": "usecase-03",
  "tier": "usecase",
  "domain": "Design and develop database solutions",
  "module": "Write advanced T-SQL code",
  "question": "A retail company wants to find likely duplicate customer records where names are misspelled or entered inconsistently, across a table with 5 million rows. To keep the fuzzy comparison fast, what should they do first?",
  "options": [
    "Run EDIT_DISTANCE_SIMILARITY across the entire table with no other filters",
    "Pre-filter candidates using indexed exact-match or LIKE conditions before applying fuzzy matching functions",
    "Replace fuzzy matching entirely with a CHECK constraint",
    "Convert the table into a graph node table before comparing names"
  ],
  "correctIndex": 1,
  "explanation": "Because fuzzy functions are computationally expensive, the recommended approach is to narrow the candidate set first with cheap, indexed filters like LIKE or exact matches, then apply fuzzy matching only to that smaller set.",
  "source": {
    "path": "dp800/Design and develop database solutions/Write advanced T-SQL code/06-find-approximate-matches-with-fuzzy-string-functions.md",
    "heading": "Performance considerations",
    "quote": "The key to efficient fuzzy matching is reducing the candidate set before applying the expensive fuzzy functions."
  }
},
{
  "id": "usecase-04",
  "tier": "usecase",
  "domain": "Design and develop database solutions",
  "module": "Implement SQL solutions by using AI-assisted tools",
  "question": "A development team finds that Copilot's SQL suggestions are based only on code visible in open editor tabs and sometimes reference outdated column names. They want the assistant to consult the live database schema during chat sessions. What should they configure?",
  "options": [
    "A copilot-instructions.md file with the current schema pasted into it",
    "An MCP server connection so the assistant can query the actual database schema in real time",
    "Only a more advanced chat model, without any other changes",
    "A DDL trigger that logs schema changes to an audit table"
  ],
  "correctIndex": 1,
  "explanation": "MCP lets the assistant query the live database directly rather than relying solely on whatever code is open in the editor, which solves the stale-schema problem the team is running into.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement SQL solutions by using AI-assisted tools/05-configure-model-and-mcp-tool-options.md",
    "heading": "What is Model Context Protocol (MCP)?",
    "quote": "the assistant can query your database directly rather than relying on whatever code context is visible in your editor"
  }
},
{
  "id": "easy-08",
  "tier": "easy",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement RAG with SQL",
  "question": "In the SQL-based RAG pattern described in the lesson, what happens during the augmentation step?",
  "options": [
    "Retrieved database data is added to the prompt as context for the model",
    "The language model is retrained on the retrieved data",
    "Embeddings are generated and stored in a vector column",
    "The model's response is parsed and returned to the caller"
  ],
  "correctIndex": 0,
  "explanation": "Augmentation is the middle step of RAG: retrieved data is added to the prompt as context so the model can ground its answer, rather than retraining the model or parsing its response.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement RAG with SQL/02-identify-rag-use-cases-architecture.md",
    "heading": "Understand how RAG works",
    "quote": "Second, augment the prompt by adding that data as context. The model receives both the question and the information to answer it."
  }
},
{
  "id": "easy-09",
  "tier": "easy",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement RAG with SQL",
  "question": "Which FOR JSON option removes the surrounding square brackets when a query returns a single record?",
  "options": [
    "WITHOUT_ARRAY_WRAPPER",
    "INCLUDE_NULL_VALUES",
    "ROOT('name')",
    "FOR JSON AUTO"
  ],
  "correctIndex": 0,
  "explanation": "WITHOUT_ARRAY_WRAPPER strips the array brackets for single-record results, which is common in RAG scenarios retrieving one customer or order; the other options control null handling, root wrapping, or automatic field naming instead.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement RAG with SQL/03-prepare-retrieval-context-augmentation.md",
    "heading": "Control JSON output options",
    "quote": "`WITHOUT_ARRAY_WRAPPER` removes the square brackets when you're retrieving a single record."
  }
},
{
  "id": "medium-08",
  "tier": "medium",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement RAG with SQL",
  "question": "Why does the lesson recommend RAG over fine-tuning for a product catalog that changes daily?",
  "options": [
    "RAG retrieves current data on every request, while a fine-tuned model's knowledge is frozen at training time",
    "RAG is always cheaper to run per request than a fine-tuned model",
    "Fine-tuning cannot be used with SQL Server or Azure SQL Database",
    "RAG eliminates the need to design a database schema"
  ],
  "correctIndex": 0,
  "explanation": "Because RAG retrieves data at query time, it automatically reflects the latest inventory, whereas a fine-tuned model would need retraining to learn about changes and can't keep pace with daily updates.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement RAG with SQL/02-identify-rag-use-cases-architecture.md",
    "heading": "Recognize when RAG fits your scenario",
    "quote": "Fine-tuned models can't keep pace with daily inventory updates, but RAG retrieves current data every time."
  }
},
{
  "id": "medium-09",
  "tier": "medium",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement RAG with SQL",
  "question": "When retrieval context spans multiple related tables, such as products, categories, and models, what pattern does the lesson use to build that context for RAG?",
  "options": [
    "Run vector search to rank matching products, then INNER JOIN the related tables and format the combined result as JSON",
    "Run a separate full-text search for each table and email the results to the model",
    "Use FREETEXTTABLE to join the tables directly without a vector search",
    "Store every table's data as a single unindexed BLOB for the model to parse"
  ],
  "correctIndex": 0,
  "explanation": "The example ranks products by vector distance, joins subcategory, category, and model tables for supporting detail, and wraps the combined result with FOR JSON, giving the model one structured JSON context object.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement RAG with SQL/03-prepare-retrieval-context-augmentation.md",
    "heading": "Combine multiple sources",
    "quote": "You might start by finding relevant products with vector search, then join other tables to build out the full picture."
  }
},
{
  "id": "hard-09",
  "tier": "hard",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement RAG with SQL",
  "question": "In a stored procedure that calls sp_invoke_external_rest_endpoint, which return value indicates the Azure OpenAI endpoint is throttling the request?",
  "options": [
    "0",
    "429",
    "200",
    "NULL"
  ],
  "correctIndex": 1,
  "explanation": "sp_invoke_external_rest_endpoint returns 0 on success and the actual HTTP status code otherwise; a 429 specifically signals rate limiting, distinct from 401/403 credential errors.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement RAG with SQL/05-generate-process-rag-responses.md",
    "heading": "Manage errors and retries",
    "quote": "a 429 status means the service is throttling your requests."
  }
},
{
  "id": "usecase-05",
  "tier": "usecase",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement RAG with SQL",
  "question": "A financial services company wants an internal chatbot to answer questions using proprietary account policy documents, but compliance requires that this sensitive data never be sent to a third party for model training. Which approach best fits this requirement?",
  "options": [
    "RAG, since it keeps data in the database and sends only per-request context to the model",
    "Fine-tuning, since it permanently embeds the data into the model weights",
    "Send the full document set to the model provider once for training, then query the fine-tuned model",
    "Avoid using an LLM entirely and rely solely on manual document lookup"
  ],
  "correctIndex": 0,
  "explanation": "RAG retrieves and sends only the context needed for each request while keeping source data in the database, giving a cleaner separation for sensitive data compared to fine-tuning, which requires sending data to the provider for training.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement RAG with SQL/02-identify-rag-use-cases-architecture.md",
    "heading": "Recognize when RAG fits your scenario",
    "quote": "For sensitive customer data or proprietary knowledge, RAG provides a cleaner separation."
  }
},
{
  "id": "easy-10",
  "tier": "easy",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement intelligent search with SQL",
  "question": "What is the maximum number of dimensions supported by the vector data type in SQL Server and Azure SQL Database?",
  "options": [
    "768",
    "1,536",
    "1,998",
    "4,096"
  ],
  "correctIndex": 2,
  "explanation": "The lesson states the maximum supported vector size is 1,998 dimensions, well above the 1,536 dimensions produced by the OpenAI text-embedding-3-small model used in the examples.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement intelligent search with SQL/04-prepare-sql-vector-search.md",
    "heading": "Store vectors with the vector data type",
    "quote": "The maximum supported is 1,998 dimensions."
  }
},
{
  "id": "easy-11",
  "tier": "easy",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement intelligent search with SQL",
  "question": "In the Reciprocal Rank Fusion formula 1/(k + rank), what value does the lesson use for the constant k?",
  "options": [
    "1",
    "10",
    "60",
    "100"
  ],
  "correctIndex": 2,
  "explanation": "The lesson uses k = 60, the value established by the original RRF research and used by Azure AI Search, which prevents top-ranked items from dominating the combined score.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement intelligent search with SQL/06-implement-hybrid-search-ranking.md",
    "heading": "Merge results with Reciprocal Rank Fusion",
    "quote": "The constant `k` (typically 60) prevents high-ranked items from dominating."
  }
},
{
  "id": "medium-10",
  "tier": "medium",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement intelligent search with SQL",
  "question": "A catalog search only needs to return items that closely match the customer's typed words, even if that means missing some conceptually related products. Based on the precision/recall trade-off in the lesson, which approach should it lean toward?",
  "options": [
    "Full-text search",
    "Vector search",
    "Hybrid search with equal weighting",
    "The LIKE operator with wildcard matching"
  ],
  "correctIndex": 0,
  "explanation": "The lesson states that applications needing exact matches should lean toward full-text search, since it returns fewer but more precise results, while vector search favors recall and discovery.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement intelligent search with SQL/02-choose-intelligent-search-approach.md",
    "heading": "Evaluate the trade-offs",
    "quote": "If your application needs exact matches, lean toward full-text. If it needs discovery, lean toward vector search."
  }
},
{
  "id": "medium-11",
  "tier": "medium",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement intelligent search with SQL",
  "question": "A documentation search must match the exact phrase 'mountain bike' and exclude rows where 'mountain' and 'bike' merely both appear somewhere in the text. Which full-text search technique satisfies this?",
  "options": [
    "Phrase search using quoted text inside CONTAINS",
    "FREETEXT search",
    "Inflectional search using FORMSOF(INFLECTIONAL, ...)",
    "Prefix search using a wildcard"
  ],
  "correctIndex": 0,
  "explanation": "Phrase search, done by wrapping the search text in quotes inside CONTAINS, matches only that exact word sequence, unlike FREETEXT or inflectional search, which also match related word forms scattered across the text.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement intelligent search with SQL/03-implement-full-text-search.md",
    "heading": "Common query patterns",
    "quote": "matches only that exact phrase, not rows where \"mountain\" and \"bike\" appear separately."
  }
},
{
  "id": "hard-10",
  "tier": "hard",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement intelligent search with SQL",
  "question": "When VECTOR_SEARCH is combined with a WHERE clause that filters on a non-key column, at what point is that filter applied relative to the nearest-neighbor search?",
  "options": [
    "After VECTOR_SEARCH finds the nearest neighbors, so filtered-out rows can shrink the final result count",
    "Before VECTOR_SEARCH runs, so it only ever scans matching rows",
    "Simultaneously, guaranteeing the requested TOP_N always matches the filter",
    "SQL Server automatically rewrites the query to filter first"
  ],
  "correctIndex": 0,
  "explanation": "The lesson explicitly warns that VECTOR_SEARCH applies WHERE conditions after finding nearest neighbors, so if none of the top candidates satisfy the filter you get fewer results than requested unless you request more candidates.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement intelligent search with SQL/05-implement-vector-search-query-patterns.md",
    "heading": "Handle post-filtering carefully",
    "quote": "`VECTOR_SEARCH` applies any WHERE clause conditions *after* finding the nearest neighbors, not before."
  }
},
{
  "id": "hard-11",
  "tier": "hard",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement intelligent search with SQL",
  "question": "Which requirement must a table satisfy before you can create a vector index on it in SQL Server?",
  "options": [
    "It must have a single-column integer primary key with a clustered index",
    "It must be partitioned by the vector column",
    "It must already have a full-text index defined",
    "It must use a computed column to store the vector"
  ],
  "correctIndex": 0,
  "explanation": "Vector indexes require a single-column integer primary key with a clustered index; tables also become read-only while the index exists and cannot be partitioned.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement intelligent search with SQL/04-prepare-sql-vector-search.md",
    "heading": "Consider index limitations",
    "quote": "The table must have a single-column integer primary key with a clustered index"
  }
},
{
  "id": "usecase-06",
  "tier": "usecase",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement intelligent search with SQL",
  "question": "A hardware store's search box sometimes receives exact model numbers like 'XR-500' and other times receives descriptive phrases like 'something to keep drinks cold on a hike.' Which search approach should the team implement to handle both patterns well?",
  "options": [
    "Hybrid search combining full-text and vector search",
    "Full-text search only",
    "Vector search only",
    "The LIKE operator with wildcard matching"
  ],
  "correctIndex": 0,
  "explanation": "Hybrid search runs full-text and vector search together and merges the results, so exact-term queries like model numbers and descriptive, concept-based queries are both handled well, unlike either technique alone.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement intelligent search with SQL/02-choose-intelligent-search-approach.md",
    "heading": "Combine approaches with hybrid search",
    "quote": "Hybrid search solves this issue by running both approaches and merging the results."
  }
},
{
  "id": "easy-12",
  "tier": "easy",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement models and embeddings with SQL",
  "question": "Which permission must be granted to a user or role before it can call an external AI endpoint from T-SQL?",
  "options": [
    "EXECUTE ANY EXTERNAL ENDPOINT",
    "CONTROL SERVER",
    "ALTER ANY EXTERNAL MODEL",
    "VIEW DATABASE STATE"
  ],
  "correctIndex": 0,
  "explanation": "The lesson specifies granting EXECUTE ANY EXTERNAL ENDPOINT to any user or role that needs to call external endpoints, separate from broader server or database administrative permissions.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement models and embeddings with SQL/03-create-manage-external-model-sql.md",
    "heading": "Use external models with AI functions",
    "quote": "Grant the `EXECUTE ANY EXTERNAL ENDPOINT` permission to users or roles that need to call external endpoints"
  }
},
{
  "id": "medium-12",
  "tier": "medium",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement models and embeddings with SQL",
  "question": "Why can chunking a long product description into one very large chunk before generating its embedding hurt search quality?",
  "options": [
    "It may exceed the model's token limits or dilute the semantic focus of the resulting embedding",
    "It always causes the embedding model to reject the request outright",
    "It forces the embedding to use Euclidean distance instead of cosine distance",
    "It automatically disables the vector index on that column"
  ],
  "correctIndex": 0,
  "explanation": "The lesson notes that oversized chunks can exceed token limits or blend multiple ideas together, diluting the semantic focus that makes embeddings useful for similarity search.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement models and embeddings with SQL/04-design-embeddings-sql-database-workloads.md",
    "heading": "Design chunking strategies",
    "quote": "Chunks that are too large may exceed token limits or dilute semantic focus."
  }
},
{
  "id": "medium-13",
  "tier": "medium",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement models and embeddings with SQL",
  "question": "A team wants embeddings refreshed on a schedule, in batches, based on which rows changed since a checkpoint, without adding overhead to every insert or update statement. Which embedding maintenance method fits best?",
  "options": [
    "Change Tracking",
    "Table triggers",
    "Change Data Capture",
    "Change Event Streaming"
  ],
  "correctIndex": 0,
  "explanation": "Change Tracking records that a row changed since a given point in time so a background process can batch-refresh embeddings later, balancing latency and performance, whereas triggers add work directly to each write.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement models and embeddings with SQL/05-generate-maintain-embeddings-sql-database-workloads.md",
    "heading": "Choose an embedding maintenance method",
    "quote": "process them in batches. This approach balances latency and performance."
  }
},
{
  "id": "hard-12",
  "tier": "hard",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement models and embeddings with SQL",
  "question": "Which CREATE EXTERNAL MODEL parameter is used to specify the number of dimensions an embeddings deployment should return?",
  "options": [
    "PARAMETERS",
    "MODEL_TYPE",
    "API_FORMAT",
    "CREDENTIAL"
  ],
  "correctIndex": 0,
  "explanation": "The PARAMETERS clause carries deployment-specific settings such as '{\"dimensions\":<n>}', while MODEL_TYPE just marks the model as an embeddings model, API_FORMAT names the API shape, and CREDENTIAL references the scoped credential.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement models and embeddings with SQL/03-create-manage-external-model-sql.md",
    "heading": "Use external models with AI functions",
    "quote": "PARAMETERS = '{\"dimensions\":<n>}'"
  }
},
{
  "id": "hard-13",
  "tier": "hard",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement models and embeddings with SQL",
  "question": "In the function call AI_GENERATE_CHUNKS(SOURCE = description, CHUNK_TYPE = FIXED, CHUNK_SIZE = 500), what does the CHUNK_SIZE argument control?",
  "options": [
    "The maximum size of each generated chunk, in this case up to 500 characters",
    "The number of chunks returned per source row",
    "The vector dimensionality of the resulting embeddings",
    "The number of rows processed per batch"
  ],
  "correctIndex": 0,
  "explanation": "CHUNK_SIZE sets the maximum size of each chunk produced from the source column; with CHUNK_TYPE = FIXED and CHUNK_SIZE = 500, the function splits description text into chunks of up to 500 characters.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement models and embeddings with SQL/04-design-embeddings-sql-database-workloads.md",
    "heading": "Design chunking strategies",
    "quote": "AI_GENERATE_CHUNKS(SOURCE = description, CHUNK_TYPE = FIXED, CHUNK_SIZE = 500)"
  }
},
{
  "id": "usecase-07",
  "tier": "usecase",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement models and embeddings with SQL",
  "question": "A team is choosing between two candidate LLMs to power a RAG pipeline that must return answers as JSON so T-SQL can parse specific fields without extra text processing. Which model characteristic should weigh most heavily in their evaluation?",
  "options": [
    "Structured output support",
    "Number of supported languages",
    "Maximum training data cutoff date",
    "Model's marketing name recognition"
  ],
  "correctIndex": 0,
  "explanation": "The lesson highlights structured output as a key characteristic for SQL-based workloads: models that can reliably produce JSON are easier to integrate into workflows where responses must be processed programmatically.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement models and embeddings with SQL/02-understand-evaluate-models-sql-database-workloads.md",
    "heading": "Identify model characteristics for SQL database workloads",
    "quote": "Models that can produce structured output, such as JSON, are easier to integrate into SQL-based workflows where responses must be processed programmatically."
  }
},
{
  "id": "easy-13",
  "tier": "easy",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement CI CD by using SQL database projects",
  "question": "When you build a SQL database project, what artifact does the build process produce?",
  "options": [
    "A .dacpac file, a compiled model of the entire database schema",
    "A .bak backup file of the target database",
    "A sequential T-SQL migration script",
    "A .sqlproj file containing the project settings"
  ],
  "correctIndex": 0,
  "explanation": "The build compiles every declared object into a single .dacpac artifact, which SqlPackage later uses to deploy or update a database; a .bak file and migration scripts are not what a project build generates.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement CI CD by using SQL database projects/02-create-build-validate-sql-database-projects.md",
    "heading": "Understand SQL database projects",
    "quote": "the output is a `.dacpac` file, a compiled model of your entire database schema."
  }
},
{
  "id": "easy-14",
  "tier": "easy",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement CI CD by using SQL database projects",
  "question": "In a SQL database project, when does a pre-deployment script execute relative to the deployment plan?",
  "options": [
    "After the deployment plan completes",
    "Before the deployment plan runs",
    "Only the first time the database is created",
    "In parallel with the build validation step"
  ],
  "correctIndex": 1,
  "explanation": "A pre-deployment script runs before the deployment plan so tasks like dropping constraints or migrating data can complete first, whereas post-deployment scripts run after the plan completes.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement CI CD by using SQL database projects/03-configure-source-control-manage-reference-data.md",
    "heading": "Manage reference data with predeployment and post-deployment scripts",
    "quote": "A **pre-deployment script** runs before the deployment plan. Use it for tasks that must complete before schema changes"
  }
},
{
  "id": "easy-15",
  "tier": "easy",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement data security and compliance with SQL",
  "question": "Which encryption technology protects the database files, transaction logs, and backups at rest without requiring any application code changes?",
  "options": [
    "Always Encrypted",
    "Column-level encryption with ENCRYPTBYKEY",
    "Transparent Data Encryption (TDE)",
    "Dynamic Data Masking"
  ],
  "correctIndex": 2,
  "explanation": "TDE encrypts data files, logs, and backups transparently, with no code changes needed, while Always Encrypted and column-level encryption require application or T-SQL changes and Dynamic Data Masking only obfuscates query output.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement data security and compliance with SQL/02-design-implement-data-encryption.md",
    "heading": "Understand encryption layers",
    "quote": "When you enable TDE, SQL Server automatically encrypts database files, transaction logs, and backups."
  }
},
{
  "id": "easy-16",
  "tier": "easy",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement data security and compliance with SQL",
  "question": "Which Dynamic Data Masking function replaces an entire column value with a fixed string such as \"XXXX\"?",
  "options": [
    "partial()",
    "random()",
    "default()",
    "email()"
  ],
  "correctIndex": 2,
  "explanation": "The default() function performs complete obfuscation, showing a fixed placeholder string for text columns, whereas partial(), random(), and email() preserve some structure or realistic-looking values.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement data security and compliance with SQL/03-design-implement-dynamic-data-masking.md",
    "heading": "Understand masking functions",
    "quote": "The **default** function replaces the entire value with a fixed string. For strings, you see *\"XXXX\"* (or fewer X characters for shorter columns)."
  }
},
{
  "id": "easy-17",
  "tier": "easy",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Integrate SQL solutions with Azure services",
  "question": "In a Data API Builder configuration file, what should you use to reference a database connection string so it isn't hardcoded into source control?",
  "options": [
    "A base64-encoded literal in the data-source section",
    "The @env() syntax referencing an environment variable",
    "A SQLCMD variable declared in the .sqlproj file",
    "A plain comment marking the value as sensitive"
  ],
  "correctIndex": 1,
  "explanation": "DAB configuration files use @env() to pull the connection string from an environment variable at runtime, keeping credentials out of the JSON file and source control.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Integrate SQL solutions with Azure services/02-create-configuration-files-data-api-builder.md",
    "heading": "Configure the data source connection",
    "quote": "Use the `@env()` syntax instead to reference environment variables. This keeps credentials out of your configuration files and source control."
  }
},
{
  "id": "easy-18",
  "tier": "easy",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Integrate SQL solutions with Azure services",
  "question": "In a Data API Builder entity definition, which `source.type` value supports full create, read, update, and delete operations?",
  "options": [
    "view",
    "stored-procedure",
    "table",
    "function"
  ],
  "correctIndex": 2,
  "explanation": "Tables support full CRUD operations, while views typically support only read operations and stored procedures execute custom logic rather than standard CRUD.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Integrate SQL solutions with Azure services/03-define-entities-rest-graphql.md",
    "heading": "Map database objects to entities",
    "quote": "Tables support full CRUD operations (create, read, update, delete), views typically support read operations, and stored procedures execute custom logic."
  }
},
{
  "id": "easy-19",
  "tier": "easy",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Optimize database performance",
  "question": "What is the default MAXDOP (max degree of parallelism) setting for a new Azure SQL Database?",
  "options": [
    "0 (unlimited)",
    "1",
    "8",
    "16"
  ],
  "correctIndex": 2,
  "explanation": "Azure SQL Database defaults MAXDOP to 8, which the lesson describes as working for the widest variety of workloads; MAXDOP 0 (unlimited) was the old default and is explicitly discouraged in production.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Optimize database performance/02-recommend-database-configurations.md",
    "heading": "Control parallelism with MAXDOP",
    "quote": "Azure SQL Database defaults to **8**, which works for the widest variety of workloads."
  }
},
{
  "id": "easy-20",
  "tier": "easy",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Optimize database performance",
  "question": "In an execution plan, which operator indicates the engine is reading every row of a table instead of targeting specific rows through an index?",
  "options": [
    "Index Seek",
    "Table Scan",
    "Key Lookup",
    "Hash Match"
  ],
  "correctIndex": 1,
  "explanation": "A Table Scan (or Index Scan) reads every row and is generally less efficient than an Index Seek, which targets specific rows using index keys.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Optimize database performance/04-evaluate-query-performance.md",
    "heading": "Identify common issues in execution plans",
    "quote": "A **Table Scan** or **Index Scan** operator on the other hand, represents a less efficient method that reads every row."
  }
},
{
  "id": "medium-14",
  "tier": "medium",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement CI CD by using SQL database projects",
  "question": "Why should a pull request that modifies a SQL database project trigger a CI build as a required check?",
  "options": [
    "It automatically deploys the change to the production environment",
    "It catches broken references, syntax errors, or unresolved dependencies before the change reaches main",
    "It generates and runs the post-deployment reference data script",
    "It assigns CODEOWNERS reviewers to the pull request automatically"
  ],
  "correctIndex": 1,
  "explanation": "A CI build compiled from the PR surfaces broken references or syntax errors before the change merges into main, giving reviewers confidence; it does not deploy to production or manage reviewer assignment.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement CI CD by using SQL database projects/04-manage-branching-pull-requests-conflict-resolution.md",
    "heading": "Connect pull requests to CI builds",
    "quote": "If the build fails because of a broken reference, syntax error, or unresolved dependency, the problem gets caught before it reaches main."
  }
},
{
  "id": "medium-15",
  "tier": "medium",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement CI CD by using SQL database projects",
  "question": "When using schema comparison to detect schema drift, which comparison direction reveals changes made directly against the live database that the project doesn't know about?",
  "options": [
    "Project-to-database",
    "Database-to-project",
    ".dacpac-to-.dacpac",
    "Database-to-database"
  ],
  "correctIndex": 1,
  "explanation": "Comparing database-to-project surfaces drift (changes in the live database the project doesn't have), while comparing project-to-database previews what a deployment would change instead.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement CI CD by using SQL database projects/05-detect-resolve-schema-drift.md",
    "heading": "Detect drift with schema comparison",
    "quote": "The direction is reversible. Compare database-to-project to find drift. Compare project-to-database to preview what a deployment would change."
  }
},
{
  "id": "medium-16",
  "tier": "medium",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement data security and compliance with SQL",
  "question": "What is the key behavioral difference between a filter predicate and a block predicate in Row-Level Security?",
  "options": [
    "Filter predicates only apply to stored procedures, while block predicates only apply to ad hoc queries",
    "Filter predicates silently exclude unauthorized rows from results, while block predicates raise an error on unauthorized changes",
    "Filter predicates require the WITH SCHEMABINDING option, while block predicates don't",
    "Block predicates only work together with Always Encrypted columns"
  ],
  "correctIndex": 1,
  "explanation": "Filter predicates remove rows a user can't see without any error, while block predicates raise an error when a user attempts an unauthorized insert, update, or delete.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement data security and compliance with SQL/04-design-implement-row-level-security.md",
    "heading": "Understand RLS components",
    "quote": "silently exclude unauthorized rows from query results, or **block predicates** that prevent unauthorized insert, update, and delete operations."
  }
},
{
  "id": "medium-17",
  "tier": "medium",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement data security and compliance with SQL",
  "question": "A user has SELECT access to a table both through a directly granted permission and through membership in a database role. If you run REVOKE SELECT against the user directly (without changing the role), what happens?",
  "options": [
    "The user loses all access to the table",
    "The user still has access to the table through the role grant",
    "The REVOKE statement fails because DENY must be used first",
    "The user's role membership is automatically removed"
  ],
  "correctIndex": 1,
  "explanation": "REVOKE only removes the specific grant it targets and doesn't block access coming from other sources, unlike DENY, which blocks access regardless of any other grants.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement data security and compliance with SQL/05-design-implement-object-level-permissions.md",
    "heading": "Grant and revoke permissions",
    "quote": "Revoking removes one grant but doesn't prevent access through other grants. Denying blocks access no matter what other grants exist."
  }
},
{
  "id": "medium-18",
  "tier": "medium",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Integrate SQL solutions with Azure services",
  "question": "When exposing a SQL view as a Data API Builder entity, why must you explicitly configure the `key-fields` property?",
  "options": [
    "Views can't be queried through GraphQL without it",
    "DAB can't automatically detect primary keys for a view",
    "It's required to enable caching on the view",
    "It disables mutation support for the entity"
  ],
  "correctIndex": 1,
  "explanation": "Unlike tables, views don't have a declared primary key that DAB can detect automatically, so you must specify which columns uniquely identify each row.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Integrate SQL solutions with Azure services/04-expose-database-objects-stored-procedures-views.md",
    "heading": "Expose views as read-only entities",
    "quote": "The `key-fields` property is required for views because DAB can't automatically detect primary keys."
  }
},
{
  "id": "medium-19",
  "tier": "medium",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Integrate SQL solutions with Azure services",
  "question": "What is the main functional difference between Change Data Capture (CDC) and Change Tracking?",
  "options": [
    "CDC requires Azure Event Hubs, while Change Tracking doesn't",
    "CDC captures the actual before-and-after column values, while Change Tracking only records which rows changed",
    "Change Tracking supports higher throughput than CDC",
    "CDC only works with SQL databases in Microsoft Fabric"
  ],
  "correctIndex": 1,
  "explanation": "CDC records the complete before-and-after state of changed rows in change tables, while Change Tracking is lighter weight and only tells you which rows changed, not the actual values.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Integrate SQL solutions with Azure services/07-handle-changes-event-driven-patterns.md",
    "heading": "Understand change capture mechanisms",
    "quote": "records insert, update, and delete operations to special change tables. It captures the complete before-and-after state of changed rows"
  }
},
{
  "id": "medium-20",
  "tier": "medium",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Optimize database performance",
  "question": "What is the key difference between Read Committed Snapshot Isolation (RCSI) and SNAPSHOT isolation?",
  "options": [
    "RCSI snapshots data at the start of each statement, while SNAPSHOT snapshots data at the start of the entire transaction",
    "RCSI uses locking while SNAPSHOT uses row versioning",
    "SNAPSHOT is enabled by default in Azure SQL Database, while RCSI is not",
    "RCSI prevents phantom reads while SNAPSHOT does not"
  ],
  "correctIndex": 0,
  "explanation": "RCSI gives each read a per-statement snapshot, while SNAPSHOT isolation gives each read a snapshot as of the start of the whole transaction, providing consistent results across multiple queries in that transaction.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Optimize database performance/03-preserve-data-integrity-isolation-levels.md",
    "heading": "Row-versioning isolation levels",
    "quote": "Instead of a per-statement snapshot, each read sees the data as it existed at the start of the entire *transaction*."
  }
},
{
  "id": "hard-14",
  "tier": "hard",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement CI CD by using SQL database projects",
  "question": "How do you mark a generated SQL Server unit test as a negative test that expects a stored procedure to raise an error?",
  "options": [
    "Set the test condition to \"Not Empty ResultSet\"",
    "Add the `ExpectedSqlException` attribute directly above the test method in the generated .cs file",
    "Add a `THROW` statement inside the test's pre-test section",
    "Disable \"Automatically deploy the database project before unit tests are run\""
  ],
  "correctIndex": 1,
  "explanation": "Visual Studio generates a C# test method per stored procedure, and adding the ExpectedSqlException attribute above that method makes the test pass only if the procedure raises a matching error.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement CI CD by using SQL database projects/07-design-implement-testing-strategy.md",
    "heading": "Negative tests",
    "quote": "add the `ExpectedSqlException` attribute directly above it and save the file"
  }
},
{
  "id": "hard-15",
  "tier": "hard",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement data security and compliance with SQL",
  "question": "With Always Encrypted, which encryption type must a column use if the application needs to perform equality comparisons or WHERE-clause filters against that column?",
  "options": [
    "Randomized",
    "Deterministic",
    "AEAD_AES_256_GCM",
    "Transparent"
  ],
  "correctIndex": 1,
  "explanation": "Deterministic encryption always produces the same ciphertext for the same plaintext, which allows equality comparisons, joins, and WHERE filters; randomized encryption is more secure but doesn't support those operations.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement data security and compliance with SQL/02-design-implement-data-encryption.md",
    "heading": "Configure Always Encrypted",
    "quote": "Use **deterministic** when you need to perform equality comparisons, joins, or filter with `WHERE` clauses"
  }
},
{
  "id": "hard-16",
  "tier": "hard",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement data security and compliance with SQL",
  "question": "In a `CREATE SERVER AUDIT` statement, what does the `QUEUE_DELAY` parameter control?",
  "options": [
    "How many days the audit records are retained before deletion",
    "How many milliseconds events are buffered before being written to the audit target",
    "The maximum size of a single audit log file before it rolls over",
    "The number of rollover files kept before the oldest is overwritten"
  ],
  "correctIndex": 1,
  "explanation": "QUEUE_DELAY sets the buffering window in milliseconds before audit events are written; lower values give more real-time logging at a performance cost, while retention and file rollover are controlled by other settings.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement data security and compliance with SQL/06-implement-auditing.md",
    "heading": "Configure SQL Server auditing",
    "quote": "The `QUEUE_DELAY` parameter specifies how many milliseconds to buffer events before writing."
  }
},
{
  "id": "hard-17",
  "tier": "hard",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement data security and compliance with SQL",
  "question": "Why should you set `allow-introspection` to `false` for a GraphQL endpoint in production?",
  "options": [
    "It reduces query response latency",
    "It prevents attackers from discovering the schema's types, fields, and relationships",
    "It's required before entity-level field permissions can be enforced",
    "It disables the `/graphql` path entirely"
  ],
  "correctIndex": 1,
  "explanation": "Introspection queries expose the full schema structure, so disabling introspection in production prevents attackers from using it to map out available types, fields, and relationships.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement data security and compliance with SQL/08-secure-graphql-rest-mcp-endpoints.md",
    "heading": "Secure GraphQL endpoints",
    "quote": "Disable introspection in production to prevent attackers from discovering your schema structure."
  }
},
{
  "id": "hard-18",
  "tier": "hard",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Integrate SQL solutions with Azure services",
  "question": "In a Data API Builder deployment's health checks, what does the readiness probe specifically verify that the liveness probe does not?",
  "options": [
    "That the container image is running the latest tag",
    "That database connectivity works, by making an actual API request",
    "That CORS origins are configured correctly for the environment",
    "That the GraphQL schema passes validation"
  ],
  "correctIndex": 1,
  "explanation": "The liveness probe only confirms DAB is responding, while the readiness probe makes an actual API request to confirm the database connection itself is working.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Integrate SQL solutions with Azure services/05-deploy-data-api-builder-azure-services.md",
    "heading": "Monitor deployment health",
    "quote": "The liveness probe checks that DAB is responding. The readiness probe verifies database connectivity by making an actual API request."
  }
},
{
  "id": "hard-19",
  "tier": "hard",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Optimize database performance",
  "question": "After the Regressed Queries view in Query Store identifies a query that switched to a slower plan, what is the immediate practical effect of running `sp_query_store_force_plan`?",
  "options": [
    "It permanently deletes the regressed plan from Query Store",
    "It forces the previously working plan immediately while you investigate the root cause",
    "It automatically rewrites the query text to avoid the regression",
    "It blocks the query from executing until statistics are refreshed"
  ],
  "correctIndex": 1,
  "explanation": "Plan forcing lets you immediately revert to a known-good plan as a stopgap fix while you investigate the underlying cause of the regression, without touching the query or application code.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Optimize database performance/05-monitor-tune-queries-query-store.md",
    "heading": "Force a plan",
    "quote": "you can force the previously working plan immediately while you investigate the root cause"
  }
},
{
  "id": "hard-20",
  "tier": "hard",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Optimize database performance",
  "question": "What is the default interval at which the deadlock monitor checks for circular lock dependencies, and how does it change when deadlocks occur frequently?",
  "options": [
    "30 seconds by default, increasing to 60 seconds under heavy load",
    "Five seconds by default, dropping to as low as 100 milliseconds when deadlocks are frequent",
    "One second by default, fixed regardless of deadlock frequency",
    "It only runs once per hour regardless of deadlock frequency"
  ],
  "correctIndex": 1,
  "explanation": "The deadlock monitor's default five-second check interval shortens to as little as 100 milliseconds when deadlocks are happening frequently, so cycles get detected and resolved faster.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Optimize database performance/06-identify-resolve-blocking-deadlocks.md",
    "heading": "Deadlocks",
    "quote": "with a default interval of five seconds that drops to as low as 100 milliseconds when deadlocks are frequent"
  }
},
{
  "id": "usecase-08",
  "tier": "usecase",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement CI CD by using SQL database projects",
  "question": "A development team's security policy prohibits storing any Azure credentials or client secrets in their GitHub Actions workflow files that deploy a .dacpac to Azure SQL Database. Which authentication approach should the pipeline use?",
  "options": [
    "SQL authentication with the password stored as a repository secret",
    "OpenID Connect (OIDC) federated credentials with azure/login",
    "A service principal client secret rotated manually every 90 days",
    "A shared access signature (SAS) token embedded in the connection string"
  ],
  "correctIndex": 1,
  "explanation": "OIDC with azure/login authenticates through federated credentials, so there is no client secret or password stored anywhere in the pipeline, satisfying the no-stored-credentials requirement.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement CI CD by using SQL database projects/06-implement-cicd-pipelines.md",
    "heading": "Service principal and OpenID Connect authentication",
    "quote": "OpenID Connect (OIDC)** with `azure/login` authenticates using federated credentials, with no client secret stored anywhere."
  }
},
{
  "id": "usecase-09",
  "tier": "usecase",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement data security and compliance with SQL",
  "question": "A team is building a stored procedure in Azure SQL Database that calls Azure OpenAI to generate embeddings. Their compliance requirements prohibit storing any API keys in the database or application code. Which authentication approach should they configure for the outbound call?",
  "options": [
    "Store the Azure OpenAI API key as the SECRET value of a database-scoped credential",
    "Use Managed Identity so Azure manages the credentials automatically, without storing API keys",
    "Embed the API key directly in the stored procedure's T-SQL text",
    "Use a SQL Server linked server configured with stored credentials"
  ],
  "correctIndex": 1,
  "explanation": "Managed Identity eliminates the need to store API keys anywhere by having Azure manage the identity credentials automatically, and you simply grant that identity access to the AI service.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement data security and compliance with SQL/07-secure-model-endpoints.md",
    "heading": "Configure Managed Identity for AI services",
    "quote": "Managed Identity eliminates the need to store API keys in your database or application code."
  }
},
{
  "id": "usecase-10",
  "tier": "usecase",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Integrate SQL solutions with Azure services",
  "question": "A company is building a real-time analytics pipeline that needs sub-second notification of Orders table changes at very high transaction volumes, with no polling delay. Which change-capture mechanism should they use?",
  "options": [
    "Change Data Capture (CDC) queried on a nightly batch schedule",
    "Change Tracking combined with an Azure Functions SQL trigger binding",
    "Change Event Streaming (CES) pushed to Azure Event Hubs",
    "A scheduled SqlPackage /Action:Extract job compared against source control"
  ],
  "correctIndex": 2,
  "explanation": "Change Event Streaming pushes changes directly to Event Hubs as transactions commit, eliminating polling delays and scaling to very high event volumes, which fits the sub-second, high-throughput requirement better than CDC, Change Tracking, or scheduled extracts.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Integrate SQL solutions with Azure services/07-handle-changes-event-driven-patterns.md",
    "heading": "Stream changes with Change Event Streaming",
    "quote": "Change Event Streaming pushes changes directly to Azure Event Hubs. This approach eliminates polling delays and scales to millions of events per second."
  }
},
{
  "id": "easy-21",
  "tier": "easy",
  "domain": "Design and develop database solutions",
  "module": "Design and implement database objects with SQL",
  "question": "For storing financial amounts like Price or Revenue, which data type should you choose to avoid the rounding errors that can occur with FLOAT?",
  "options": [
    "DECIMAL",
    "FLOAT",
    "REAL",
    "BIGINT"
  ],
  "correctIndex": 0,
  "explanation": "DECIMAL provides exact precision for financial calculations, while FLOAT can introduce rounding errors that can't be fixed without recalculating every dependent value.",
  "source": {
    "path": "dp800/Design and develop database solutions/Design and implement database objects with SQL/03-build-effective-tables.md",
    "heading": "Explore common data types",
    "quote": "using FLOAT for financial data instead of DECIMAL can introduce rounding errors that can't be fixed without recalculating every dependent value"
  }
},
{
  "id": "medium-21",
  "tier": "medium",
  "domain": "Design and develop database solutions",
  "module": "Design and implement database objects with SQL",
  "question": "A ProductName column stores only ASCII characters and never needs Unicode support. Per the lesson's example, what effect does switching its type from NVARCHAR(100) to VARCHAR(100) have?",
  "options": [
    "It roughly doubles storage per row",
    "It cuts string storage in that column roughly in half, since VARCHAR uses 1 byte per character versus NVARCHAR's 2 bytes",
    "It has no measurable effect on storage",
    "It forces the column to become a fixed-length CHAR type"
  ],
  "correctIndex": 1,
  "explanation": "VARCHAR uses 1 byte per character versus 2 bytes for NVARCHAR, so a 30-character ProductName uses about 30 bytes as VARCHAR(100) versus about 60 bytes as NVARCHAR(100).",
  "source": {
    "path": "dp800/Design and develop database solutions/Design and implement database objects with SQL/03-build-effective-tables.md",
    "heading": "Design effective columns",
    "quote": "VARCHAR (1 byte per character) cuts string storage in half. A ProductName VARCHAR(100) uses ~30 bytes vs ~60 bytes for NVARCHAR(100) on a 30-character name."
  }
},
{
  "id": "easy-22",
  "tier": "easy",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "What is the purpose of including SET NOCOUNT ON at the start of a stored procedure?",
  "options": [
    "It prevents the message about the number of rows affected from being sent to the client, reducing network traffic",
    "It disables all error handling within the procedure",
    "It forces the procedure to run inside a single transaction",
    "It converts the procedure into a scalar function"
  ],
  "correctIndex": 0,
  "explanation": "SET NOCOUNT ON suppresses the rows-affected message sent to the client, which reduces network traffic and improves performance, especially for procedures that execute multiple statements.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/03-create-stored-procedures.md",
    "heading": "Create basic stored procedures",
    "quote": "The SET NOCOUNT ON statement prevents the message about the number of rows affected from being sent to the client. This reduces network traffic and improves performance"
  }
},
{
  "id": "medium-22",
  "tier": "medium",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "Why does the lesson recommend avoiding the sp_ prefix when naming your own stored procedures?",
  "options": [
    "SQL Server reserves sp_ for system procedures in master, so it searches master first before the current database, adding unnecessary overhead",
    "sp_ procedures cannot accept parameters",
    "The sp_ prefix disables query plan caching",
    "SQL Server automatically deletes any procedure named with the sp_ prefix"
  ],
  "correctIndex": 0,
  "explanation": "SQL Server reserves the sp_ prefix for system procedures stored in master, so naming a user procedure with that prefix makes SQL Server search master first, adding unnecessary lookup overhead.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/03-create-stored-procedures.md",
    "heading": "Avoid the sp_ prefix",
    "quote": "SQL Server reserves this prefix for system procedures stored in the master database. When you name a procedure with sp_, SQL Server first searches master before checking the current database, adding unnecessary overhead"
  }
},
{
  "id": "hard-21",
  "tier": "hard",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "Inside a stored procedure's CATCH block, why does the lesson check @@TRANCOUNT before issuing ROLLBACK TRANSACTION?",
  "options": [
    "To avoid an error from attempting to roll back a transaction that already completed or was never started",
    "To count how many stored procedures are currently executing",
    "To determine whether the procedure was called with output parameters",
    "@@TRANCOUNT has no relation to ROLLBACK and is checked only for logging"
  ],
  "correctIndex": 0,
  "explanation": "Checking @@TRANCOUNT before rolling back prevents an error that would occur if the transaction already completed or was never started, which can happen depending on where the failure occurred.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/03-create-stored-procedures.md",
    "heading": "Implement error handling",
    "quote": "Always check @@TRANCOUNT before rolling back transactions in the CATCH block. This prevents errors if the transaction already completed or was never started."
  }
},
{
  "id": "medium-23",
  "tier": "medium",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "A scalar function calculates employee tenure using GETDATE(). What limitation does this introduce?",
  "options": [
    "The function becomes non-deterministic and can't be used in indexed views or indexes on computed columns",
    "The function can no longer accept parameters",
    "The function must be rewritten as a stored procedure",
    "SQL Server will refuse to create the function at all"
  ],
  "correctIndex": 0,
  "explanation": "Referencing GETDATE() makes a function non-deterministic since its result changes between calls with the same input, which disqualifies it from use in indexed views or indexes on computed columns.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/04-create-scalar-functions.md",
    "heading": "Implement scalar functions with business logic",
    "quote": "This function uses GETDATE(), which makes it non-deterministic. Non-deterministic functions can't be used in indexed views or indexes on computed columns."
  }
},
{
  "id": "hard-22",
  "tier": "hard",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "A scalar function is called in the WHERE clause of a query against a large table. What performance risk does the lesson warn about, and what alternative does it suggest?",
  "options": [
    "SQL Server may execute the function once per row, significantly hurting performance; consider an inline table-valued function instead",
    "The function will always run exactly once regardless of row count, so there's no performance concern",
    "SQL Server automatically converts the WHERE clause into a JOIN, eliminating any performance concern",
    "The query fails to compile because scalar functions aren't allowed in WHERE clauses"
  ],
  "correctIndex": 0,
  "explanation": "SQL Server may invoke a scalar function once per row when it's used in a WHERE clause or SELECT list against a large table, so the lesson suggests inline table-valued functions as a better-performing alternative.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/04-create-scalar-functions.md",
    "heading": "Apply best practices for scalar functions",
    "quote": "When you use a scalar function in a WHERE clause or SELECT list with large tables, SQL Server may execute the function for every row. This can significantly impact query performance. For such scenarios, consider inline table-valued functions as an alternative."
  }
},
{
  "id": "easy-23",
  "tier": "easy",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "What is a key difference between an inline table-valued function and a multi-statement table-valued function?",
  "options": [
    "An inline TVF's table structure is inferred by SQL Server from its single SELECT statement, while a multi-statement TVF requires you to explicitly declare the returned table's structure",
    "A multi-statement TVF can only return a single row, while an inline TVF can return many rows",
    "Inline TVFs cannot accept parameters, while multi-statement TVFs can",
    "Multi-statement TVFs cannot be used in a FROM clause"
  ],
  "correctIndex": 0,
  "explanation": "Inline TVFs contain a single SELECT and let SQL Server infer the returned table's structure, while multi-statement TVFs require an explicit table declaration and a BEGIN...END block to populate it.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/05-create-table-valued-functions.md",
    "heading": "Understand table-valued function types",
    "quote": "With inline functions, you don't define the table structure—SQL Server infers it from your SELECT statement."
  }
},
{
  "id": "usecase-11",
  "tier": "usecase",
  "domain": "Design and develop database solutions",
  "module": "Implement programmability objects with SQL",
  "question": "A report needs to call a table-valued function once per row of the Customers table, passing each row's own CustomerID value into the function as a parameter. Which construct is designed for this kind of row-by-row, correlated call?",
  "options": [
    "CROSS APPLY, calling the function with the correlated column value",
    "A plain INNER JOIN with no ON clause",
    "UNION ALL between the two tables",
    "A recursive CTE anchored on the Customers table"
  ],
  "correctIndex": 0,
  "explanation": "CROSS APPLY is built for passing a correlated column value like c.CustomerID into a table-valued function for each outer row, acting like a correlated subquery but with better readability and reusability.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement programmability objects with SQL/05-create-table-valued-functions.md",
    "heading": "Use table-valued functions in queries",
    "quote": "The function acts as a correlated subquery but with better readability and reusability."
  }
},
{
  "id": "easy-24",
  "tier": "easy",
  "domain": "Design and develop database solutions",
  "module": "Implement SQL solutions by using AI-assisted tools",
  "question": "What is SQL MCP Server, Microsoft's open-source solution for connecting AI agents to SQL databases, built on?",
  "options": [
    "Data API builder",
    "Azure Functions",
    "SQL Server Reporting Services",
    "Entity Framework Core"
  ],
  "correctIndex": 0,
  "explanation": "SQL MCP Server is described as Microsoft's open-source solution built on Data API builder, enabling AI agents to interact with SQL databases.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement SQL solutions by using AI-assisted tools/07-connect-to-mcp-server-endpoints.md",
    "heading": "Connect to SQL Server MCP endpoints",
    "quote": "SQL MCP Server is Microsoft's open-source solution built on Data API builder that enables AI agents to interact with SQL databases."
  }
},
{
  "id": "medium-24",
  "tier": "medium",
  "domain": "Design and develop database solutions",
  "module": "Implement SQL solutions by using AI-assisted tools",
  "question": "A team wants to give multiple team members and an automated process shared, non-interactive access to an MCP server endpoint. Which authentication method does the lesson recommend for this scenario?",
  "options": [
    "Interactive browser sign-in",
    "Service principal",
    "An API key pasted directly into mcp.json",
    "No authentication, relying on network isolation alone"
  ],
  "correctIndex": 1,
  "explanation": "The lesson recommends configuring a service principal (a Microsoft Entra ID application) for automated or shared MCP access, distinct from interactive sign-in which suits individual development use.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement SQL solutions by using AI-assisted tools/07-connect-to-mcp-server-endpoints.md",
    "heading": "Configure authentication for MCP endpoints",
    "quote": "Service principal: Configure a Microsoft Entra ID application with appropriate permissions. Best for automated scenarios and shared environments."
  }
},
{
  "id": "usecase-12",
  "tier": "usecase",
  "domain": "Design and develop database solutions",
  "module": "Implement SQL solutions by using AI-assisted tools",
  "question": "A developer is testing new MCP-based Copilot prompts and wants to avoid any risk of an AI assistant querying live customer data while iterating. What does the lesson recommend?",
  "options": [
    "Configure separate MCP endpoints for development, test, and production, and avoid connecting AI assistants to production data during routine development",
    "Grant the AI assistant full production access so results are always realistic",
    "Disable MCP entirely during development",
    "Use the same MCP endpoint for all environments to keep configuration simple"
  ],
  "correctIndex": 0,
  "explanation": "The lesson's best practice is to configure separate MCP endpoints per environment and avoid connecting AI assistants to production data during routine development work.",
  "source": {
    "path": "dp800/Design and develop database solutions/Implement SQL solutions by using AI-assisted tools/07-connect-to-mcp-server-endpoints.md",
    "heading": "Best practices for MCP endpoint management",
    "quote": "Separate environments: Configure different MCP endpoints for development, test, and production databases. Avoid connecting AI assistants to production data during routine development."
  }
},
{
  "id": "easy-25",
  "tier": "easy",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement RAG with SQL",
  "question": "In the chat message structure used to call a language model, what does the system role define?",
  "options": [
    "How the assistant should behave",
    "The original question from the user",
    "The retrieved database context only",
    "The final formatted JSON response"
  ],
  "correctIndex": 0,
  "explanation": "The system role sets the ground rules for how the assistant should behave, while the user role carries the question and retrieved context together.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement RAG with SQL/04-augment-prompts-database-context.md",
    "heading": "Understand the chat message structure",
    "quote": "The system role defines how the assistant should behave."
  }
},
{
  "id": "medium-25",
  "tier": "medium",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement RAG with SQL",
  "question": "For a RAG scenario where you want consistent, factual answers grounded in retrieved data, what temperature range does the lesson recommend?",
  "options": [
    "0.3 to 0.5",
    "1.0 to 1.5",
    "Exactly 2.0, the maximum",
    "Temperature has no effect on RAG output consistency"
  ],
  "correctIndex": 0,
  "explanation": "Lower temperature values between 0.3 and 0.5 produce more consistent, factual responses, which is what grounded RAG answers need, unlike higher values that favor creativity.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement RAG with SQL/04-augment-prompts-database-context.md",
    "heading": "Control model behavior",
    "quote": "temperature controls creativity on a scale from 0 to 2. Lower values (0.3 to 0.5) produce more consistent, factual responses."
  }
},
{
  "id": "usecase-13",
  "tier": "usecase",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement RAG with SQL",
  "question": "A team wants to build the entire chat completion request payload for Azure OpenAI, including the system and user messages, directly inside a T-SQL stored procedure without any application code. Which T-SQL functions does the lesson use for this?",
  "options": [
    "JSON_OBJECT and JSON_ARRAY",
    "OPENJSON and JSON_MODIFY",
    "STRING_AGG and CONCAT",
    "FOR JSON AUTO only"
  ],
  "correctIndex": 0,
  "explanation": "The lesson builds the request payload using JSON_OBJECT and JSON_ARRAY, which handle the JSON formatting for the messages array directly in T-SQL.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement RAG with SQL/04-augment-prompts-database-context.md",
    "heading": "Build prompts in T-SQL",
    "quote": "T-SQL's `JSON_OBJECT` and `JSON_ARRAY` functions handle the JSON formatting."
  }
},
{
  "id": "medium-26",
  "tier": "medium",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement RAG with SQL",
  "question": "sp_invoke_external_rest_endpoint is enabled by default in Azure SQL Database. In which product must it instead be explicitly enabled using sp_configure?",
  "options": [
    "SQL Server 2025",
    "SQL Server 2019",
    "Azure SQL Managed Instance",
    "Microsoft Fabric warehouses"
  ],
  "correctIndex": 0,
  "explanation": "The lesson states the stored procedure is enabled by default in Azure SQL Database, but must be enabled in SQL Server 2025 using sp_configure.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement RAG with SQL/05-generate-process-rag-responses.md",
    "heading": "Call the model from SQL",
    "quote": "The stored procedure is enabled by default in Azure SQL Database and can be enabled in SQL Server 2025 using `sp_configure`."
  }
},
{
  "id": "hard-23",
  "tier": "hard",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement RAG with SQL",
  "question": "In a call to sp_invoke_external_rest_endpoint, what does adding the @retry_count = 3 parameter do?",
  "options": [
    "It automatically retries the call up to three times for transient failures like timeouts before giving up",
    "It limits the response to three JSON fields",
    "It caps the number of tokens the model can generate to three hundred",
    "It forces the credential to be re-authenticated three times"
  ],
  "correctIndex": 0,
  "explanation": "The @retry_count parameter makes the stored procedure retry the call automatically for transient failures like timeouts, attempting up to the specified number of times before giving up.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement RAG with SQL/05-generate-process-rag-responses.md",
    "heading": "Manage errors and retries",
    "quote": "For transient failures like timeouts or temporary service unavailability, the stored procedure can retry automatically. Add the `@retry_count` parameter and in this example, it attempts the call up to three times before giving up"
  }
},
{
  "id": "medium-27",
  "tier": "medium",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement intelligent search with SQL",
  "question": "Why does Reciprocal Rank Fusion (RRF) avoid the need to normalize full-text BM25 scores and vector cosine distances onto the same scale before combining them?",
  "options": [
    "RRF combines results based on rank position rather than raw score values, sidestepping the different scales entirely",
    "RRF converts every score to a percentage before combining",
    "RRF only ever uses the vector search score and ignores full-text scores",
    "SQL Server automatically normalizes all scores before RRF runs"
  ],
  "correctIndex": 0,
  "explanation": "RRF works with rank positions instead of raw scores, so it sidesteps the fact that BM25 scores and cosine distances use completely different scales.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement intelligent search with SQL/06-implement-hybrid-search-ranking.md",
    "heading": "Merge results with Reciprocal Rank Fusion",
    "quote": "Score normalization isn't needed. Full-text BM25 scores and cosine distances use completely different scales. RRF sidesteps these differences by using ranks instead."
  }
},
{
  "id": "usecase-14",
  "tier": "usecase",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement intelligent search with SQL",
  "question": "A hybrid search implementation returns results driven too heavily by exact keyword matches, and the team wants vector/semantic relevance to count roughly twice as much. Based on the lesson's tuning guidance, how should they adjust the RRF calculation?",
  "options": [
    "Multiply the vector search term's contribution by 2 in the RRF score formula",
    "Double the value of the RRF constant k for the entire query",
    "Remove the full-text search term from the query entirely",
    "Double @topN for the full-text search only"
  ],
  "correctIndex": 0,
  "explanation": "The lesson shows weighting one source more heavily by multiplying its contribution in the RRF sum, e.g. using 2.0/(k + vector_rank) to weight vector search twice as much as keyword search.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement intelligent search with SQL/06-implement-hybrid-search-ranking.md",
    "heading": "Tune hybrid search parameters",
    "quote": "Weight vector search 2x more than keyword search"
  }
},
{
  "id": "easy-26",
  "tier": "easy",
  "domain": "Implement AI capabilities in database solutions",
  "module": "Design and implement models and embeddings with SQL",
  "question": "Which embedding maintenance approach streams DML changes directly into Azure Event Hubs in near real-time, without adding work to database transactions?",
  "options": [
    "Change Event Streaming (CES)",
    "Table triggers",
    "Azure Logic Apps",
    "Microsoft Foundry"
  ],
  "correctIndex": 0,
  "explanation": "Change Event Streaming pushes DML changes directly into Azure Event Hubs in near real-time, letting downstream consumers regenerate embeddings without adding work to database transactions.",
  "source": {
    "path": "dp800/Implement AI capabilities in database solutions/Design and implement models and embeddings with SQL/05-generate-maintain-embeddings-sql-database-workloads.md",
    "heading": "Choose an embedding maintenance method",
    "quote": "Change event streaming (CES) streams DML changes directly into Azure Event Hubs in near real-time. Downstream systems can consume these events and regenerate embeddings as changes occur without adding work to database transactions."
  }
},
{
  "id": "easy-27",
  "tier": "easy",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Integrate SQL solutions with Azure services",
  "question": "In Application Insights telemetry for a Data API Builder deployment, what does dependency telemetry specifically capture?",
  "options": [
    "Database queries issued by DAB, including execution time and success/failure status",
    "Only front-end page load times",
    "The number of GitHub commits to the DAB configuration repo",
    "CPU temperature of the underlying host machine"
  ],
  "correctIndex": 0,
  "explanation": "Dependency telemetry tracks database queries with their execution time and success/failure status, separate from request telemetry or exception telemetry.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Integrate SQL solutions with Azure services/06-recommend-azure-monitor-configurations.md",
    "heading": "Configure Application Insights integration",
    "quote": "Dependency telemetry - Database queries with execution time and success/failure status"
  }
},
{
  "id": "hard-24",
  "tier": "hard",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Integrate SQL solutions with Azure services",
  "question": "When configuring Azure Monitor alert rules for a DAB deployment, what does the lesson recommend to avoid alert fatigue?",
  "options": [
    "Start with high-severity conditions and refine thresholds based on normal operating patterns",
    "Configure every possible metric as a critical alert immediately",
    "Disable all alerts until a major incident occurs",
    "Set every alert's evaluation frequency to one second"
  ],
  "correctIndex": 0,
  "explanation": "The lesson recommends configuring alerts thoughtfully by starting with high-severity conditions and refining thresholds based on observed normal operating patterns, rather than alerting on everything at once.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Integrate SQL solutions with Azure services/06-recommend-azure-monitor-configurations.md",
    "heading": "Configure alert rules for proactive monitoring",
    "quote": "Configure alerts thoughtfully to avoid alert fatigue. Start with high-severity conditions and refine thresholds based on normal operating patterns."
  }
},
{
  "id": "usecase-15",
  "tier": "usecase",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Integrate SQL solutions with Azure services",
  "question": "A DAB-backed API is called by multiple client applications, and the team needs to see the complete end-to-end latency breakdown for a single request as it flows from client through the API to the database. What should they implement?",
  "options": [
    "Distributed tracing, correlating requests using trace context headers like traceparent",
    "A single high-level uptime check",
    "Increasing MAXDOP on the database",
    "Disabling Application Insights sampling entirely"
  ],
  "correctIndex": 0,
  "explanation": "Distributed tracing correlates requests across the client, API, and database using trace context headers such as traceparent, letting Application Insights show the end-to-end latency breakdown for a single request.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Integrate SQL solutions with Azure services/06-recommend-azure-monitor-configurations.md",
    "heading": "Implement distributed tracing",
    "quote": "distributed tracing connects the complete request flow from client through API to database."
  }
},
{
  "id": "easy-28",
  "tier": "easy",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Integrate SQL solutions with Azure services",
  "question": "Which Azure hosting option includes Data API Builder as a built-in feature called database connections, offering the simplest deployment when your API complements a static frontend?",
  "options": [
    "Azure Static Web Apps",
    "Azure Container Apps",
    "Azure App Service",
    "Azure Kubernetes Service"
  ],
  "correctIndex": 0,
  "explanation": "Azure Static Web Apps includes DAB as a built-in feature called database connections, described as the simplest deployment experience when the API complements a static frontend.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Integrate SQL solutions with Azure services/05-deploy-data-api-builder-azure-services.md",
    "heading": "Deploy to Azure Static Web Apps",
    "quote": "includes Data API Builder as a built-in feature called database connections. This integration provides the simplest deployment experience when your API complements a static frontend."
  }
},
{
  "id": "medium-28",
  "tier": "medium",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Optimize database performance",
  "question": "Which Query Store view does the lesson describe as the most common starting point for day-to-day performance tuning?",
  "options": [
    "Top Resource Consuming Queries",
    "Regressed Queries",
    "Queries With Forced Plans",
    "Query Wait Statistics"
  ],
  "correctIndex": 0,
  "explanation": "Top Resource Consuming Queries shows the highest resource-usage queries for a chosen metric and time range, and the lesson calls it the most common starting point for day-to-day performance tuning.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Optimize database performance/05-monitor-tune-queries-query-store.md",
    "heading": "Detect regressed queries",
    "quote": "Top Resource Consuming Queries: Shows the queries with the highest resource usage for a chosen metric and time range. This report is the most common starting point for day-to-day performance tuning."
  }
},
{
  "id": "hard-25",
  "tier": "hard",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Optimize database performance",
  "question": "Query Store silently switches to read-only mode and stops collecting new data when it runs out of storage space. How can you detect that this has happened?",
  "options": [
    "Query sys.database_query_store_options and compare actual_state_desc to desired_state_desc",
    "Check the SQL Server error log for error 1205",
    "Run DBCC CHECKDB and look for corruption warnings",
    "There is no way to detect this; you must rebuild the database from backup"
  ],
  "correctIndex": 0,
  "explanation": "Querying sys.database_query_store_options reveals whether actual_state_desc shows READ_ONLY while desired_state_desc shows READ_WRITE, which indicates Query Store switched itself to read-only after running out of space.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Optimize database performance/05-monitor-tune-queries-query-store.md",
    "heading": "Follow best practices",
    "quote": "If `actual_state_desc` shows `READ_ONLY` while `desired_state_desc` shows `READ_WRITE`, Query Store switched itself. The `readonly_reason` column tells you why."
  }
},
{
  "id": "hard-26",
  "tier": "hard",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Optimize database performance",
  "question": "Read Committed Snapshot Isolation (RCSI) is enabled by default in Azure SQL Database. Which type of blocking does RCSI NOT eliminate?",
  "options": [
    "Blocking between two writer sessions that both need to modify the same rows",
    "Blocking between a reader and a writer session",
    "Blocking caused by a SELECT statement waiting on a row's shared lock",
    "All blocking, since RCSI eliminates locking entirely"
  ],
  "correctIndex": 0,
  "explanation": "RCSI removes blocking between readers and writers by using row versioning for reads, but two sessions that both need to write to the same rows can still block each other.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Optimize database performance/06-identify-resolve-blocking-deadlocks.md",
    "heading": "Identify blocking chains",
    "quote": "This setting significantly reduces blocking between readers and writers. However, blocking between two writers, or blocking caused by explicit transactions with higher isolation levels, still happens."
  }
},
{
  "id": "usecase-16",
  "tier": "usecase",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Optimize database performance",
  "question": "An application occasionally receives SQL error 1205 during peak load. According to the lesson's guidance, how should the application handle this error?",
  "options": [
    "Catch the error, roll back, pause briefly with a randomized delay, and resubmit the transaction",
    "Immediately terminate the database connection and alert an administrator",
    "Ignore the error since SQL Server automatically retries deadlock victims",
    "Escalate the transaction's isolation level to SERIALIZABLE and resubmit without a delay"
  ],
  "correctIndex": 0,
  "explanation": "Error 1205 means the transaction was chosen as a deadlock victim and rolled back, so the application should catch it, pause briefly with a randomized delay, and resubmit, which also avoids repeatedly deadlocking with the same transaction.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Optimize database performance/06-identify-resolve-blocking-deadlocks.md",
    "heading": "Handle deadlocks in application code",
    "quote": "Your application should catch this error, pause briefly, and resubmit the transaction."
  }
},
{
  "id": "hard-27",
  "tier": "hard",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement data security and compliance with SQL",
  "question": "When validating AI-generated queries submitted through an MCP endpoint, why does the lesson recommend implementing allow lists for permitted tables and operations rather than trying to block malicious patterns?",
  "options": [
    "Because blocking known-bad patterns is inherently incomplete, and you should never trust AI-generated queries without validation against what's explicitly permitted",
    "Because allow lists are the only mechanism supported by T-SQL",
    "Because block lists are more expensive to evaluate at query time",
    "Because allow lists automatically encrypt all returned data"
  ],
  "correctIndex": 0,
  "explanation": "The lesson explicitly warns to never trust AI-generated queries without validation and to implement allow lists for permitted tables and operations rather than relying on block lists of malicious patterns, which are easy to miss cases with.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement data security and compliance with SQL/08-secure-graphql-rest-mcp-endpoints.md",
    "heading": "Secure MCP endpoints",
    "quote": "Never trust AI-generated queries without validation. Implement allow lists for permitted tables and operations rather than trying to block malicious patterns."
  }
},
{
  "id": "usecase-17",
  "tier": "usecase",
  "domain": "Secure, optimize, and deploy database solutions",
  "module": "Implement CI CD by using SQL database projects",
  "question": "A security team is worried that someone could modify a pipeline definition on a feature branch to deploy directly to production using the production service connection. Which Azure DevOps control specifically prevents this?",
  "options": [
    "A branch control check on the service connection, which only allows pipelines running in the context of main to access it",
    "A required-reviewers rule on the pull request",
    "A CODEOWNERS file listing the database team",
    "A firewall rule restricting the build agent's IP address"
  ],
  "correctIndex": 0,
  "explanation": "A branch control check on the service connection locks down which pipelines can access production credentials to only those running in the context of main, so even a modified feature-branch pipeline is refused.",
  "source": {
    "path": "dp800/Secure, optimize, and deploy database solutions/Implement CI CD by using SQL database projects/06-implement-cicd-pipelines.md",
    "heading": "Branch control checks",
    "quote": "In Azure DevOps, a **branch control check** on service connections locks down which pipelines can access production credentials. Only pipelines running in the context of `main` get access. Even if someone modifies a pipeline on a feature branch to target production, the service connection refuses the request."
  }
}
];
