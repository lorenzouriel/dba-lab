// DP-900 practice quiz questions.
// Auto-assembled from domain drafts; each item's `source` cites the exact
// dp900/content/ lesson file the answer/explanation comes from.
const DP900_QUESTIONS = [
{
  "id": "easy-01",
  "tier": "easy",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "What is the defining characteristic of structured data?",
  "options": [
    "It has no fixed schema and fields vary freely between records",
    "It adheres to a fixed schema, most commonly represented as tables of rows and columns",
    "It's always stored as raw binary that applications must interpret",
    "It can only ever be represented using JSON"
  ],
  "correctIndex": 1,
  "explanation": "Structured data adheres to a fixed schema where every record has the same fields, typically represented as tables with rows for entity instances and columns for attributes.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/02-identify-data-formats.md",
    "heading": "Structured data",
    "quote": "the data is represented in one or more tables that consist of rows to represent each instance of a data entity, and columns to represent attributes of the entity"
  }
},
{
  "id": "easy-02",
  "tier": "easy",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "Which of the following is a common format used to represent semi-structured data?",
  "options": [
    "JSON",
    "A CSV file with a fixed set of columns",
    "A relational table schema",
    "A raw binary BLOB"
  ],
  "correctIndex": 0,
  "explanation": "JSON is a common semi-structured format because its documents allow fields to vary between records, unlike the fixed schema of structured tabular data.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/02-identify-data-formats.md",
    "heading": "Semi-structured data",
    "quote": "One common format for semi-structured data is JavaScript Object Notation (JSON)"
  }
},
{
  "id": "easy-03",
  "tier": "easy",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "Which delimited text format separates fields with commas and terminates rows with a carriage return/new line?",
  "options": [
    "CSV",
    "XML",
    "Parquet",
    "Avro"
  ],
  "correctIndex": 0,
  "explanation": "Comma-separated values (CSV) is the most common delimited text format, using commas to separate fields and a new line to terminate each row.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/03-explore-file-storage.md",
    "heading": "Delimited text files",
    "quote": "The most common format for delimited data is comma-separated values (CSV) in which fields are separated by commas"
  }
},
{
  "id": "easy-04",
  "tier": "easy",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "Which optimized file format stores data in columnar row groups and is the de facto standard for modern data lakehouses?",
  "options": [
    "Avro",
    "Parquet",
    "XML",
    "CSV"
  ],
  "correctIndex": 1,
  "explanation": "Parquet is a columnar data format that has become the de facto standard for modern data lakehouses, storing column data together within row groups.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/03-explore-file-storage.md",
    "heading": "Optimized file formats",
    "quote": "Parquet is a columnar data format and the de facto standard for modern data lakehouses"
  }
},
{
  "id": "easy-05",
  "tier": "easy",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "In a relational database, what uniquely identifies each instance of an entity within a table?",
  "options": [
    "A foreign key",
    "A primary key",
    "A column family",
    "A partition key"
  ],
  "correctIndex": 1,
  "explanation": "Each instance of an entity is assigned a primary key that uniquely identifies it, and that key can be referenced from other tables.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/04-explore-databases.md",
    "heading": "Relational databases",
    "quote": "Each instance of an entity is assigned a primary key that uniquely identifies it"
  }
},
{
  "id": "easy-06",
  "tier": "easy",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "What is the common term for the work performed by transactional systems that process high-volume business transactions?",
  "options": [
    "OLAP",
    "OLTP",
    "ETL",
    "ELT"
  ],
  "correctIndex": 1,
  "explanation": "The work performed by transactional systems handling high volumes of business transactions is referred to as Online Transactional Processing (OLTP).",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/05-explore-transactional-data-processing.md",
    "heading": "Explore transactional data processing",
    "quote": "The work performed by transactional systems is often referred to as Online Transactional Processing (OLTP)"
  }
},
{
  "id": "easy-07",
  "tier": "easy",
  "domain": "Describe core data concepts",
  "module": "Explore data roles and services",
  "question": "Which task is a core responsibility of a database administrator?",
  "options": [
    "Creating dashboards and reports",
    "Backing up and restoring databases",
    "Building machine learning pipelines",
    "Writing ETL pipelines for a data lake"
  ],
  "correctIndex": 1,
  "explanation": "Database administrators work with stakeholders to implement backup and recovery plans so data can be restored after a disaster or human error, alongside managing availability and security.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore data roles and services/02-explore-job-roles-in-the-world-of-data.md",
    "heading": "Database Administrator",
    "quote": "implement policies, tools, and processes for backup and recovery plans to recover following a natural disaster or human-made error"
  }
},
{
  "id": "easy-08",
  "tier": "easy",
  "domain": "Describe core data concepts",
  "module": "Explore data roles and services",
  "question": "What type of service is Azure SQL Database?",
  "options": [
    "An infrastructure-as-a-service virtual machine",
    "A fully managed platform-as-a-service (PaaS) database",
    "A software-as-a-service analytics suite",
    "An on-premises only database engine"
  ],
  "correctIndex": 1,
  "explanation": "Azure SQL Database is a fully managed platform-as-a-service (PaaS) database hosted in Azure, distinct from the more configurable but more administratively demanding Managed Instance and VM options.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore data roles and services/03-identify-data-services.md",
    "heading": "Azure SQL",
    "quote": "Azure SQL Database – a fully managed platform-as-a-service (PaaS) database hosted in Azure"
  }
},
{
  "id": "medium-01",
  "tier": "medium",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "Which of the following data types is best classified as unstructured?",
  "options": [
    "A customer table with a fixed set of columns",
    "A JSON document with optional fields",
    "An audio recording file",
    "A relational database schema"
  ],
  "correctIndex": 2,
  "explanation": "Audio, video, images, and documents don't have a specific structure, so they're classified as unstructured, unlike tabular structured data or flexible-schema JSON semi-structured data.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/02-identify-data-formats.md",
    "heading": "Unstructured data",
    "quote": "documents, images, audio and video data, and binary files might not have a specific structure"
  }
},
{
  "id": "medium-02",
  "tier": "medium",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "Which statement accurately describes the Avro file format?",
  "options": [
    "It's a columnar format that groups data by column within row groups",
    "It's a row-based format whose header, stored as JSON, describes the file's structure",
    "It's a plain-text delimited format optimized for human readability",
    "It's a transaction log layered on top of Parquet"
  ],
  "correctIndex": 1,
  "explanation": "Avro is a row-based format where each file contains a JSON-formatted header describing the data's structure, followed by binary blocks of records.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/03-explore-file-storage.md",
    "heading": "Optimized file formats",
    "quote": "Avro is a row-based format. It was created by Apache. Each file contains a header that describes the structure of the data in the file"
  }
},
{
  "id": "medium-03",
  "tier": "medium",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "How does Delta Lake extend the Parquet format?",
  "options": [
    "By converting columnar storage into row-based storage",
    "By adding a transaction log that enables ACID transactions, versioning, and reliable updates",
    "By removing the need for metadata describing row groups",
    "By encoding data as XML instead of binary"
  ],
  "correctIndex": 1,
  "explanation": "Delta Lake builds on Parquet by adding a transaction log, which enables ACID transactions, data versioning, and reliable updates on data lake files.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/03-explore-file-storage.md",
    "heading": "Optimized file formats",
    "quote": "Delta Lake is an open-source storage format that builds on Parquet by adding a transaction log, which enables ACID transactions, data versioning, and reliable updates"
  }
},
{
  "id": "medium-04",
  "tier": "medium",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "How does a document database relate to a key-value database?",
  "options": [
    "It's unrelated — document databases don't use keys at all",
    "It's a specific form of key-value database where the value is a JSON document",
    "It's a form of graph database where documents are the nodes",
    "It's a column-family database where each column is a document"
  ],
  "correctIndex": 1,
  "explanation": "A document database is a specific form of key-value database in which the value is a JSON document that the system is optimized to parse and query.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/04-explore-databases.md",
    "heading": "Nonrelational databases",
    "quote": "Document databases, which are a specific form of key-value database in which the value is a JSON document"
  }
},
{
  "id": "medium-05",
  "tier": "medium",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "Which ACID property ensures that a transaction either completes entirely or has no effect at all?",
  "options": [
    "Consistency",
    "Isolation",
    "Atomicity",
    "Durability"
  ],
  "correctIndex": 2,
  "explanation": "Atomicity treats each transaction as a single unit that either succeeds completely or fails completely, with no partial effect.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/05-explore-transactional-data-processing.md",
    "heading": "Explore transactional data processing",
    "quote": "Atomicity – each transaction is treated as a single unit, which succeeds completely or fails completely"
  }
},
{
  "id": "medium-06",
  "tier": "medium",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "What is the key difference between the ETL and ELT patterns for loading data into an analytical store?",
  "options": [
    "ETL transforms data before loading it; ELT loads data first and applies transformations afterward",
    "ETL is used only for streaming data, while ELT is used only for batch data",
    "ETL loads raw data with no transformation at all; ELT isn't a real pattern",
    "ETL and ELT are simply two names for the exact same process"
  ],
  "correctIndex": 0,
  "explanation": "ETL extracts, transforms, and then loads data, whereas ELT extracts and loads the data first and applies transformations afterward, a pattern common in modern lakehouses.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/06-explore-analytical-data-processing.md",
    "heading": "Choose your preferred content format",
    "quote": "Operational data is extracted, transformed, and loaded (ETL) into a data lake for analysis—or extracted and loaded first with transformations applied afterward, a pattern called ELT"
  }
},
{
  "id": "medium-07",
  "tier": "medium",
  "domain": "Describe core data concepts",
  "module": "Explore data roles and services",
  "question": "Which data role is primarily responsible for designing data ingestion pipelines and cleansing/transformation activities for analytical workloads?",
  "options": [
    "Database administrator",
    "Data engineer",
    "Data analyst",
    "AI engineer"
  ],
  "correctIndex": 1,
  "explanation": "A data engineer collaborates with stakeholders to design and implement data-related workloads, including ingestion pipelines and cleansing and transformation activities.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore data roles and services/02-explore-job-roles-in-the-world-of-data.md",
    "heading": "Data Engineer",
    "quote": "A data engineer collaborates with stakeholders to design and implement data-related workloads, including data ingestion pipelines, cleansing and transformation activities"
  }
},
{
  "id": "medium-08",
  "tier": "medium",
  "domain": "Describe core data concepts",
  "module": "Explore data roles and services",
  "question": "What is OneLake in the context of Microsoft Fabric?",
  "options": [
    "A single virtual machine that hosts all Fabric compute",
    "The shared storage layer underlying all of Fabric's workloads",
    "A dedicated relational database engine used only by Fabric Warehouse",
    "An AI model used for natural-language querying"
  ],
  "correctIndex": 1,
  "explanation": "Microsoft Fabric brings data engineering, warehousing, real-time analytics, data science, and Power BI together in a single workspace on top of one shared storage layer called OneLake.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore data roles and services/03-identify-data-services.md",
    "heading": "Microsoft Fabric",
    "quote": "brings data engineering, data warehousing, real-time analytics, data science, and Power BI together in a single browser-based workspace on top of one shared storage layer called OneLake"
  }
},
{
  "id": "hard-01",
  "tier": "hard",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "What distinguishes a column-family database from a simple key-value database?",
  "options": [
    "It stores tabular rows and columns, and lets you group related columns into column-families",
    "It stores only a unique key and an associated unstructured value with no grouping",
    "It stores entities exclusively as nodes connected by relationship links",
    "It requires every row to have identical columns, exactly like a relational table"
  ],
  "correctIndex": 0,
  "explanation": "Column-family databases store tabular rows and columns like structured data, but let you divide the columns into logically related groups called column-families, unlike a plain key-value store where the value can be any format.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/04-explore-databases.md",
    "heading": "Nonrelational databases",
    "quote": "Column family databases, which store tabular data comprising rows and columns, but you can divide the columns into groups known as column-families"
  }
},
{
  "id": "hard-02",
  "tier": "hard",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "A transaction transferring funds between two accounts is in progress. Which ACID property guarantees that a concurrent transaction reading both balances won't see a mix of pre-transfer and post-transfer values?",
  "options": [
    "Atomicity",
    "Consistency",
    "Isolation",
    "Durability"
  ],
  "correctIndex": 2,
  "explanation": "Isolation ensures concurrent transactions can't interfere with one another, so a balance-checking transaction can't retrieve a pre-transfer value for one account and a post-transfer value for the other.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/05-explore-transactional-data-processing.md",
    "heading": "Explore transactional data processing",
    "quote": "the balance-checking transaction can't retrieve a value for one account that reflects the balance before the transfer, and a value for the other account that reflects the balance after the transfer"
  }
},
{
  "id": "hard-03",
  "tier": "hard",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "In the medallion architecture, which layer holds raw, unmodified data exactly as ingested from source systems so it can be reprocessed later if requirements change?",
  "options": [
    "Gold",
    "Silver",
    "Bronze",
    "Semantic"
  ],
  "correctIndex": 2,
  "explanation": "The Bronze layer holds raw data ingested as-is from source systems with no transformations applied, preserving the original records for reprocessing.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/06-explore-analytical-data-processing.md",
    "heading": "Organizing data with the medallion architecture",
    "quote": "Bronze: raw data ingested as-is from source systems, with no transformations applied, preserving the original records for reprocessing"
  }
},
{
  "id": "hard-04",
  "tier": "hard",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "In an OLAP (semantic) model, what are the aggregated numeric values calculated for intersections of dimensions called?",
  "options": [
    "Attributes",
    "Measures",
    "Entities",
    "Primary keys"
  ],
  "correctIndex": 1,
  "explanation": "Measures are aggregated numeric values from fact tables, calculated for intersections of dimensions from dimension tables — for example, sales revenue totaled by date, customer, and product.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/06-explore-analytical-data-processing.md",
    "heading": "Choose your preferred content format",
    "quote": "Aggregated numeric values (measures) from fact tables are calculated for intersections of dimensions from dimension tables"
  }
},
{
  "id": "hard-05",
  "tier": "hard",
  "domain": "Describe core data concepts",
  "module": "Explore data roles and services",
  "question": "What distinguishes a PaaS offering like Azure SQL Database from a SaaS offering like Microsoft Fabric?",
  "options": [
    "SaaS requires you to manage the underlying servers, while PaaS does not",
    "PaaS delivers a ready-to-use product with zero infrastructure management, while SaaS requires patching servers",
    "With PaaS, Microsoft manages the infrastructure while you focus on your data/apps; with SaaS, the entire product is delivered ready-to-use with no infrastructure management at all",
    "There's no meaningful difference between PaaS and SaaS"
  ],
  "correctIndex": 2,
  "explanation": "PaaS means Microsoft manages the underlying infrastructure so you focus on your data and applications, while SaaS delivers the entire product as a ready-to-use service with no installation or infrastructure management required.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore data roles and services/03-identify-data-services.md",
    "heading": "Choose your preferred content format",
    "quote": "PaaS means Microsoft manages the underlying infrastructure (servers, patching, backups) so you focus on your data and applications. SaaS means the entire product is delivered as a ready-to-use service"
  }
},
{
  "id": "hard-06",
  "tier": "hard",
  "domain": "Describe core data concepts",
  "module": "Explore data roles and services",
  "question": "Which statement correctly ranks the Azure SQL family by administrative responsibility placed on the owner, from least to most?",
  "options": [
    "Azure SQL VM, Azure SQL Managed Instance, Azure SQL Database",
    "Azure SQL Database, Azure SQL Managed Instance, Azure SQL VM",
    "Azure SQL Managed Instance, Azure SQL Database, Azure SQL VM",
    "All three place identical administrative responsibility on the owner"
  ],
  "correctIndex": 1,
  "explanation": "Azure SQL Database is the fully managed PaaS option with the least owner responsibility, Managed Instance trades some management burden for more flexible configuration, and Azure SQL VM gives maximum configurability with full management responsibility.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore data roles and services/03-identify-data-services.md",
    "heading": "Azure SQL",
    "quote": "Azure SQL Managed Instance – a hosted instance of SQL Server with automated maintenance, which allows more flexible configuration than Azure SQL DB but with more administrative responsibility for the owner"
  }
},
{
  "id": "hard-07",
  "tier": "hard",
  "domain": "Describe core data concepts",
  "module": "Explore data roles and services",
  "question": "Even though AI tools are central to an AI engineer's daily workflow, which responsibilities remain distinctly human according to the module?",
  "options": [
    "Generating boilerplate code snippets",
    "Design decisions, evaluation, and responsible deployment of AI systems",
    "Explaining model behavior in natural language",
    "Suggesting possible architectures"
  ],
  "correctIndex": 1,
  "explanation": "While AI assistance helps generate code, explain model behavior, and suggest architectures, the design decisions, evaluation, and responsible deployment of AI systems remain distinctly human responsibilities.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore data roles and services/02-explore-job-roles-in-the-world-of-data.md",
    "heading": "AI Engineer",
    "quote": "AI assistance is central to the AI engineer's daily work—generating code, explaining model behavior, and suggesting architectures using natural language, though the design decisions, evaluation, and responsible deployment of AI systems remain distinctly human responsibilities"
  }
},
{
  "id": "usecase-01",
  "tier": "usecase",
  "domain": "Describe core data concepts",
  "module": "Explore core data concepts",
  "question": "A company wants to build an AI assistant that can answer natural-language questions grounded in its own internal documents. Which type of data representation enables this capability?",
  "options": [
    "Delimited text data",
    "Vector data (embeddings)",
    "Column-family data",
    "XML data"
  ],
  "correctIndex": 1,
  "explanation": "Vector data, also called embeddings, is the data type that enables AI assistants to answer questions grounded in an organization's own documents and data.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore core data concepts/02-identify-data-formats.md",
    "heading": "Unstructured data",
    "quote": "Organizations are also increasingly working with vector data (also called embeddings)—the data type that enables AI assistants to answer questions over your own documents and data"
  }
},
{
  "id": "usecase-02",
  "tier": "usecase",
  "domain": "Describe core data concepts",
  "module": "Explore data roles and services",
  "question": "An IoT solution generates a continuous stream of sensor readings that must be queried and manipulated in near real time before the results are written to a dashboard. Which Azure service is purpose-built for this?",
  "options": [
    "Azure Data Factory",
    "Azure Stream Analytics",
    "Azure Data Explorer",
    "Azure Database for PostgreSQL"
  ],
  "correctIndex": 1,
  "explanation": "Azure Stream Analytics is a real-time stream processing engine that captures a stream of data from an input, applies a query to extract and manipulate it, and writes results to an output, which fits a near-real-time IoT scenario.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore data roles and services/03-identify-data-services.md",
    "heading": "Azure Stream Analytics",
    "quote": "Azure Stream Analytics is a real-time stream processing engine that captures a stream of data from an input, applies a query to extract and manipulate data from the input stream, and writes the results to an output"
  }
},
{
  "id": "usecase-03",
  "tier": "usecase",
  "domain": "Describe core data concepts",
  "module": "Explore data roles and services",
  "question": "A team needs to run high-performance queries over huge volumes of timestamped log files and IoT telemetry data. Which Azure service is best suited to this workload?",
  "options": [
    "Azure Data Explorer",
    "Azure SQL Managed Instance",
    "Azure Data Factory",
    "Power BI"
  ],
  "correctIndex": 0,
  "explanation": "Azure Data Explorer is a fully managed, standalone, big data analytics platform that offers high-performance querying of log and telemetry data, which typically includes a timestamp attribute.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore data roles and services/03-identify-data-services.md",
    "heading": "Azure Data Explorer",
    "quote": "Azure Data Explorer is a fully managed, standalone, big data analytics platform that offers high-performance querying of log and telemetry data"
  }
},
{
  "id": "usecase-04",
  "tier": "usecase",
  "domain": "Describe core data concepts",
  "module": "Explore data roles and services",
  "question": "A large enterprise wants to map where all of its data lives, track how it flows and transforms across systems, and ensure teams can find trustworthy data for analysis and reporting. Which service is designed for this?",
  "options": [
    "Microsoft Purview",
    "Azure Data Factory",
    "Azure Cosmos DB",
    "Microsoft Foundry"
  ],
  "correctIndex": 0,
  "explanation": "Microsoft Purview provides enterprise-wide data governance and discoverability, letting organizations map their data and track data lineage across multiple sources and systems to find trustworthy data.",
  "source": {
    "path": "dp900/content/Describe core data concepts/Explore data roles and services/03-identify-data-services.md",
    "heading": "Microsoft Purview",
    "quote": "Microsoft Purview provides a solution for enterprise-wide data governance and discoverability. You can use Microsoft Purview to create a map of your data and track data lineage across multiple data sources and systems"
  }
},
{
  "id": "easy-09",
  "tier": "easy",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "In a relational database table, what does each row represent?",
  "options": [
    "A single instance of an entity",
    "A single column definition",
    "The entire database schema",
    "A foreign key constraint"
  ],
  "correctIndex": 0,
  "explanation": "Each row in a relational table represents one instance of the entity the table models, such as one customer or one order.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/02-understand-relational-data.md",
    "heading": "# Understand relational data",
    "quote": "each row represents a single instance of an entity"
  }
},
{
  "id": "easy-10",
  "tier": "easy",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "In a normalized relational database, what is used to uniquely identify each row (instance) of an entity?",
  "options": [
    "A primary key",
    "A composite index",
    "A stored procedure",
    "A view"
  ],
  "correctIndex": 0,
  "explanation": "A primary key uniquely identifies each row in a table, which is one of the core normalization principles described in the lesson.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/03-understand-normalization.md",
    "heading": "# Understand normalization",
    "quote": "Instances of each entity are uniquely identified by an ID or other key value, known as a *primary key*"
  }
},
{
  "id": "easy-11",
  "tier": "easy",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "Which category of SQL statements is used by database administrators to grant, deny, or revoke permissions on database objects?",
  "options": [
    "DDL",
    "DML",
    "DCL",
    "TCL"
  ],
  "correctIndex": 2,
  "explanation": "Data Control Language (DCL) statements such as GRANT, DENY, and REVOKE are used to manage user permissions on database objects.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/04-explore-sql.md",
    "heading": "### DCL statements",
    "quote": "Database administrators generally use DCL statements to manage access to objects in a database by granting, denying, or revoking permissions"
  }
},
{
  "id": "easy-12",
  "tier": "easy",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "What is a view in a relational database?",
  "options": [
    "A virtual table based on the results of a SELECT query",
    "A physical copy of a table's data taken at creation time",
    "A compiled program that runs on a schedule",
    "A column-level security policy"
  ],
  "correctIndex": 0,
  "explanation": "A view is a virtual table defined by a SELECT query; it doesn't store its own copy of the data.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/05-describe-database-objects.md",
    "heading": "## What is a view?",
    "quote": "A view is a virtual table based on the results of a **SELECT** query."
  }
},
{
  "id": "easy-13",
  "tier": "easy",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore relational database services in Azure",
  "question": "Which Azure SQL deployment option runs SQL Server inside a virtual machine and is classified as an IaaS (infrastructure-as-a-service) solution?",
  "options": [
    "Azure SQL Database",
    "Azure SQL Managed Instance",
    "SQL Server on Azure Virtual Machines",
    "Azure Database for MySQL"
  ],
  "correctIndex": 2,
  "explanation": "SQL Server on Azure Virtual Machines runs full SQL Server inside a VM you manage, making it an IaaS approach, unlike the PaaS Managed Instance and SQL Database options.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore relational database services in Azure/02-describe-azure-sql-services-and-capabilities.md",
    "heading": "## SQL Server on Azure Virtual Machines",
    "quote": "This is an example of the IaaS approach."
  }
},
{
  "id": "easy-14",
  "tier": "easy",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore relational database services in Azure",
  "question": "Which Azure relational database service is described as a hybrid relational-object database that can store custom data types and geometric data?",
  "options": [
    "Azure Database for MySQL",
    "Azure SQL Managed Instance",
    "Azure Database for PostgreSQL",
    "SQL Server on Azure Virtual Machines"
  ],
  "correctIndex": 2,
  "explanation": "PostgreSQL is described as a hybrid relational-object database that supports custom, nonrelational data types and geometric data such as lines and polygons.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore relational database services in Azure/03-describe-azure-services-for-open-source-databases.md",
    "heading": "## What are MySQL and PostgreSQL?",
    "quote": "PostgreSQL is a hybrid relational-object database."
  }
},
{
  "id": "medium-09",
  "tier": "medium",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "A Customer table includes a MiddleName column that isn't required for every customer. What does the database store in this column for a customer with no middle name?",
  "options": [
    "NULL",
    "The value zero",
    "An empty string that's treated identically to NULL for all purposes",
    "The word 'Unknown' automatically inserted by the database"
  ],
  "correctIndex": 0,
  "explanation": "Columns that aren't required for every row, like an optional MiddleName column, can hold NULL to represent the absence of a value.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/02-understand-relational-data.md",
    "heading": "# Understand relational data",
    "quote": "which can be empty (or *NULL*) for rows that represent customers with no middle name"
  }
},
{
  "id": "medium-10",
  "tier": "medium",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "In relational database design, what is a composite key?",
  "options": [
    "A key based on a unique combination of multiple columns",
    "A key automatically generated by an index",
    "A foreign key that references more than one table at once",
    "A key that's allowed to contain duplicate values"
  ],
  "correctIndex": 0,
  "explanation": "A composite key is a primary or foreign key defined using a unique combination of multiple columns, as when a LineItem table is uniquely identified by OrderNo plus ItemNo.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/03-understand-normalization.md",
    "heading": "# Understand normalization",
    "quote": "a key (primary or foreign) can be defined as a *composite* key based on a unique combination of multiple columns"
  }
},
{
  "id": "medium-11",
  "tier": "medium",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "Which DDL statement would you use to add a new column to an existing table?",
  "options": [
    "CREATE",
    "ALTER",
    "DROP",
    "RENAME"
  ],
  "correctIndex": 1,
  "explanation": "ALTER modifies the structure of an existing object, such as adding a new column to a table, whereas CREATE builds a brand-new object.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/04-explore-sql.md",
    "heading": "### DDL statements",
    "quote": "ALTER | Modify the structure of an object. For instance, altering a table to add a new column."
  }
},
{
  "id": "medium-12",
  "tier": "medium",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore relational database services in Azure",
  "question": "How does an Elastic Pool differ from provisioning a Single Database in Azure SQL Database?",
  "options": [
    "Multiple databases share the same pool of resources through multiple-tenancy",
    "Each database in the pool gets its own dedicated, unshared server",
    "An elastic pool can only ever contain a single database",
    "Elastic pools don't support scaling resources up or down"
  ],
  "correctIndex": 0,
  "explanation": "An elastic pool lets multiple databases share the same allocated resources (memory, storage, processing power), which is useful when databases have varying load at different times, unlike a single dedicated database.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore relational database services in Azure/02-describe-azure-sql-services-and-capabilities.md",
    "heading": "### Elastic Pool",
    "quote": "multiple databases can share the same resources, such as memory, data storage space, and processing power through multiple-tenancy"
  }
},
{
  "id": "medium-13",
  "tier": "medium",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "What is a key tradeoff of adding more indexes to a table?",
  "options": [
    "Indexes speed up qualifying queries but add storage and maintenance overhead on insert, update, and delete operations",
    "Indexes eliminate the need for a primary key",
    "Indexes always slow down every query, regardless of table size",
    "Indexes automatically normalize the underlying table"
  ],
  "correctIndex": 0,
  "explanation": "While indexes speed up lookups on indexed columns, they consume storage and must be maintained on every insert, update, and delete, which can slow those operations down.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/05-describe-database-objects.md",
    "heading": "## What is an index?",
    "quote": "indexes aren't free. An index consumes storage space, and each time you insert, update, or delete data in a table, the indexes for that table must be maintained."
  }
},
{
  "id": "medium-14",
  "tier": "medium",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore relational database services in Azure",
  "question": "Which statement accurately compares Azure SQL Managed Instance with Azure SQL Database?",
  "options": [
    "Managed Instance offers near-100% SQL Server compatibility, while Azure SQL Database supports most, but not necessarily all, core SQL Server capabilities",
    "Azure SQL Database offers near-100% SQL Server compatibility, while Managed Instance supports only basic capabilities",
    "Both offer exactly identical compatibility with on-premises SQL Server",
    "Managed Instance is an IaaS offering, while Azure SQL Database is a PaaS offering"
  ],
  "correctIndex": 0,
  "explanation": "The service comparison shows Managed Instance provides near-100% compatibility with on-premises SQL Server, while Azure SQL Database supports most core database-level capabilities but some on-premises-dependent features may be unavailable; both are PaaS.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore relational database services in Azure/02-describe-azure-sql-services-and-capabilities.md",
    "heading": "## Compare Azure SQL services",
    "quote": "Near-100% compatibility with SQL Server. Most on-premises databases can be migrated with minimal code changes"
  }
},
{
  "id": "medium-15",
  "tier": "medium",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore relational database services in Azure",
  "question": "Which Azure Database for MySQL deployment option is recommended for new workloads because it provides more granular control and cost optimization?",
  "options": [
    "Flexible Server",
    "Single Server",
    "Elastic Pool",
    "Hyperscale"
  ],
  "correctIndex": 0,
  "explanation": "The Flexible Server deployment option gives more granular control over configuration and cost optimization, and is the recommended choice for new MySQL workloads on Azure.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore relational database services in Azure/03-describe-azure-services-for-open-source-databases.md",
    "heading": "### Azure Database for MySQL Flexible Server",
    "quote": "It provides cost optimization controls and is the recommended deployment option for new workloads."
  }
},
{
  "id": "hard-08",
  "tier": "hard",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "Which of the following is NOT one of the basic normalization steps described for refactoring data?",
  "options": [
    "Separate each entity into its own table",
    "Combine multiple entities into a single wide table to reduce the number of joins needed",
    "Uniquely identify each entity instance (row) using a primary key",
    "Use foreign key columns to link related entities"
  ],
  "correctIndex": 1,
  "explanation": "Normalization does the opposite of combining entities into one wide table; it separates each entity into its own table and links them with primary/foreign keys to remove duplication.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/03-understand-normalization.md",
    "heading": "# Understand normalization",
    "quote": "Separate each *entity* into its own table."
  }
},
{
  "id": "hard-09",
  "tier": "hard",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "An administrator wants to permanently remove a stored procedure object from the database. Which SQL statement category provides the command needed, and what is that command called?",
  "options": [
    "DML category; the command is DELETE",
    "DDL category; the command is DROP",
    "DCL category; the command is REVOKE",
    "DDL category; the command is ALTER"
  ],
  "correctIndex": 1,
  "explanation": "Removing an object such as a stored procedure entirely from the database is a Data Definition Language (DDL) operation performed with the DROP statement.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/04-explore-sql.md",
    "heading": "### DDL statements",
    "quote": "DROP | Remove an object from the database."
  }
},
{
  "id": "hard-10",
  "tier": "hard",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "Which capability distinguishes a stored procedure from a view in a relational database?",
  "options": [
    "A stored procedure can accept input parameters to perform a parameterized action, while a view can't",
    "A stored procedure permanently stores a copy of the data, while a view doesn't",
    "A view can accept input parameters, while a stored procedure can't",
    "A view can execute INSERT, UPDATE, and DELETE statements, while a stored procedure can only SELECT"
  ],
  "correctIndex": 0,
  "explanation": "Stored procedures can be defined with parameters to create flexible, reusable logic for actions applied based on specific criteria, which a view (built purely on a SELECT statement) can't do.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/05-describe-database-objects.md",
    "heading": "## What is a stored procedure?",
    "quote": "You can define a stored procedure with parameters to create a flexible solution for common actions"
  }
},
{
  "id": "hard-11",
  "tier": "hard",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore relational database services in Azure",
  "question": "In Azure SQL Managed Instance, which authentication method lets users connect without re-entering credentials each time, because it reuses their current computer sign-in?",
  "options": [
    "SQL Server Database engine logins",
    "Microsoft Entra ID logins",
    "Shared access signature tokens",
    "Certificate-only authentication"
  ],
  "correctIndex": 1,
  "explanation": "Microsoft Entra ID logins reuse the credentials from the user's current sign-in, so they don't need to be re-entered on every connection, unlike SQL Server Database engine logins, which require a username and password each time.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore relational database services in Azure/02-describe-azure-sql-services-and-capabilities.md",
    "heading": "## Azure SQL Managed Instance",
    "quote": "Microsoft Entra logins use the credentials associated with your current computer sign-in, and you don't need to provide them with each time you connect to the server."
  }
},
{
  "id": "hard-12",
  "tier": "hard",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore relational database services in Azure",
  "question": "How does the Hyperscale service tier of Azure SQL Database differ from the standard Single Database and Elastic Pool options in terms of scale?",
  "options": [
    "It supports databases up to 100 TB with rapid, on-demand scaling and fast backup/restore regardless of data size",
    "It caps database size at 10 GB but offers faster query performance",
    "It only supports read-only workloads and can't accept writes",
    "It requires manual resizing and can't scale storage independently of compute"
  ],
  "correctIndex": 0,
  "explanation": "Hyperscale is built to support very large databases, up to 100 TB, with rapid on-demand scaling and fast backup and restore regardless of data size, unlike the more size-constrained default tiers.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore relational database services in Azure/02-describe-azure-sql-services-and-capabilities.md",
    "heading": "### Hyperscale",
    "quote": "The Hyperscale service tier supports very large databases—up to 100 TB—with rapid, on-demand scaling and fast backup and restore regardless of data size."
  }
},
{
  "id": "hard-13",
  "tier": "hard",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore relational database services in Azure",
  "question": "Why might a PostgreSQL administrator find that some familiar pgAdmin server-management tasks, such as performing server backup and restore, are unavailable on Azure Database for PostgreSQL?",
  "options": [
    "pgAdmin isn't compatible with any Azure database service",
    "Those tasks are handled by Microsoft because the server itself is managed and maintained by the service",
    "Azure Database for PostgreSQL doesn't support the pgsql query language",
    "Backup and restore functionality was permanently removed from PostgreSQL"
  ],
  "correctIndex": 1,
  "explanation": "Because Azure Database for PostgreSQL is a managed service, some server-focused functionality like backup and restore is handled by Microsoft rather than being exposed to the administrator through tools like pgAdmin.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore relational database services in Azure/03-describe-azure-services-for-open-source-databases.md",
    "heading": "### Benefits of Azure Database for PostgreSQL",
    "quote": "some server-focused functionality, such as performing server backup and restore, aren't available because the server is managed and maintained by Microsoft"
  }
},
{
  "id": "usecase-05",
  "tier": "usecase",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore relational database services in Azure",
  "question": "A company has a large on-premises SQL Server solution that relies on advanced instance-level features. They want to migrate to Azure with minimal code changes but don't want the overhead of managing virtual machine infrastructure. Which service should they choose?",
  "options": [
    "SQL Server on Azure Virtual Machines",
    "Azure SQL Managed Instance",
    "Azure SQL Database (single database)",
    "Azure Database for PostgreSQL"
  ],
  "correctIndex": 1,
  "explanation": "Azure SQL Managed Instance offers near-100% compatibility with on-premises SQL Server and its advanced features, letting the company lift-and-shift without the management overhead of running SQL Server on a VM.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore relational database services in Azure/02-describe-azure-sql-services-and-capabilities.md",
    "heading": "## Azure SQL Managed Instance",
    "quote": "Consider Azure SQL Managed Instance if you want to *lift-and-shift* an on-premises SQL Server instance and all its databases to the cloud, without incurring the management overhead of running SQL Server on a virtual machine."
  }
},
{
  "id": "usecase-06",
  "tier": "usecase",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore relational database services in Azure",
  "question": "A startup is building a brand-new cloud application with unpredictable, spiky traffic and wants a fully managed database that automatically scales resources up and down as demand changes, without a fixed pre-allocated server. Which option best fits?",
  "options": [
    "SQL Server on Azure Virtual Machines",
    "Azure SQL Managed Instance",
    "Azure SQL Database with a serverless configuration",
    "Azure Database for MySQL Standard edition"
  ],
  "correctIndex": 2,
  "explanation": "Azure SQL Database's serverless configuration automatically scales and allocates or deallocates resources as required, fitting a new cloud application with variable demand.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore relational database services in Azure/02-describe-azure-sql-services-and-capabilities.md",
    "heading": "### Single Database",
    "quote": "Your database automatically scales and resources are allocated or deallocated as required."
  }
},
{
  "id": "usecase-07",
  "tier": "usecase",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore relational database services in Azure",
  "question": "A company runs a web application on a Linux, Apache, MySQL, and PHP (LAMP) stack and wants to move its database to Azure with the fewest possible application changes. Which Azure service is the best fit?",
  "options": [
    "Azure SQL Managed Instance",
    "Azure Database for MySQL",
    "Azure Database for PostgreSQL",
    "SQL Server on Azure Virtual Machines"
  ],
  "correctIndex": 1,
  "explanation": "Azure Database for MySQL is a PaaS implementation based on MySQL Community Edition, the same engine LAMP applications already use, making migration straightforward.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore relational database services in Azure/03-describe-azure-services-for-open-source-databases.md",
    "heading": "## Azure Database for MySQL",
    "quote": "Azure Database for MySQL is a PaaS implementation of MySQL in the Azure cloud, based on the MySQL Community Edition."
  }
},
{
  "id": "usecase-08",
  "tier": "usecase",
  "domain": "Identify considerations for relational data on Azure",
  "module": "Explore fundamental relational data concepts",
  "question": "A reporting application repeatedly filters a large Orders table by CustomerId, and these lookups are becoming slow as the table grows. Without duplicating the table's data, which database object should be created to speed up these specific lookups?",
  "options": [
    "A view on the Orders table",
    "An index on the CustomerId column",
    "A stored procedure that selects from Orders",
    "A foreign key on the CustomerId column"
  ],
  "correctIndex": 1,
  "explanation": "An index stores a sorted copy of the specified column's values with pointers back to the corresponding rows, letting the query optimizer find matching rows quickly instead of scanning the whole table.",
  "source": {
    "path": "dp900/content/Identify considerations for relational data on Azure/Explore fundamental relational data concepts/05-describe-database-objects.md",
    "heading": "## What is an index?",
    "quote": "When you create an index in a database, you specify a column from the table, and the index contains a copy of this data in a sorted order, with pointers to the corresponding rows in the table."
  }
},
{
  "id": "easy-15",
  "tier": "easy",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore Azure Storage for nonrelational data",
  "question": "Which type of Azure Blob Storage blob is optimized for random read and write operations and is used by Azure to implement virtual disk storage for virtual machines?",
  "options": [
    "Block blob",
    "Page blob",
    "Append blob",
    "Archive blob"
  ],
  "correctIndex": 1,
  "explanation": "Page blobs are organized as fixed 512-byte pages optimized for random read/write access, which is why Azure uses them to back virtual machine disks.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore Azure Storage for nonrelational data/02-explore-azure-blob-storage.md",
    "heading": "Explore Azure blob storage",
    "quote": "A page blob is optimized to support random read and write operations; you can fetch and store data for a single page if necessary."
  }
},
{
  "id": "easy-16",
  "tier": "easy",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore Azure Storage for nonrelational data",
  "question": "What capability does enabling the hierarchical namespace option add to an Azure Storage account, turning it into Azure Data Lake Storage Gen2?",
  "options": [
    "Automatic conversion of blobs into relational tables",
    "POSIX-compliant access control lists (ACLs) for fine-grained permissions on files and folders",
    "Unlimited free storage capacity",
    "Support for the NFS protocol only"
  ],
  "correctIndex": 1,
  "explanation": "The hierarchical namespace enables POSIX-compliant ACLs, letting you set fine-grained read, write, and execute permissions on individual files and folders separate from the broader RBAC model.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore Azure Storage for nonrelational data/03-explore-azure-data-lake-storage-gen2.md",
    "heading": "Explore Azure Data Lake Storage Gen2",
    "quote": "The hierarchical namespace also enables POSIX-compliant access control lists (ACLs), so you can set fine-grained read, write, and execute permissions on individual files and folders"
  }
},
{
  "id": "easy-17",
  "tier": "easy",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore Azure Storage for nonrelational data",
  "question": "Which two network file-sharing protocols does Azure Files support?",
  "options": [
    "FTP and HTTP",
    "SMB and NFS",
    "iSCSI and SMB",
    "NFS and HTTPS"
  ],
  "correctIndex": 1,
  "explanation": "Azure Files supports Server Message Block (SMB), usable across Windows, Linux, and macOS, and Network File System (NFS), used by Linux with kernel 4.3 or later.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore Azure Storage for nonrelational data/05-explore-azure-files.md",
    "heading": "Explore Azure Files",
    "quote": "Azure Files supports two common network file sharing protocols:"
  }
},
{
  "id": "easy-18",
  "tier": "easy",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore fundamentals of Azure Cosmos DB",
  "question": "What kind of Azure service is Azure Cosmos DB?",
  "options": [
    "An infrastructure-as-a-service virtual machine image",
    "A fully managed, schema-agnostic NoSQL database platform-as-a-service offering",
    "An on-premises-only relational database engine",
    "A file-sharing service for unstructured documents"
  ],
  "correctIndex": 1,
  "explanation": "Azure Cosmos DB is a fully managed PaaS NoSQL database service where Microsoft handles the infrastructure, and it is schema-agnostic, so items in the same container don't need to share the same structure.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore fundamentals of Azure Cosmos DB/02-describe-azure-cosmos-db.md",
    "heading": "What is Azure Cosmos DB?",
    "quote": "Azure Cosmos DB is a fully managed NoSQL database service on Azure—a platform-as-a-service (PaaS) offering."
  }
},
{
  "id": "easy-19",
  "tier": "easy",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore fundamentals of Azure Cosmos DB",
  "question": "Which Azure Cosmos DB API is the native API, storing data as JSON documents and supporting a SQL-like query syntax?",
  "options": [
    "Azure Cosmos DB for MongoDB",
    "Azure Cosmos DB for Apache Cassandra",
    "Azure Cosmos DB for NoSQL",
    "Azure Cosmos DB for Apache Gremlin"
  ],
  "correctIndex": 2,
  "explanation": "Azure Cosmos DB for NoSQL is the native Cosmos DB API, storing data as JSON documents with SQL-like queries, and it's the API recommended for new applications.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore fundamentals of Azure Cosmos DB/03-identify-azure-cosmos-db-apis.md",
    "heading": "Cosmos DB for NoSQL",
    "quote": "Azure Cosmos DB for NoSQL is the native Cosmos DB API. It stores data as JSON documents and lets you query with a SQL-like syntax."
  }
},
{
  "id": "medium-16",
  "tier": "medium",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore Azure Storage for nonrelational data",
  "question": "A blob has been sitting in the Archive access tier of Azure Blob Storage. What must happen before an application can read that blob's data?",
  "options": [
    "Nothing — Archive-tier blobs can be read directly with only a few milliseconds of latency",
    "The blob must be deleted and re-uploaded to the Hot tier",
    "The blob's access tier must be changed to Hot, Cool, or Cold, and the blob must finish rehydrating",
    "The storage account's redundancy option must be changed to GRS"
  ],
  "correctIndex": 2,
  "explanation": "Archive-tier blobs are stored in an effectively offline state; you must change the access tier to Hot, Cool, or Cold to trigger rehydration, and you can read the blob only once that process completes.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore Azure Storage for nonrelational data/02-explore-azure-blob-storage.md",
    "heading": "Explore Azure blob storage",
    "quote": "To retrieve a blob from the Archive tier, you must change the access tier to Hot, Cool, or Cold. The blob will then be rehydrated."
  }
},
{
  "id": "medium-17",
  "tier": "medium",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore Azure Storage for nonrelational data",
  "question": "In Azure Table Storage, why does including the PartitionKey in a query's search criteria improve performance?",
  "options": [
    "It automatically creates a secondary index on every column",
    "It narrows the search to rows stored together in that partition, reducing the I/O needed to locate the data",
    "It converts the query into a relational join across tables",
    "It forces the table to move to the Hot access tier"
  ],
  "correctIndex": 1,
  "explanation": "Rows that share a partition key are stored together, so including the partition key in a query narrows the volume of data Azure needs to examine, reducing I/O and improving performance.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore Azure Storage for nonrelational data/06-explore-azure-tables.md",
    "heading": "Explore Azure Tables",
    "quote": "This helps to narrow down the volume of data to be examined, and improves performance by reducing the amount of I/O"
  }
},
{
  "id": "medium-18",
  "tier": "medium",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore fundamentals of Azure Cosmos DB",
  "question": "Which Azure Cosmos DB consistency level is described as the most widely used, and is the recommended starting point for most transactional applications?",
  "options": [
    "Strong",
    "Bounded staleness",
    "Session",
    "Eventual"
  ],
  "correctIndex": 2,
  "explanation": "Session consistency guarantees consistency within a single client session, and the lesson calls it the most widely used level and the recommended starting point for most transactional applications.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore fundamentals of Azure Cosmos DB/02-describe-azure-cosmos-db.md",
    "heading": "Global distribution and performance",
    "quote": "For most transactional applications, Session consistency is the recommended starting point."
  }
},
{
  "id": "medium-19",
  "tier": "medium",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore fundamentals of Azure Cosmos DB",
  "question": "Which Azure Cosmos DB throughput mode requires no upfront provisioning and charges per request, but restricts the account to a single Azure region?",
  "options": [
    "Dedicated",
    "Shared",
    "Serverless",
    "Autoscale"
  ],
  "correctIndex": 2,
  "explanation": "Serverless throughput has no upfront provisioning and charges per request, but serverless accounts are limited to a single Azure region, so an application needing global distribution must use a provisioned throughput account instead.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore fundamentals of Azure Cosmos DB/02-describe-azure-cosmos-db.md",
    "heading": "Throughput modes and pricing",
    "quote": "Serverless accounts are limited to a single Azure region. If your application requires global distribution across multiple regions, use a provisioned throughput account instead."
  }
},
{
  "id": "medium-20",
  "tier": "medium",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore fundamentals of Azure Cosmos DB",
  "question": "A team wants to migrate an existing Apache Cassandra workload, where rows in the same table don't need identical columns, to a managed Azure database. Which Cosmos DB API should they use, and what query language does it support?",
  "options": [
    "Cosmos DB for Apache Gremlin, using graph traversal syntax",
    "Cosmos DB for Apache Cassandra, using CQL",
    "Cosmos DB for MongoDB, using MQL",
    "Cosmos DB for Table, using REST-style endpoints"
  ],
  "correctIndex": 1,
  "explanation": "Azure Cosmos DB for Apache Cassandra supports the column-family model where rows can have different columns, and it's queried using CQL (Cassandra Query Language), whose syntax resembles SQL.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore fundamentals of Azure Cosmos DB/03-identify-azure-cosmos-db-apis.md",
    "heading": "Cosmos DB for Apache Cassandra",
    "quote": "Cassandra uses CQL (Cassandra Query Language), which has a syntax similar to SQL."
  }
},
{
  "id": "hard-14",
  "tier": "hard",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore Azure Storage for nonrelational data",
  "question": "Which Azure Storage redundancy option keeps data accessible if an entire availability zone fails, by spreading three copies across separate zones in the primary region, without replicating to a different region?",
  "options": [
    "Locally redundant storage (LRS)",
    "Zone-redundant storage (ZRS)",
    "Geo-redundant storage (GRS)",
    "Geo-zone-redundant storage (GZRS)"
  ],
  "correctIndex": 1,
  "explanation": "ZRS spreads copies across three availability zones in the primary region so data stays accessible if one zone goes down, whereas GRS and GZRS additionally replicate asynchronously to a separate, distant secondary region.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore Azure Storage for nonrelational data/02-explore-azure-blob-storage.md",
    "heading": "Explore Azure blob storage",
    "quote": "Zone-redundant storage (ZRS) spreads copies across three availability zones in the primary region, so your data remains accessible even if one zone goes down."
  }
},
{
  "id": "hard-15",
  "tier": "hard",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore Azure Storage for nonrelational data",
  "question": "Which statement about Microsoft OneLake in Fabric is true?",
  "options": [
    "OneLake requires a separate data lake to be manually created for each business group",
    "OneLake is built on Azure Data Lake Storage Gen2 and stores data in the open Delta Parquet format",
    "OneLake replaces the need for Fabric workspaces entirely",
    "OneLake only supports structured file types, not unstructured ones"
  ],
  "correctIndex": 1,
  "explanation": "OneLake is built on ADLS Gen2 and stores data in Delta Parquet, an open, efficient format, and it replaces the older pattern of provisioning a separate data lake per business group with one organization-wide lake.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore Azure Storage for nonrelational data/04-explore-microsoft-onelake-in-fabric.md",
    "heading": "Key Benefits of OneLake",
    "quote": "Built on Azure Data Lake Storage (ADLS) Gen2, OneLake stores data in Delta Parquet format—an open, efficient file format widely used for analytics data."
  }
},
{
  "id": "hard-16",
  "tier": "hard",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore fundamentals of Azure Cosmos DB",
  "question": "An application uses a Cosmos DB container whose partition key funnels most writes into a single logical partition. Which limit will this design most directly run into?",
  "options": [
    "Each logical partition can hold up to 20 GB of data, and throughput becomes unbalanced as the container grows",
    "Cosmos DB accounts are limited to a single database",
    "Containers cannot exceed four levels in the resource hierarchy",
    "RU/s cannot be measured for skewed partitions"
  ],
  "correctIndex": 0,
  "explanation": "Each logical partition is capped at 20 GB, and a partition key with uneven distribution concentrates data and throughput into fewer partitions — which is exactly why a well-chosen key needs many distinct values spread evenly.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore fundamentals of Azure Cosmos DB/02-describe-azure-cosmos-db.md",
    "heading": "How Azure Cosmos DB organizes data",
    "quote": "Each logical partition can hold up to 20 GB of data. A well-chosen partition key—one with many distinct values and an even spread of data across those values—is important for keeping throughput balanced"
  }
},
{
  "id": "hard-17",
  "tier": "hard",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore fundamentals of Azure Cosmos DB",
  "question": "Which of the following is NOT true about Azure Cosmos DB for NoSQL?",
  "options": [
    "It stores data as JSON documents",
    "It was previously called the SQL API before being renamed in 2023",
    "It is recommended for new applications",
    "An application must first migrate an existing MongoDB codebase before it can use this API"
  ],
  "correctIndex": 3,
  "explanation": "The NoSQL API is Cosmos DB's native, recommended-for-new-applications API for JSON documents (formerly named the SQL API); it has no dependency on migrating a MongoDB application — that scenario instead describes the separate Cosmos DB for MongoDB API.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore fundamentals of Azure Cosmos DB/03-identify-azure-cosmos-db-apis.md",
    "heading": "Cosmos DB for NoSQL",
    "quote": "This API was previously called the SQL API. It was renamed to the NoSQL API in 2023."
  }
},
{
  "id": "hard-18",
  "tier": "hard",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore fundamentals of Azure Cosmos DB",
  "question": "An application already uses Azure Table Storage with PartitionKey and RowKey values. If it's migrated to Azure Cosmos DB for Table instead, what changes?",
  "options": [
    "The application must be rewritten to use graph traversal syntax",
    "The programming model changes completely, requiring a new key structure",
    "It keeps the same key-value programming model but gains greater scalability, global distribution, automatic secondary indexes, and instant autoscale",
    "It loses the ability to use PartitionKey and RowKey"
  ],
  "correctIndex": 2,
  "explanation": "Cosmos DB for Table uses the same key-value programming model as Azure Table Storage, so an existing PartitionKey/RowKey-based application connects with minimal code changes while gaining scalability, global distribution, automatic secondary indexes, and instant autoscale.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore fundamentals of Azure Cosmos DB/03-identify-azure-cosmos-db-apis.md",
    "heading": "Cosmos DB for Table",
    "quote": "What you gain compared to Azure Table Storage includes greater scalability, global distribution, automatic secondary indexes, and instant autoscale."
  }
},
{
  "id": "usecase-09",
  "tier": "usecase",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore fundamentals of Azure Cosmos DB",
  "question": "A social network needs to model millions of users and quickly traverse complex, multi-hop relationships between them — such as 'friends of friends who like the same pages' — for a recommendation engine. Which Cosmos DB API best fits this requirement?",
  "options": [
    "Azure Cosmos DB for Table",
    "Azure Cosmos DB for Apache Gremlin",
    "Azure Cosmos DB for MongoDB",
    "Azure Cosmos DB for NoSQL"
  ],
  "correctIndex": 1,
  "explanation": "Gremlin models entities as vertices and relationships as edges and is designed for graph traversal scenarios such as social networks and recommendation engines, where the connections between data matter as much as the data itself.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore fundamentals of Azure Cosmos DB/03-identify-azure-cosmos-db-apis.md",
    "heading": "Cosmos DB for Apache Gremlin",
    "quote": "Graph databases are useful when the connections between your data are as important as the data itself: think social networks, recommendation engines, fraud detection, and organizational hierarchies."
  }
},
{
  "id": "usecase-10",
  "tier": "usecase",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore fundamentals of Azure Cosmos DB",
  "question": "A company has an existing application built on MongoDB and wants to move to a fully managed Azure database without rewriting its driver calls or query logic. Which Cosmos DB API should it choose?",
  "options": [
    "Azure Cosmos DB for Apache Cassandra",
    "Azure Cosmos DB for MongoDB",
    "Azure Cosmos DB for Apache Gremlin",
    "Azure Cosmos DB for Table"
  ],
  "correctIndex": 1,
  "explanation": "Azure Cosmos DB for MongoDB is compatible with MongoDB drivers and client libraries and uses the MongoDB Query Language, letting an existing MongoDB application connect without significant code changes.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore fundamentals of Azure Cosmos DB/03-identify-azure-cosmos-db-apis.md",
    "heading": "Cosmos DB for MongoDB",
    "quote": "Azure Cosmos DB for MongoDB is compatible with MongoDB drivers and client libraries, so your existing MongoDB applications can connect to Cosmos DB without significant code changes."
  }
},
{
  "id": "usecase-11",
  "tier": "usecase",
  "domain": "Describe considerations for working with non-relational data on Azure",
  "module": "Explore Azure Storage for nonrelational data",
  "question": "A data engineering team wants a distributed file system in the cloud that analytics tools such as Azure Databricks can mount directly, while also assigning file-and-folder-level permissions independent of Azure RBAC. Which storage option should they choose?",
  "options": [
    "Azure Blob Storage without a hierarchical namespace",
    "Azure Data Lake Storage Gen2",
    "Azure Files with the SMB protocol",
    "Azure Table Storage"
  ],
  "correctIndex": 1,
  "explanation": "Azure Data Lake Storage Gen2 combines Blob Storage's scale with a hierarchical namespace and POSIX-compliant ACLs, and systems like Azure Databricks can mount its distributed file system directly for analytics processing.",
  "source": {
    "path": "dp900/content/Describe considerations for working with non-relational data on Azure/Explore Azure Storage for nonrelational data/03-explore-azure-data-lake-storage-gen2.md",
    "heading": "Explore Azure Data Lake Storage Gen2",
    "quote": "Systems like Azure Databricks can mount a distributed file system hosted in Azure Data Lake Storage Gen2 and use it to process huge volumes of data."
  }
},
{
  "id": "easy-20",
  "tier": "easy",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of large-scale analytics",
  "question": "In Microsoft Fabric, what is the name of the tenant-wide storage layer that every Fabric workload shares?",
  "options": [
    "OneLake",
    "Delta Lake",
    "Unity Catalog",
    "Data Lake Storage Gen2"
  ],
  "correctIndex": 0,
  "explanation": "Fabric's storage is provided by OneLake, a tenant-wide data lake shared by every Fabric workload instead of copying data between silos.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/02-describe-data-warehousing-architecture.md",
    "heading": "Microsoft Fabric",
    "quote": "Storage is provided by OneLake—a tenant-wide data lake that every Fabric workload shares."
  }
},
{
  "id": "easy-21",
  "tier": "easy",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of large-scale analytics",
  "question": "Which open-source storage format does Azure Databricks use as its native storage format for lakehouse tables?",
  "options": [
    "Delta Lake",
    "Plain Apache Parquet with no extra features",
    "Avro",
    "ORC"
  ],
  "correctIndex": 0,
  "explanation": "Azure Databricks uses Delta Lake, which adds transactions, schema enforcement, and versioning on top of Parquet files, giving lakehouse-style reliability at scale.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/01-introduction.md",
    "heading": "Introduction",
    "quote": "It uses Delta Lake—an open-source storage format that adds transactions, schema enforcement, and versioning on top of Parquet files"
  }
},
{
  "id": "easy-22",
  "tier": "easy",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of large-scale analytics",
  "question": "In a star schema used by a data warehouse, which type of table stores the central numeric values being analyzed, such as sales amounts?",
  "options": [
    "Dimension table",
    "Fact table",
    "Lookup table",
    "Snowflake table"
  ],
  "correctIndex": 1,
  "explanation": "Fact tables are the central tables that store numeric measures like sales order data, related to one or more dimension tables that enable aggregation.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/04-explore-analytical-data-stores.md",
    "heading": "Data warehouses",
    "quote": "numeric values are stored in central fact tables, which are related to one or more dimension tables"
  }
},
{
  "id": "easy-23",
  "tier": "easy",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of real-time analytics",
  "question": "Which of these best describes batch processing?",
  "options": [
    "Multiple data records are collected and stored before being processed together in a single operation",
    "Each new piece of data is processed the instant it arrives",
    "Data is only ever processed once a year",
    "Data is discarded after 30 seconds if not processed"
  ],
  "correctIndex": 0,
  "explanation": "Batch processing collects and stores data, then processes the whole group together as a batch, unlike stream processing which handles each event as it arrives.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of real-time analytics/02-understand-batch-and-stream-processing.md",
    "heading": "Understand batch processing",
    "quote": "newly arriving data elements are collected and stored, and the whole group is processed together as a batch"
  }
},
{
  "id": "easy-24",
  "tier": "easy",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of real-time analytics",
  "question": "Approximately what latency is typical for stream processing, compared to batch processing which is typically a few hours?",
  "options": [
    "Seconds or milliseconds",
    "Several days",
    "A full week",
    "Exactly 24 hours"
  ],
  "correctIndex": 0,
  "explanation": "Stream processing latency is typically in the order of seconds or milliseconds, while batch processing latency is usually a few hours.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of real-time analytics/02-understand-batch-and-stream-processing.md",
    "heading": "Understand differences between batch and streaming data",
    "quote": "The latency for batch processing is typically a few hours. Stream processing typically occurs immediately, with latency in the order of seconds or milliseconds."
  }
},
{
  "id": "easy-25",
  "tier": "easy",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of real-time analytics",
  "question": "What is the purpose of the Microsoft Fabric real-time hub?",
  "options": [
    "It acts as a centralized catalog for discovering, exploring, and sharing streaming data across the organization",
    "It stores relational data warehouse tables",
    "It replaces the need for Power BI reports",
    "It's a code editor exclusively for PySpark notebooks"
  ],
  "correctIndex": 0,
  "explanation": "The real-time hub is a centralized catalog that simplifies access, addition, exploration, and sharing of streaming data sources across an organization.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of real-time analytics/04-explore-microsoft-fabric-real-time-intelligence.md",
    "heading": "Real-time hub",
    "quote": "acts as a centralized catalog for your organization. It simplifies access, addition, exploration, and data sharing."
  }
},
{
  "id": "easy-26",
  "tier": "easy",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of data visualization",
  "question": "Which tool is a Windows application used to import data from multiple sources, build a data model, and author reports?",
  "options": [
    "Power BI service",
    "Power BI Desktop",
    "Power BI phone app",
    "Real-Time hub"
  ],
  "correctIndex": 1,
  "explanation": "Power BI Desktop is the Windows application used to import, model, and author reports before publishing them to the Power BI service.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of data visualization/02-describe-power-bi-tools-and-workflow.md",
    "heading": "Microsoft Power BI",
    "quote": "starts with Power BI Desktop, a Microsoft Windows application in which you can import data from a wide range of data sources"
  }
},
{
  "id": "easy-27",
  "tier": "easy",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of data visualization",
  "question": "In an analytical data model, which type of table represents entities you use to group or filter measures, such as product or customer?",
  "options": [
    "Fact table",
    "Dimension table",
    "Measure table",
    "Semantic table"
  ],
  "correctIndex": 1,
  "explanation": "Dimension tables represent the entities used to group or filter data, such as product or customer, with each row identified by a unique key.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of data visualization/03-describe-core-concepts-of-data-modeling.md",
    "heading": "Tables and schema",
    "quote": "Dimension tables represent the entities you want to group or filter by—for example, product or customer."
  }
},
{
  "id": "easy-28",
  "tier": "easy",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of data visualization",
  "question": "Which visualization type is best suited for comparing two numeric measures to identify a relationship or correlation between them?",
  "options": [
    "Pie chart",
    "Scatter plot",
    "Map",
    "Table"
  ],
  "correctIndex": 1,
  "explanation": "Scatter plots plot two numeric measures against each other, making them useful for spotting correlations or relationships.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of data visualization/04-describe-considerations-for-data-visualization.md",
    "heading": "Scatter plots",
    "quote": "Scatter plots are useful when you want to compare two numeric measures and identify a relationship or correlation between them."
  }
},
{
  "id": "medium-21",
  "tier": "medium",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of large-scale analytics",
  "question": "In an ELT (extract, load, and transform) process, when does data transformation occur relative to loading?",
  "options": [
    "Data is transformed before being loaded into the analytical store",
    "Data is copied to the analytical store first, and then transformed",
    "Data is never transformed in an ELT process",
    "Data is transformed only during real-time streaming, never in ELT"
  ],
  "correctIndex": 1,
  "explanation": "In ELT, data is first copied into the store and then transformed, whereas in ETL the data is transformed before being loaded.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/02-describe-data-warehousing-architecture.md",
    "heading": "Describe data warehousing architecture",
    "quote": "In ETL processes, the data is transformed before being loaded into an analytical store, while in an ELT process the data is copied to the store and then transformed."
  }
},
{
  "id": "medium-22",
  "tier": "medium",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of large-scale analytics",
  "question": "Which Microsoft Fabric item is best described as a fully managed, SQL Server-compatible relational data warehouse with strong schema enforcement?",
  "options": [
    "Fabric Lakehouse",
    "Fabric Warehouse",
    "Fabric Notebooks",
    "Fabric Eventstream"
  ],
  "correctIndex": 1,
  "explanation": "The Fabric Warehouse is a fully managed, SQL Server-compatible relational data warehouse for structured analytics with strong schema enforcement, while a Lakehouse combines lake storage with SQL querying.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/02-describe-data-warehousing-architecture.md",
    "heading": "Microsoft Fabric",
    "quote": "Fabric Warehouse: a fully managed, SQL Server–compatible relational data warehouse for structured analytics with strong schema enforcement."
  }
},
{
  "id": "medium-23",
  "tier": "medium",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of large-scale analytics",
  "question": "What does a OneLake shortcut do?",
  "options": [
    "It copies external data into OneLake on a nightly schedule",
    "It creates a live reference to external storage so the data appears in a Lakehouse without being copied",
    "It automatically deletes stale data from OneLake",
    "It permanently converts CSV files into Delta Lake format"
  ],
  "correctIndex": 1,
  "explanation": "A shortcut is a live reference to external storage such as ADLS Gen2, S3, or another OneLake location, making the data appear in OneLake without copying or moving it.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/03-explore-data-ingestion-pipelines.md",
    "heading": "OneLake Shortcuts",
    "quote": "a shortcut makes external data appear as if it's already in your Lakehouse. No pipelines, no movement, no duplication."
  }
},
{
  "id": "medium-24",
  "tier": "medium",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of real-time analytics",
  "question": "In a lambda architecture that combines batch and stream processing, what happens to the nonstreaming data?",
  "options": [
    "It's discarded once it has been shown on a real-time dashboard",
    "It's periodically batch processed and the results are persisted in an analytical data store for historical analysis",
    "It's only ever kept inside the streaming source and never persisted elsewhere",
    "It bypasses the data lake entirely and is sent straight to Power BI"
  ],
  "correctIndex": 1,
  "explanation": "In a lambda architecture, nonstreaming data is periodically batch processed and the results are persisted in an analytical data store, often called a data warehouse, for historical analysis.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of real-time analytics/02-understand-batch-and-stream-processing.md",
    "heading": "Combine batch and stream processing",
    "quote": "The nonstreaming data is periodically batch processed to prepare it for analysis, and the results are persisted in an analytical data store"
  }
},
{
  "id": "medium-25",
  "tier": "medium",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of real-time analytics",
  "question": "How does a kappa architecture differ from a lambda architecture?",
  "options": [
    "Kappa adds an additional batch layer for redundancy",
    "Kappa eliminates the separate batch layer, treating all data as a continuous stream that can be replayed",
    "Kappa only works with relational databases, never streams",
    "Kappa requires Apache Hadoop instead of Spark"
  ],
  "correctIndex": 1,
  "explanation": "The kappa architecture simplifies lambda by removing the separate batch layer entirely, treating all data as a continuous stream and replaying it when historical reprocessing is needed.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of real-time analytics/02-understand-batch-and-stream-processing.md",
    "heading": "Combine batch and stream processing",
    "quote": "The kappa architecture is a simpler alternative that eliminates the separate batch layer entirely—treating all data as a continuous stream and replaying it when historical reprocessing is needed."
  }
},
{
  "id": "medium-26",
  "tier": "medium",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of real-time analytics",
  "question": "Which Azure service ingests high volumes of event data, delivers events within a partition in order, and guarantees at-least-once delivery?",
  "options": [
    "Azure Event Hubs",
    "Azure Data Lake Storage Gen2",
    "Azure Stream Analytics",
    "Apache Kafka"
  ],
  "correctIndex": 0,
  "explanation": "Azure Event Hubs ingests high-volume event data, delivers events within a partition in order, and guarantees at-least-once delivery.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of real-time analytics/03-explore-common-elements-of-stream-processing-architecture.md",
    "heading": "**Sources** for stream processing",
    "quote": "Events within a partition are delivered in order, and Event Hubs guarantees at-least-once delivery."
  }
},
{
  "id": "medium-27",
  "tier": "medium",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of data visualization",
  "question": "What does Direct Lake mode allow a Power BI semantic model to do?",
  "options": [
    "Read Delta tables from OneLake directly without importing or pre-aggregating data",
    "Automatically translate DAX measures into KQL queries",
    "Store all data exclusively in Power BI Desktop's local cache",
    "Require a nightly scheduled refresh before any query can run"
  ],
  "correctIndex": 0,
  "explanation": "Direct Lake mode lets semantic models read Delta tables from OneLake directly, without a separate data import or refresh cycle.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/02-describe-data-warehousing-architecture.md",
    "heading": "Describe data warehousing architecture",
    "quote": "semantic models can use Direct Lake mode to read Delta tables from OneLake directly, without importing or pre-aggregating data at all"
  }
},
{
  "id": "medium-28",
  "tier": "medium",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of data visualization",
  "question": "What is the purpose of defining a hierarchy in a Power BI data model, such as grouping days into months and months into years in a Time table?",
  "options": [
    "To let users drill up or drill down through aggregated values at different levels of a dimension",
    "To enforce referential integrity between fact tables",
    "To physically re-sort the rows stored in the fact table",
    "To automatically encrypt sensitive columns"
  ],
  "correctIndex": 0,
  "explanation": "Hierarchies let users drill up or drill down through aggregated values at different levels of a dimension, such as day, month, and year.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of data visualization/03-describe-core-concepts-of-data-modeling.md",
    "heading": "Attribute hierarchies",
    "quote": "Hierarchies let you drill up or drill down through aggregated values at different levels of a dimension."
  }
},
{
  "id": "hard-19",
  "tier": "hard",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of large-scale analytics",
  "question": "Which Microsoft Fabric ingestion feature continuously replicates an external database such as Azure SQL Database or Snowflake into OneLake in near-real-time, without requiring any pipeline authoring?",
  "options": [
    "Fabric Mirroring",
    "OneLake Shortcuts",
    "Dataflows Gen2",
    "Fabric Eventstream"
  ],
  "correctIndex": 0,
  "explanation": "Fabric Mirroring continuously replicates external databases directly into OneLake in near-real-time once the source connection is configured, without any pipeline authoring, unlike shortcuts which only reference external storage without replicating it.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/03-explore-data-ingestion-pipelines.md",
    "heading": "Mirroring",
    "quote": "Fabric Mirroring continuously replicates an external database—Azure SQL Database, Snowflake, Azure Cosmos DB, and others—directly into OneLake in near-real-time."
  }
},
{
  "id": "hard-20",
  "tier": "hard",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of large-scale analytics",
  "question": "Compared to older SSAS Multidimensional cubes that pre-aggregated numeric values in advance, how does a modern semantic model (the tabular model behind Power BI and Fabric) handle aggregations?",
  "options": [
    "Aggregations are computed at query time rather than stored in advance",
    "Aggregations must be manually recalculated every night in a batch job",
    "Aggregations are not supported in a semantic model",
    "Aggregations are stored permanently and never recalculated"
  ],
  "correctIndex": 0,
  "explanation": "Unlike cubes that pre-aggregated values in advance, a semantic model defines tables, relationships, and DAX measures, with aggregations computed at query time.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/02-describe-data-warehousing-architecture.md",
    "heading": "Describe data warehousing architecture",
    "quote": "with aggregations computed at query time rather than stored in advance"
  }
},
{
  "id": "hard-21",
  "tier": "hard",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of large-scale analytics",
  "question": "How does a snowflake schema differ from a basic star schema?",
  "options": [
    "A snowflake schema has no fact table at all",
    "A snowflake schema extends the star schema by adding tables related to the dimension tables to represent dimensional hierarchies",
    "A snowflake schema supports only a single dimension table",
    "A snowflake schema stores data exclusively in a data lake, never in a warehouse"
  ],
  "correctIndex": 1,
  "explanation": "A snowflake schema extends a star schema by relating dimension tables to further tables representing hierarchies, such as linking a product dimension to a product category table.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/04-explore-analytical-data-stores.md",
    "heading": "Data warehouses",
    "quote": "it's often extended into a snowflake schema by adding additional tables related to the dimension tables to represent dimensional hierarchies"
  }
},
{
  "id": "hard-22",
  "tier": "hard",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of real-time analytics",
  "question": "Which Microsoft Fabric Real-Time Intelligence component is a database optimized for time-series and event data, queried using KQL?",
  "options": [
    "Eventstream",
    "Eventhouse",
    "Activator",
    "Real-Time Dashboards"
  ],
  "correctIndex": 1,
  "explanation": "Eventhouse is the database optimized for time-series and event data in Fabric Real-Time Intelligence, queried with Kusto Query Language, distinct from Eventstream which ingests and routes the data.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of real-time analytics/03-explore-common-elements-of-stream-processing-architecture.md",
    "heading": "Real-time analytics services",
    "quote": "Eventhouse (a database optimized for time-series and event data, queried using KQL — Kusto Query Language, a query language designed for fast log and telemetry analysis)"
  }
},
{
  "id": "hard-23",
  "tier": "hard",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of real-time analytics",
  "question": "Which of the following is described as a source for ingesting data for stream processing, rather than a typical sink for the output of stream processing?",
  "options": [
    "Microsoft Power BI",
    "Azure IoT Hub",
    "Azure SQL Database",
    "Microsoft OneLake"
  ],
  "correctIndex": 1,
  "explanation": "Azure IoT Hub is listed as a source used to ingest event data from IoT devices, whereas Power BI, Azure SQL Database, and OneLake are listed as sinks that receive the processed stream output.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of real-time analytics/03-explore-common-elements-of-stream-processing-architecture.md",
    "heading": "**Sinks** for stream processing",
    "quote": "Azure Data Lake Store Gen 2, Microsoft OneLake, or Azure blob storage: Used to persist the processed results as a file."
  }
},
{
  "id": "hard-24",
  "tier": "hard",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of real-time analytics",
  "question": "In Spark Structured Streaming, how is a live data stream conceptually treated once it's read into Spark?",
  "options": [
    "As a static file that never changes once loaded",
    "As a dataframe—a table of rows and columns that continuously fills with new data as events arrive",
    "As a single scalar value updated once per day",
    "As a binary large object with no defined schema"
  ],
  "correctIndex": 1,
  "explanation": "Spark Structured Streaming reads incoming data into a dataframe that behaves like a table but keeps growing in real time as new events arrive.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of real-time analytics/05-explore-apache-spark-structured-streaming.md",
    "heading": "Spark Structured Streaming",
    "quote": "Spark reads incoming data into a dataframe—essentially a table of rows and columns that continuously fills with new data as events arrive."
  }
},
{
  "id": "hard-25",
  "tier": "hard",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of data visualization",
  "question": "What is the role of the VertiPaq engine when data is loaded into a Power BI semantic model?",
  "options": [
    "It stores the data in an efficient in-memory columnar store and computes aggregations at query time",
    "It's a network protocol used to stream data from IoT devices",
    "It's the rendering engine behind the Power BI phone app",
    "It physically pre-sorts fact tables on disk into a snowflake schema"
  ],
  "correctIndex": 0,
  "explanation": "When data is loaded into a semantic model, Power BI stores it in an efficient in-memory columnar store using the VertiPaq engine, computing aggregations at query time.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of data visualization/03-describe-core-concepts-of-data-modeling.md",
    "heading": "Tables and schema",
    "quote": "Power BI stores it in an efficient in-memory columnar store using the VertiPaq engine. Aggregations are calculated at query time"
  }
},
{
  "id": "hard-26",
  "tier": "hard",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of data visualization",
  "question": "Which Power BI AI-driven visualization feature enables interactive drill-down across multiple dimensions to identify what is contributing to a value?",
  "options": [
    "Smart narrative",
    "Q&A visual",
    "Key influencers",
    "Decomposition tree"
  ],
  "correctIndex": 3,
  "explanation": "The decomposition tree enables interactive drill-down across multiple dimensions to identify contributing factors, distinct from key influencers, which identifies which factors most strongly drive a metric.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of data visualization/04-describe-considerations-for-data-visualization.md",
    "heading": "AI-driven visualizations in Power BI",
    "quote": "Decomposition tree: enables interactive drill-down across multiple dimensions to identify what is contributing to a value."
  }
},
{
  "id": "hard-27",
  "tier": "hard",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of data visualization",
  "question": "What is required to use Copilot capabilities such as generating DAX measures or creating report pages in Power BI?",
  "options": [
    "Nothing extra — Copilot is included free with every Power BI account",
    "Fabric capacity (F2 or higher) or Power BI Premium (P1 or higher)",
    "A separate Azure Databricks workspace",
    "An on-premises data gateway"
  ],
  "correctIndex": 1,
  "explanation": "Copilot capabilities in Power BI require Fabric capacity (F2 or higher) or Power BI Premium (P1 or higher), unlike features such as the smart narrative visual, which don't require a Copilot license.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of data visualization/02-describe-power-bi-tools-and-workflow.md",
    "heading": "Copilot in Power BI",
    "quote": "Copilot capabilities require Fabric capacity (F2 or higher) or Power BI Premium (P1 or higher)"
  }
},
{
  "id": "usecase-12",
  "tier": "usecase",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of large-scale analytics",
  "question": "A company's data team works entirely in structured tables, writes SQL every day, and needs strong schema enforcement plus good concurrency for many simultaneous analysts, all within a Microsoft Fabric workspace. Which item should they use?",
  "options": [
    "Fabric Lakehouse",
    "Fabric Warehouse",
    "Fabric Eventstream",
    "Azure Databricks Notebooks"
  ],
  "correctIndex": 1,
  "explanation": "Fabric Warehouse is the right choice when data is structured, the team writes SQL, and strong schema enforcement plus concurrency for many simultaneous users is required.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/04-explore-analytical-data-stores.md",
    "heading": "Azure services for analytical stores",
    "quote": "It's the right choice when your data is structured, your team writes SQL, and you need strong schema enforcement and concurrency for many simultaneous users."
  }
},
{
  "id": "usecase-13",
  "tier": "usecase",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of large-scale analytics",
  "question": "A company must keep a dataset in its existing ADLS Gen2 account for compliance reasons, but analysts need to query it from a Microsoft Fabric Lakehouse without duplicating the files. What should they set up?",
  "options": [
    "Fabric Mirroring",
    "A OneLake shortcut",
    "Fabric Eventstream",
    "A scheduled Fabric pipeline copy activity"
  ],
  "correctIndex": 1,
  "explanation": "A OneLake shortcut is designed for exactly this scenario: it makes external data appear in a Lakehouse without moving or duplicating it, which is useful when data must stay in its original location for compliance reasons.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of large-scale analytics/03-explore-data-ingestion-pipelines.md",
    "heading": "OneLake Shortcuts",
    "quote": "This is particularly useful when data must stay in its original location for compliance or cost reasons, but still needs to be queryable from Fabric."
  }
},
{
  "id": "usecase-14",
  "tier": "usecase",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of real-time analytics",
  "question": "A building safety system must trigger alarms and unlock doors the instant smoke or heat is detected, so residents can escape immediately. Which data processing approach fits this requirement?",
  "options": [
    "Batch processing",
    "Stream processing",
    "A weekly scheduled ETL job",
    "Manual data entry and review"
  ],
  "correctIndex": 1,
  "explanation": "This is a time-critical operation requiring an instant real-time response, which is exactly what stream processing is designed for, unlike batch processing which introduces a delay before results are available.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of real-time analytics/02-understand-batch-and-stream-processing.md",
    "heading": "Understand stream processing",
    "quote": "Stream processing is ideal for time-critical operations that require an instant real-time response. For example, a system that monitors a building for smoke and heat needs to trigger alarms and unlock doors"
  }
},
{
  "id": "usecase-15",
  "tier": "usecase",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of real-time analytics",
  "question": "A team wants a single storage layer that can act as the sink for real-time streaming writes while also serving as the source for historical batch queries, with schema enforcement so bad records can't slip in. Which technology fits best?",
  "options": [
    "A plain CSV file in blob storage",
    "Delta Lake",
    "Azure IoT Hub",
    "A pie chart visual in Power BI"
  ],
  "correctIndex": 1,
  "explanation": "Delta Lake unifies batch and streaming: the same Delta table can serve as both a streaming sink and a source for batch queries, while enforcing schema so incompatible records are rejected.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of real-time analytics/05-explore-apache-spark-structured-streaming.md",
    "heading": "Delta Lake",
    "quote": "Unified batch and streaming: The same Delta table can serve as both a streaming sink (data written to it in real time) and a source for batch queries"
  }
},
{
  "id": "usecase-16",
  "tier": "usecase",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of data visualization",
  "question": "An analyst wants to see how monthly subscription revenue has changed over the past two years, to spot seasonal patterns and long-term trends. Which visualization type should they use?",
  "options": [
    "A pie chart",
    "A scatter plot",
    "A line chart",
    "A map"
  ],
  "correctIndex": 2,
  "explanation": "Line charts are useful for examining trends, often over time, making them the right choice for tracking how a value changes across many time periods.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of data visualization/04-describe-considerations-for-data-visualization.md",
    "heading": "Line charts",
    "quote": "Line charts can also be used to compare categorized values and are useful when you need to examine trends, often over time."
  }
},
{
  "id": "usecase-17",
  "tier": "usecase",
  "domain": "Describe an analytics workload on Azure",
  "module": "Explore fundamentals of data visualization",
  "question": "A business analyst who does not have Power BI Desktop installed needs to make a quick edit to a report directly from a browser while collaborating in a shared Microsoft Fabric workspace. What lets them do this?",
  "options": [
    "The Power BI phone app only",
    "Web-based report editing built into Power BI within Fabric",
    "The Azure Data Factory pipeline editor",
    "SQL Server Management Studio"
  ],
  "correctIndex": 1,
  "explanation": "Power BI's integration in Microsoft Fabric provides web-based report editing, letting analysts create and update reports entirely in the browser without installing Power BI Desktop.",
  "source": {
    "path": "dp900/content/Describe an analytics workload on Azure/Explore fundamentals of data visualization/02-describe-power-bi-tools-and-workflow.md",
    "heading": "Power BI in Microsoft Fabric",
    "quote": "Web-based report editing: analysts can create and update reports entirely in the browser, making Power BI accessible without installing Power BI Desktop."
  }
},
];
