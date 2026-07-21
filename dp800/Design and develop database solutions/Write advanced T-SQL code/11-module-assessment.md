# Module assessment

200 XP
10 Minutes

This assessment evaluates your understanding of the module. Unlike before, you won't get feedback on individual answers—just whether they're right or wrong. This is meant to measure what you've learned. Take time to review the module materials before starting.

> AI-generated content
>
> The questions and answer choices in this module assessment were generated using AI and reviewed by a human author.

**1. You want to rank employees by their sales performance across different regions. Which window function should you use for accurate ranking?**

- ROW_NUMBER() with PARTITION BY region and ORDER BY sales.
- RANK() with PARTITION BY region and ORDER BY sales.
- SUM() with PARTITION BY region and ORDER BY sales.

**2. A recursive CTE is used to calculate cumulative sales per employee but is returning incorrect results. Which component is most likely missing or improperly configured?**

- Multiple references to the same CTE name causing confusion.
- An ORDER BY clause in the anchor member to sort initial results.
- A termination condition in the recursive member to prevent infinite recursion.

**3. You have a JSON column in your SQL Server database containing order details. To extract individual order items as rows for further analysis, which function should you use?**

- OPENJSON()
- JSON_VALUE()
- JSON_ARRAYAGG()

**4. A CTE is used to generate a product sales rank, but results are inconsistent. What element is most likely missing or incorrectly configured?**

- A recursive member in the CTE to calculate ranks.
- An ORDER BY clause in the main query to ensure consistent ranking.
- A WHERE clause in the CTE to filter by product category.

**5. Your team needs to ensure that a JSON column contains valid JSON data before processing it. Which SQL function should be used to check the validity of the JSON data?**

- ISJSON()
- JSON_ARRAYAGG()
- JSON_PATH_EXISTS()

**6. You need to extract a JSON object from a column in the SalesOrder table and use it for further processing in your SQL Server environment. Which function should you use to ensure the JSON structure is preserved?**

- OPENJSON()
- JSON_QUERY()
- JSON_VALUE()

**7. Which of the following is a valid approach to combine multiple CTEs for complex transformations?**

- Use nested CTE definitions to encapsulate transformation logic.
- Define each CTE in a separate query block for isolated execution.
- Separate each CTE with a comma within the same WITH clause to allow progressive transformations.

**8. Your company wants to create a report showing each employee's sales and the total sales of their department. How would you achieve this using window functions?**

- Use a subquery to calculate department totals for each employee.
- Use GROUP BY department to aggregate sales data.
- Use SUM() with OVER(PARTITION BY department) to calculate total sales per department alongside each employee's sales.

**9. What is the default frame specification when using ORDER BY in a window function without specifying ROWS or RANGE?**

- ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
- RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
