# Appendix C: Date and Time Types, Operations, and Functions

Quick-reference note: date/time handling is one of the least portable corners of SQL — every platform picked its own data types, arithmetic rules, and function names. The SQL Standard only nails down three functions: `CURRENT_DATE`, `CURRENT_TIME`, `CURRENT_TIMESTAMP` — not every platform even supports all three. This appendix is the book's platform-by-platform cheat sheet; use it to translate an example written for one platform into another.

## Data Types Supported

| Platform | Types |
|---|---|
| DB2 | `DATE`, `TIME`, `TIMESTAMP` |
| Access | `Date/Time` (single type covers date + time) |
| SQL Server | `date`, `time`, `smalldatetime`, `datetime`, `datetime2`, `datetimeoffset` |
| MySQL | `date`, `time`, `datetime`, `timestamp`, `year` |
| Oracle | `DATE`, `TIMESTAMP`, `INTERVAL YEAR TO MONTH`, `INTERVAL DAY TO SECOND` |
| PostgreSQL | `DATE`, `TIME` (±tz), `TIMESTAMP` (±tz), `INTERVAL` |

Only Oracle and PostgreSQL have a first-class `INTERVAL` type — everywhere else, a "duration" is just a number of days/an integer, or a vendor-specific string passed to a function like `DATEADD`.

## Arithmetic Rules

| Platform | Core rule |
|---|---|
| DB2 | `DATE +/- duration = DATE`; `TIMESTAMP - TIMESTAMP` = a `DECIMAL` encoding `yyyymmddhhmmss.microseconds` |
| Access | `Date/Time` is a float under the hood — day 0 is **Dec 31, 1899**; `+/- integer` = whole days, `+/- fraction` = time of day (0.5 = 12 hours) |
| SQL Server | Same float-like model as Access, but day 0 is **Jan 1, 1900** |
| MySQL | Must use `INTERVAL <n> <unit>` for date arithmetic — plain `date + 30` silently converts the date to a number first (e.g. `2017-11-15 + 30` = `20171145`, not a valid date!) |
| Oracle | `DATE - DATE` = plain numeric days; `INTERVAL * numeric` / `INTERVAL / numeric` are legal (scale a duration) |
| PostgreSQL | `DATE - DATE` = plain integer; every other combination with `INTERVAL` produces `TIMESTAMP` or `INTERVAL` as you'd expect |

🤯 In MySQL, forgetting the `INTERVAL` keyword doesn't error — it just quietly reinterprets your date as an 8-digit integer and does normal arithmetic on *that*. Easy way to corrupt a date silently.

## "Get me right now" — Current Date/Time Functions

| Platform | Current date | Current time | Current date+time |
|---|---|---|---|
| DB2 | `CURRENT_DATE`, `CURDATE()` | `CURRENT_TIME`, `CURTIME()` | `CURRENT_TIMESTAMP`, `NOW` |
| Access | `Date` | `Time` | `Now` |
| SQL Server | `GETDATE()` (as datetime) | — | `CURRENT_TIMESTAMP`, `SYSDATETIME()`, `GETUTCDATE()`/`SYSUTCDATETIME()` for UTC |
| MySQL | `CURRENT_DATE`, `CURDATE()` | `CURRENT_TIME`, `CURTIME()` | `CURRENT_TIMESTAMP`, `NOW()`, `UTC_TIMESTAMP` for UTC |
| Oracle | `CURRENT_DATE`, `SYSDATE` (server, no tz) | — | `CURRENT_TIMESTAMP`, `LOCALTIMESTAMP`, `SYSTIMESTAMP` |
| PostgreSQL | `CURRENT_DATE` | `CURRENT_TIME`, `LOCALTIME` | `CURRENT_TIMESTAMP`, `NOW()`, `CLOCK_TIMESTAMP()` (changes mid-statement, unlike the others) |

✨ **Side learning:** PostgreSQL's `CURRENT_TIMESTAMP` is frozen at transaction start (so every reference in one transaction returns the same value), while `CLOCK_TIMESTAMP()` re-evaluates the real wall clock every call. Handy distinction if you're timing something *inside* a transaction.

## Extracting Parts (year/month/day/etc.)

