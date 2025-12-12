INSERT INTO `Employees` (`EmployeeID`, `LastName`, `FirstName`, `Title`, `TitleOfCourtesy`, `BirthDate`, `HireDate`, `Address`, `City`, `Region`, `PostalCode`, `Country`, `HomePhone`, `Extension`, `Notes`, `ReportsTo`, `PhotoPath`, `Salary`) VALUES
(12, 'Leroy', 'Schmuck', 'Sales Manager', 'Mrs.', '1967-02-23 02:50:10', '1995-01-25 00:00:00', '23 Houndstooth Ln.', 'Manchester', NULL, 'WG2 7LT', 'UK', '(71) 555-4424', '453', 'Frau has an Msc degree in Engineering from St. Lawrence College.She is fluent in French and German.', 5, 'http://accweb/emmployees/davolio.bmp', 2333.33);

use sales;
show tables;
select * from employees;

-- A query to show the employees with the same salary
SELECT 
	e1.employeeID, concat_ws(' ', e1.firstName, e1.lastName) AS 'Employee Full Name', e1.salary,
    e2.employeeID, concat_ws(' ', e2.firstName, e2.lastName) AS 'Employee Full Name', e2.salary
FROM employees e1, employees e2
WHERE e1.salary = e2.salary
AND e1.employeeID > e2.employeeID
ORDER BY e1.employeeID;

-- Alternative solution to "A query to show the employees with the same salary"
SELECT	e1.employeeID, concat_ws(' ', e1.firstName, e1.lastName) FullName, e1.salary,
		e2.employeeID, concat_ws(' ', e2.firstName, e2.lastName) FullName, e2.salary
FROM employees e1
INNER JOIN employees e2
ON e1.salary = e2.salary
WHERE e1.employeeID > e2.employeeID
ORDER BY e1.employeeID;

-- A query to show the employees with the greater salary
SELECT	e1.employeeID, concat_ws(' ', e1.firstName, e1.lastName) FullName, e1.salary,
		e2.employeeID, concat_ws(' ', e2.firstName, e2.lastName) FullName, e2.salary
FROM employees e1
INNER JOIN employees e2
ON e1.salary > e2.salary
ORDER BY e1.employeeID;

-- Employees and their reporting managers
SELECT	e1.employeeID, concat_ws(' ', e1.firstname, e1.lastname) `Employee Name`,
		COALESCE(e1.ReportsTo, 'No Reporting Manager') `Manager ID`,
        (IF(concat_ws(' ', e2.firstname, e2.lastname) = '' 
			OR concat_ws(' ', e2.firstname, e2.lastname) IS NULL, 'No Reporting Manager',
				concat_ws(' ', e2.firstname, e2.lastname))
		) `Manager Name`
FROM	employees e1
LEFT JOIN	employees e2
ON		e1.ReportsTo = e2.employeeID;


-- Customers that have not placed any orders using the SubQuery Method
describe customers;

select customerID, companyName
from customers
where customerID not in
	(select customerID from orders);

-- Customers that have not placed any orders using the JOIN Method
select c.customerID, c.companyName
from customers c
left join orders o
using(customerID)
where o.customerID is null;

select * from orders limit 3;

-- Show delays in order deliveries
SELECT
  orderid,
  companyName,
  country,
  orderdate,
  requireddate,
  shippeddate,
  DATEDIFF(shippeddate,orderdate) Orderdate_to_ShippedDate,
  DATEDIFF(shippeddate,requireddate) RequiredDate_to_ShippedDate
FROM
  orders
INNER JOIN customers
ON customers.customerid = orders.customerid 
WHERE
  requireddate <= shippeddate
ORDER BY RequiredDate_to_ShippedDate DESC;


