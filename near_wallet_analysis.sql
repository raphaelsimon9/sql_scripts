-- drop schema if exists wallet_analysis; -- If this schema or database does not exist, this statement will throw an error
create schema if not exists wallet_analysis; -- creates a database called wallet_analysis.db if it does not already exist
use wallet_analysis; -- switches to this database so that querying can begin

-- alter table near_wallet  -- attempting to make the transaction hash the primary key but it is not a numerical field and throws an error
-- modify column `txn hash` int not null
-- primary key;

select count(*) from near_wallet; -- counts all the rows or records in the table

select * from near_wallet; -- shows all the records from the table

describe near_wallet; -- shows the data about the table. shows all the field names and their datatypes

select sum(`txn fee`) from near_wallet; -- sums all the transaction fees that has been deducted from the wallet

select max(time), min(time) from near_wallet; -- displays the beginning and end dates as at the last download

select distinct count(*) from near_wallet; 

select method, sum(`deposit value`) as `Deposit Value` -- selecting all the 
from near_wallet
where `Deposit Value` > 0
group by method;

show databases;

select schema_name
from information_schema.schemata
where schema_name like %e%;

show databases like wallet_analysis;

create database if not exists hr;

create table users(
	id int,
    username varchar(255),
    email varchar(255),
    brithdate date,
    isActive boolean
);

-- alter table users
-- update columnUPDATE `wallet_analysis`.`users`
-- SET
-- `brithdate` = <{brithdate}>
-- WHERE <{where_expression}>;


ALTER TABLE `wallet_analysis`.`users` 
CHANGE COLUMN `id` `id` INT NOT NULL ,
CHANGE COLUMN `brithdate` `birthdate` DATE NULL DEFAULT NULL ,
ADD PRIMARY KEY (`id`);

use wallet_analysis;

show tables;

describe users;

insert into users(id, username, email, birthdate, isActive)
values
(1, user1, user1@email.com, 1990-10-1, true),
(2, user2, user2@email.com, 1991-10-2, false),
(3, user3, user3@email.com, 1990-10-3, true);

select * from users;

-- All INT Data Types
create table RetailPlatform(
	UserId bigint,
    Age tinyint,
    ProductId smallint,
    ProductRating tinyint,
    WarehouseId mediumint,
    TransactionId int
);

alter table retailplatform
add primary key(userid);

show tables;

insert into RetailPlatform(UserId, age, productid, productrating, warehouseid, transactionid)
values
(10000000000, 25, 1000, 5, 200, 200000000),
(10000000001, 22, 1001, 5, 300, 200000001),
(10000000002, 24, 1003, 5, 204, 200000002),
(10000000003, 27, 1005, 5, 120, 200000003),
(10000000004, 21, 1006, 5, 320, 200000004),
(10000000005, 29, 1002, 5, 238, 200000005),
(10000000006, 34, 1008, 5, 291, 200000006);

show tables;

describe retailplatform;

select * from retailplatform;

-- Varchar and Boolean Data Types
create table books(
	id int auto_increment primary key,
    title varchar(225) not null,
    author varchar(225),
    isInStock boolean not null default 1, -- 1 for True, 0 for False
    isOnSale boolean not null default 0 -- 1 for True, 0 for False
);

INSERT INTO books (title, author, isInStock, isOnSale)
VALUES
('Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', 1, 0),
('To Kill a Mockingbird', 'Harper Lee', 1, 1),
('The Great Gatsby', 'F. Scott Fitzgerald', 0, 0),
('Moby Dick', 'Herman Melville', 1, 0),
('1984', 'George Orwell', 1, 1);

select * from books;

describe books;

-- Decimal Data Type
create table EmployeeFinance(
	EmployeeID INT NOT NULL PRIMARY KEY,
    Salary DECIMAL(8,2),
    Bonus DECIMAL(8,2)
);

describe employeefinance;

