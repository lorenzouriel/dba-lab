# Summary

Completed

- 2 minutes

In this module, you learned how to implement comprehensive data security and compliance features for SQL Server, Azure SQL Database, and SQL databases in Microsoft Fabric.

You explored how to:

- Implement data encryption using Always Encrypted for client-side encryption and column-level encryption for granular protection
- Configure Dynamic Data Masking to protect sensitive columns while maintaining data usability for authorized users
- Design Row-Level Security policies to filter data access based on user context and business rules
- Apply object-level permissions using roles and schemas to implement the principle of least privilege
- Enable passwordless authentication using Microsoft Entra ID and Managed Identity
- Set up auditing to track database activity and maintain compliance records
- Secure AI model endpoints using Managed Identity authentication
- Protect GraphQL, REST, and MCP endpoints from unauthorized access

## Key takeaways

- Defense in depth requires combining multiple security features. Use encryption for data protection, masking for presentation-layer security, and Row-Level Security for row-level access control.
- Managed Identity eliminates credential management risks by letting Azure handle authentication automatically.
- Auditing provides accountability, but plan your retention strategy and storage location to meet compliance requirements while managing costs.

## Learn more

- [Always Encrypted documentation](https://learn.microsoft.com/en-us/sql/relational-databases/security/encryption/always-encrypted-database-engine)
- [Dynamic Data Masking in Azure SQL Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/dynamic-data-masking-overview)
- [Row-Level Security](https://learn.microsoft.com/en-us/sql/relational-databases/security/row-level-security)
- [Microsoft Entra authentication with Azure SQL](https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-overview)
- [Auditing for Azure SQL Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/auditing-overview)