-- Quantity of each product purchased per customer in 1996
SELECT
    c.companyName,
    p.productName,
    sum(od.quantity) as TotalQuantityOfProduct
  FROM orders o
  INNER JOIN orderdetails od
  ON o.orderid = od.orderid
  INNER JOIN products p
  ON p.productid = od.productid
  INNER JOIN customers c
  ON c.customerid = o.customerid
  WHERE
    EXTRACT(YEAR FROM o.orderdate) = 1996
  GROUP BY
    c.companyName, p.productName
  ORDER BY c.companyName;
  
  -- Quantity of each product purchased per customer in 1996 using date_format() to get the year
  SELECT
    c.companyName,
    p.productName,
    sum(od.quantity) as TotalQuantityOfProduct
  FROM orders o
  INNER JOIN orderdetails od
  ON o.orderid = od.orderid
  INNER JOIN products p
  ON p.productid = od.productid
  INNER JOIN customers c
  ON c.customerid = o.customerid
  WHERE
    date_format(o.orderdate, '%Y') = 1996
  GROUP BY
    c.companyName, p.productName
  ORDER BY c.companyName;
  
  -- select date_format(orderdate, '%Y') from orders;
  
  
  /* Get the names of customers who placed orders in 1996 along with their total orders. Include the following comments;
	Below $1000, 'Very Low Order'
    Between $1000 and $1500, 'Low Order'
    Between $5001 and $10000, 'Medium Order'
    Between $10001 and $15000, 'High Order'
    Above $15000, 'Very High Order'
  */
  describe orderdetails;
  describe products;
  
  WITH 1996Orders AS (
  SELECT
	c.customerid,
    c.companyName,
    sum(od.unitprice * od.quantity) as TotalOrder
  FROM orders o
  INNER JOIN orderdetails od
  ON o.orderid = od.orderid
  INNER JOIN customers c
  ON c.customerid = o.customerid
  WHERE
    EXTRACT(YEAR FROM o.orderdate) = 1996
  GROUP BY
    c.customerid, c.companyName
)
SELECT
	c.companyName,
	concat('$',round(kk.TotalOrder, 2)) "Total Order Placed",
  CASE
    WHEN kk.TotalOrder < 1000 THEN 'Very Low Order'
    WHEN kk.TotalOrder BETWEEN 1000 AND 5000 THEN 'Low Order'
    WHEN kk.TotalOrder BETWEEN 5001 AND 10000 THEN 'Medium Order'
    WHEN kk.TotalOrder BETWEEN 10001 AND 15000 THEN 'High Order'
    ELSE 'Very High Order'
  END Comment
FROM
  customers c
INNER JOIN
  1996Orders kk
ON c.customerid = kk.customerid
ORDER BY round(kk.TotalOrder, 2) DESC;
  
/*
  SELECT
	c.customerid,
    c.companyName,
    sum(od.unitprice * od.quantity) as TotalOrder
  FROM orders o
  INNER JOIN orderdetails od
  ON o.orderid = od.orderid
  INNER JOIN customers c
  ON c.customerid = o.customerid
  WHERE
    EXTRACT(YEAR FROM o.orderdate) = 1996
  GROUP BY
    c.customerid, c.companyName;
*/


/* Employees with the percentage of late orders more than 5% of their total orders */
with
	totalOrdersByEmployee as (
		select employeeID, count(distinct(orderID)) `Number of Orders`
		from orders
		group by employeeID
	),
	totalNumberofLateOrdersByEmployee as (
		select employeeID, count(distinct(orderID)) `Number of Late Orders`
		from orders
		where RequiredDate <= ShippedDate
		group by employeeID
	)
select 
	concat_ws(' ', firstName, lastName) Employee,
	toe.`Number of Orders` 'Number of Orders Taken',
    tlo.`Number of Late Orders` 'Number of Late Orders',
    concat(format(((tlo.`Number of Late Orders`/toe.`Number of Orders`)*100),2), '%') as `Percentage of Late Orders`
from employees e
inner join totalOrdersByEmployee toe
on e.EmployeeID = toe.employeeID
inner join totalNumberofLateOrdersByEmployee tlo
on toe.EmployeeID = tlo.EmployeeID
where ((tlo.`Number of Late Orders`/toe.`Number of Orders`)*100) > 5
order by ((tlo.`Number of Late Orders`/toe.`Number of Orders`)*100) desc
; 

/*
select employeeID, count(distinct(orderID)) `Number of Orders`
		from orders
		where RequiredDate <= ShippedDate
		group by employeeID;
*/

