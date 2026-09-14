# Appendix B: Schema for the Sample Databases

Quick-reference note: "which database has which tables" cheat sheet, for recalling context when an example elsewhere in the book references `Customers`, `Bowlers`, `Faculty`, etc. Not a full column listing — just table names and their one-line purpose.

Every sample database (except Recipes) ships in two variants:
1. **Example** — the base version used for SELECT/JOIN/grouping chapters.
2. **Modify** — same schema plus a few extra columns (e.g. `OrderTotal`) and `_Archive` twin tables, used for the UPDATE/INSERT/DELETE chapters where you need somewhere to move rows to.

`PK` = primary key, `FK` = foreign key, `CPK` = composite primary key (the table's PK is made of more than one column — usually the signature of a many-to-many resolver table).

## Sales Orders

1. **Customers** — customer contact/address info.
2. **Employees** — sales employee info.
3. **Orders** — one row per order; FK to `Customers` and `Employees`.
4. **Order_Details** — line items per order (CPK `OrderNumber` + `ProductNumber`); resolves the Orders↔Products many-to-many.
5. **Products** — product catalog; FK to `Categories`.
6. **Categories** — lookup table for product category names.
7. **Product_Vendors** — which vendors supply which product, at what price/lead time (CPK `ProductNumber` + `VendorID`).
8. **Vendors** — vendor contact/address info.

*Modify variant adds:* `OrderTotal` column on `Orders`; `Orders_Archive` and `Order_Details_Archive` tables to hold rows moved out of the live tables.

## Entertainment Agency

1. **Customers** — clients who book entertainment.
2. **Agents** — booking agents.
3. **Entertainers** — performer "acts" (may be a solo act or a band).
4. **Members** — individual musicians.
5. **Entertainer_Members** — which members belong to which act (CPK `EntertainerID` + `MemberID`) — resolves Entertainers↔Members many-to-many, since a member can play in more than one act.
6. **Musical_Styles** — lookup of style names (jazz, rock, etc.).
7. **Entertainer_Styles** — which styles an act performs (CPK `EntertainerID` + `StyleID`).
8. **Musical_Preferences** — which styles a customer likes (CPK `CustomerID` + `StyleID`).
9. **Engagements** — one row per booked gig; FK to `Customers`, `Agents`, `Entertainers`.

*Modify variant adds:* `EntPricePerDay` column on `Entertainers`; `Engagements_Archive` table.

## School Scheduling

1. **Staff** — every staff member.
2. **Faculty** — subset of staff who teach (shares `StaffID` with `Staff`).
3. **Faculty_Subjects** — subjects a faculty member is qualified to teach (CPK `StaffID` + `SubjectID`).
4. **Faculty_Classes** — which faculty member teaches which class section (CPK `StaffID` + `ClassID`).
5. **Faculty_Categories** — which categories a faculty member is associated with (CPK `StaffID` + `CategoryID`).
6. **Subjects** — course catalog; FK to `Categories`.
7. **Categories** — subject category lookup; FK to `Departments`.
8. **Departments** — academic departments; FK `DeptChair` back to staff.
9. **Classes** — a scheduled section of a subject; FK to `Subjects`, `Classrooms`.
10. **Classrooms** — physical rooms; FK to `Buildings`.
11. **Buildings** — campus buildings.
12. **Students** — student records.
13. **Student_Schedules** — which student is enrolled in which class + grade (CPK `ClassID` + `StudentID`); FK `ClassStatus`.
14. **Student_Class_Status** — lookup for enrollment status (enrolled, dropped, etc.).
15. **Majors** — lookup of major names.

## Bowling League

1. **Tournaments** — one row per tournament event.
2. **Teams** — bowling teams; FK `CaptainID` to a bowler.
3. **Bowlers** — individual bowler info; FK to `Teams`.
4. **Tourney_Matches** — one match within a tournament, pairing two teams on given lanes; FK to `Tournaments` and `Teams` (odd/even lane).
5. **Match_Games** — one game within a match (CPK `MatchID` + `GameNumber`); FK `WinningTeamID`.
6. **Bowler_Scores** — one bowler's score in one game (CPK `MatchID` + `GameNumber` + `BowlerID`).

*Modify variant adds:* running totals (`BowlerTotalPins`, `BowlerGamesBowled`, `BowlerCurrentAverage`, `BowlerCurrentHcp`) on `Bowlers`; `_Archive` twins for `Tournaments`, `Tourney_Matches`, `Match_Games`, and `Bowler_Scores`.

## Recipes

No Modify variant — this database only appears in read-oriented examples.

1. **Recipe_Classes** — lookup of recipe category names (appetizer, dessert, etc.).
2. **Recipes** — one row per recipe; FK to `Recipe_Classes`.
3. **Recipe_Ingredients** — which ingredients go in which recipe, in what amount, in what order (CPK `RecipeID` + `RecipeSeqNo`); resolves Recipes↔Ingredients many-to-many.
4. **Ingredients** — ingredient catalog; FK to `Ingredient_Classes` and `Measurements`.
5. **Ingredient_Classes** — lookup of ingredient category names (dairy, produce, etc.).
6. **Measurements** — lookup of unit-of-measure names (cup, tsp, etc.).

## "Driver" Tables

Small helper tables used only in Chapter 20's unlinked-data/CROSS JOIN examples — not real business entities, prefixed `ztbl` so they sort away from the real schema. Listed per database family they support:

- **Sales Orders:** `ztblPurchaseCoupons`, `ztblPurchaseRanges` — range-lookup tables (spend amount → coupon/price category).
- **Entertainment Agency:** `ztblDays` — one row per calendar day.
- **Entertainment + Bowling:** `ztblSkipLabels` — sequence table for skipping N label positions; `ztblWeeks` — one row per week.
- **School Scheduling:** `ztblGenderMatrix`, `ztblMaritalStatus`, `ztblProfRatings`, `ztblLetterGrades` (grade-point range → letter grade), `ztblSemesterDays`.
- **Bowling League:** `ztblBowlerRatings` — range-lookup (average → rating category).
- **Sales + Entertainment:** `ztblMonths` — one row per month, with a 0/1 flag column per month name (pivot driver table).
- **Sales + School:** `ztblSeqNumbers` — plain list of integers 1..N, for "explode a quantity into N rows" problems.

See `Chapter 20 - Using Unlinked Data and Driver Tables.md` for the query patterns these tables support.
