# A Guide to CTEs vs. Subqueries  

Team Iron Man or Team Cap? That's exactly how I feel when we debate what's better: CTEs or Subqueries.  

At first, it's always the same question: *"If I can do this with a Subquery, why should I use a CTE?"*  

By the end of this article, I hope you can explain when to choose one approach over the other.  

I'll list some advantages you can gain by using a CTE.  

## 1. Query Readability and Maintenance  
Of course, this is the first and most impactful point: are you writing code just for yourself or for other developers who may work with it later?  

A **CTE** provides a way to define a temporary result set that can be queried multiple times within the main query. This makes the query easier to read and understand, especially for complex queries.  

A **Subquery** can be harder to read, especially when embedded in `WHERE`, `SELECT`, or other clauses. The logic may not be immediately obvious.  

### Example:  

```sql  
-- CTE  
WITH active_goals AS (  
    SELECT   
        contact_id,   
        COUNT(*) AS total_goals  
    FROM goals  
    WHERE status = 1  
    GROUP BY contact_id  
)  
SELECT   
    c.name,   
    c.surname,   
    ag.total_goals  
FROM contacts c  
JOIN active_goals ag ON c.id = ag.contact_id  
WHERE ag.total_goals > 2;  

-- Subquery  
SELECT   
    c.name,   
    c.surname,   
    (  
        SELECT COUNT(*)   
        FROM goals g   
        WHERE g.contact_id = c.id AND g.status = 1  
    ) AS total_goals  
FROM contacts c  
WHERE (  
        SELECT COUNT(*)   
        FROM goals g   
        WHERE g.contact_id = c.id AND g.status = 1  
    ) > 2;  
```  

You know exactly what the query means and its purpose just by reading the main query, then you can manipulate it however you want.  

## 2. Query Reusability  
A **CTE** can be referenced multiple times in the same query, which is useful when you need to reuse a complex calculation or aggregation in different parts of the query.  

A **Subquery** can only be used once in the query, meaning if you need the same result in multiple places, you'll have to repeat the Subquery.  

### Example:  

```sql  
-- CTE  
WITH active_habits AS (  
    SELECT   
        contact_id,   
        COUNT(*) AS habit_count  
    FROM habits  
    WHERE status = 1  
    GROUP BY contact_id  
)  
SELECT   
    c.name,   
    c.surname  
FROM contacts c  
JOIN active_habits ah ON c.id = ah.contact_id  
WHERE ah.habit_count > 2  

UNION  

SELECT   
    c.name,   
    c.surname  
FROM contacts c  
JOIN active_habits ah ON c.id = ah.contact_id  
WHERE ah.habit_count < 0;  

-- Subquery  
SELECT   
    c.name,   
    c.surname  
FROM contacts c  
WHERE (  
        SELECT COUNT(*)   
        FROM habits h   
        WHERE h.contact_id = c.id AND h.status = 1  
    ) > 2  

UNION  

SELECT   
    c.name,   
    c.surname  
FROM contacts c  
WHERE (  
        SELECT COUNT(*)   
        FROM habits h   
        WHERE h.contact_id = c.id AND h.status = 1  
    ) < 0;  
```  

### 3. Recursive Query  
A recursive **CTE** is useful for working with hierarchical data. It allows you to query the **CTE's** result set within its own definition.  

[*A recursive query in SQL is a query that calls itself repeatedly until a termination condition is met.*](https://medium.com/@ugorjicalebchijindu/explaining-recursive-query-in-sql-38c043fcc740)  

**Subqueries** are not designed to handle recursive queries.  

### Example:  

```sql  
WITH goal_hierarchy AS (  
    -- Select the top level goals  
    SELECT id, name, description, contact_id, parent_goal_id, 1 AS level  
    FROM goals  
    WHERE contact_id = 1 AND parent_goal_id IS NULL  

    UNION ALL  

    -- Select subgoals and increment the level  
    SELECT g.id, g.name, g.description, g.contact_id, g.parent_goal_id, cte.level + 1  
    FROM goals g  
    JOIN goal_hierarchy cte ON g.parent_goal_id = cte.id  
)  
-- Get all goals and subgoals  
SELECT   
 id,   
 name,  
 description,   
 level  
FROM goal_hierarchy  
ORDER BY level, id;  
```  

We start by selecting goals that don't have a parent field (`parent_goal_id IS NULL`). For each selected goal, we join the **CTE** with the goals table to find its subgoals.  

The `level` column helps track the depth of each goal in the hierarchy.  

## 4. Performance  
In many cases, **CTEs** can improve performance, especially if the same result set is referenced multiple times.  

A **Subquery** is usually optimized by the database engine, but it may be less efficient if the same **Subquery** needs to be evaluated multiple times.  

I don’t think this will have a huge impact. Performance depends a lot on your database architecture and how the tables are related.  

*Performance is all about understanding your database.*  

## 5. Error Handling  
This is easier with a **CTE**, no doubt.  

A **CTE** is declared separately at the beginning of the query, making it easier to debug. You can also isolate a **CTE** in a separate query to check the results before using it in the final query.  

**Subqueries** can be tricky because they are all nested inside the main query.  

## Conclusion  
Use **CTEs** for:  
- Better readability, maintenance, and reusability.  
- Recursive queries.  
- Working with complex logic in multiple parts of a query.  

Use **Subqueries** for:  
- Simple queries.  
- If your query won't be repeated.  

If you want to explore the same database used in the examples, I recommend checking out the article I wrote about data modeling. There, you'll find more information and access to the model used.