describe employees;
-- Get the name of employees that were employeed in the same period: same month and weekday
select 
	concat_ws(' ', concat_ws(' ',e1.firstName, e1.lastName), 'and', concat_ws(' ',e2.firstName, e2.lastName), 'were employed on the same month and week') 'Employees',
    date_format(e1.hireDate, '%W %M') Month,
    date_format(e1.hireDate, '%W %M') as 'Weekday',
    extract(year from e1.hireDate) Year
from employees e1, employees e2
where date_format(e1.hireDate, '%W%M') = date_format(e2.hireDate, '%W%M')
and e1.EmployeeID != e2.EmployeeID;


-- Alternative solutions to "Get the name of employees that were employeed in the same period: same month and weekday" using Group_Concat
select
	monthname(e1.HireDate) `Hire Month`,
    dayname(e1.HireDate) `Hire Day`,
	concat_ws(' ', group_concat(concat_ws(' ', e1.FirstName, e1.lastName) order by e1.EmployeeID separator ', '), 'were hired on the same weekday and month') as Employees
from employees e1
group by `Hire Month`, `Hire Day`
having count(*) > 1;

-- Another one
select 
	`Hire Month`,
    `Hire Day`,
    case
		when name_count = 2 then concat(replace(names, ',', ' and'), ' were employed on the same month and week.')
	else
		concat(reverse(replace(reverse(names), ',', 'dna ')), ' were hired on the same weekday and month')
	end as Employees
from (
select
	monthname(e1.HireDate) `Hire Month`,
    dayname(e1.HireDate) `Hire Day`,
	group_concat(concat_ws(' ', e1.FirstName, e1.lastName) order by e1.EmployeeID separator ', ') as names,
    count(*) as name_count
from employees e1
group by `Hire Month`, `Hire Day`
having count(*) > 1
) as sub_query;



select * from employees;

-- ---- 3/12/2025 -------
-- QUESTION: Find products that were never ordered
USE sales;
SHOW TABLES;
DESCRIBE products;
DESCRIBE orderdetails;

-- First select all the products in the products table
SELECT	productID	FROM	products LIMIT 10;

-- Next select all the products in the orderdetails table that are not found (NOT IN) in the products table
SELECT	o.productID, p.ProductName
FROM	orderdetails o LEFT JOIN products p
ON		o.productID = p.productID
WHERE	o.productID IN (SELECT	productID	FROM	products)
GROUP BY o.productID											-- Using Group By instead of the distinct keyword
ORDER BY	o.productID;

-- Check all columns that have a particular column_name in a particular schema
SELECT	TABLE_NAME
FROM	INFORMATION_SCHEMA.COLUMNS
WHERE	COLUMN_NAME = 'email'
AND		TABLE_SCHEMA = 'analytics_db';

SELECT	TABLE_NAME
FROM	INFORMATION_SCHEMA.COLUMNS
WHERE	COLUMN_NAME LIKE 'department'
AND		TABLE_SCHEMA = 'analytics_db';

-- QUESTION: Extract the domain name from the emails
USE analytics_db;
SELECT
		SUBSTR(email, INSTR(email, '@') + 1) AS Domain
FROM	students;

-- QUESTION: Find the number of students in each department
SELECT	TABLE_NAME
FROM	INFORMATION_SCHEMA.COLUMNS
WHERE	COLUMN_NAME = 'email'
AND		TABLE_SCHEMA = 'analytics_db';

DESCRIBE	student_grades;

-- Solution
SELECT	department, COUNT(student_id) 'Number of Students'
FROM	student_grades
GROUP BY department;

-- Find the fullnames of students that have their lastnames ending with n and contains only 6 alphabets
DESCRIBE	students;

-- Solution
SELECT	*
FROM	students
WHERE	SUBSTRING_INDEX(student_name, ' ', -1) LIKE '%n'
AND		LENGTH(SUBSTRING_INDEX(student_name, ' ', -1)) = 6;


-- Find the employees who earn more than their managers.
USE sales;
DESCRIBE	employees;

