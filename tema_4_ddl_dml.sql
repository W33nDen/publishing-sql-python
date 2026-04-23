-- ============================================================
-- Практична робота до теми 4. DDL та DML команди
-- База даних: publishing
-- ============================================================

-- ============================================================
-- ЧАСТИНА 1: DDL - Створення структури бази даних
-- ============================================================

CREATE DATABASE IF NOT EXISTS publishing;
USE publishing;

-- Таблиця авторів
CREATE TABLE IF NOT EXISTS Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Country VARCHAR(50),
    Phone VARCHAR(20),
    Email VARCHAR(100)
);

-- Таблиця книг
CREATE TABLE IF NOT EXISTS Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    Genre VARCHAR(50),
    ISBN VARCHAR(20) UNIQUE,
    YearPublished INT
);

-- Зв'язкова таблиця Автор-Книга (багато до багатьох)
CREATE TABLE IF NOT EXISTS author_book (
    AuthorID INT NOT NULL,
    BookID INT NOT NULL,
    PRIMARY KEY (AuthorID, BookID),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON DELETE CASCADE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE
);

-- Таблиця співробітників
CREATE TABLE IF NOT EXISTS Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Position VARCHAR(50),
    Phone VARCHAR(20),
    Salary DECIMAL(10,2)
);

-- Зв'язкова таблиця Співробітник-Книга
CREATE TABLE IF NOT EXISTS EmployeeBook (
    EmployeeID INT NOT NULL,
    BookID INT NOT NULL,
    Role VARCHAR(50),
    PRIMARY KEY (EmployeeID, BookID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON DELETE CASCADE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE
);

-- Таблиця контрактів
CREATE TABLE IF NOT EXISTS Contracts (
    ContractID INT AUTO_INCREMENT PRIMARY KEY,
    AuthorID INT,
    EmployeeID INT,
    ContractType VARCHAR(20) CHECK (ContractType IN ('Author', 'Employee')),
    StartDate DATE NOT NULL,
    EndDate DATE,
    RoyaltyRate DECIMAL(5,2),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON DELETE SET NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON DELETE SET NULL
);

-- Таблиця замовлень
CREATE TABLE IF NOT EXISTS Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2),
    ShippingAddress VARCHAR(200),
    Status VARCHAR(20) DEFAULT 'Pending'
);

-- Таблиця позицій замовлення
CREATE TABLE IF NOT EXISTS OrderItem (
    OrderID INT NOT NULL,
    BookID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (OrderID, BookID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE
);

-- ============================================================
-- ЧАСТИНА 2: DML - Наповнення таблиць тестовими даними
-- ============================================================

-- Вставка авторів
INSERT INTO Authors (Name, Country, Phone, Email) VALUES
('Іван Франко', 'Україна', '+380501234567', 'franko@ua.com'),
('Леся Українка', 'Україна', '+380672345678', 'lesya@ua.com'),
('Ernest Hemingway', 'USA', '+12125551234', 'hem@usa.com'),
('George Orwell', 'UK', '+442071234567', 'orwell@uk.com'),
('Ліна Костенко', 'Україна', '+380933456789', 'kostenko@ua.com');

-- Вставка книг
INSERT INTO Books (Title, Genre, ISBN, YearPublished) VALUES
('Захар Беркут', 'Навчальна', '978-966-01-0001-1', 1883),
('Лісова пісня', 'Навчальна', '978-966-01-0002-2', 1911),
('The Old Man and the Sea', 'Fiction', '978-0-684-80122-3', 1952),
('Animal Farm', 'Sci-Fi', '978-0-452-28424-1', 1945),
('Маруся Чурай', 'Навчальна', '978-966-01-0003-3', 1979),
('1984', 'Sci-Fi', '978-0-451-52493-5', 1949);

-- Зв'язок Автор-Книга
INSERT INTO author_book (AuthorID, BookID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(4, 6);

-- Вставка співробітників
INSERT INTO Employees (Name, Position, Phone, Salary) VALUES
('Олексій Петренко', 'Редактор', '+380441234567', 35000.00),
('Марія Коваль', 'Менеджер', '+380442345678', 42000.00),
('Дмитро Шевченко', 'Коректор', '+380443456789', 28000.00),
('Анна Бондаренко', 'Маркетолог', '+380444567890', 38000.00),
('Сергій Мельник', 'Перекладач', '+380445678901', 31000.00);

-- Зв'язок Співробітник-Книга
INSERT INTO EmployeeBook (EmployeeID, BookID, Role) VALUES
(1, 1, 'Редактор'),
(2, 2, 'Менеджер'),
(3, 3, 'Коректор'),
(1, 4, 'Редактор'),
(4, 5, 'Маркетолог'),
(5, 6, 'Перекладач');

-- Вставка контрактів
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate, RoyaltyRate) VALUES
(1, NULL, 'Author', '2020-01-15', '2025-01-15', 12.50),
(2, NULL, 'Author', '2019-06-01', '2024-06-01', 10.00),
(3, NULL, 'Author', '2021-03-10', '2026-03-10', 15.00),
(NULL, 1, 'Employee', '2018-09-01', NULL, NULL),
(NULL, 2, 'Employee', '2017-04-15', NULL, NULL);

-- Вставка замовлень
INSERT INTO Orders (CustomerName, OrderDate, TotalAmount, ShippingAddress, Status) VALUES
('Тарас Іваненко', '2024-01-10', 450.00, 'Київ, вул. Хрещатик 1', 'Delivered'),
('Олена Сидоренко', '2024-02-15', 320.00, 'Львів, пр. Свободи 5', 'Delivered'),
('Микола Грищенко', '2024-03-20', 780.00, 'Харків, вул. Сумська 10', 'Processing'),
('Ірина Ткаченко', '2024-04-05', 215.00, 'Одеса, вул. Дерибасівська 3', 'Pending'),
('Василь Кравченко', '2024-05-12', 560.00, 'Дніпро, пр. Гагаріна 15', 'Delivered');

-- Вставка позицій замовлення
INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice) VALUES
(1, 1, 2, 150.00),
(1, 2, 1, 150.00),
(2, 3, 2, 160.00),
(3, 4, 3, 140.00),
(3, 5, 3, 120.00),
(4, 6, 1, 215.00),
(5, 1, 2, 150.00),
(5, 3, 1, 160.00),
(5, 6, 1, 90.00);

