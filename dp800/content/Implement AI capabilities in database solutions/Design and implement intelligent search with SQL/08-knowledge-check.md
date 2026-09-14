# Knowledge check

Completed

- 5 minutes

## Check your knowledge

**1. Which full-text predicate finds documents containing words that are inflectional forms of a search term, such as finding 'running' when searching for 'run'?**

- CONTAINS with FORMSOF(INFLECTIONAL)
- FREETEXT
- Both CONTAINS with FORMSOF(INFLECTIONAL) and FREETEXT
- Neither - inflectional matching requires vector search

**2. What is the range of cosine distance values when comparing two vectors?**

- -1 to 1
- 0 to 1
- 0 to 2
- 0 to infinity

**3. Which function should be used for vector search on a table with 500,000 rows when query speed is the priority?**

- VECTOR_DISTANCE
- VECTOR_SEARCH
- VECTOR_NORMALIZE
- FREETEXTTABLE

**4. What problem does Reciprocal Rank Fusion (RRF) solve in hybrid search?**

- It improves the speed of vector search
- It combines ranked results from different sources without requiring score normalization
- It converts full-text results to vectors
- It creates full-text indexes automatically
