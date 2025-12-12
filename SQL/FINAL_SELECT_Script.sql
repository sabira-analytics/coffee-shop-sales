----------------------------------------------------------------------------------------------------------------
-- All in one Final SELECT STATEMENT with CTE and CASE WHEN 
----------------------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------------------   
-- Check that the table was created correctly
SELECT Top 10 *
FROM  dbo.Coffee_shop_sales_cleaned

----------------------------------------------------------------------------------------------------------------
-- Final Data Quality Verification
----------------------------------------------------------------------------------------------------------------
 
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

----------------------------------------------------------------------------------------------------------------
