

-- All in one Final SELECT with CTE and CASE WHEN 

WITH Source AS (
    SELECT
        NULLIF(TRIM(coffee_name), '')          AS Coffee_Name,
        NULLIF(TRIM(Time_of_Day), '')          AS Time_of_Day,
        NULLIF(TRIM([Weekday]), '')            AS [Weekday],
        NULLIF(TRIM(Month_name), '')           AS Month_Name,
        TRY_CONVERT(DATE, [Date], 103)         AS [Date],
        TRY_CONVERT(decimal(10,2), [money])    AS [Money],
        NULLIF(TRIM(cash_type), '')            AS cash_type_clean,
        hour_of_day                            AS Hour_Of_Day,
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
        WHEN cash_type_clean IS NULL THEN NULL
        ELSE UPPER(LEFT(cash_type_clean,1)) 
             + LOWER(SUBSTRING(cash_type_clean,2,LEN(cash_type_clean)))
    END AS CashType,

    Hour_Of_Day,
    Weekdaysort,
    Monthsort
FROM Source;

    
    


;WITH Source AS (
    SELECT
        Coffee_Name       = NULLIF(TRIM(coffee_name), ''),
        Time_of_Day       = NULLIF(TRIM(Time_of_Day), ''),
        [Weekday]         = NULLIF(TRIM([Weekday]), ''),
        Month_Name        = NULLIF(TRIM(Month_name), ''),
        [Date]            = TRY_CONVERT(DATE, [Date], 103),
        [Money]           = TRY_CONVERT(decimal(10,2), [money]),
        cash_type_clean   = NULLIF(TRIM(cash_type), ''),
        Hour_Of_Day       = hour_of_day,
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
        WHEN cash_type_clean IS NULL THEN NULL
        ELSE UPPER(LEFT(cash_type_clean,1)) 
             + LOWER(SUBSTRING(cash_type_clean,2,LEN(cash_type_clean)))
    END AS CashType,
    Hour_Of_Day,
    Weekdaysort,
    Monthsort
INTO dbo.Coffee_shop_sales_cleaned
FROM Source;

SELECT DISTINCT Weekdaysort
FROM dbo.Coffee_shop_sales
ORDER BY Weekdaysort
