# A Guide to Relational Algebra

## What is relational algebra?
Relational algebra is a theoretical framework for manipulating data in a relational database. This concept did not receive much attention until the publication of the relational model by Edgar F. Codd. **In his publication of the relational model, Codd proposed using relational algebra as the foundation for database query languages.**

Relational algebra allows us to perform operations to query and manipulate data, such as:
- selection
- projection
- union
- difference
- Cartesian product
- joins

These operations are based on mathematical sets and are applied to relations that represent the tables and data in a relational database.

We can say that **SQL is a database query language derived from relational algebra.**

## What makes up relational algebra?
Relational algebra is composed of Set Theory and some specific operations. We can discuss the following:

**1. Relations:** Relations are represented by tables that store data in a relational database. Each relation consists of tuples (rows) and attributes (columns). (In this mathematical field, we call rows "tuples" and columns "attributes.")

**2. Basic Operators:**
- **Selection (σ):** filters the tuples of a relation based on a specific condition.
- **Projection (π):** selects certain columns from a relation, discarding the others.

**3. Set Theory:**
- **Union (∪):** combines two relations, returning all distinct tuples.
- **Intersection (∩):** returns the tuples that are common to two relations.
- **Difference (-):** returns the tuples that are in one relation but not in the other.

To represent set theory visually, we use a Venn Diagram.

**4. Combination Operators:**
- **Cartesian Product (×):** Also known as "cross join," the Cartesian product combines all tuples from two relations. The result is a new relation that contains all possible combinations of tuples from the two input relations. For example, if the first relation has m tuples and the second relation has n tuples, the Cartesian product will have m x n tuples.

- **Join (⨝):** The join combines tuples from two or more relations based on a join condition. The join condition is specified to compare attribute values in the involved relations. There are different types of joins:
    - **Inner Join:** Returns tuples that have matching values in the joined relations.
    - **Outer Join:** Returns matching tuples as well as non-matching tuples in one or both of the joined relations.
    - **Left Join:** Returns all tuples from the first joined relation and the matching tuples from the second relation.
    - **Right Join:** Returns all tuples from the second joined relation and the matching tuples from the first relation.
    - **Full Join:** Returns all tuples from both joined relations, combining matching tuples and filling with null values when there is no match.

We will cover more on joins in a future chapter about Joins!