SELECT	e1.employeeID, e1.FirstName, e1.ReportsTo, e1.Salary, e2.employeeID, e2.FirstName, e2.salary
FROM	employees e1 INNER JOIN employees e2
ON		e1.ReportsTo = e2.EmployeeID
AND		e1.salary > e2.salary;

-- Solution without Joins
SELECT	e.employeeID, e.FirstName, e.ReportsTo, e.Salary, m.employeeID, m.FirstName, m.salary
FROM	employees e, employees m
WHERE	m.EmployeeID = e.ReportsTo
AND		e.salary > m.salary;

-- QUESTION: Report all duplicate emails.
USE analytics_db;

-- Solution
SELECT	email AS Email
FROM	students
GROUP BY email
HAVING COUNT(email) > 1;


-- Find all customers who never order anything.
SELECT  name AS Customers
FROM    Customers
WHERE   id NOT IN (SELECT  customerId  FROM  Orders);


-- Find employees who have the highest salary in each of the departments.
USE sales;
SHOW TABLES;
DESCRIBE employees;

-- Solution
WITH rn AS (SELECT	employeeID, city, Salary,
		DENSE_RANK() OVER(PARTITION BY city ORDER BY salary DESC) AS rnk
FROM	employees)

SELECT	City, employeeID, Salary
FROM	rn
WHERE	rnk = 1;

-- Solution given on LeetCode
# Write your MySQL query statement below
WITH rn AS (SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary,
        DENSE_RANK() OVER(PARTITION BY d.name ORDER BY e.salary DESC) as rnk
FROM    Employee e LEFT JOIN Department d
ON      e.departmentid = d.id)

SELECT  Department, Employee, Salary
FROM    rn
WHERE   rnk = 1;


-- Find the departments Top Three Salaries

-- Solution
WITH rn AS (SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary,
        DENSE_RANK() OVER(PARTITION BY d.name ORDER BY e.salary DESC) as rnk
FROM    Employee e LEFT JOIN Department d
ON      e.departmentid = d.id)

SELECT  Department, Employee, Salary
FROM    rn
WHERE   rnk IN (1, 2, 3);


-- ---- 4/12/2025 -------
-- QUESTION: Write a solution to report the movies with an odd-numbered ID and a description that is not "boring". 
-- Return the result table ordered by rating in descending order.
SELECT  id, movie, description, rating
FROM    Cinema
WHERE   MOD(id, 2) = 1
AND     description != 'boring'
ORDER BY    rating DESC;

/*
Write a solution to:
Find the name of the user who has rated the greatest number of movies. In case of a tie, return the lexicographically smaller user name.
Find the movie name with the highest average rating in February 2020. In case of a tie, return the lexicographically smaller movie name.
*/
# Write your MySQL query statement below
(SELECT     u.name AS results
FROM        Movies m INNER JOIN MovieRating mr
ON          m.movie_id = mr.movie_id
INNER JOIN  Users u
ON          u.user_id = mr.user_id
GROUP BY    u.user_id, u.name
ORDER BY    COUNT(*) DESC, u.name ASC
LIMIT       1)

UNION ALL

(SELECT     m.title AS results
FROM        Movies m INNER JOIN MovieRating mr
ON          m.movie_id = mr.movie_id
INNER JOIN  Users u
ON          u.user_id = mr.user_id
WHERE       mr.created_at >= '2020-02-01' AND mr.created_at < '2020-03-01'
GROUP BY    m.movie_id, m.title
ORDER BY    AVG(mr.rating) DESC, m.title ASC
LIMIT       1);

-- ---- 5/12/2025 -------
-- LeetCode QUESTION: Write a solution to find the number of times each student attended each exam.
-- Return the result table ordered by student_id and subject_name.

SELECT      s.student_id,
            s.student_name,
            sj.subject_name,
            COUNT(e.subject_name) AS attended_exams
FROM        Students s    CROSS JOIN    Subjects sj
LEFT JOIN   Examinations e
ON          s.student_id = e.student_id
AND         sj.subject_name = e.subject_name
GROUP BY    s.student_id,
            s.student_name,
            sj.subject_name
ORDER BY    s.student_id, sj.subject_name;