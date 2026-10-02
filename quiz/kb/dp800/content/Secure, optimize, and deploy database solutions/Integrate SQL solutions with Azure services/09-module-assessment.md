# Module assessment

Completed

- 5 minutes

> AI-generated content
>
> The questions and answer choices in this module assessment were generated using AI and reviewed by a human author.

**1. You're creating a Data API Builder configuration and need to store the database connection string securely without hardcoding it. Which approach should you use?**

- Store the connection string directly in the dab-config.json file for easy access
- Use the @env() syntax to reference an environment variable containing the connection string
- Create a separate credentials.json file and import it into the configuration
- Encrypt the connection string using Base64 encoding before adding it to the configuration

**2. A development team wants to ensure their Data API Builder entity only allows clients to retrieve data, not modify it. Which permission configuration achieves this?**

- Configure permissions with only the 'read' action for the appropriate roles
- Set the source type to 'view' which automatically prevents all write operations
- Disable REST and only enable GraphQL with operation set to 'mutation'
- Use the 'anonymous' role which only supports read operations by default

**3. Your organization is deploying Data API Builder to production and needs to use managed identity for database authentication. Which Azure hosting option supports this requirement while also providing automatic scaling based on request volume?**

- Azure Virtual Machines with autoscale sets
- Azure Container Apps with system-assigned managed identity
- Azure Functions consumption plan
- Azure Static Web Apps database connections

**4. You need to monitor your Data API Builder deployment and create alerts when the 95th percentile response time exceeds 2 seconds. Which Azure service and query approach should you use?**

- Azure Monitor metrics with a threshold alert on average response time
- Application Insights with a Kusto query using the percentile() function on request duration
- Log Analytics with container CPU metrics
- Azure Monitor health probes configured with a 2-second timeout
