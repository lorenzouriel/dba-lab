# database/

A SQL Server Database Project (SSDT) for a multi-tenant vehicle/GPS tracking
system, buildable from Visual Studio or the `msbuild`/`dotnet build` CLI into a
`.dacpac`, then deployed with `SqlPackage`.

## Structure

```
database/
├── database.sln
├── database.sqlproj
├── Tables/
├── Views/
├── StoredProcedures/
├── Functions/
├── Security/
├── Properties/
└── PostDeployment/
    └── MigrationScripts/
```

The project targets SQL Server 2019 (`Sql150DatabaseSchemaProvider`) — change the
`DSP` property in `database.sqlproj` to target a different version.

## Schema

Everything except `alarm_types` is scoped to a `tenant_id` (multi-tenant: one
customer's fleet is invisible to another's).

| Table         | Purpose                                                                 |
|---------------|--------------------------------------------------------------------------|
| `tenants`     | Customer/company that owns vehicles, devices and users.                 |
| `users`       | Login accounts (email + password) that manage a tenant's fleet.         |
| `drivers`     | People assigned to vehicles; don't necessarily log in.                  |
| `vehicles`    | A tenant's fleet, optionally with a current `driver_id`.                |
| `devices`     | GPS hardware, optionally installed in a `vehicle_id`.                   |
| `geofences`   | Named circular zones (center + radius) used to trigger alarms.          |
| `alarm_types` | Fixed lookup of alarm kinds (speeding, sos, geofence, ...), seeded via PostDeployment. |
| `tracks`      | A trip: the in-motion segment of a vehicle's journey.                   |
| `stops`       | A stationary period, optionally tied to the track it ended.             |
| `points`      | Raw GPS pings from a device; grouped into `tracks`/`stops` downstream.  |
| `alarms`      | Triggered alarm events, optionally tied to a `geofence`.                |
| `logs`        | Audit trail of actions (`entity_type`/`entity_id` point at the row).    |

All FKs are real constraints (not just indexed columns) for referential
integrity. `points` and `alarms` use `BIGINT` identities since they're the
highest-volume, time-series tables.

## Build

```powershell
msbuild database.sqlproj /p:Configuration=Release
```

This produces `bin/Release/database.dacpac`.

## Deploy

```powershell
SqlPackage /Action:Publish `
  /SourceFile:bin\Release\database.dacpac `
  /TargetConnectionString:"Server=localhost;Database=database;User Id=sa;Password=<password>;TrustServerCertificate=True"
```

See [`lab-ag-&-cicd/`](../labs/lab-ag-&-cicd/) for a full worked example of this
pattern (schema, PostDeployment seed data, Docker-based dev/staging/prod pipeline).
