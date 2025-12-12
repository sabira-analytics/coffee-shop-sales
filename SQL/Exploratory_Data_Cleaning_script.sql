-- view sample records
SELECT TOP 10 *
FROM dbo.Coffee_shop_sales;

----------------------------------------------------------------------------------------------------------------

-- Count total rows
SELECT COUNT(*)
FROM dbo.Coffee_shop_sales;

----------------------------------------------------------------------------------------------------------------

--Check column names and data types
sp_help 'dbo.Coffee_shop_sales';

----------------------------------------------------------------------------------------------------------------

-- Inspecting/Validating 'hour_of_day' 

-- Check Unique hour values
SELECT DISTINCT hour_of_day
FROM dbo.Coffee_shop_sales
ORDER BY hour_of_day DESC;

-- Check for NULL or invalid entries 
SELECT *
FROM dbo.Coffee_shop_sales
WHERE hour_of_day IS NULL
	OR hour_of_day NOT BETWEEN 0 AND 23;

----------------------------------------------------------------------------------------------------------------

-- Inspecting/Standardizing 'cash_type'

-- View unique payment types
SELECT DISTINCT cash_type
FROM dbo.Coffee_shop_sales;

-- Check for NULLS or incorrect spellings
SELECT *
FROM dbo.Coffee_shop_sales
WHERE cash_type IS NULL 
	OR cash_type NOT IN ('Cash', 'Card');

-- Standardize any format variations
SELECT cash_type,
	UPPER(LEFT(TRIM(cash_type),1))
             + LOWER(SUBSTRING(TRIM(cash_type),2,LEN(TRIM(cash_type))))
				AS Cleaned_Cash_type
FROM dbo.Coffee_shop_sales

----------------------------------------------------------------------------------------------------------------

-- INSPECTING 'money' 

-- Check value range and unique patterns
SELECT DISTINCT ROUND([money], 2) AS [Money]
FROM dbo.Coffee_shop_sales
ORDER BY [Money] 

-- Detect the exact rows containing negative or zero sales amounts
SELECT *
FROM dbo.Coffee_shop_sales
WHERE [money] < = 0;

-- Check for nulls
SELECT [money]
FROM dbo.Coffee_shop_sales
WHERE [money] IS NULL;

-- Look for unusually high outlier amounts
SELECT TOP (10)
    ROUND([money], 2) AS rounded_money
FROM dbo.Coffee_shop_sales
ORDER BY rounded_money DESC;

----------------------------------------------------------------------------------------------------------------

-- INSPECTING/VALIDATING coffee_name

-- View all unique coffee product name
SELECT DISTINCT coffee_name
FROM dbo.Coffee_shop_sales
ORDER BY coffee_name;

-- check for duplicated variations (example: 'Latte' vs 'Latte ') and counts per value
SELECT coffee_name, COUNT(*) AS Total
FROM dbo.Coffee_shop_sales
GROUP BY coffee_name
ORDER BY Total DESC;

-- Check for NULLS or empty values or whitespace
SELECT *
FROM dbo.Coffee_shop_sales
WHERE coffee_name IS NULL
	OR coffee_name = ''
	OR coffee_name LIKE ' %'
	OR coffee_name LIKE '% ';

-- Trim leading and trailing whitespaces and turn blanks into proper nulls
SELECT 
    coffee_name,
    NULLIF(TRIM(coffee_name), '') AS cleaned_coffee_name
FROM dbo.Coffee_shop_sales
WHERE NULLIF(TRIM(coffee_name), '') IS NULL

----------------------------------------------------------------------------------------------------------------

-- Inspecting/Validating Weekday

-- Validate weekday names
SELECT DISTINCT [Weekday], [Weekdaysort]
FROM dbo.Coffee_shop_sales
ORDER BY [Weekdaysort];

-- Isolate rows containing NULLS or invalid weekday names
SELECT *
FROM dbo.Coffee_shop_sales
WHERE [Weekday] IS NULL
	OR [Weekday] NOT IN ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');

-- Check for duplicates
SELECT [Weekday], COUNT(*) as Total_Number
FROM dbo.Coffee_shop_sales
GROUP BY [Weekday], Weekdaysort
ORDER BY [Weekdaysort]

