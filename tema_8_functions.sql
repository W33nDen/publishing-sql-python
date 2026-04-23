-- ================================================
-- Практична робота до теми 8. Додаткові вбудовані SQL функції
-- Текстові, числові, часові, логічні функції
-- База даних: publishing
-- ================================================

USE publishing;

-- ================================================
-- ЗАДАЧА 1: Текстові функції
-- ================================================
SELECT UPPER(Name) AS AuthorNameUpper FROM authors;

SELECT CONCAT(Name, ' — ', Position) AS Signature FROM employees;

SELECT Name, Department, Position
FROM employees
WHERE Department LIKE '%Edit%';

SELECT Title, LENGTH(Title) AS TitleLength FROM books;

-- ================================================
-- ЗАДАЧА 2: Числові та агрегатні функції
-- ================================================
SELECT
    ROUND(AVG(UnitPrice), 2) AS AvgPrice,
    MIN(UnitPrice)            AS MinPrice,
    MAX(UnitPrice)            AS MaxPrice
FROM orderitem;

SELECT COUNT(*) AS TotalOrders FROM orders;

SELECT
    b.Title,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM books b
JOIN orderitem oi ON oi.BookID = b.BookID
GROUP BY b.Title
ORDER BY TotalRevenue DESC;

-- ================================================
-- ЗАДАЧА 3: Часові функції
-- ================================================
SELECT CURDATE() AS Today;

SELECT
    OrderID,
    OrderDate,
    YEAR(OrderDate)  AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    DAY(OrderDate)   AS OrderDay
FROM orders;

SELECT
    OrderID,
    OrderDate,
    DATEDIFF(CURDATE(), OrderDate) AS DaysSinceOrder
FROM orders;

SELECT
    Name,
    HireDate,
    DATEDIFF(CURDATE(), HireDate) DIV 365 AS YearsWorked
FROM employees;

-- ================================================
-- ЗАДАЧА 4: Логічні функції (IF, CASE, COALESCE)
-- ================================================
SELECT
    b.Title,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue,
    IF(SUM(oi.Quantity * oi.UnitPrice) > 500, 'Популярна', 'Звичайна') AS Category
FROM books b
JOIN orderitem oi ON oi.BookID = b.BookID
GROUP BY b.Title;

SELECT
    b.Title,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue,
    CASE
        WHEN SUM(oi.Quantity * oi.UnitPrice) > 1000 THEN 'Високий'
        WHEN SUM(oi.Quantity * oi.UnitPrice) > 500  THEN 'Середній'
        ELSE 'Низький'
    END AS RevenueLevel
FROM books b
JOIN orderitem oi ON oi.BookID = b.BookID
GROUP BY b.Title;

SELECT
    Name,
    Salary,
    COALESCE(CAST(Salary AS CHAR), 'не вказано') AS SalaryInfo,
    CASE
        WHEN Salary >= 3000 THEN 'Висока'
        WHEN Salary >= 1500 THEN 'Середня'
        ELSE 'Низька'
    END AS SalaryLevel
FROM employees;

-- ================================================
-- ЗАДАЧА 5: Службові функції (IFNULL, COALESCE, NULLIF)
-- ================================================
SELECT
    Name,
    IFNULL(Biography, '— немає біографії —') AS BiographyDisplay
FROM authors;

SELECT
    Name,
    COALESCE(Country, 'невідома країна') AS CountryDisplay
FROM authors;

SELECT
    Name,
    Email,
    IF(Email LIKE '%@%', 'Valid email', 'Invalid email') AS CheckEmail
FROM authors;

SELECT
    Name,
    NULLIF(Country, '') AS CountryClean
FROM authors;
