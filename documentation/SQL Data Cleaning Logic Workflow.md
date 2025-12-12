# SQL Data Cleaning Logic Workflow - Coffee Shop Sales 
*A complete explanation demonstrating ETL (Extract/Transform/Load) process and analysis logic workflow.*

---

## Project Overview
This project simulates a **real-world data analyst workflow** - similar to what is done in professional roles.
The goal is to:

- Import, Clean and Prepare raw data
- Understand business context before cleaning
- Transform messy data into structured, analysable form
- Create meaningful data for storytelling and visualisations

---

## Tools Used

| Tool | Purpose |
|------|-------------------------|
| **SQL Server (SSMS)** | Data import, cleaning, transformation, export with SQL queries |
| **Google Sheets** | Quick checks, Pivot Tables & Visualizations |
| **Jupyter Lab / Notepad / Markdown** |   Workflow Documentation |
| **GitHub** | Portfolio & version control |

## Business Problem
The coffee shop wants to -  
- Understand sales patterns & revenue
- Identify peak hours
- Improve stock & staffing decisions
- Track product perfromance
- Analyse performance across different days/weeks/months

But the raw data had **data quality issues** (date/time format issues, missing values, etc.), so SQL cleaning was essential

---

## SQL Cleaning Techniques Used

- Importing raw CSV into SQL Server
- Inspecting the dataset with various queries
- Creating Helper columns
- Using `SELECT`, `FROM`, `WHERE`, and `INTO`
- Identifying unusable columns and documenting them
- Identifying the range of Unique categories with `DISTINCT`
- Checking for duplicates using `GROUP BY`
- Checking for NULL/missing values `NULLIF`
- Cleaning text fields using `TRIM()`
- Converting formats using `TRY_CONVERT()`
- Standardizing text rows and columns with `UPPER/LOWER`
- Creating permanent cleaned data table using `SELECT` `INTO` with `CTE`and `CASE WHEN` statements before Exporting data to Google sheets 

**Full SQL scripts can be found in the Repository**

***Key Learning:***
> Never clean or analyse data blindly - always understand business context first.

---

## About the Dataset

The dataset represents coffee shop sales transactions collected over several months.<br>

It contains one row per transaction, including:<br>
- Date of purchase
- Time of purchase
- Product type (e.g., Latte, Americano, Mocha)
- Payment method
- Transaction amount

**Source:** *Source: Public dataset from Kaggle (“Coffee Shop Sales”).* input Raw csv file link here 
**Granularity:** One row = one customer transaction.  
**Time period:** Sales data across 1 year.  
**Primary Use:** Time-based trend analysis, product performance analysis, and operational insights. 

---