----------------------------------------------------------------------------------------------------------------

-- Inspecting/Validating Month_name

-- Validate month names
SELECT DISTINCT Month_name, Monthsort
FROM dbo.Coffee_shop_sales
ORDER BY Monthsort;

-- Isolate rows containing NULLS or invalid month names
SELECT *
FROM dbo.Coffee_shop_sales
WHERE Month_name IS NULL
	OR Month_name NOT IN (
		'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
		'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

-- Check for duplicates
SELECT Month_name, COUNT(*) AS Total_Number
FROM dbo.Coffee_shop_sales
GROUP BY Month_name, Monthsort
ORDER BY Monthsort

----------------------------------------------------------------------------------------------------------------

-- Inspecting/Verifying 'Weeksort' and 'Monthsort'

-- Verify weekdaysort order is correct (1-7)
SELECT DISTINCT Weekdaysort
FROM dbo.Coffee_shop_sales
ORDER BY Weekdaysort;

-- Verify monthsort order is correct (1-12)
SELECT DISTINCT Monthsort
FROM dbo.Coffee_shop_sales
ORDER BY Monthsort;

-- Isolate rows containing NULLs or incorrect weekdaysort and monthsort values
SELECT *
FROM dbo.Coffee_shop_sales
WHERE Weekdaysort IS NULL
   OR Monthsort IS NULL
   OR Weekdaysort NOT BETWEEN 1 AND 7
   OR Monthsort NOT BETWEEN 1 AND 12;

----------------------------------------------------------------------------------------------------------------

-- Inspecting/Validating/Verifying Date column

-- Verify Date Values to confirm formatting
SELECT DISTINCT [Date]
FROM dbo.Coffee_shop_sales
ORDER BY [Date];

-- Identify NULLS, invalid or unconvertible date formats
SELECT *
FROM dbo.Coffee_shop_sales
WHERE try_convert(DATE, [Date]) IS NULL
	  OR [Date] IS NULL;

-- Confirming that Date is converted and read correctly with Style code 103 for UK dates
SELECT
    try_convert(DATE, [Date], 103) AS Cleaned_Date
FROM dbo.Coffee_shop_sales
WHERE try_convert(DATE, [Date], 103) IS NULL

-- Validate date range looks reasonable
SELECT 
	min(try_convert(DATE, [Date])) AS Earliest_Date,
	max(try_convert(DATE, [Date])) AS Latest_Date
FROM dbo.Coffee_shop_sales;

----------------------------------------------------------------------------------------------------------------
	
-- Inspecting Time (Unreliable Column)

-- View unique Time values to identify formatting issues
SELECT DISTINCT [Time]
FROM dbo.Coffee_shop_sales
ORDER BY [Time] DESC;

-- Detect missing or ambiguous AM/PM Time values
SELECT [Time]
FROM dbo.Coffee_shop_sales
WHERE Time LIKE '%AM'
    AND Time LIKE '%PM';

-- Attempt to convert and see valid and invalid results 
SELECT [Time]
FROM dbo.Coffee_shop_sales
WHERE try_convert(TIME, [Time]) IS NULL;

SELECT [Time]
FROM CoffeeSalesDB.dbo.Coffee_shop_sales
WHERE try_convert(TIME, [Time]) IS NOT NULL;

-- Find WHY conversion failed (pattern audit)
SELECT [Time]
FROM dbo.Coffee_shop_sales
WHERE [Time] LIKE '%:%:%:%'  -- 3+ colons 
   OR [Time] LIKE '%::%'     -- Double colons
   OR [Time] LIKE '%..%'     -- Unusual dots
   OR [Time] LIKE '%--%'     -- Double hyphens
   OR [Time] LIKE '% % %'    -- Multiple spaces
   OR [Time] LIKE '%:%.%'    -- Incorrect time format 
   OR [Time] IS NULL;		 -- Missing values
/* After inspecting the values, this column was identified as unreliable and 
unsafe for repair and excluded the cleaning workflow.


-- Reasoning for Checking for Duplicates
/* 
Same sale imported twice from Kaggle
CSV accidentally duplicated rows
Flat file import glitch
Rounding or formatting created false duplicates
App recorded the same sale twice
*/





SELECT *
FROM dbo.Coffee_shop_sales






















	