insert into employeefinance(employeeid, salary, bonus)
values
(20, 34200.32, 2003.32),
(21, 90342.32, 2213.54),
(22, 28003.32, 123.52),
(23, 55920.32, 2384.04),
(24, 40000.32, 980.18);

INSERT INTO EmployeeFinance (EmployeeID, Salary, Bonus)
VALUES
(1001, 5000.00, 200.50),
(1002, 6000.00, 300.75),
(1003, 7000.00, 400.25),
(1004, 8000.00, 500.50),
(1005, 9000.00, 600.75);

select * from employeefinance;

-- Float and Double Data Type
CREATE TABLE ResearchData (
    ExperimentID INT,
    MeasurementFloat FLOAT,
    MeasurementDouble DOUBLE
);

INSERT INTO ResearchData (ExperimentID, MeasurementFloat, MeasurementDouble)
VALUES
(101, 0.12345, 0.12345678901234),
(102, 12345.6789, 12345.67890123456789),
(103, 0.000012345, 0.00001234567890123456),
(104, 1234567890.1234, 1234567890.1234567890123456),
(105, -12345.6789, -12345.67890123456789);

describe researchdata;

select * from researchdata;

-- Bit Data Type
create table ServerStatus(
	ServerId INT,
    ModuleStatus BIT(8)
);

INSERT INTO ServerStatus (ServerID, ModuleStatus)
VALUES
(1, b'11111111'),
(2, b'11111110'),
(3, b'11001100'),
(4, b'10101010'),
(5, b'00000000');

select * from serverstatus;

CREATE TABLE Products (
    ProductCode CHAR(5),
    ProductName VARCHAR(100),
    Description VARCHAR(255)
);

INSERT INTO Products (ProductCode, ProductName, Description)
VALUES
('P001A', 'Apple', 'Fresh and juicy red apples'),
('P002B', 'Banana', 'Sweet and delicious yellow bananas'),
('P003C', 'Carrot', 'Crunchy and healthy carrots'),
('P004D', 'Dates', 'Sweet and nutritious dates'),
('P005E', 'Eggplant', 'Fresh and organic eggplants');

select * from products;

describe products;

-- Binary Data Type
CREATE TABLE UserProfiles (
    UserID VARCHAR(50),
    Username VARCHAR(50),
    PasswordHash BINARY(32)
);

INSERT INTO UserProfiles (UserID, Username, PasswordHash)
VALUES
('USR001', 'Alice', UNHEX('AABBCCDDEEFF00112233445566778899AABBCCDDEEFF0011')),
('USR002', 'Bob', UNHEX('BBCCDDEEFF00112233445566778899AABBCCDDEEFF001122')),
('USR003', 'Charlie', UNHEX('CCDDEEFF00112233445566778899AABBCCDDEEFF00113344')),
('USR004', 'Dave', UNHEX('DDEEFF00112233445566778899AABBCCDDEEFF0011445566')),
('USR005', 'Eve', UNHEX('EEFF00112233445566778899AABBCCDDEEFF001155667788'));

describe userprofiles;

select * from userprofiles;

-- MediumBLOB Data Type
CREATE TABLE DigitalAssets (
    AssetID INT,
    AssetName VARCHAR(255),
    AssetType VARCHAR(50),
    AssetData MEDIUMBLOB
);

-- Inserting binary data like this is generally not done in raw SQL, since binary data isn't easily represented as text.
-- Instead, you'd use a function or method in your programming language of choice to read the file data and insert it into the database.
-- For the sake of simplicity, we'll insert a simple string as binary data.

INSERT INTO DigitalAssets (AssetID, AssetName, AssetType, AssetData)
VALUES
(1, 'Sample Text Document', 'text', UNHEX('48656C6C6F20576F726C6421')),
(2, 'Sample Image', 'image', UNHEX('AABBCC')),
(3, 'Sample Video', 'video', UNHEX('112233')),
(4, 'Sample Audio', 'audio', UNHEX('445566')),
(5, 'Another Text Document', 'text', UNHEX('5468697320697320616E6F74686572207465787420646F63756D656E742E'));

