# Implement SQL solutions by using AI-assisted tools

Estimated Time: 45 minutes

In this exercise, you practice using AI-assisted development tools to design and implement SQL solutions. You configure GitHub Copilot in Visual Studio Code, create custom instruction files for consistent T-SQL code generation, and use Copilot to generate database objects.

You are a database developer who wants to accelerate your development workflow using AI-assisted tools. Your team has adopted GitHub Copilot to help write T-SQL code following consistent standards and best practices.

📝 These exercises ask you to copy and paste T-SQL code. Please verify that the code has been copied correctly, before executing the code.

## Prerequisites

- An Azure subscription
- A GitHub account with Copilot access
- Visual Studio Code installed on your computer
- Basic familiarity with Azure SQL Database and T-SQL

## Provision an Azure SQL Database

First, you need to create an Azure SQL Database to use with GitHub Copilot.

1. Sign in to the Azure portal.
2. Navigate to the Azure SQL page, in the resource menu expand Azure SQL Database, and then select SQL databases.
3. Select + Create and select SQL database.
4. Fill in the required information on the Create SQL Database page:

| Setting | Value |
|---|---|
| Subscription | Select your Azure subscription. |
| Resource group | Select or create a resource group. |
| Database name | AdventureWorksLT |
| Server | Select Create new and create a new server with a unique name, using SQL authentication with an admin login and password. |
| Workload environment | Development |
| Backup storage redundancy | Locally-redundant backup storage |

5. Select Next: Networking and configure the following settings:

| Setting | Value |
|---|---|
| Connectivity method | Public endpoint |
| Allow Azure services and resources to access this server | Yes |
| Add current client IP address | Yes |

6. Select Next: Security, then select Next: Additional settings.
7. On the Additional settings page, set Use existing data to Sample to create the AdventureWorksLT sample database.
8. Select Review + create, review the settings, and then select Create.
9. Wait for the deployment to complete, then navigate to the new Azure SQL Database resource.

## Set up Visual Studio Code with GitHub Copilot

Next, configure Visual Studio Code with the required extensions for AI-assisted SQL development.

1. Open Visual Studio Code on your computer.
2. Select the Extensions icon in the Activity Bar (or press Ctrl+Shift+X).
3. Search for and install the following extensions:
   - GitHub Copilot Chat (by GitHub)
   - SQL Server (mssql) (by Microsoft)
4. After installation, select the Accounts icon in the Activity Bar.
5. Select Sign in to use GitHub Copilot and sign in with your GitHub account that has Copilot access.
6. Verify the Copilot icon appears in the status bar, indicating Copilot is active.

## Connect to the Azure SQL Database

Now, connect Visual Studio Code to your Azure SQL Database.

1. In Visual Studio Code, select the SQL Server icon in the Activity Bar.
2. Select Add Connection and enter the following connection details:

| Setting | Value |
|---|---|
| Server name | Your Azure SQL server name (for example, yourserver.database.windows.net) |
| Database name | AdventureWorksLT |
| Authentication type | SQL Login |
| User name | Your SQL admin username |
| Password | Your SQL admin password |
| Trust server certificate | True |

3. Select Connect and verify the connection appears in the Connections pane.
4. Expand your connection to view the database objects (Tables, Views, Stored Procedures).

## Create a custom instruction file for Copilot

Custom instruction files guide Copilot to generate code that follows your team's standards. Create an instruction file for T-SQL development.

1. In Visual Studio Code, open the folder where you want to store your database project (or create a new folder).
2. Create a new folder named .github in the root of your project.
3. Create a new file named copilot-instructions.md inside the .github folder.
4. Add the following content to the instruction file:

```
# T-SQL Development Guidelines for Copilot

## Naming Conventions
- Tables: PascalCase, singular form (Customer, Product, SalesOrder)
- Columns: PascalCase (FirstName, OrderDate, UnitPrice)
- Stored procedures: usp_ActionEntity (usp_GetCustomerOrders, usp_InsertProduct)
- Views: vw_EntityDescription (vw_ActiveCustomers, vw_ProductInventory)
- Indexes: IX_TableName_ColumnName

## T-SQL Style Guidelines
- Always use explicit column lists in SELECT statements (avoid SELECT *)
- Include schema prefix for all objects (SalesLT.Product, SalesLT.Customer)
- Use ANSI JOIN syntax (INNER JOIN, LEFT JOIN) instead of comma-separated tables
- Include SET NOCOUNT ON at the beginning of stored procedures
- Use TRY...CATCH blocks for error handling in stored procedures

## Security Requirements
- Use parameterized queries, never concatenate user input
- Never include actual credentials or connection strings in code
- Use least-privilege principles for GRANT statements

## Comments
- Include a header comment with procedure name, purpose, and author
- Add inline comments for complex logic
```

5. Save the file. Copilot will now consider these guidelines when generating T-SQL code.

## Use Copilot to generate a stored procedure

Now use GitHub Copilot to generate a stored procedure following your custom guidelines.

1. In Visual Studio Code, create a new file named usp_GetCustomerOrderSummary.sql.
2. Open the Copilot Chat panel by pressing Ctrl+Alt+I (or selecting the Copilot Chat icon).
3. Make sure the Mode is set to Ask in the bottom-left of the Copilot Chat panel.
4. In the chat, type the following prompt:

```
Create a stored procedure na
```

> **Note:** Source content was truncated at this point (exceeded 50,000 character limit). Remaining content to be appended when provided.