-- ============================================================
-- ЧАСТИНА 3: DML - Операції UPDATE, DELETE, SELECT
-- ============================================================

-- UPDATE: Оновлення даних
-- Оновити зарплату редактора
UPDATE Employees
SET Salary = 40000.00
WHERE Position = 'Редактор';

-- Оновити статус замовлення
UPDATE Orders
SET Status = 'Delivered'
WHERE OrderID = 3;

-- Оновити рік видання книги
UPDATE Books
SET YearPublished = 1952
WHERE Title = 'The Old Man and the Sea';

-- DELETE: Видалення даних
-- Видалити замовлення зі статусом 'Pending' (старіші за 6 місяців)
DELETE FROM Orders
WHERE Status = 'Pending' AND OrderDate < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

-- SELECT: Вибірка даних
-- Вибрати всіх авторів з України
SELECT * FROM Authors WHERE Country = 'Україна';

-- Вибрати книги з роком видання після 1950
SELECT Title, Genre, YearPublished
FROM Books
WHERE YearPublished > 1950
ORDER BY YearPublished DESC;

-- Кількість книг за жанром
SELECT Genre, COUNT(*) AS BookCount
FROM Books
GROUP BY Genre
ORDER BY BookCount DESC;

-- ============================================================
-- ЧАСТИНА 4: JOIN запити
-- ============================================================

-- Список авторів та їх книг
SELECT a.Name AS Author, b.Title AS Book, b.Genre, b.YearPublished
FROM Authors a
JOIN author_book ab ON a.AuthorID = ab.AuthorID
JOIN Books b ON ab.BookID = b.BookID
ORDER BY a.Name;

-- Співробітники та книги, над якими вони працювали
SELECT e.Name AS Employee, e.Position, b.Title AS Book, eb.Role
FROM Employees e
JOIN EmployeeBook eb ON e.EmployeeID = eb.EmployeeID
JOIN Books b ON eb.BookID = b.BookID
ORDER BY e.Name;

-- Замовлення з деталями книг
SELECT o.CustomerName, o.OrderDate, b.Title, oi.Quantity, oi.UnitPrice,
       (oi.Quantity * oi.UnitPrice) AS LineTotal
FROM Orders o
JOIN OrderItem oi ON o.OrderID = oi.OrderID
JOIN Books b ON oi.BookID = b.BookID
ORDER BY o.OrderDate;

-- Контракти з іменами авторів та співробітників
SELECT c.ContractID, c.ContractType,
       a.Name AS AuthorName,
       e.Name AS EmployeeName,
       c.StartDate, c.EndDate, c.RoyaltyRate
FROM Contracts c
LEFT JOIN Authors a ON c.AuthorID = a.AuthorID
LEFT JOIN Employees e ON c.EmployeeID = e.EmployeeID;

-- Загальна сума замовлень по кожному клієнту
SELECT o.CustomerName,
       COUNT(DISTINCT o.OrderID) AS OrderCount,
       SUM(oi.Quantity * oi.UnitPrice) AS TotalSpent
FROM Orders o
JOIN OrderItem oi ON o.OrderID = oi.OrderID
GROUP BY o.CustomerName
ORDER BY TotalSpent DESC;

-- ============================================================
-- ЧАСТИНА 5: DDL - ALTER TABLE (зміна структури)
-- ============================================================

-- Додати поле до таблиці Books
ALTER TABLE Books ADD COLUMN Price DECIMAL(10,2) DEFAULT 0.00;

-- Додати поле до таблиці Authors
ALTER TABLE Authors ADD COLUMN BirthYear INT;

-- Змінити тип поля
ALTER TABLE Employees MODIFY COLUMN Phone VARCHAR(30);

-- Перейменувати колонку (MySQL 8+)
ALTER TABLE Orders RENAME COLUMN TotalAmount TO OrderTotal;
-- DROP TABLE IF EXISTS temp_table; -- закоментовано для безпеки
