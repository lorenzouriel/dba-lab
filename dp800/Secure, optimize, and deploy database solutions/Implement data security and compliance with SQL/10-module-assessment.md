# Module assessment

Completed

- 5 minutes

> AI-generated content
>
> The questions and answer choices in this module assessment were generated using AI and reviewed by a human author.

**1. A financial services company needs to protect credit card numbers stored in an Azure SQL Database. The application must be able to perform equality searches on the encrypted column, but database administrators should not be able to view the plaintext values. Which encryption approach should you recommend?**

- Transparent Data Encryption (TDE)
- Always Encrypted with deterministic encryption
- Column-level encryption with symmetric keys
- Always Encrypted with randomized encryption

**2. A retail company wants support staff to verify customer phone numbers by seeing only the last four digits. The actual phone numbers must remain unchanged in the database for billing system integration. Which security feature should you implement?**

- Row-Level Security with a filter predicate
- A view that truncates phone numbers
- Dynamic Data Masking with partial masking
- Always Encrypted with deterministic encryption

**3. A multitenant SaaS application stores data for multiple customers in the same database tables. Each table includes a TenantID column. You need to ensure users can only query rows belonging to their own tenant, even if they write SELECT statements directly. Which implementation approach should you use?**

- Create separate views for each tenant and grant SELECT only on views
- Create a security policy with a filter predicate that checks TenantID against session context
- Implement Dynamic Data Masking on the TenantID column
- Use object-level permissions to deny SELECT on rows with other TenantIDs

**4. A development team needs to deploy an Azure App Service that connects to Azure SQL Database. The security policy requires eliminating stored credentials from application configuration. What authentication method should the team implement?**

- SQL authentication with credentials stored in Azure Key Vault
- Microsoft Entra authentication with a service principal and client secret
- System-assigned managed identity with Microsoft Entra authentication
- Contained database user with a complex password

**5. An organization needs to track all data modifications to a sensitive table for compliance purposes. The audit logs must be retained for seven years and protected from deletion by database administrators. For Azure SQL Database, which auditing configuration meets these requirements?**

- Database audit specification writing to the Windows Application log
- Azure SQL auditing to Blob Storage with immutable storage policy
- Extended Events session capturing data modifications
- SQL Server Audit writing to a file share
