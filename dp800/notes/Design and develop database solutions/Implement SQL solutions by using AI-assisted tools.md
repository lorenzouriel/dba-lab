## Introduction
- This module = AI-assisted development tools (GitHub Copilot, Fabric Copilot, MCP) for SQL platforms — lighter/conceptual vs the syntax-heavy modules, but DP-800 still tests terminology and workflow understanding here

- **Exam angle**: expect "what does X do" / "which tool for which platform" / security-policy scenario questions rather than syntax recall

## Describe AI-assisted development tools
- Two primary assistants: **GitHub Copilot** (works in SSMS 22+, VS Code, Visual Studio — general dev environment) vs **Fabric Copilot** (native to Fabric workspaces — data engineering/science/analytics/lakehouse context)

- Platform coverage:
    - SQL Server, Azure SQL DB, Azure SQL MI → **GitHub Copilot** (via SSMS/VS Code)
    - SQL DB in Fabric → **both**: Fabric Copilot (in-portal) + GitHub Copilot (external tools)

- Core capabilities: code completion, natural-language-to-SQL, code explanation, query optimization suggestions, error/debugging assistance

- **MCP (Model Context Protocol)** — lets the AI assistant query your **actual live schema/data/metadata** instead of relying only on visible editor context → more accurate, contextual suggestions

- **Exam angle**: know Fabric SQL DB is the only platform with **dual** Copilot access (Fabric Copilot + GitHub Copilot); AI-generated code must always be **human-reviewed before execution**, especially data-modifying or security-related statements — this "always review" principle is a recurring exam theme across this whole module

## Interpret security impact of AI-assisted tools
- Data sent to the AI service: current code/query being written, open-file context, connected DB schema info, your natural-language prompts

- **Key claim to remember**: prompts/responses are **not used to train the underlying models**; data is encrypted in transit and at rest (both Copilot and Fabric Copilot)

- Organizational policy considerations before enabling: data classification (PII/financial/healthcare), compliance framework alignment, IP/trade-secret concerns around schema exposure, access-control alignment with existing DB permissions

- **GitHub Copilot security features**:
    - Content filtering — flags SQL injection patterns and other security anti-patterns
    - Org-level policy controls (admin-configurable — which repos can use Copilot, public-code matching)
    - Audit logging (GitHub Enterprise Cloud)

- **Credential protection best practices**:
    - Never paste real credentials/connection strings into prompts
    - Use environment variables / parameterized approaches instead of hardcoded passwords
    - Review AI output before committing to source control

- **Critical review checklist for AI-generated code**:
    - Verify `GRANT`/`REVOKE` suggestions against **least-privilege** model
    - Validate dynamic SQL is parameterized (`sp_executesql` with parameters) → injection risk otherwise
    - Check SELECT/view/proc output doesn't over-expose data

- **MCP-specific security**: use **dedicated read-only service accounts** for schema-only needs (least privilege), consider private endpoints/VPN for sensitive environments over public network MCP traffic, understand what "data sampling" configurations actually transmit

- **Exam angle**: "not used for model training / encrypted in transit+at rest" is a testable factual claim; least-privilege MCP service accounts and dynamic-SQL-injection review are the two most likely scenario-question hooks

## Enable GitHub Copilot and Fabric Copilot
- **Prerequisites**:
    - GitHub Copilot: GitHub account w/ Copilot subscription (Individual/Business/Enterprise), supported IDE (VS Code, Visual Studio, **SSMS 22+**), internet connection
    - Fabric Copilot: **Fabric capacity F2+ or Power BI Premium P1+**, workspace permissions, tenant-level enablement by admin

- **SSMS setup path**: Visual Studio Installer → Modify SSMS install → Workloads tab → **AI Assistance** workload → install → sign in via Copilot badge (top-right) → "Open Chat Window to Sign In"

- **VS Code setup path**: install **GitHub Copilot** extension + **GitHub Copilot Chat** extension + **MSSQL extension** (for DB-aware chat) → sign in → right-click connected DB → **"Chat with this database"** for schema-aware conversation

- **Fabric Copilot setup — two levels**:
    - **Tenant level** (Fabric Administrator only): Admin portal → Tenant settings → Copilot/Azure OpenAI section → enable → assign security groups
    - **Workspace level**: once tenant-enabled, available in Data Engineering, Data Warehouse, Data Science experiences per user permissions

- **Verification steps** (know these — could appear as "how do you confirm Copilot is working" scenario):
    - SSMS: `Ctrl+\, Ctrl+C` opens Copilot Chat
    - VS Code: `Ctrl+Alt+I` opens Copilot Chat panel
    - Fabric: ask "Describe the tables in this database" and confirm schema-accurate response

- **Exam angle**: know the exact prerequisite tiers (**SSMS 22+**, **Fabric F2+/PBI P1+**) and that SSMS Copilot is installed via the **Workloads → AI Assistance** path in the VS Installer — very specific, testable details

## Configure model and MCP tool options
- Multiple underlying models selectable in Copilot Chat (GPT-family for complex reasoning/design, Claude-family strong at explanation/documentation, Gemini in some configs) — switch via model-picker dropdown in SSMS or VS Code chat panel

- **MCP client-server architecture** — memorize the three roles:
    - **MCP Host**: the AI environment itself (e.g., GitHub Copilot)
    - **MCP Client**: protocol client connecting to servers
    - **MCP Server**: exposes a specific data source/tool (e.g., a SQL database)

