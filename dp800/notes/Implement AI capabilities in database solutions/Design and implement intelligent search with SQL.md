## Introduction
- Module theme = **intelligent search in SQL**: full-text search (keywords) → vector search (semantic/embeddings) → hybrid search (combine both via RRF)
- Core framing: query intent decides the approach — known terms → full-text; described needs/concepts → vector; unpredictable mix → hybrid
- **Exam angle**: this module pairs directly with the prior embeddings module — expect scenario questions matching a described user search behavior to the right approach, plus RRF score-calculation questions (they clearly love RRF as a worked-example topic)

## Choose an intelligent search approach
- **Three approaches, know exactly what each does:**
    - **Full-text search** — matches words/phrases, understands **inflectional forms** (ride→riding/rode) via language rules; use when users know the specific words
    - **Semantic vector search** — compares mathematical meaning representations; finds conceptually related results even with **zero shared words** (e.g., "keep visible on evening rides" → "reflective cycling vest"); use when users describe needs rather than name things
    - **Hybrid search** — runs both, merges results — covers unpredictable query style (exact model number **and** vague description in the same query)
- **Trade-off dimensions to weigh:**
    - **Precision vs recall**: full-text = fewer but tightly-matching results (higher precision); vector = broader, includes conceptually-related items using different words (higher recall). Exact-match need → full-text; discovery need → vector
    - **Data prep requirements**: full-text needs a **full-text index**; vector needs **embeddings in vector columns** — different upfront preparation
    - **Performance**: full-text index = fast keyword lookup; vector search speed depends on candidate count + exact vs approximate method; **hybrid runs both → slowest of the three**
- **Reciprocal Rank Fusion (RRF)** — the algorithm for merging two ranked lists without normalizing incompatible score scales (BM25 vs cosine distance):
    - Formula: **`1/(rank + k)`**, where **k = 60** (standard constant from the original RRF research, also used by Azure AI Search)
    - Documents appearing in **both** lists get their per-list scores **summed** — this is the core mechanic: appearing twice, even at a lower rank in one list, can beat a #1-in-only-one-list result
    - **Worked example to internalize**: a product ranked #1 full-text + #3 vector → combined score `1/(60+1) + 1/(60+3) = 0.0164+0.0159 = 0.0323`, which **beats** a different product ranked #1 in vector-only (`1/(60+1) = 0.0164` alone) — dual-list presence wins over single-list top rank
    - Ties in RRF score → ordering is implementation-defined/arbitrary; practically treated as equally relevant
- **Exam angle**: the RRF formula (`1/(rank+k)`, k=60) and the "appearing in both lists beats being #1 in only one" mechanic are near-certain to be tested, likely via a mini worked calculation; also matching search-approach to described query intent

## Implement full-text search
- Full-text search ≠ `LIKE` — it's **language-aware**: understands word forms/inflections, but does **NOT** auto-match synonyms or abbreviations (e.g., "MTB" ≠ "mountain bike") **unless you configure a thesaurus**
- Requires: a **full-text index** on the text column (tokenizes text, strips **stopwords** like "the"/"is", builds an inverted index word→rows) + **predicates** in the WHERE clause to query it
- **Two core predicates — know the distinction:**
    - **`CONTAINS`** — exact word/phrase matching, precise control
    - **`FREETEXT`** — meaning-based, automatically expands to inflectional forms (searching "riding bikes" also matches "ride", "rides", "biking")
- **Ranked variants**: `CONTAINSTABLE` / `FREETEXTTABLE` — table-valued functions returning a `RANK` column (relevance score) for sorting — these ranks later feed into hybrid search's RRF calculation
```sql
SELECT p.ProductID, p.Name, ft.RANK
FROM Production.Product p
INNER JOIN CONTAINSTABLE(Production.Product, Name, 'NEAR((mountain, bike))') AS ft
    ON p.ProductID = ft.[KEY]
ORDER BY ft.RANK DESC;
```

- **Five query patterns — memorize each syntax:**
    - **Term**: `CONTAINS(Description, 'aluminum')`
    - **Phrase** (exact order): `CONTAINS(Description, '"mountain bike"')`
    - **Prefix**: `CONTAINS(Description, '"light*"')` → matches light/lights/lighter/lightweight
    - **Inflectional**: `CONTAINS(Description, 'FORMSOF(INFLECTIONAL, "ride")')` → matches ride/rides/riding/rode
    - **Proximity**: `CONTAINS(Description, 'NEAR((light, aluminum))')` → words appearing close together
- **Diagnosing full-text search problems** — three signals and what they indicate:
    - **Precision problems** (irrelevant results, e.g. "brake" matching "brake-resistant") → use phrase search or more specific terms
    - **Noise** (common words diluting results despite stoplists) → may need a **custom stoplist** for domain-specific noise words
    - **Query intent mismatch** (users search concepts, e.g. "something for rainy commutes" expecting waterproof gear) → signal to move to **vector or hybrid search**
