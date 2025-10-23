use classicmodels;

describe orderdetails;

select priceEach, format(priceeach, 1) as OneDecmialPrice, format(priceEach, 0) as NoDecimalPrice, format(priceEach, 3) as ThreeDecimalPrice
from orderdetails;


-- Group By and Having
select * from orderdetails
limit 1;

/* Total Sales Per Order */
select orderNumber, sum(quantityOrdered * priceEach) as TotalSales
from orderdetails
group by orderNumber
order by orderNumber;

select * from orderdetails
where orderNumber = 10100;

# Total Sales and Quantity Ordered Per Product
select productCode, sum(quantityOrdered) as `Quantity Ordered`, sum(quantityOrdered * priceEach) as `Total Sales By Product`
from orderdetails
-- where quantityOrdered = 20
group by productCode
order by productCode;


select orderNumber, sum(quantityOrdered * priceEach) as `Total Sales`
from orderdetails
group by orderNumber
having `Total Sales` between 10000 and 20000
order by `Total Sales`;


/* Window Functions Practices */
# Create a new table and insert data into it
CREATE TABLE students2 (
    student_id INT PRIMARY KEY,
    name VARCHAR(50),
    class VARCHAR(10),
    age INT,
    score INT
);

INSERT INTO students2 (student_id, name, class, age, score) VALUES
(1, 'Alice', 'A', 17, 90),
(2, 'Bob', 'A', 16, 85),
(3, 'Carol', 'B', 17, 85),
(4, 'Dave', 'B', 16, 80),
(5, 'Eve', 'A', 17, 75),
(6, 'Frank', 'B', 16, 70),
(7, 'Grace', 'A', 15, 95),
(8, 'Hank', 'B', 15, 60),
(9, 'Ivy', 'A', 17, 82),
(10, 'Jack', 'B', 16, 78),
(11, 'Kate', 'A', 15, 88),
(12, 'Leo', 'A', 17, 75), 
(13, 'Mia', 'B', 17, 85); 


select student_id, name, class, age, score,
row_number() over(partition by class order by score desc) as `Row Number`
from students2
-- order by score desc;
limit 5;

select *, 
row_number() over (partition by class order by score) as `Row Number`
from students2;


select student_id, name, class, age, score,
coalesce((lag(score) over(partition by class order by score desc)), 'No Previous Value') as `Previous Value`, -- Returns the previous value for each row, then adds 'No Previous Value' for every Null Value
coalesce((lead(score) over(partition by class order by score desc)), 'No Next Value') as `No Next Value`, -- Returns the next value for each row, then adds 'No Next Value' for every Null Value
row_number() over (partition by class order by score desc) as `Row Number`, -- Returns the row number for each value per class
rank() over(partition by class order by score desc) as `Student Rank`, -- Returns the rank of scores without. It skips a position if there is a tie in the values
dense_rank() over(partition by class order by score desc) as `Ranked`, -- Returns the rank of scores without skipping any position
-- ntile(10) over(order by score desc) as `TILE`,
ntile(10) over(partition by class order by score desc rows between unbounded preceding and unbounded following) as `TILE`, -- Returns
first_value(score) over(partition by class order by score desc rows between unbounded preceding and unbounded following) as `Highest Ever Score`, -- Returns the highest score for each class 
last_value(score) over(partition by class order by score desc rows between unbounded preceding and unbounded following) as `Lowest Ever Score`, -- Returns the lowest score for each class
nth_value(score, 2) over(partition by class order by score desc rows between unbounded preceding and unbounded following) as `Second Value`, -- Returns the second score on the list
sum(score) over(partition by class order by score desc rows between unbounded preceding and unbounded following) as `Total Score Per Class` -- Returns the sum of all the scores for each class
from students2;


select *, 
row_number() over (partition by class order by score) as `Row Number`
from students2;


select class, sum(score) as `Total Score`
from students2
group by class;

use classicmodels;

select * from students2
limit 5;

--  Update a record
update students2 
set score = 92
where name = 'Alice';

update students2
set score = 86, 
	age = 18
where name = 'bob';

--  replace function to replace the values on a column
update students2
set name = replace(name, 'Bob', 'Bobs')
where name like '%Bob%';

-- replace multiple walues on a one column
update students2
set name = replace(replace(replace(name, 'Alice', 'Alices'), 'Carol', 'Carols'), 'Dave', 'Daves')
where name like '%Alice%' or name like '%Carol%' or name like '%Dave%';


describe customers;
describe employees;
describe offices;


select e.employeenumber, concat_ws(' ', e.firstname, e.lastname) as `fullname`, o.officecode as 'office code from office table', e.officecode as 'office code from employees table', jobtitle 
from employees e inner join offices o
using(officecode); -- Applying the USING keyword to join the tables instead of ON since the column names and datatypes are the same on the 2 tables

