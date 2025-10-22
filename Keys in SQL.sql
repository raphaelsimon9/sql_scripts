/* This is a multi-line comment */

use wallet_analysis;

-- Creating the table with the primary key
CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    DOB DATE
);

-- Creating the table with the foreign key
CREATE TABLE Books2 (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    AuthorID INT,
    PublishedDate DATE,
    Genre VARCHAR(100),
    ISBN VARCHAR(13) UNIQUE NOT NULL,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

describe authors;
describe books2;
select * from books2;

-- Adds the unique constraint to a column
alter table books2
add unique(title);

alter table books2
drop column genre;

-- Adds a new column to a table
alter table books2
add column genre varchar(100);

-- Renames a column
alter table books2
rename column genre to Genre;

-- Rename a table
alter table wallet_analysis.product2 rename to products;

-- Drops the unique constraint from a column
alter table books2
drop index title;

-- shows all the unique constraints on a table
show indexes from books2;

describe books2;

create table price (
	id int primary key,
    sku_name varchar(50),
    price double
);

describe price;

-- set default value to a column
alter table price
alter column price
set default 0.00;


-- Drop DEFAULT from a column
alter table price
alter column price
drop default;