## Table of Contents
1. [Importing and Inspecting the Dataset](#1-importing-and-inspecting-the-dataset)
2. [Understanding the Business Context](#2-understanding-the-business-context)
3. [Data Cleaning & Preparation](#3-data-cleaning--preparation)
   - [3.1 Column Classification](#31-column-classification)
   - [3.2 Column-by-Column Inspection](#32-column-by-column-inspection)
   - [3.3 Cleaning Steps](#33-cleaning-steps)
   - [3.4 Final Cleaned Dataset (SELECT-Based Cleaning)](#34-final-cleaned-dataset-select-based-cleaning)
   - [3.5 Final Data Quality Checks](#35-final-data-quality-checks)
4. [Exporting the Cleaned Dataset](#4-exporting-the-cleaned-dataset)

---
  
## 1. Importing and Inspecting the Dataset
Before cleaning the data, the first step is to import the dataset as a .csv file into SQL server and perform basic inspection queries to understand the structure, data types, row counts, and any obvious issues in the raw dataset. 

---

#### Importing CSV into SQL Server 
The CSV file was imported into SQL Server using the Import Data Wizard in SSMS (right-click Database **->** Tasks **->** Import Flat File). This created the raw querying table named 'Coffee_shop_sales'.

---

#### Basic Inspection Queries
To inspect the raw dataset, I ran the following SQL checks:
```sql
-- view sample records
SELECT TOP 10 *
FROM dbo.Coffee_shop_sales;
-- count total rows
SELECT COUNT(*)
FROM dbo.Coffee_shop_sales;
-- check column names and data types 
sp_help 'dbo.Coffee_shop_sales'; 
```

---

## 2. Understanding the Business Context
The dataset represents transactions from a fictional coffee shop chain that operates across multiple days and months. Each row reflects a single customer purchase, including the drink type, price, payment method, and timestamp.

Understanding the business context is essential before performing any cleaning as it helps determine which columns are critical for analysis and which were optional or acceptable to exclude if unreliable.

- The coffee shop serves customers throughout the day, with demand likely influenced by daily routines such as commuting, work breaks, and weekend patterns.
- Product performance can reveal which beverages drive the most revenue and which may need promotion or review.
- Payment method patterns can indicate operational considerations, such as cash handling vs. digital payment efficiency.
- Time-based trends (hourly, daily, monthly) can guide decisions about staffing levels, inventory planning, and targeted promotions.

This foundational understanding ensures that cleaning, transformation, and visualization focus on insights that matter to the business and support real operational improvements.

---

## 3. Understanding the RAW DATA

#### 3.1 Column Classification 
Each column was evaluated to assess its credibility, consistency, and relevance before cleaning. Columns were then classified into three categories based on verified behaviour rather than assumptions.

---

##### Category A - Credible Columns (Safe to Clean)
These columns had consistent values, correct data types, and no logical contradictions:

- `hour_of_day` - already clean and reliable
- `cash_type` - consistent categories (Cash/Card)
- `money` - numeric, clean, and matches expected ranges
- `coffee_name` - consistent product names
- `Weekday` - logically correct (Monday-Sunday)
- `Month_name` - correct month names
- `Weekdaysort` - numeric sort order for weekdays
- `Monthsort` - numeric sort order for months

---
  
##### Category B - Columns Requiring Validation

These columns were mostly usable but required checks:  
- `Date` - required correct date format validation.
- `Time_of_Day` - partially consistent but needed inspection for AM/PM logic.

---

##### Category C - Unreliable or Unusable Columns
These columns contained inconsistent formatting, ambiguous values, or incorrect entries:  
- `Time` - inconsistent format, missing AM/PM, impossible times, not repairable with confidence.

---

#### 3.2 Column-Level Data Profiling & Transformation Testing
Each column was individually profiled through exploratory data cleaning, where I tested Trimming, Standardization, and Conversion logic to see how the data responded before applying these steps in the final query. By trial-running transformations and validating their outputs, I was able to inspect the columns and confirm the correct cleaning approach. This ensured that  every action was based on verified behaviour rather than assumptions. 

---

##### Inspecting `hour_of_day`
The hour_of_day column was inspected to validate that all the values were within a valid 0-23 hour range and contained no unexpected categories or missing values. 

```sql
-- check unique hour values
SELECT DISTINCT hour_of_day
FROM dbo.Coffee_shop_sales
ORDER BY hour_of_day DESC;

-- check for NULL or invalid entries
SELECT *
FROM dbo.Coffee_shop_sales
WHERE hour_of_day IS NULL
    OR hour_of_day NOT BETWEEN 0 AND 23;
```

---

##### Inspecting/Standardizing `cash_type`
The cash_type column stores the payment methods for each transaction. The goal was to verify that the values were limited to valid categories such as 'Cash' and 'Card', with no inconsistent spellings or unexpected entries. Additionally I standardized the text format of the entries into ProperCase to ensure consistency and miantain uniformity in the dataset.

```sql
-- view unique payment types
SELECT DISTINCT cash_type
FROM dbo.Coffee_shop_sales;

-- check for NULLS or incorrect spellings
SELECT *
FROM dbo.Coffee_shop_sales
WHERE cash_type IS NULL 
    OR cash_type NOT IN ('Cash', 'Card');

-- Standardize any format variations
SELECT cash_type,
	UPPER(LEFT(TRIM(cash_type),1))
             + LOWER(SUBSTRING(TRIM(cash_type),2,LEN(TRIM(cash_type)
    ))) AS Cleaned_Cash_type
FROM dbo.Coffee_shop_sales 
```

---

##### Inspecting/Verifying/Standardizing `money`
The money column represents the transaction amount. It was inspected to ensure values were numeric, non-negative, and within a reasonable range for coffee shop purchases. This step helps detect outliers, data entry mistakes, or incorrect imports. 

```sql
-- check value range and unique patterns 
SELECT DISTINCT money
FROM dbo.Coffee_shop_sales
ORDER BY money;

-- detect the exact rows containing negative or zero sales amounts
SELECT *
FROM dbo.Coffee_shop_sales
WHERE money <= 0;

-- check for NULLS 
SELECT *
FROM dbo.Coffee_shop_sales
WHERE money IS NULL;

-- Look for unusually high outlier amounts
SELECT TOP (10)
    ROUND([money], 2) AS rounded_money
FROM dbo.Coffee_shop_sales
ORDER BY rounded_money DESC;
```

---

##### Inspecting/Validating `coffee_name`
The coffee_name column contains the product name for each transaction. The inspection focused on checking for inconsistent spellings, extra whitespace, unexpected categories, and null values.

```sql
-- view all unique coffee product names
SELECT DISTINCT coffee_name
FROM dbo.Coffee_shop_sales
ORDER BY coffee_name;

-- check for duplicated variations (example: 'Latte' vs 'Latte ') and counts per value
SELECT coffee_name, COUNT(*) AS Total
FROM dbo.Coffee_shop_sales
GROUP BY coffee_name
ORDER BY Total DESC;

-- check for NULLS or empty values or whitespace
SELECT *
FROM dbo.Coffee_shop_sales
WHERE coffee_name IS NULL
    OR coffee_name = ''
    OR coffee_name LIKE ' %'
    OR coffee_name LIKE '% ';

-- trim leading and trailing whitespaces and turn blanks into proper nulls
SELECT 
    coffee_name,
    NULLIF(TRIM(coffee_name), '') AS cleaned_coffee_name
FROM dbo.Coffee_shop_sales
WHERE NULLIF(TRIM(coffee_name), '') IS NULL
```

---

##### Inspecting/Validating `Weekday`
The Weekday column stores the day name for each transaction. The inspection checked for correct weekday names, proper capitalization, and any inconsistent or misspelled values.

```sql
-- validate weekday names
SELECT DISTINCT [Weekday], [Weekdaysort]
FROM dbo.Coffee_shop_sales
ORDER BY [Weekdaysort];

-- check for duplicates
SELECT [Weekday], COUNT(*) as Total_Number
FROM dbo.Coffee_shop_sales
GROUP BY [Weekday], Weekdaysort
ORDER BY [Weekdaysort]

-- isolate rows containing NULLS or invalid weekday names
SELECT *
FROM dbo.Coffee_shop_sales
WHERE [Weekday] IS NULL
	OR [Weekday] NOT IN ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');
```

---

##### Inspecting/Validating `Month_name`
The Month_name column contains the month for each transaction. The inspection checked that month names were consistent, correctly spelled, and matched the corresponding dates. 

```sql
-- validate month names
SELECT DISTINCT Month_name, Monthsort
FROM dbo.Coffee_shop_sales
ORDER BY Monthsort;

-- check for duplicates
SELECT Month_name, COUNT(*) AS Total_Number
FROM dbo.Coffee_shop_sales
GROUP BY Month_name, Monthsort
ORDER BY Monthsort;

-- isolate rows containing NULLS or invalid month names
SELECT *
FROM dbo.Coffee_shop_sales
WHERE Month_name IS NULL
	OR Month_name NOT IN (
		'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
		'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
```

---

##### Inspecting/Verifying `Weekdaysort` and `Monthsort`
The Weekdaysort and Monthsort columns are numerical helper fields used to correctly sort weekdays (Monday-Sunday) and months (January-December). These were inspected to ensure the numbers follow the correct sequence and contained no missing or incorrect values.

```sql
-- verify weekdaysort order is correct (1-7)
SELECT DISTINCT Weekdaysort
FROM dbo.Coffee_shop_sales
ORDER BY Weekdaysort;

-- verify monthsort order is correct (1-12)
SELECT DISTINCT Monthsort
FROM dbo.Coffee_shop_sales
ORDER BY Monthsort;

-- isolate rows containing NULLs or incorrect weekdaysort and monthsort values
SELECT *
FROM dbo.Coffee_shop_sales
WHERE Weekdaysort IS NULL
   OR Monthsort IS NULL
   OR Weekdaysort NOT BETWEEN 1 AND 7
   OR Monthsort NOT BETWEEN 1 AND 12;
```

---

##### Inspecting/Validating/Verifying `Date`
The Date column was inspected to ensure all values were valid dates with no malformed formats, missing entries, or values that could not be converted into a proper SQL 'DATE' data type. This validation is essential for any time-base analysis.

```sql
-- verify date values to confirm formatting
SELECT DISTINCT [Date]
FROM dbo.Coffe_shop_sales
ORDER BY [Date];

-- identify NULLS, invalid or unconvertible date formats
SELECT *
FROM dbo.Coffee_shop_sales
WHERE try_convert(DATE, [Date]) IS NULL
	  OR [Date] IS NULL;

-- confirming that Date is converted and read correctly with Style code 103 for UK dates
SELECT
    try_convert(DATE, [Date], 103) AS Cleaned_Date
FROM dbo.Coffee_shop_sales
WHERE try_convert(DATE, [Date], 103) IS NULL

-- validate date range looks reasonable 
SELECT
    min(try_convert(date, Date)) AS Earliest_Date,
    max(try_convert(date, Date)) AS Latest_Date
FROM dbo.Coffee_shop_sales;
```

---

##### Inspecting `Time` (Unreliable Column)
The Time column contained multiple inconsistencies, including missing AM/PM indicators, mixed formats, impossible time values, and entries that did not align with expected business hours. 
After inspecting the values, this column was identified as unreliable and unsafe for repair. Instead of cleaning this column, a decision was to exclude it from analysis and rely on alternative fields such as 'hour_of_day' and 'Time_of_Day'.

```sql
-- view unique Time values to identify formatting issues
SELECT DISTINCT [Time]
FROM dbo.Coffee_shop_sales
ORDER BY [Time] DESC;

-- detect missing or ambiguous AM/PM Time values
SELECT [Time]
FROM dbo.Coffee_shop_sales
WHERE Time LIKE '%AM'
    AND Time LIKE '%PM';

-- attempt to convert and see valid and invalid results 
SELECT [Time]
FROM dbo.Coffee_shop_sales
WHERE try_convert(TIME, [Time]) IS NULL;

SELECT [Time]
FROM CoffeeSalesDB.dbo.Coffee_shop_sales
WHERE try_convert(TIME, [Time]) IS NOT NULL;

-- find WHY conversion failed (pattern audit)
SELECT [Time]
FROM dbo.Coffee_shop_sales
WHERE [Time] LIKE '%:%:%:%'  -- 3+ colons 
   OR [Time] LIKE '%::%'     -- Double colons
   OR [Time] LIKE '%..%'     -- Unusual dots
   OR [Time] LIKE '%--%'     -- Double hyphens
   OR [Time] LIKE '% % %'    -- Multiple spaces
   OR [Time] LIKE '%:%.%'    -- Incorrect time format 
   OR [Time] IS NULL;		 -- Missing values
```

Based on these inspections, the 'Time' column was classified as a Category C field (unusable) and excluded from the cleaning workflow.  
***Exploratory data cleaning script can be found in the Repository***  
>input .sql file link here

---

### 3.3 Cleaning Steps
After completing the inspection, validation, standardization and verification phase, the next step was to apply targeted cleaning actions in SQL. Each cleaning step was based on verified issues identified earlier, ensuring that no assumptions were made and no columns were altered without logical justification. The goal was to prepare a clean, reliable version of the dataset suitable for accurate analysis. 

---

### 3.4 Final Cleaned Dataset (SELECT-Based Cleaning)
In this final cleaning query I used a CTE (`WITH Source AS (...)`) to separate raw-data standardisation from the final output, which keeps the logic readable and easy to maintain. 

Inside the CTE I standardised all text fields with `TRIM` and `NULLIF('', ...)`, so any leading or trailing spaces are removed and blank strings are consistently treated as real `NULL` values rather than hidden text. I also enforced correct data types at this stage: `TRY_CONVERT(DATE, [Date], 103)` parses the correct UK-style dates into a proper `DATE` type, and `TRY_CONVERT(decimal(10,2), [money])` converts money column into a numeric type with 2 decimal values suitable for money aggregation.

In the outer `SELECT`, I then applied a `CASE` expression only to `Cash_type_clean` to derive a presentation-ready `Cash_Type` column, using `UPPER/LOWER` to fix the casing while preserving `NULL` where the original value was missing. Finally, I used `SELECT ... INTO dbo.Coffee_shop_sales_cleaned` to materialise this cleaned and standardised result set into a new table, so the original raw data remains untouched and the cleaned table is ready for analysis, reporting and downstream tools.

```sql
-- All in one Final SELECT with CTE and CASE WHEN 

WITH Source AS (
    SELECT
        NULLIF(TRIM(coffee_name), '')          AS Coffee_Name,
        NULLIF(TRIM(Time_of_Day), '')          AS Time_of_Day,
        NULLIF(TRIM([Weekday]), '')            AS [Weekday],
        NULLIF(TRIM(Month_name), '')           AS Month_Name,
        TRY_CONVERT(DATE, [Date], 103)         AS [Date],
        TRY_CONVERT(decimal(10,2), [money])    AS [Money],
        NULLIF(TRIM(cash_type), '')            AS Cash_type_clean,
        hour_of_day                            AS Hour_of_Day,
        Weekdaysort,
        Monthsort
    FROM dbo.Coffee_shop_sales
)
SELECT 
    Coffee_Name, 
    Time_of_Day,
    [Weekday],
    Month_Name,
    [Date],
    [Money],
    CASE 
        WHEN Cash_type_clean IS NULL THEN NULL
        ELSE UPPER(LEFT(Cash_type_clean,1)) 
             + LOWER(SUBSTRING(Cash_type_clean,2,LEN(Cash_type_clean)))
    END AS Payment_Method,
    Hour_of_Day,
    Weekdaysort,
    Monthsort
INTO dbo.Coffee_shop_sales_cleaned
FROM Source;
```

---

### 3.5 Final Data Quality Verification
After generating the cleaned dataset using the final SELECT query, a series of quality checks were performed to ensure that no invalid values, NULL entries, or inconsistencies remained, to confirm that the dataset is fully reliable and ready for export. 

---

##### Quality Checks
The following SQL checks were run to validate the cleaned dataset and ensure that all important fields were complete, correctly formatted, and logically consistent. 

```sql
-- check for NULLS in critical columns
SELECT * 
FROM dbo.Coffee_shop_sales_cleaned
WHERE [Date] IS NULL
   OR [Money] IS NULL
   OR Coffee_name IS NULL
   OR Payment_Method IS NULL
   OR Time_of_Day IS NULL
   OR [Weekday] IS NULL
   OR Month_Name IS NULL;

-- ensure money values are positive and valid decimals 
SELECT *
FROM dbo.Coffee_shop_sales_cleaned
WHERE [Money] <= 0;

-- confirm date range is reasonable for a coffee shop dataset
SELECT 
    min([Date]) AS Earliest_date,
    max([Date]) AS Latest_date
FROM dbo.Coffee_shop_sales_cleaned;

-- confirm that all payment types are valid
SELECT DISTINCT Payment_Method
FROM dbo.Coffee_shop_sales_cleaned
WHERE Payment_Method NOT IN ('Cash', 'Card');

-- verify weekdaysort and monthsort pattern structure
SELECT DISTINCT Weekdaysort
FROM dbo.Coffee_shop_sales_cleaned
ORDER BY Weekdaysort;

SELECT DISTINCT Monthsort
FROM dbo.Coffee_shop_sales_cleaned
ORDER BY Monthsort;
```

All verification checks confirmed that the cleaned dataset met the required quality standards and was ready for export and visualization.  
***Final SELECT script with quality verification statements can be found in the Repository***  
>input .sql file link here

---

## 4. Exporting the Cleaned Dataset
After validating the cleaned dataset, the next step was to export it into a spreadsheet format for further visualization in Google Sheet or Power BI. Since the cleaned dataset was created using a `SELECT ... INTO dbo.Coffee_shop_sales_cleaned` statement, exporting was done directly from the new table stored in SSMS database. This ensures that only validated and standardized data is exported, while the original raw table remains untouched. 

---

##### Steps to Export from SSMS

1. Run the final cleaned SELECT query in SSMS.
2. After the results load, right-click anywhere inside the results grid.
3. Select **Save Results As...**
4. Choose either:
   - CSV (Comma delimited)
   - Excel (via .csv or .xlsx if plugins are available)
5. Save the file as:
   SQL_Cleaned_Coffee_shop_sales.csv
6. Open the exported file in Excel or import it into Power BI for visualization.

> Or I also use `Query -> Results To -> Results To File` and then save as CSV file

The exported spreadsheet represents the final cleaned dataset that was used for all reporting, visualization, and business insights.  
>input cleaned csv link here

>input visualisation Readme link here


---