select * from digitalassets;

-- MediumText Data Type
CREATE TABLE BlogPosts (
    PostID INT,
    Title VARCHAR(255),
    Content MEDIUMTEXT
);

INSERT INTO BlogPosts (PostID, Title, Content)
VALUES
(1, 'First Blog Post', 'This is the content of the first blog post. It is quite short.'),
(2, 'Second Blog Post', 'This is the content of the second blog post. It is a bit longer than the first one. It has a couple of paragraphs.'),
(3, 'Third Blog Post', 'This is the content of the third blog post. It is quite long, and goes into a lot of detail on a particular topic.'),
(4, 'Fourth Blog Post', 'This is the content of the fourth blog post. It is medium length, and covers a few different topics.'),
(5, 'Fifth Blog Post', 'This is the content of the fifth blog post. It is very long, and covers many different topics in great detail.');

select * from blogposts;

drop table if exists students;

use wallet_analysis;

-- Enum Data Type (Accepts single result like from a radio button)
create table students (
	id int auto_increment,
    Name varchar(100),
    grade enum('Freshman', 'Sophomore', 'Junior', 'Senior'),
    primary key (id)
);

show tables;

describe students;

INSERT INTO Students (Name, Grade)
VALUES
('John Doe', 'Freshman'),
('Jane Smith', 'Sophomore'),
('Alice Johnson', 'Junior'),
('Bob Williams', 'Senior'),
('Charlie Brown', 'Freshman');

select * from students
order by grade;

-- Set Data Type (Accepts multiple selections of results like from a checkbox.)
CREATE TABLE Bookshop (
    BookID INT AUTO_INCREMENT,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genres SET('Science Fiction', 'Adventure', 'Thriller', 'Romance', 'Fantasy', 'Mystery', 'Horror'),
    PRIMARY KEY(BookID)
);

describe bookshop;

INSERT INTO bookshop (Title, Author, Genres)
VALUES
('The Galactic Adventure', 'John Doe', 'Science Fiction,Adventure'),
('Romantic Spaceships', 'Jane Smith', 'Science Fiction,Romance'),
('Mysteries of the Universe', 'Robert Brown', 'Science Fiction,Mystery'),
('Thrills in Space', 'Emma White', 'Science Fiction,Thriller'),
('Fantasy of Stars', 'Emily Johnson', 'Science Fiction,Fantasy');

INSERT INTO bookshop (Title, Author, Genres)
VALUES
('The Galactic Adventure', 'John Doe', 'Science Fiction,Romance');

select * from bookshop;

CREATE TABLE Movies (
    MovieID INT AUTO_INCREMENT,
    MovieName VARCHAR(100),
    ShowDateTime DATETIME,
    ReleaseYear YEAR,
    LastUpdated TIMESTAMP,
    PRIMARY KEY(MovieID)
);

INSERT INTO Movies (MovieName, ShowDateTime, ReleaseYear)
VALUES
('The Great Movie', '2023-08-10 20:00:00', 2023),
('Another Great Movie', '2023-08-11 18:00:00', 2023),
('Old Classic', '2023-08-11 16:00:00', 1990),
('Interesting Documentary', '2023-08-12 15:00:00', 2022),
('Kids Movie', '2023-08-12 14:00:00', 2023);

select * from movies;

SELECT MONTH('2023-07-30');

-- Point Spatial Data Type
CREATE TABLE DeliveryLocations (
    ID INT AUTO_INCREMENT,
    CustomerName VARCHAR(100),
    Location POINT,
    PRIMARY KEY(ID)
);

INSERT INTO DeliveryLocations (CustomerName, Location)
VALUES
    ('John', ST_GeomFromText('POINT(1 1)')),
    ('Jane', ST_GeomFromText('POINT(2 3)')),
    ('Jack', ST_GeomFromText('POINT(3 2)')),
    ('Jim', ST_GeomFromText('POINT(4 4)')),
    ('Julia', ST_GeomFromText('POINT(5 5)'));

