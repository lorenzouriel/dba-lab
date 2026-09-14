# Part 2: SQL Basics

This part builds the fundamental SELECT/WHERE toolkit that every later, more complex query is assembled from. Everything here still operates against a single table — joins, subqueries, grouping, and set operations all come later.

## Chapter 4: Creating a Simple Query

SELECT + FROM == the minimum viable query. Introduces the book's recurring translation technique (English request → Translation → Clean Up → SQL), DISTINCT for deduplicating rows, and ORDER BY for sorting an otherwise unordered result set.

## Chapter 5: Getting More Than Simple Columns

A result set doesn't have to be raw column values. Expressions (concatenation, math, date arithmetic) turn the SELECT clause into a small computation engine, CAST bridges incompatible data types, and Null gets introduced as "missing/unknown" — with the 🤯 fact that it poisons any expression it touches.

## Chapter 6: Filtering Your Data

WHERE turns a table scan into a targeted question. The five core predicates — comparison, BETWEEN, IN, LIKE, IS NULL — cover almost everything you'll ever need to filter on, and AND/OR/NOT let you compose them into arbitrarily complex conditions (carefully parenthesized, since precedence rules are easy to misremember).

## What unifies these chapters

1. Every later, fancier SQL construct (joins, subqueries, GROUP BY, set operators) is still just SELECT/FROM/WHERE underneath — this part is the vocabulary the rest of the book keeps reusing.
2. Null behavior — established in Chapter 5, weaponized against you in Chapter 6 — is a recurring gotcha that resurfaces all the way through aggregates (Chapter 12+) and joins.
3. The Translation → Clean Up → SQL habit taught in Chapter 4 is the same mental process the book keeps applying even as the requests it translates get much harder.
