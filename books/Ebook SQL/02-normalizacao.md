# A Guide to Normalization
It consists of techniques used to avoid data inconsistency and redundancy through the structuring of the database. It is a set of rules and techniques that help to design and organize the structure of a relational database efficiently.
- **Inconsistency:** Normalization helps to maintain data consistency since changes in one table are automatically reflected in other related tables. This prevents inconsistency issues and ensures **referential integrity**.
- **Redundancy:** It avoids unnecessary data repetition in different parts of the database, which saves storage space and reduces the likelihood of inconsistencies.

Some **benefits** include:
- Clear semantics;
- Prevents NULL values in tuples;
- Better performance;
- Easier maintenance.

It also prevents **anomalies** of:
- Insertion;
- Update;
- Deletion.

For normalization to occur, we need to apply **Normal Forms** along with the rules of **Functional Dependencies**.
- **NF (Normal Forms)** are techniques used in standardization; they are a series of rules aimed at eliminating redundancy and ensuring data integrity.
- **FD (Functional Dependency)** describes the relationship between attributes in a table, indicating how the value of one attribute determines or is determined by the value of another attribute.

## Functional Dependency
There are different types of functional dependencies that can occur in a database. To explain clearly, we will use X and Y as:
- `X` (Determinant) — ID
- `Y` (Dependent) — Field

**1. Simple Functional Dependency:** Occurs when the determinant fully determines the value of the dependent.
- We say that `Y` is functionally dependent on `X` if and only if each value of `Y` is associated with `X`.

**2. Partial Functional Dependency:** In this case, the determinant only partially determines the value of the dependent, meaning other attributes may also influence the dependent’s value besides the determinant.
- When non-key attributes (`Y`) are not functionally dependent on the primary key (`X`) when it is composite.

**3. Total Functional Dependency:** Occurs when a set of attributes determines all other attributes in a table.
- When dependent attributes (`Y`) depend on the determinant (`X`).

**4. Transitive Functional Dependency:** Occurs when an attribute indirectly determines another attribute through a chain of dependencies.
- When a non-key attribute (`Y`) depends on another non-key attribute (`Y`).

**5. Multivalued Functional Dependency:** Occurs when a set of attributes determines a set of other attributes, but there is no direct functional dependency between attributes within those sets.
- Occurs when a key attribute (`X`) multidetermines non-key attributes (`Y`) OR (`Y`) is multidependent on (`X`).

*These dependencies are the ones I consider most important in the modeling and normalization process. There are other more complex types of dependencies, which will not be covered in this article. Depending on the complexity of your normalization model, these will be useful.*

## Normal Forms
The most well-known normal forms and their rules are as follows:

- **1NF:** Data is organized into tables, with each table containing only atomic and non-repeating values. This means that each value in a column must be indivisible and cannot be a list or set of values.

- **2NF:** In addition to meeting the criteria of 1NF, each non-key column in a table must depend entirely on the table’s primary key. This means there should be no partial dependencies where a non-key column depends only on part of the primary key.

- **3NF:** In addition to meeting the criteria of 2NF, there should be no transitive dependencies between non-key columns. This means if one column depends on another column, which in turn depends on a third column, the first column should be moved to a separate table.

- **4NF:** In addition to meeting the criteria of 3NF, there should be no multivalued dependencies. This means there should be no sets of columns that could create undesirable dependencies between each other.

*These normal forms are the ones I consider most important in the modeling and standardization process. There are other more complex types of normal forms that will not be covered in this chapter.*

## Application of Normal Forms
Let’s analyze my two tables below:
```sql
CREATE TABLE [sales] 
(
	[id] [int] not null identity(1,1) PRIMARY KEY,
	[date] [date] not null,
    [product_id] [int] not null,
	  not null,
	[value] [money] not null
)

CREATE TABLE products
(
    [id] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[creation_date] [date] not null,
	  not null,
	  not null
)
```
- *These tables will be frequently used in the following chapters.*

### 1NF (First Normal Form)
- **Rule:** Each value must be atomic, and each entry must be unique.

**Table `sales`:**
- The values are atomic, and there are no lists or sets. Each entry is unique.

**Table `products`:**
- The values are atomic, and there are no lists or sets. Each entry is unique.

Both the `sales` and `products` tables are already in 1NF.

**Example:**
A good example we can find here is the `address` field. To meet 1NF, we need to split the address into other fields, such as: `ZIP`, `Number`, `Neighborhood`, `City`, etc...

### 2NF (Second Normal Form)
- **Rule:** Meet 1NF, and each non-key column must depend entirely on the primary key.

**Table `sales`:**
- The primary key is [`id`]. The columns [`date`] and [`value`] depend entirely on the primary key [`id`].
- The column [`product`] should depend on [`product_id`] (and not on [`id`]), indicating a transitive dependency, which is a concern for 3NF. But since we are focusing on 2NF, the table meets 2NF as there is no partial dependency, since `product_id` is not part of a composite key.

**Table `products`:**
- The primary key is [`id`]. The columns [`creation_date`], [`product`], and [`description`] depend entirely on the primary key [`id`].

Both the `sales` and `products` tables meet 2NF.

**Example:**
A good example to explain 2NF is an orders table where the primary key is composed of `order_id` and `product_id`. If the table has columns like `quantity` and `unit_price`, these columns must depend entirely on the combination of `order_id` and `product_id`. If a column like `product_name` depends only on `product_id`, it violates 2NF and should be moved to another table related solely to products.

---
### 3NF (Third Normal Form)
- **Rule:** Meet 2NF, and there should be no transitive dependencies between non-key columns.

**Table `sales`:**
- There is a transitive dependency, as [`product`] depends on [`product_id`], which depends on [`id`]. To resolve this, we remove the column [`product`] from the `sales` table and ensure that the relationship with the `products` table is based on [`product_id`].

**Table `products`:**
- There are no transitive dependencies. The columns [`creation_date`], [`product`], and [`description`] depend only on the primary key [`id`].

To make the `sales` table meet 3NF, we need to modify its structure:
```sql
CREATE TABLE [sales] (
    [id] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [date] [date] NOT NULL,
    [product_id] [int] NOT NULL,
    [value] [money] NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id)
)
```

**Example:**
An example of 3NF, aside from the one used, is a table of employees with columns `employee_id`, `name`, `department_id`, `department_name`. The column `department_name` transitively depends on `department_id`, which in turn depends on the primary key `employee_id`. To meet 3NF, `department_name` should be moved to a separate departments table.

### 4NF (Fourth Normal Form)
- **Rule:** Meet 3NF, and there should be no multivalued dependencies.

**Table `sales`:**
- There are no multivalued dependencies after the modification.

**Table `products`:** 
- There are no multivalued dependencies.

Both the `sales` and `products` tables meet 4NF after the modification.

**Example:**
An example of multivalued dependency is a project table where a `project_id` can be associated with multiple employees and multiple clients. This creates a scenario where there are two independent multivalued dependencies. To resolve this, the associations should be divided into two tables: `project_employees` and `project_clients`.
