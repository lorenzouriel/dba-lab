# DBA Lab

A collection of self-contained SQL Server DBA/CI-CD labs, plus personal study notes
for the Microsoft **DP-800** certification.

Each lab lives in its own folder with its own `README.md`, `docker-compose.yml`, and
CLI script — labs don't reach into each other's files, so you can spin one up without
the others.

## Repository layout

```
dba-lab/
├── lab-ag-&-cicd/     # SQL Server CI/CD with Always On Availability Groups
├── lab-octopus/       # Same schema, deployed through Octopus Deploy
├── dp800/             # DP-800 study notes (Microsoft Learn style modules)
└── .claude/           # Claude Code project config (skills, settings)
```

### [`lab-ag-&-cicd/`](lab-ag-&-cicd/)

A portfolio project simulating a production database CI/CD pipeline: four SQL Server
containers (dev, staging, prod primary, prod secondary) wired together with an Always
On Availability Group, deployed from an SSDT project (`db.sqlproj`) via
`msbuild` → `.dacpac` → `SqlPackage`. Includes scripts to initialize the databases,
configure the AG, deploy through Dev → Staging → Prod with promotion gates, and test
manual failover. See its [README](lab-ag-&-cicd/README.md) for the full CLI (`dba-lab.ps1`).

### [`lab-octopus/`](lab-octopus/)

The same finance-app SSDT schema as `lab-ag-&-cicd/`, but deployed through
[Octopus Deploy](https://octopus.com) instead of raw scripts: build the dacpac,
package it as a `.nupkg`, push it to Octopus's built-in feed, and deploy through
Dev → Staging → Production lifecycle gates in the Octopus UI. Depends on
`lab-ag-&-cicd`'s SQL Server containers being up first. See its
[README](lab-octopus/README.md) for setup and CLI (`octopus-lab.ps1`).

### [`dp800/`](dp800/)

Study notes for the DP-800 exam, organized like a Microsoft Learn course: one folder
per domain, one subfolder per module, numbered lesson files inside
(`01-introduction.md`, `02-...md`, …, plus `knowledge-check` / `module-assessment`
files where Microsoft provides them). Current domains:

- `Design and develop database solutions/`
- `Implement AI capabilities in database solutions/`
- `Secure, optimize, and deploy database solutions/` *(not yet populated)*

Use the `/dp800-quiz` skill (see below) to drill yourself on this content.

### [`.claude/`](.claude/)

Project-level Claude Code configuration.

- `skills/dp800-quiz/` — generates original practice questions from the `dp800/`
  notes and runs an interactive quiz, scoped to a domain, module, or the whole tree.
  Invoke with `/dp800-quiz [topic]`.

