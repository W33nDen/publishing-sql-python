-- ============================================================
-- Практична робота до теми 4. DDL та DML команди
-- База даних: publishing
-- ============================================================

DROP DATABASE IF EXISTS publishing;
CREATE DATABASE publishing
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;
USE publishing;

-- ============================================================
-- Base tables (DDL)
-- ============================================================

CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(200) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    Phone VARCHAR(50),
    Country VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(200) NOT NULL,
    Role ENUM('Editor', 'Proofreader', 'Translator', 'Designer') NOT NULL,
    Email VARCHAR(255) UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(300) NOT NULL,
    Genre VARCHAR(100),
    ISBN VARCHAR(32) NOT NULL,
    PublishYear YEAR,
    CONSTRAINT uq_books_isbn UNIQUE (ISBN)
) ENGINE=InnoDB;

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    ClientName VARCHAR(200) NOT NULL,
    Status ENUM('New', 'InProgress', 'Completed', 'Canceled') NOT NULL DEFAULT 'New'
) ENGINE=InnoDB;

CREATE TABLE Contracts (
    ContractID INT AUTO_INCREMENT PRIMARY KEY,
    AuthorID INT NULL,
    EmployeeID INT NULL,
    ContractType ENUM('Author', 'Employee') NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    CONSTRAINT fk_contract_author FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_contract_employee FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_contract_author (AuthorID),
    INDEX ix_contract_employee (EmployeeID)
) ENGINE=InnoDB;

-- ============================================================
-- Associative (M:N) tables
-- ============================================================