- **Exam angle**: CONTAINS vs FREETEXT distinction, the five query pattern syntaxes (especially FORMSOF and NEAR), and recognizing "query intent mismatch" as the specific signal that full-text search is the wrong tool are the top testable points

## Prepare SQL for vector search
- **`VECTOR(n)`** data type — native, stores embeddings as an array of **single-precision (4-byte) floats**, exposed as JSON arrays; `n` = dimension count must match your embedding model's output (e.g., OpenAI text-embedding-3-small = 1536). **Max supported: 1,998 dimensions**
    - Storage cost: ~6 KB per row for a 1536-dim vector — factor into storage/memory planning at scale
- **Three distance metrics — know exactly what each measures and its range:**
    - **Cosine**: angle only, ignores magnitude — range **0 (identical) to 2 (opposite)** — most common, since most embedding models are cosine-optimized
    - **Euclidean**: straight-line distance, considers magnitude — range **0 to infinity**
    - **Dot product**: SQL Server returns the **negative** dot product so smaller = more similar (consistent direction with the other two metrics)
- **Exact (ENN) vs Approximate (ANN) search — the core capacity-planning decision:**
    - **Exact** — `VECTOR_DISTANCE` function, computes distance to **every row**, guaranteed accurate, best for **<50,000 vectors** (general guideline) or heavily-filtered queries
    - **Approximate** — `VECTOR_SEARCH` function + a **vector index**, trades perfect accuracy for speed via the **DiskANN** algorithm (graph-based navigation); use for hundreds of thousands to millions of vectors where speed > perfect accuracy
    - **Recall** = how many true nearest neighbors ANN actually returns vs what exact search would — DiskANN typically achieves high recall

```sql
CREATE VECTOR INDEX idx_Products_DescriptionVector
ON dbo.Products(DescriptionVector)
WITH (METRIC = 'cosine', TYPE = 'DiskANN');
```

- **Vector index limitations — memorize these constraints, they're very testable:**
    - Table must have a **single-column integer primary key with a clustered index**
    - Table becomes **read-only while the index exists** — must drop the index to modify data, then recreate it
    - Vector indexes **cannot be partitioned**
    - Currently **in preview**; Azure SQL DB/Fabric SQL DB offer `ALLOW_STALE_VECTOR_INDEX` scoped config to permit writes anyway (index just won't reflect new data until rebuilt) — **not available in SQL Server 2025**
    - Practical design implication: for frequently-changing tables, use exact search until data stabilizes, then add the index
- **Exam angle**: the three distance metric ranges/definitions, the 50,000-vector exact-vs-approximate threshold guideline, and especially the vector index limitations (read-only during index lifetime, single-int-PK requirement, no partitioning) are the highest-yield testable facts

## Implement vector search query patterns
- **Four core functions — know exactly what each does and when to use it:**
    - **`VECTOR_DISTANCE(metric, vector1, vector2)`** — exact, computes distance to every qualifying row; metric must be `'cosine'`/`'euclidean'`/`'dot'`; both vectors must share dimension count
    - **`VECTOR_SEARCH(TABLE=, COLUMN=, SIMILAR_TO=, METRIC=, TOP_N=)`** — approximate, uses the vector index if one exists on that column+metric; **falls back to exact search with a warning if no matching index exists**
    - **`VECTOR_NORMALIZE(vector, norm_type)`** — scales to unit length; `norm_type`: `'norm2'` (Euclidean, most common), `'norm1'` (sum of absolute values), `'norminf'` (max absolute value) — needed when comparing vectors from **different models/sources** that aren't already normalized (most modern models like OpenAI's already are)
    - **`VECTORPROPERTY(vector, property)`** — metadata inspection: `'Dimensions'` (int) or `'BaseType'` (currently always float) — useful for debugging dimension mismatches across different embedding models
    - Related: `VECTOR_NORM(vector, norm_type)` — returns the magnitude itself (not the normalized vector)

```sql
SELECT TOP 10 ProductID, Name, VECTOR_DISTANCE('cosine', @searchVector, DescriptionVector) AS Distance
FROM dbo.Products ORDER BY Distance;
```

- **Critical gotcha — `VECTOR_SEARCH` filters AFTER finding nearest neighbors, not before**: a `WHERE` clause on the outer query only filters the `TOP_N` candidates already retrieved — if none of those candidates match the filter, you get **zero results** even if matching rows exist elsewhere in the table
    - **Fix pattern**: over-request candidates (`TOP_N = 50`) then apply the filter and take your actual desired count (`SELECT TOP 10 ... WHERE ...`) — gives the filter more candidates to work with

