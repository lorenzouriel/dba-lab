# Match patterns with regular expressions

Completed
100 XP
14 minutes

## Choose your preferred content format

Text processing in databases often requires pattern matching that goes beyond what the LIKE operator can handle. Regular expressions provide a standardized syntax for complex pattern matching, validation, and text transformation. SQL Server 2025 and SQL databases in Microsoft Fabric include regular expression support through new T-SQL functions.

Consider scenarios where LIKE falls short: when someone validates an email address with proper format, extracting phone numbers regardless of formatting variations, finding product codes that follow specific naming conventions, or detecting patterns like consecutive repeated characters. The LIKE operator supports only simple wildcards (% for any characters, _ for a single character), which can't express these complex patterns.

Regular expressions solve these limitations by providing a rich pattern language. With regex, you can match specific character ranges, require exact repetition counts, use alternation (match this OR that), and capture portions of matched text for extraction or replacement. Once you learn regex syntax, you can apply it across many programming languages and tools—the patterns you write for SQL Server work similarly in Python, JavaScript, and command-line utilities.

## Understand regular expression basics

Regular expressions (regex) use a pattern syntax to describe text patterns. Before you learn SQL Server's functions, let's review these common regex components:

| Pattern | Description | Example Match |
|---|---|---|
| `.` | Any single character | `a.c` matches "abc", "a1c" |
| `*` | Zero or more of preceding | `ab*c` matches "ac", "abc", "abbc" |
| `+` | One or more of preceding | `ab+c` matches "abc", "abbc" but not "ac" |
| `?` | Zero or one of preceding | `colou?r` matches "color", "colour" |
| `^` | Start of string | `^Hello` matches strings starting with "Hello" |
| `$` | End of string | `world$` matches strings ending with "world" |
| `[abc]` | Character class | `[aeiou]` matches any vowel |
| `[^abc]` | Negated class | `[^0-9]` matches nondigits |
| `\d` | Digit (0-9) | `\d{3}` matches three digits |
| `\w` | Word character | `\w+` matches word characters |
| `{n}` | Exactly n occurrences | `\d{4}` matches exactly four digits |
| `{n,m}` | Between n and m occurrences | `\d{2,4}` matches 2 to 4 digits |

> **Note**
>
> SQL Server's regular expression functions use the ECMAScript standard regex syntax. This script is the same syntax used in JavaScript and many other programming languages, making patterns portable across technologies.

## Match patterns with REGEXP_LIKE

REGEXP_LIKE returns 1 (true) if a string matches a regular expression pattern, or 0 (false) if it doesn't. Use this function in WHERE clauses to filter rows based on complex patterns:

```sql
-- Find customers with email addresses from specific domains
SELECT CustomerID, FirstName, LastName, EmailAddress
FROM SalesLT.Customer
WHERE REGEXP_LIKE(EmailAddress, '@(contoso|adventure-works|fabrikam)\.com$') = 1;
```

Validate data formats:

```sql
-- Find valid US phone numbers (various formats)
SELECT CustomerID, Phone
FROM SalesLT.Customer
WHERE REGEXP_LIKE(Phone, '^\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}$') = 1;

-- Validate product numbers match expected format (XX-XXXX)
SELECT ProductID, ProductNumber, Name
FROM SalesLT.Product
WHERE REGEXP_LIKE(ProductNumber, '^[A-Z]{2}-[A-Z0-9]{4,6}$') = 1;
```

Use case-insensitive matching with the flags parameter:

```sql
-- 'i' flag enables case-insensitive matching
SELECT Name
FROM SalesLT.Product
WHERE REGEXP_LIKE(Name, 'frame', 'i') = 1;
```

> **Tip**
>
> Use REGEXP_LIKE for validation and filtering. It's more efficient than extracting substrings when you only need to know whether a pattern exists.

## Replace text with REGEXP_REPLACE

REGEXP_REPLACE finds all occurrences of a pattern and replaces them with a specified string. This function is useful for data cleansing and standardization:

```sql
-- Standardize phone numbers to (XXX) XXX-XXXX format
SELECT 
    Phone AS OriginalPhone,
    REGEXP_REPLACE(
        REGEXP_REPLACE(Phone, '[^\d]', ''),  -- First remove all non-digits
        '^(\d{3})(\d{3})(\d{4})$',
        '($1) $2-$3'
    ) AS StandardizedPhone
FROM SalesLT.Customer
WHERE Phone IS NOT NULL;
```

The following examples demonstrate how to use capture groups with backreferences:

```sql
-- Swap first and last name
DECLARE @name NVARCHAR(100) = 'Smith, John';
SELECT REGEXP_REPLACE(@name, '^(\w+),\s*(\w+)$', '$2 $1') AS SwappedName;
-- Returns: John Smith

-- Mask credit card numbers (show last 4 digits only)
DECLARE @card NVARCHAR(20) = '4532-1234-5678-9012';
SELECT REGEXP_REPLACE(@card, '\d(?=[\d-]{4,})', '*') AS MaskedCard;
-- Returns: ****-****-****-9012
```

The following examples demonstrate how to clean and normalize data:

```sql
-- Remove extra whitespace (multiple spaces to single space)
SELECT REGEXP_REPLACE(Description, '\s+', ' ') AS CleanedDescription
FROM Products;

-- Remove HTML tags
SELECT REGEXP_REPLACE(HtmlContent, '<[^>]+>', '') AS PlainText
FROM WebPages;
```

## Extract substrings with REGEXP_SUBSTR

REGEXP_SUBSTR extracts the portion of a string that matches a regular expression pattern. Use it to pull specific data elements from unstructured text like the following examples:

```sql
-- Extract domain from email address
SELECT 
    EmailAddress,
    REGEXP_SUBSTR(EmailAddress, '@(.+)$', 1, 1, '', 1) AS Domain
FROM SalesLT.Customer
WHERE EmailAddress IS NOT NULL;

-- Extract the first number from a string
SELECT 
    ProductNumber,
    REGEXP_SUBSTR(ProductNumber, '\d+') AS FirstNumber
FROM SalesLT.Product;
```

The following example demonstrates the function signature, which includes parameters for occurrence and capture groups:

```sql
REGEXP_SUBSTR(source, pattern, start_position, occurrence, flags, capture_group)
```

## Find pattern positions with REGEXP_INSTR

REGEXP_INSTR returns the starting position of a pattern match within a string. Returns 0 if no match is found, like the following examples:

```sql
-- Find position of first digit in product number
SELECT 
    ProductNumber,
    REGEXP_INSTR(ProductNumber, '\d') AS FirstDigitPosition
FROM SalesLT.Product;

-- Find position of email domain
SELECT 
    EmailAddress,
    REGEXP_INSTR(EmailAddress, '@') AS AtPosition,
    REGEXP_INSTR(EmailAddress, '\.[a-z]+$', 1, 1, 0, 'i') AS TldPosition
FROM SalesLT.Customer
WHERE EmailAddress IS NOT NULL;
```

## Count pattern occurrences with REGEXP_COUNT

REGEXP_COUNT returns the number of times a pattern appears in a string. The following examples illustrate its use:

```sql
-- Count words in a description
SELECT  
    Name,
    REGEXP_COUNT(Name, '\w+') AS WordCount
FROM SalesLT.Product;

-- Count vowels in product names
```

> **Note:** Source content was truncated at this point (exceeded 50,000 character limit). Remaining content to be appended when provided.