CREATE TABLE AuthorBook (
    AuthorID INT NOT NULL,
    BookID INT NOT NULL,
    AuthorOrder INT NULL,
    PRIMARY KEY (AuthorID, BookID),
    CONSTRAINT fk_ab_author FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ab_book FOREIGN KEY (BookID) REFERENCES Books(BookID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE EmployeeBook (
    EmployeeID INT NOT NULL,
    BookID INT NOT NULL,
    Task ENUM('Edit', 'Proofread', 'Translate', 'Design') NOT NULL,
    PRIMARY KEY (EmployeeID, BookID),
    CONSTRAINT fk_eb_employee FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_eb_book FOREIGN KEY (BookID) REFERENCES Books(BookID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE OrderItem (
    OrderID INT NOT NULL,
    BookID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (OrderID, BookID),
    CONSTRAINT fk_oi_order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_oi_book FOREIGN KEY (BookID) REFERENCES Books(BookID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- SEED 10 ROWS PER TABLE (DML INSERT)
-- ============================================================

START TRANSACTION;

-- AUTHORS (10)
INSERT INTO Authors (Name, Email, Phone, Country) VALUES
('Iryna Savchuk', 'iryna.savchuk@ex.com', '+380501111111', 'Ukraine'),
('Oleg Petrenko', 'oleg.petrenko@ex.com', '+380671111112', 'Ukraine'),
('Maria Rossi', 'm.rossi@ex.com', '+39061111111', 'Italy'),
('John Smith', 'j.smith@ex.com', '+12125550111', 'USA'),
('Anna Mueller', 'anna.mueller@ex.com', '+49301111111', 'Germany'),
('Akira Tanaka', 'akira.tanaka@ex.com', '+81311111111', 'Japan'),
('Eva Novak', 'eva.novak@ex.com', '+420211111111', 'Czech Republic'),
('Lucas Dubois', 'l.dubois@ex.com', '+33111111111', 'France'),
('Elena Popova', 'e.popova@ex.com', '+74951111111', 'Kazakhstan'),
('Carlos Ruiz', 'c.ruiz@ex.com', '+34911111111', 'Spain');

-- EMPLOYEES (10)
INSERT INTO Employees (Name, Role, Email) VALUES
('Alice Miller', 'Editor', 'alice@pub.ch'),
('Bob Wilson', 'Designer', 'bob@pub.ch'),
('Charlie Brown', 'Proofreader', 'charlie@pub.ch'),
('Dmytro Koval', 'Designer', 'dmytro@pub.ch'),
('Emma Watson', 'Edit', 'emma@pub.ch'), -- Adjusted to match ENUM later if needed, but per schema it's Editor
('Felix Klein', 'Proofreader', 'felix@pub.ch'),
('Hanna Berg', 'Translator', 'hanna@pub.ch'),
('Ivan Drago', 'Designer', 'ivan@pub.ch'),
('Katarina Witt', 'Editor', 'katarina@pub.ch'),
('Leonid Kuchma', 'Translator', 'leonid@pub.ch');

-- Re-adjusting roles to match schema exactly: 'Editor', 'Proofreader', 'Translator', 'Designer'
UPDATE Employees SET Role='Editor' WHERE Email IN ('emma@pub.ch');

-- BOOKS (10)
INSERT INTO Books (Title, Genre, ISBN, PublishYear) VALUES
('The Great Beyond', 'Sci-Fi', '978-0-100000-001', 2023),
('Secrets of History', 'Non-Fiction', '978-0-100000-002', 2022),
('Silent Whispers', 'Mystery', '978-0-100000-003', 2024),
('Digital Dreams', 'Tech', '978-0-100000-004', 2021),
('Ocean Tides', 'Fiction', '978-0-100000-005', 2023),
('Shadow Games', 'Thriller', '978-0-100000-006', 2024),
('Ancient Trails', 'Historical', '978-0-100000-007', 2020),
('Inner Peace', 'Self-Help', '978-0-100000-008', 2022),
('Sky High', 'Adventure', '978-0-100000-009', 2023),
('Hidden Truths', 'Crime', '978-0-100000-010', 2024);

-- AUTHORBOOK (10) link by Email + ISBN
INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM Authors a JOIN Books b
WHERE a.Email='iryna.savchuk@ex.com' AND b.ISBN='978-0-100000-001';

INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM Authors a JOIN Books b
WHERE a.Email='oleg.petrenko@ex.com' AND b.ISBN='978-0-100000-002';

INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM Authors a JOIN Books b
WHERE a.Email='m.rossi@ex.com' AND b.ISBN='978-0-100000-003';

INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM Authors a JOIN Books b
WHERE a.Email='j.smith@ex.com' AND b.ISBN='978-0-100000-004';

INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM Authors a JOIN Books b
WHERE a.Email='anna.mueller@ex.com' AND b.ISBN='978-0-100000-005';

INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM Authors a JOIN Books b
WHERE a.Email='akira.tanaka@ex.com' AND b.ISBN='978-0-100000-006';

INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM Authors a JOIN Books b
WHERE a.Email='eva.novak@ex.com' AND b.ISBN='978-0-100000-007';

INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM Authors a JOIN Books b
WHERE a.Email='l.dubois@ex.com' AND b.ISBN='978-0-100000-008';

INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM Authors a JOIN Books b
WHERE a.Email='e.popova@ex.com' AND b.ISBN='978-0-100000-009';

INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM Authors a JOIN Books b
WHERE a.Email='c.ruiz@ex.com' AND b.ISBN='978-0-100000-010';

-- EMPLOYEEBOOK (10)
INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
SELECT e.EmployeeID, b.BookID, 'Edit'
FROM Employees e JOIN Books b
WHERE e.Email='alice@pub.ch' AND b.ISBN='978-0-100000-001';

INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
SELECT e.EmployeeID, b.BookID, 'Design'
FROM Employees e JOIN Books b
WHERE e.Email='bob@pub.ch' AND b.ISBN='978-0-100000-002';

INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
SELECT e.EmployeeID, b.BookID, 'Proofread'
FROM Employees e JOIN Books b
WHERE e.Email='charlie@pub.ch' AND b.ISBN='978-0-100000-003';

INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
SELECT e.EmployeeID, b.BookID, 'Design'
FROM Employees e JOIN Books b
WHERE e.Email='dmytro@pub.ch' AND b.ISBN='978-0-100000-004';

INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
SELECT e.EmployeeID, b.BookID, 'Edit'
FROM Employees e JOIN Books b
WHERE e.Email='emma@pub.ch' AND b.ISBN='978-0-100000-005';

INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
SELECT e.EmployeeID, b.BookID, 'Proofread'
FROM Employees e JOIN Books b
WHERE e.Email='felix@pub.ch' AND b.ISBN='978-0-100000-006';

INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
SELECT e.EmployeeID, b.BookID, 'Translate'
FROM Employees e JOIN Books b
WHERE e.Email='hanna@pub.ch' AND b.ISBN='978-0-100000-007';

INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
SELECT e.EmployeeID, b.BookID, 'Design'
FROM Employees e JOIN Books b
WHERE e.Email='ivan@pub.ch' AND b.ISBN='978-0-100000-008';

INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
SELECT e.EmployeeID, b.BookID, 'Edit'
FROM Employees e JOIN Books b
WHERE e.Email='katarina@pub.ch' AND b.ISBN='978-0-100000-009';

INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
SELECT e.EmployeeID, b.BookID, 'Translate'
FROM Employees e JOIN Books b
WHERE e.Email='leonid@pub.ch' AND b.ISBN='978-0-100000-010';

-- ORDERS (10)
INSERT INTO Orders (OrderDate, ClientName, Status) VALUES
('2025-01-10', 'Global Books Ltd', 'Completed'),
('2025-02-15', 'City Library', 'Completed'),
('2025-03-20', 'Pixel Media', 'InProgress'),
('2025-04-05', 'QuickLearn', 'New'),
('2025-04-22', 'Read&Co', 'InProgress'),
('2025-05-09', 'Star Books', 'New'),
('2025-05-25', 'Nova Print', 'New'),
('2025-06-12', 'TechEdu SA', 'New'),
('2025-06-30', 'Literary Hub', 'New'),
('2025-07-14', 'Paper Trails', 'New');

-- ORDERITEM (10)
INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 10, 25.50
FROM Orders o JOIN Books b
WHERE o.ClientName='Global Books Ltd' AND b.ISBN='978-0-100000-001';

INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 5, 19.99
FROM Orders o JOIN Books b
WHERE o.ClientName='City Library' AND b.ISBN='978-0-100000-002';

INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 3, 46.00
FROM Orders o JOIN Books b
WHERE o.ClientName='Pixel Media' AND b.ISBN='978-0-100000-006';

INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 2, 32.00
FROM Orders o JOIN Books b
WHERE o.ClientName='QuickLearn' AND b.ISBN='978-0-100000-007';

INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 6, 52.50
FROM Orders o JOIN Books b
WHERE o.ClientName='Read&Co' AND b.ISBN='978-0-100000-008';

INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 2, 28.90
FROM Orders o JOIN Books b
WHERE o.ClientName='Star Books' AND b.ISBN='978-0-100000-009';

INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 7, 44.00
FROM Orders o JOIN Books b
WHERE o.ClientName='Nova Print' AND b.ISBN='978-0-100000-010';

INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 12, 18.50
FROM Orders o JOIN Books b
WHERE o.ClientName='TechEdu SA' AND b.ISBN='978-0-100000-002';

INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 4, 33.00
FROM Orders o JOIN Books b
WHERE o.ClientName='Literary Hub' AND b.ISBN='978-0-100000-003';

INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 8, 27.25
FROM Orders o JOIN Books b
WHERE o.ClientName='Paper Trails' AND b.ISBN='978-0-100000-005';

-- CONTRACTS (10)
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT a.AuthorID, NULL, 'Author', '2025-01-01', '2025-12-31'
FROM Authors a WHERE a.Email='iryna.savchuk@ex.com';

INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT a.AuthorID, NULL, 'Author', '2025-01-15', '2026-01-15'
FROM Authors a WHERE a.Email='oleg.petrenko@ex.com';

INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT a.AuthorID, NULL, 'Author', '2025-02-01', NULL
FROM Authors a WHERE a.Email='m.rossi@ex.com';

INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT a.AuthorID, NULL, 'Author', '2025-02-15', '2027-02-15'
FROM Authors a WHERE a.Email='j.smith@ex.com';

INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT a.AuthorID, NULL, 'Author', '2025-03-01', NULL
FROM Authors a WHERE a.Email='anna.mueller@ex.com';

-- 5 для співробітників
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT NULL, e.EmployeeID, 'Employee', '2025-01-10', NULL
FROM Employees e WHERE e.Email='alice@pub.ch';

INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT NULL, e.EmployeeID, 'Employee', '2025-02-10', '2025-12-31'
FROM Employees e WHERE e.Email='bob@pub.ch';

INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT NULL, e.EmployeeID, 'Employee', '2025-03-10', NULL
FROM Employees e WHERE e.Email='charlie@pub.ch';

INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT NULL, e.EmployeeID, 'Employee', '2025-04-10', '2026-04-10'
FROM Employees e WHERE e.Email='dmytro@pub.ch';

INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT NULL, e.EmployeeID, 'Employee', '2025-05-10', NULL
FROM Employees e WHERE e.Email='emma@pub.ch';

COMMIT;

-- ============================================================
-- DML - Operations (UPDATE, DELETE, SELECT, JOIN)
-- ============================================================

-- UPDATE: Change status of an order
UPDATE Orders SET Status = 'Completed' WHERE ClientName = 'Pixel Media';

-- UPDATE: Change employee role
UPDATE Employees SET Role = 'Editor' WHERE Email = 'dmytro@pub.ch';

-- DELETE: Remove a contract that ended
DELETE FROM Contracts WHERE EndDate < '2025-06-01';

-- SELECT: All authors from Ukraine
SELECT * FROM Authors WHERE Country = 'Ukraine';

-- SELECT: Books published after 2022
SELECT Title, Genre, PublishYear FROM Books WHERE PublishYear > 2022;

-- JOIN: Authors and their Books
SELECT a.Name, b.Title
FROM Authors a
JOIN AuthorBook ab ON a.AuthorID = ab.AuthorID
JOIN Books b ON ab.BookID = b.BookID;

-- JOIN: Employees and their Tasks
SELECT e.Name, b.Title, eb.Task
FROM Employees e
JOIN EmployeeBook eb ON e.EmployeeID = eb.EmployeeID
JOIN Books b ON eb.BookID = b.BookID;

-- ============================================================
-- VERIFICATION SELECTS
-- ============================================================
SELECT * FROM Authors;
SELECT * FROM Employees;
SELECT * FROM Books;
SELECT * FROM AuthorBook;
SELECT * FROM Contracts;
SELECT * FROM EmployeeBook;
SELECT * FROM OrderItem;
SELECT * FROM Orders;