| Platform | Idiom |
|---|---|
| DB2 | One function per part: `YEAR()`, `MONTH()`, `DAY()`, `HOUR()`, `MINUTE()`, `SECOND()`, plus ISO variants (`DAYOFWEEK_ISO`, `WEEK_ISO`) |
| Access | One function per part: `Year()`, `Month()`, `Day()`, `Hour()`, `Minute()`, `Second()`, `WeekDay()` |
| SQL Server | `DATEPART(<interval>, <expr>)` — one general function, interval as first argument; also has the one-per-part shortcuts (`YEAR()`, `MONTH()`, `DAY()`) |
| MySQL | Both styles: `EXTRACT(<unit> FROM <expr>)` (standard) and one-per-part (`YEAR()`, `MONTH()`, `DAY()`, ...) |
| Oracle | `EXTRACT(<interval> FROM <expr>)` — standard style |
| PostgreSQL | `EXTRACT(<text> FROM <expr>)` and the equivalent `DATE_PART(<text>, <expr>)` |

Oracle and PostgreSQL both favor the ANSI `EXTRACT(unit FROM expr)` syntax; DB2/Access/MySQL default to a function-per-part style, though MySQL supports `EXTRACT` too.

## Adding/Subtracting an Interval

| Platform | Idiom |
|---|---|
| DB2 | `<value> + <n> <units>` inline (e.g. `DATE + 3 DAYS`), or `ADD_MONTHS(expr, n)` |
| Access | `DateAdd(<interval>, <number>, <expr>)` |
| SQL Server | `DATEADD(<interval>, <number>, <expr>)` |
| MySQL | `DATE_ADD(expr, INTERVAL n unit)` / `DATE_SUB(expr, INTERVAL n unit)`, or `ADDDATE()`/`SUBDATE()` |
| Oracle | `expr + INTERVAL '...' ...` inline, or `ADD_MONTHS(date, n)` |
| PostgreSQL | `expr + INTERVAL '...'` inline |

## Difference Between Two Dates

| Platform | Idiom |
|---|---|
| DB2 | Subtract directly; result is a `DECIMAL` encoding a duration, or use `TIMESTAMPDIFF(<code>, <string>)` with a numeric unit code |
| Access | `DateDiff(<interval>, <expr1>, <expr2>, ...)` |
| SQL Server | `DATEDIFF(<interval>, <expr1>, <expr2>)` |
| MySQL | `DATEDIFF(<expr1>, <expr2>)` (days only) or `TIMESTAMPDIFF(<interval>, <expr1>, <expr2>)` (any unit) |
| Oracle | Subtract directly for days; `MONTHS_BETWEEN(expr1, expr2)` for months |
| PostgreSQL | Subtract directly (`TIMESTAMP - TIMESTAMP = INTERVAL`), or `AGE(timestamp, timestamp)` for a "years/months" symbolic result |

## Building a Date/Time From Parts

| Platform | Idiom |
|---|---|
| Access | `DateSerial(year, month, day)`, `TimeSerial(hour, minute, second)` |
| SQL Server | `DATEFROMPARTS(y,m,d)`, `DATETIMEFROMPARTS(...)`, `TIMEFROMPARTS(...)`, etc. — one `*FROMPARTS` function per type |
| MySQL | `MAKEDATE(year, dayofyear)`, `MAKETIME(hour, minute, second)` |
| Oracle | `TO_DATE(string, format)` — parse from a formatted string rather than discrete parts |
| PostgreSQL | No dedicated builder in this appendix's list — typically built via string literal + cast, or `MAKE_DATE`/`MAKE_TIMESTAMP` (added after this edition) |

## Validity Checks

| Platform | Idiom |
|---|---|
| Access | `IsDate(expr)` |
| SQL Server | `ISDATE(expr)` |
| PostgreSQL | `ISFINITE(date \| timestamp \| interval)` — checks for `+/- infinity`, not malformed input |

🤯 PostgreSQL actually allows literal `infinity` and `-infinity` as valid `DATE`/`TIMESTAMP` values — hence `ISFINITE()` existing at all as a distinct concept from "is this parseable."

## Takeaway

There is no portable date function vocabulary across platforms — only the three bare `CURRENT_*` functions are guaranteed by the Standard. Anything beyond "what is right now" (extracting parts, diffing, building from parts) needs a per-platform lookup — keep this table bookmarked rather than memorized.