```sql
SELECT TOP 10 t.ProductID, t.Name, s.distance
FROM VECTOR_SEARCH(TABLE = dbo.Products AS t, COLUMN = DescriptionVector, SIMILAR_TO = @searchVector, METRIC = 'cosine', TOP_N = 50) AS s
WHERE t.CategoryID = 5
ORDER BY s.distance;
```

- Threshold-based search (find "everything similar enough" rather than a fixed count) uses `VECTOR_DISTANCE` in a `WHERE ... < threshold` clause — threshold value is empirically tuned per dataset/model, not a fixed universal number
- **Function selection table** (mirrors the exact-vs-approximate decision from the prior unit): small/filtered → `VECTOR_DISTANCE`; large+indexed → `VECTOR_SEARCH`; cross-model comparison → `VECTOR_NORMALIZE`; debugging → `VECTORPROPERTY`
- **Exam angle**: the post-filtering behavior of `VECTOR_SEARCH` (filters apply after TOP_N retrieval, not before) and the over-request-candidates workaround is the single most testable gotcha in this unit; also matching each of the four functions to its purpose

## Implement hybrid search and ranking
- Hybrid search = run **both** `FREETEXTTABLE`/`CONTAINSTABLE` (full-text, BM25-ranked) **and** `VECTOR_DISTANCE`/`VECTOR_SEARCH` (vector, distance-ranked) against the same data, then merge via **RRF**
- **RRF formula** (same as prior module, now with full implementation): `RRF_score = 1/(k + rank_source1) + 1/(k + rank_source2)`, **k = 60** typically
    - Why RRF over raw score fusion: **BM25 and cosine distance use incompatible scales** — RRF sidesteps this by using rank position only; also prevents one source's naturally higher scores from dominating (fairness between sources)
- **Full T-SQL implementation pattern** — structured via **three CTEs**, know this shape:

```sql
WITH keyword_search AS (
    SELECT TOP(@topN) p.ProductID, RANK() OVER (ORDER BY ftt.[RANK] DESC) AS keyword_rank
    FROM dbo.Products p
    INNER JOIN FREETEXTTABLE(dbo.Products, Description, @searchText) AS ftt ON p.ProductID = ftt.[KEY]
),
vector_search AS (
    SELECT TOP(@topN) ProductID, RANK() OVER (ORDER BY distance) AS vector_rank
    FROM (SELECT ProductID, VECTOR_DISTANCE('cosine', @searchVector, DescriptionVector) AS distance FROM dbo.Products) AS sp
),
combined AS (
    SELECT TOP(@topN) COALESCE(ks.ProductID, vs.ProductID) AS ProductID,
        COALESCE(1.0/(@rrfK + ks.keyword_rank), 0.0) + COALESCE(1.0/(@rrfK + vs.vector_rank), 0.0) AS rrf_score
    FROM keyword_search ks FULL OUTER JOIN vector_search vs ON ks.ProductID = vs.ProductID
)
SELECT p.*, c.rrf_score FROM combined c INNER JOIN dbo.Products p ON c.ProductID = p.ProductID ORDER BY c.rrf_score DESC;
```

- **`FULL OUTER JOIN`** between the two CTEs — ensures products in **either** list are included, not just the intersection
- **`COALESCE(..., 0.0)`** — handles products appearing in only one list by treating the missing side's contribution as zero
- For large tables, swap the exact `VECTOR_DISTANCE` subquery for `VECTOR_SEARCH` (DiskANN-indexed) in the `vector_search` CTE
- **Tunable parameters:**
    - **`@topN`** (candidates per source, e.g. 50) — larger = more thorough RRF input but slower
    - **`@rrfK`** (60 standard) — larger k **smooths** rank differences; smaller k **amplifies** top-rank advantage
    - **Source weighting**: multiply one source's contribution (e.g., `2.0/(@rrfK + vector_rank)` to weight vector 2x over keyword)
    - **Filter timing**: apply filters **before** hybrid search when possible — filtering after RRF risks eliminating already-highly-ranked results (same post-filter pitfall as `VECTOR_SEARCH` alone)
- **Quality evaluation metrics — know each definition:**
    - **Precision** = % of returned results that are relevant
    - **Recall** = % of all relevant documents actually found
    - **MRR (Mean Reciprocal Rank)** = how high the _first_ relevant result ranks — rewards putting the best result at top
    - Requires a test set of queries with known-relevant documents; compare full-text-only vs vector-only vs hybrid. **Hybrid typically improves recall with minimal precision loss** vs either alone
- **Exam angle**: the three-CTE structure (especially FULL OUTER JOIN + COALESCE handling for single-source-only results), what raising/lowering `@rrfK` does, and the precision/recall/MRR definitions are the top testable points — very likely paired with a "calculate the RRF score" numeric question given how much worked-example emphasis both search modules put on it