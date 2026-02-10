/*

PROJE ADI: NovaStore E-Ticaret Veri Yönetim Sistemi
ÖÐRENCÝ: [Adýnýz Soyadýnýz]
KONU: SQL Veri Tabaný Tasarýmý, DML, DQL ve Veri Tabaný Nesneleri
TARÝH: 2026-02-04

*/


-- BÖLÜM 1: Veri Tabaný Tasarýmý (DDL)


-- 1. Veri tabaný oluþturma
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'NovaStoreDB')
BEGIN
    CREATE DATABASE NovaStoreDB;
END
GO

USE NovaStoreDB;
GO

-- 2. Kategoriler Tablosu 
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(50) NOT NULL
);

-- 3. Müþteriler Tablosu
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(50) NOT NULL,
    City VARCHAR(20),
    Email VARCHAR(100) UNIQUE -- E-posta benzersiz olmalý
);

-- 4. Ürünler Tablosu 
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2),
    Stock INT DEFAULT 0, -- Varsayýlan deðer 0
    CategoryID INT,
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- 5. Sipariþler Tablosu 
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    OrderDate DATETIME DEFAULT GETDATE(), -- Varsayýlan bugünün tarihi
    TotalAmount DECIMAL(10,2),
    CONSTRAINT FK_Order_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- 6. Sipariþ Detaylarý Tablosu 
CREATE TABLE OrderDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    ProductID INT,
    Quantity INT,
    CONSTRAINT FK_Detail_Order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_Detail_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


-- BÖLÜM 2: Veri Giriþi (DML)


-- Görev 1: 5 adet Kategori ekleme
INSERT INTO Categories (CategoryName) VALUES 
('Elektronik'), ('Giyim'), ('Kitap'), ('Kozmetik'), ('Ev ve Yaþam');

-- Görev 2: En az 10-12 Ürün ekleme
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES 
('Gaming Laptop', 35000, 8, 1), ('Bluetooth Kulaklýk', 2500, 25, 1), 
('Akýllý Saat', 5500, 15, 1), ('4K Monitör', 8000, 10, 1),
('Pamuklu Kapüþonlu', 750, 45, 2), ('Keten Gömlek', 600, 30, 2), 
('Deri Ceket', 2800, 12, 2), ('Spor Ayakkabý', 3200, 20, 2),
('SQL Öðreniyorum', 250, 50, 3), ('Dünya Tarihi', 180, 40, 3), 
('Psikoloji 101', 140, 60, 3), ('Distopya Romaný', 95, 100, 3),
('Gece Kremi', 450, 35, 4), ('Güneþ Kremi', 550, 80, 4), 
('Maskara', 300, 55, 4), ('El Yapýmý Sabun', 85, 120, 4),
('Hava Fritözü (Airfryer)', 4200, 7, 5), ('Ortopedik Yastýk', 850, 18, 5), 
('Dekoratif Lamba', 1100, 14, 5), ('Bitki Bakým Seti', 350, 22, 5);

-- Görev 3: 6 adet Müþteri kaydý
INSERT INTO Customers (FullName, City, Email) VALUES 
('Ahmet Yýlmaz', 'Ýstanbul', 'ahmet@mail.com'),
('Ayþe Demir', 'Ankara', 'ayse@mail.com'),
('Mehmet Kaya', 'Ýzmir', 'mehmet@mail.com'),
('Canan Öz', 'Bursa', 'canan@mail.com'),
('Ece Aydýn', 'Antalya', 'ece@mail.com'),
('Murat Yýldýz', 'Eskiþehir', 'murat@mail.com');

-- Görev 4: En az 8-10 Sipariþ ve Detaylarý
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES 
(1, '2026-01-05', 37500), (2, '2026-01-10', 2500), (3, '2026-01-15', 600),
(4, '2026-01-20', 4200), (5, '2026-01-25', 1100), (1, '2026-02-01', 5500),
(6, '2026-02-02', 180), (2, '2026-02-03', 1300), (3, '2026-02-03', 8000),
(4, '2026-02-04', 450), (5, '2026-02-04', 350), (1, '2026-02-04', 2800);

-- Sipariþlere ait ürün detaylarý
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES 
(1, 1, 1), (1, 2, 1), (2, 2, 1), (3, 6, 1), (4, 17, 1), (5, 19, 1), 
(6, 3, 1), (7, 10, 1), (8, 13, 2), (8, 15, 1), (9, 4, 1), (10, 13, 1), 
(11, 20, 1), (12, 7, 1);


-- BÖLÜM 3: Sorgulama ve Analiz (DQL)


-- 1. Stok miktarý 20'den az olan ürünleri azalan sýrada listele
SELECT ProductName, Stock 
FROM Products 
WHERE Stock < 20 
ORDER BY Stock DESC;

-- 2. Hangi müþteri, hangi tarihte sipariþ vermiþ?
SELECT C.FullName, C.City, O.OrderDate, O.TotalAmount 
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID;

-- 3. "Ahmet Yýlmaz" isimli müþterinin aldýðý ürünlerin detaylarý
SELECT C.FullName, P.ProductName, P.Price, Cat.CategoryName
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN OrderDetails OD ON O.OrderID = OD.OrderID
JOIN Products P ON OD.ProductID = P.ProductID
JOIN Categories Cat ON P.CategoryID = Cat.CategoryID
WHERE C.FullName = 'Ahmet Yýlmaz';

-- 4. Kategorideki toplam ürün sayýsý
SELECT C.CategoryName, COUNT(P.ProductID) AS ToplamUrunSayisi
FROM Categories C
LEFT JOIN Products P ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryName;

-- 5. Müþteri bazlý ciro analizi (En yüksekten en düþüðe)
SELECT C.FullName, SUM(O.TotalAmount) AS ToplamCiro
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.FullName
ORDER BY ToplamCiro DESC;

-- 6. Zaman Analizi (Sipariþlerin üzerinden kaç gün geçti?)
SELECT OrderID, OrderDate, GETDATE() AS Bugun, 
       DATEDIFF(DAY, OrderDate, GETDATE()) AS GecenGun
FROM Orders;


-- BÖLÜM 4: View  Veri Tabaný Nesneleri


-- 1. View (Görünüm) Oluþturma
GO
CREATE VIEW vw_SiparisOzet AS
SELECT C.FullName AS MusteriAdi, O.OrderDate, P.ProductName, OD.Quantity
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN OrderDetails OD ON O.OrderID = OD.OrderID
JOIN Products P ON OD.ProductID = P.ProductID;
GO



PRINT 'NovaStoreDB Baþarýyla Oluþturuldu ve Veriler Eklendi!';

BACKUP DATABASE NovaStoreDB TO DISK = 'C:\Yedek\NovaStoreDB.bak' WITH FORMAT,      MEDIANAME = 'NovaStore_Backup',   
NAME = 'Full Backup of NovaStoreDB';

-- Yedeklemenin baþarýlý olup olmadýðýný kontrol etmek için:
PRINT 'Yedekleme iþlemi C:\Yedek\ klasörüne baþarýyla tamamlandý.';