- To use MCP in VS Code: switch chat mode to **Agent mode** (from Ask/Edit/Agent selector) → MCP tools only usable in Agent mode

- Adding a server: Command Palette → **`MCP: Add Server`** → choose HTTP or Stdio type → provide URL/config; or manually edit **`.vscode/mcp.json`**:
```json
{
  "servers": {
    "sql-server": {
      "type": "http",
      "url": "https://your-mcp-endpoint/mcp"
    }
  }
}
```

- Named MCP server options: **SQL MCP Server** (Microsoft OSS, built on **Data API builder**, for SQL Server/Azure SQL), **Microsoft Fabric MCP Server** (connects to Fabric data agents), **Azure MCP Server** (broader Azure resource integration)

- **Fabric side**: publish a **data agent** → Settings → **Model Context Protocol tab** → copy MCP server URL → use that URL as the endpoint in external tools (VS Code etc.) — this lets one data agent serve both the Fabric portal and external IDEs

- Best practices: start with defaults, match model capability to task complexity, **limit MCP scope to least privilege** (schema-only if that's all that's needed), retest after config changes

- **Exam angle**: the MCP Host/Client/Server terminology, Agent-mode-required-for-MCP-tools rule, and the `.vscode/mcp.json` config pattern (`"type": "http"`, `"url"`) are the concrete testable specifics

## Create and configure GitHub Copilot instruction files
- Two file types, **know the distinction and exact paths**:
    - **Repository instructions**: `copilot-instructions.md` in the **`.github`** folder at repo root → applies to everyone in that repo automatically
    - **Prompt files**: `*.prompt.md` files in **`.github/prompts`** folder → reusable templates for specific recurring tasks, referenced explicitly (via `#` in chat or the prompt picker)

- Instruction file content = markdown; typically covers naming conventions, T-SQL style rules, security requirements, performance guidelines — e.g.:
```markdown
### Naming Conventions
- Tables: PascalCase, singular
- Stored procedures: usp_ActionEntity
### T-SQL Style
- Explicit column lists, schema-prefixed names, ANSI JOIN syntax
### Security
- Never generate GRANT to public; parameterized queries only
```
- Configuration locations: VS Code → Settings → "GitHub Copilot: Instructions"; Visual Studio → Tools > Options > GitHub > Copilot; or explicitly via Command Palette → **`Chat: Configure Instructions`**

- Prompt file example uses `{{parameterName}}` placeholder syntax for template variables

- Best practices: be specific (not "use good naming" — give the exact pattern), provide concrete code examples, put highest-priority rules first, test iteratively, keep instructions current

- Team strategies: centralized master instruction file shared/copied across repos, layered org-level + repo-level instructions, version-controlled so changes are tracked over time

- **Exam angle**: the exact folder paths (`.github/copilot-instructions.md` vs `.github/prompts/*.prompt.md`) are the single most testable fact in this unit — expect a direct "where do you place X file" question

## Connect to MCP server endpoints
- **SQL Server / Azure SQL**: use **SQL MCP Server** (Data API builder-based) OR the simpler built-in MSSQL extension "Chat with this database" (no separate MCP server setup needed for basic schema-aware chat)

- **Azure SQL specific**: also supports **Azure MCP Server** for broader Azure resource integration; requires **firewall/network configuration** (client IP allowed, private endpoint config for restricted networks, service principals for automated/shared access)
```json
{
  "servers": {
    "azure-sql-mcp": {
      "type": "http",
      "url": "https://your-api-endpoint.azurewebsites.net/mcp",
      "headers": { "Authorization": "Bearer ${input:azure_token}" }
    }
  },
  "inputs": [{ "id": "azure_token", "type": "promptString", "description": "Azure access token", "password": true }]
}
```

- **Fabric Lakehouse**: create + configure a **data agent** in the Fabric workspace → publish it → Settings → **Model Context Protocol tab** → copy URL → drop into `.vscode/mcp.json` → VS Code prompts to Add Server + authenticate. A dedicated **Fabric MCP Server extension** in the VS Code marketplace simplifies this.

- **Authentication methods** — know all three:
    - **Interactive** (browser sign-in) — best for dev environments
    - **Service principal** (Entra ID app) — best for automated/shared scenarios
    - **API keys** — stored via env vars or secure input prompts, **never in committed config files**

- **Troubleshooting table — high-yield for exam**:

|Issue|Cause|Fix|
|---|---|---|
|Server not listed|Config file syntax error|Validate JSON in `mcp.json`|
|Authentication failed|Expired credentials|Re-authenticate/refresh tokens|
|Connection timeout|Network/firewall blocking|Check firewall rules|
|Empty schema results|Insufficient permissions|Verify DB permissions for the authenticated user|

- Best practices: least-privilege dedicated accounts (typically **read-only schema access**), **separate MCP endpoints per environment** (dev/test/prod — avoid pointing AI at production data during routine dev), monitor/log MCP usage, share configs via version control for team consistency

- **Exam angle**: the troubleshooting table (symptom→cause→fix mapping) and the "never connect AI to production during routine dev" / "separate environments" principle are the most likely direct test points; also remember MSSQL extension's "Chat with this database" works **without** a separate MCP server — a common point of confusion vs the full MCP setup path