-- Linestring Spatial Data Type
CREATE TABLE DeliveryRoutes (
    ID INT AUTO_INCREMENT,
    RouteName VARCHAR(50),
    RoutePath LINESTRING,
    PRIMARY KEY(ID)
);

INSERT INTO DeliveryRoutes (RouteName, RoutePath)
VALUES
    ('Route1', ST_GeomFromText('LINESTRING(1 1,2 2,3 3)')),
    ('Route2', ST_GeomFromText('LINESTRING(2 2,3 3,4 4)')),
    ('Route3', ST_GeomFromText('LINESTRING(3 3,4 4,5 5)')),
    ('Route4', ST_GeomFromText('LINESTRING(4 4,5 5,6 6)')),
    ('Route5', ST_GeomFromText('LINESTRING(5 5,6 6,7 7)'));

-- Polygon Spatial Data Type
CREATE TABLE DeliveryZones (
    ID INT AUTO_INCREMENT,
    ZoneName VARCHAR(50),
    ZoneArea POLYGON,
    PRIMARY KEY(ID)
);

INSERT INTO DeliveryZones (ZoneName, ZoneArea)
VALUES
    ('Zone1', ST_GeomFromText('POLYGON((1 1,1 2,2 2,2 1,1 1))')),
    ('Zone2', ST_GeomFromText('POLYGON((2 2,2 3,3 3,3 2,2 2))')),
    ('Zone3', ST_GeomFromText('POLYGON((3 3,3 4,4 4,4 3,3 3))')),
    ('Zone4', ST_GeomFromText('POLYGON((4 4,4 5,5 5,5 4,4 4))')),
    ('Zone5', ST_GeomFromText('POLYGON((5 5,5 6,6 6,6 5,5 5))'));
    
    
select * from deliveryzones;
select * from deliveryroutes;
select * from deliverylocations;

-- JSON Data Type
CREATE TABLE Product (
    ProductID INT AUTO_INCREMENT,
    ProductName VARCHAR(100),
    Attributes JSON,
    PRIMARY KEY (ProductID)
);

INSERT INTO Product (ProductName, Attributes)
VALUES
    ('T-shirt', '{"color": "blue", "size": "M", "brand": "BrandA"}'),
    ('Coffee Mug', '{"color": "white", "brand": "BrandB", "volume": "300ml"}'),
    ('Book', '{"author": "AuthorName", "pages": 200, "publisher": "PublisherName"}'),
    ('Laptop', '{"brand": "BrandC", "ram": "16GB", "storage": "512GB SSD"}'),
    ('Smartphone', '{"brand": "BrandD", "ram": "8GB", "storage": "128GB", "color": "black"}');

select * from product;

CREATE TABLE TempProduct (
    ProductID INT AUTO_INCREMENT,
    ProductName VARCHAR(100),
    Attributes JSON,
    PRIMARY KEY (ProductID)
);

-- Inserting Data from another table
insert into TempProduct(productname, attributes)
select productname, attributes from product;

select * from tempproduct;

describe tempproduct;

-- Inserting data with the set clause
insert into product
set productname = 'House',
attributes = '{"color": "blue", "rooms": "5", "brand": "Bungalow"}';

select * from product;

select * from movies;

select * from movies
order by releaseyear desc
limit 2 offset 5;

select * from movies
order by releaseyear desc
limit 3 offset 2;


-- Random Number Function
SELECT RAND() AS RandomNumber;

SELECT RAND(9) AS RandomNumber; -- This will always produce the same sequence of numbers for that seed.

SELECT RAND(), RAND(), RAND();

SELECT RAND(42), RAND(), RAND();

SELECT * FROM students ORDER BY RAND()
LIMIT 1;


-- Concat Function
select concat('Hello', ' ', 'World') as Concatenate;

select concat('I ', 'Love ', 'SQL ', 'Query') as Concatenate;

