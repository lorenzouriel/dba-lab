# Knowledge check

Completed

- 5 minutes

## Check your knowledge

**1. A team needs I/O latency under 2 milliseconds and a free read-only replica for reporting queries. Which Azure SQL Database service tier should they choose?**

- General Purpose
- Business Critical
- Hyperscale
- DTU Standard

**2. Which isolation level is the default in Azure SQL Database and uses row versioning to prevent readers from blocking writers?**

- READ COMMITTED with shared locks
- READ COMMITTED SNAPSHOT (RCSI)
- SNAPSHOT
- SERIALIZABLE

**3. Which Query Store feature restores query performance after a plan regression without modifying application code?**

- Query Store hints
- Regressed Queries view
- Plan forcing
- Wait statistics

**4. An execution plan shows a Key Lookup operator that accounts for most of the query cost. What is the recommended approach to eliminate it?**

- Add a filtered index on the predicate columns
- To reduce fragmentation, rebuild the clustered index
- Add included columns to the nonclustered index
- Switch the query to use the NOLOCK hint

**5. How do you identify the head blocker in a blocking chain using dynamic management views?**

- Query sys.dm_exec_requests for the session with the highest wait_time
- Query sys.dm_exec_sessions for sessions with status = 'running'
- Query sys.dm_exec_requests for sessions where blocking_session_id = 0 that also appear as blocking_session_id for other sessions
- Query sys.dm_tran_locks for the session holding the most exclusive locks

**6. Two transactions running under SNAPSHOT isolation both read the same row, then each tries to update it. What happens?**

- Both updates succeed because snapshot isolation uses row versions instead of locks
- The second update blocks until the first transaction commits
- The first transaction to commit succeeds; the second transaction fails with an update conflict error
- The deadlock monitor detects a circular dependency and terminates one transaction
