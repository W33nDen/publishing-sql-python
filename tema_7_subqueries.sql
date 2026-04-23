-- ================================================
-- Практична робота до теми 7. Вкладені запити. Повторне використання коду
-- NOT EXISTS, IN, HAVING, CTE (WITH), VIEW
-- База даних: publishing
-- ================================================

USE publishing;

-- ================================================
-- ЗАДАЧА 1: Автори, чиї книжки не замовляли (NOT EXISTS)
-- ================================================
SELECT a.AuthorID, a.Name
FROM authors a
WHERE NOT EXISTS (
    SELECT 1
    FROM author_book ab
    JOIN orderitem oi ON oi.BookID = ab.BookID
    WHERE ab.AuthorID = a.AuthorID
);

-- ================================================
-- ЗАДАЧА 2: Книжки з доходом вище середнього (вкладений запит)
-- ================================================
SELECT
    b.BookID,
    b.Title,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM books b
JOIN orderitem oi ON oi.BookID = b.BookID
GROUP BY b.BookID, b.Title
HAVING SUM(oi.Quantity * oi.UnitPrice) > (
    SELECT AVG(revenue)
    FROM (
        SELECT SUM(oi2.Quantity * oi2.UnitPrice) AS revenue
        FROM orderitem oi2
        GROUP BY oi2.BookID
    ) AS sub
)
ORDER BY TotalRevenue DESC;

-- ================================================
-- ЗАДАЧА 3: CTE - рейтинг книжок у межах жанру
-- ================================================
WITH BookRevenue AS (
    SELECT
        b.BookID,
        b.Title,
        b.Genre,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
    FROM books b
    JOIN orderitem oi ON oi.BookID = b.BookID
    GROUP BY b.BookID, b.Title, b.Genre
)
SELECT
    BookID,
    Title,
    Genre,
    TotalRevenue,
    RANK() OVER (PARTITION BY Genre ORDER BY TotalRevenue DESC) AS GenreRank
FROM BookRevenue
ORDER BY Genre, GenreRank;

-- ================================================
-- ЗАДАЧА 4: VIEW для підрахунку продажів
-- ================================================
CREATE OR REPLACE VIEW vw_book_sales AS
SELECT
    b.BookID,
    b.Title,
    b.Genre,
    SUM(oi.Quantity)              AS TotalQuantity,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM books b
JOIN orderitem oi ON oi.BookID = b.BookID
GROUP BY b.BookID, b.Title, b.Genre;

-- Використовуємо VIEW
SELECT * FROM vw_book_sales ORDER BY TotalRevenue DESC;
