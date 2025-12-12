-- Filtering the remark column using the WITH CTE
USE sales;

WITH remark as (
	select o.orderID as `Order ID`,
	companyName as `Customer Name`,
	concat_ws(' ', firstName, lastName) as `Employee Name`,
	concat('$ ',round(sum(Quantity * p.UnitPrice),2)) as `Purchasing Price`,
	concat('$ ',round(sum(od.UnitPrice * Quantity),2)) as `Selling Price`,
	concat('$ ',round(sum(abs(od.UnitPrice * Quantity - Quantity * p.UnitPrice)),2)) as `Absolute Profit/Loss`,
	(case
		when sum(od.UnitPrice * Quantity - Quantity * p.UnitPrice) < 0
		then concat('Loss of ', concat('$ ',round(sum(abs(od.UnitPrice * Quantity - Quantity * p.UnitPrice)),2)))
		when sum(od.UnitPrice * Quantity - Quantity * p.UnitPrice) = 0
		then 'No Profit / Loss'
		else concat('Profit of ', concat('$ ',round(sum(abs(od.UnitPrice * Quantity - Quantity * p.UnitPrice)),2)))
		end) as Remark
	from employees
	join orders o using(employeeID)
	join customers using(customerID)
	join orderdetails od on o.orderID = od.orderID
	join products p using(ProductID)
	group by od.orderID
	order by o.orderID asc
)
select * from remark
where remark like 'loss%';


-- Return each country's happiness score for the year alongside the country's average happiness score. With Multiple CTEs
USE analytics_db;
/* SELECT	* FROM happiness_scores;

SELECT	country, AVG(happiness_score)
FROM	happiness_scores
GROUP BY country;
*/
WITH country_hs AS (
					SELECT	country, AVG(happiness_score) AS Avg_happiness_score
					FROM	happiness_scores
					GROUP BY country
                    ),
	hs AS			(SELECT	*
                    FROM	happiness_scores
                    )
                    
	SELECT	hs.year, hs.country, hs.happiness_score, format(country_hs.Avg_happiness_score,2) AS Avg_happiness_score
    FROM	hs
    LEFT JOIN country_hs
    ON hs.country = country_hs.country
;
                    
                    
                    
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
    concat(round(((tlo.`Number of Late Orders`/toe.`Number of Orders`)*100),2), '%') as `Percentage of Late Orders`
from employees e
inner join totalOrdersByEmployee toe
on e.EmployeeID = toe.employeeID
inner join totalNumberofLateOrdersByEmployee tlo
on toe.EmployeeID = tlo.EmployeeID
where ((tlo.`Number of Late Orders`/toe.`Number of Orders`)*100) > 5
order by ((tlo.`Number of Late Orders`/toe.`Number of Orders`)*100) desc
; 


-- Return all orders over $200 and also the number of orders over $200
WITH total_amount_spent AS (SELECT	order_id, ROUND(SUM(o.units * p.unit_price),2) AS Total_Order
							FROM	orders o
							LEFT JOIN	products p
							ON			o.product_id = p.product_id
							GROUP BY	o.order_id
							HAVING 		Total_Order > 200
							ORDER BY	Total_Order DESC)
SELECT		total_amount_spent.order_id,
			total_amount_spent.Total_Order,
            (SELECT COUNT(*) FROM total_amount_spent) AS `No. of Orders Above $200`
FROM		total_amount_spent;


-- Generating dates with RECURSIVE
SET @@cte_max_recursion_depth = 50000;

WITH RECURSIVE dates(date) AS	(
								SELECT '1990-07-01'
                                UNION ALL
                                SELECT date + INTERVAL 1 DAY
                                FROM dates
                                WHERE date <= NOW()
                                )
SELECT date FROM dates;


-- QUESTION: Get the reporting hierarchy for each employee
USE sales;

WITH RECURSIVE employee_hierarchy AS (
										SELECT employeeID, firstName, COALESCE(reportsTo, 'No Reporting Manager') Manager_Id,
												CAST(firstName AS CHAR(1000)) AS hierarchy
										FROM employees
                                        WHERE reportsTo IS NULL
									UNION ALL
										SELECT e.employeeID, e.firstName, e.reportsTo,
												CONCAT_WS(' > ', eh.hierarchy, e.firstName) as hierarchy
                                        FROM employees e INNER JOIN employee_hierarchy eh
										ON e.reportsTo = eh.employeeID
									)
SELECT *
FROM employee_hierarchy;


/* QUESTION: Get the names of customers who placed orders in 1996 along with their total orders. Include the following comments;
	Below $1000, 'Very Low Order'
    Between $1000 and $1500, 'Low Order'
    Between $5001 and $10000, 'Medium Order'
    Between $10001 and $15000, 'High Order'
    Above $15000, 'Very High Order'
  */
-- SOLUTION --
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


-- QUESTION: Calculate the amount spent on each product, within each order
USE analytics_db;

WITH product_spend AS (
						SELECT	
								o.order_id,
								o.product_id,
								p.product_name,
								o.units * p.unit_price AS amount_spent
						FROM	orders o LEFT JOIN products p
						ON		o.product_id = p.product_id
					)
SELECT	order_id,
		product_id,
        product_name,
        SUM(amount_spent) AS total_spent
FROM	product_spend
GROUP BY	order_id, product_id, product_name
ORDER BY	order_id, product_name;


-- QUESTION: Calculate the total spend for each customer and put them into BINs of $0 - $10, $10 - 20, etc
-- SOLUTION --
SELECT	customer_id,
        ROUND(SUM(units * unit_price),2) AS total_spend,
        FLOOR(SUM(units * unit_price) / 10) * 10 AS total_spend_bins
FROM	orders o LEFT JOIN products p
ON		o.product_id = p.product_id
GROUP BY customer_id;


-- Categorize the customers Total Spend into bins
-- SOLUTION --
WITH bins AS (
				SELECT	customer_id,
						ROUND(SUM(units * unit_price),2) AS total_spend,
						FLOOR(SUM(units * unit_price) / 10) * 10 AS total_spend_bin
				FROM	orders o LEFT JOIN products p
				ON		o.product_id = p.product_id
				GROUP BY customer_id
			)
SELECT	CONCAT_WS(' - ', total_spend_bin + 1 , total_spend_bin + 10) as 'Total Spend Bins',
		COUNT(customer_id) AS 'Number of Customers'
FROM bins
GROUP BY total_spend_bin
ORDER BY total_spend_bin;


-- QUESTION: A student's record keeps coming as a duplicate, generate a report that excludes the duplicated record.
-- SOLUTION --
-- Check the entire table Note: This is a small table
SELECT	*
FROM students
ORDER BY student_name;

-- Counting the number of times each student occurs in the table
SELECT	*,
		ROW_NUMBER() OVER(PARTITION BY student_name) AS student_count
FROM students; -- This shows that Noah Scott is the duplicate student

-- I need to rank the highest id number as 1 since it is the most recent record
SELECT	*,
		ROW_NUMBER() OVER(PARTITION BY student_name ORDER BY id DESC) AS student_count
FROM students;

-- Final query for the report. Using a CTE so that I can filter all the students in rank 1
WITH sc AS (
			SELECT	*,
					ROW_NUMBER() OVER(PARTITION BY student_name ORDER BY id DESC) AS student_count
			FROM students)
SELECT	*
FROM	sc
WHERE	student_count = 1
ORDER BY id;

-- Using a SUBQUERY for the final report
SELECT	*
FROM	(
			SELECT	*,
					ROW_NUMBER() OVER(PARTITION BY student_name ORDER BY id DESC) AS student_count
			FROM students
		) AS sc
WHERE student_count = 1
ORDER BY id;


-- QUESTION: Calaculate 3 months Moving Averages of the happiness scores
SELECT	country, year,
		happiness_score,
        ROUND(AVG(happiness_score) OVER(PARTITION BY country ORDER BY year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 3) as Moving_Avg
FROM	happiness_scores
ORDER BY country, year;


-- Generate a report that shows the total sales for each month, cummulative sum of sales, and the 6-months moving average of the sales
SELECT	*	FROM	orders;
SELECT	*	FROM	products;
DESCRIBE orders;
UPDATE orders
SET order_date = STR_TO_DATE(order_date, '%m/%e/%y');
ALTER TABLE orders
MODIFY order_date DATE;

WITH monthly_sales AS (
						SELECT	YEAR(order_date) AS Year, MONTH(order_date) AS Month,
								ROUND(SUM(o.units * p.unit_price)) AS Total_Sales
						FROM	orders o LEFT JOIN products p
						ON		o.product_id = p.product_id
						GROUP BY YEAR(order_date), MONTH(order_date)
						ORDER BY YEAR(order_date), MONTH(order_date)
					)
SELECT	Year, Month, Total_Sales,
		SUM(Total_Sales) OVER(ORDER BY Year,Month) AS Cummulative_Sales,
        ROUND(AVG(Total_Sales) OVER(ORDER BY Year, Month ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)) AS '6_Months_Moving_Average'
FROM monthly_sales;


-- Add a sub total for each year's total sales
WITH mnth_sales AS (
						SELECT	YEAR(order_date) AS Year, MONTH(order_date) AS Month,
								ROUND(SUM(o.units * p.unit_price)) AS Total_Sales
						FROM	orders o LEFT JOIN products p
						ON		o.product_id = p.product_id
						GROUP BY YEAR(order_date), MONTH(order_date)
						ORDER BY YEAR(order_date), MONTH(order_date)
                    )

SELECT	Year, COALESCE(Month, CONCAT_WS(' ', Year, 'SubTotal')) AS 'Month', SUM(Total_Sales) AS 'Total Sales'
FROM	mnth_sales
GROUP BY Year, Month WITH ROLLUP;


# Write a solution to find the second highest distinct salary from the Employee table. If there is no second highest salary, return null
# Write your MySQL query statement below
WITH rn AS (SELECT  DISTINCT salary,
        DENSE_RANK() OVER(ORDER BY salary DESC) AS row_num
FROM    employee)

SELECT IFNULL(
                (SELECT  salary
                FROM    rn
                WHERE   row_num = 2),
            NULL) AS SecondHighestSalary

/* Alternate Solution to the above question 
SELECT (
    SELECT DISTINCT Salary
    FROM Employee
    ORDER BY Salary DESC
    LIMIT 1 OFFSET 1
) AS SecondHighestSalary;
*/


-- Write a solution to find the nth highest distinct salary from the Employee table. If there are less than n distinct salaries, return null.
DELIMITER //
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT -- Creating the function
DETERMINISTIC 										   
READS SQL DATA
BEGIN
  RETURN (
      # Write your MySQL query statement below.
        WITH rn AS (SELECT  DISTINCT salary,
        DENSE_RANK() OVER(ORDER BY salary DESC) AS row_num
        FROM    salaries)

        SELECT IFNULL(
                (SELECT  salary
                FROM    rn
                WHERE   row_num = N),
            NULL) AS SecondHighestSalary      

  );
END //
DELIMITER ;

-- DROP FUNCTION analytics_db.getNthHighestSalary;

SELECT	getNthHighestSalary(3);  -- Calling the getNHighestSalary Function


SELECT  DISTINCT salary,
        DENSE_RANK() OVER(ORDER BY salary DESC) AS row_num
FROM    salaries;


-- QUESTION: Find employees who have the highest salary in each of the departments.
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


-- QUESTION: Find the departments Top Three Salaries

-- Solution
WITH rn AS (SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary,
        DENSE_RANK() OVER(PARTITION BY d.name ORDER BY e.salary DESC) as rnk
FROM    Employee e LEFT JOIN Department d
ON      e.departmentid = d.id)

SELECT  Department, Employee, Salary
FROM    rn
WHERE   rnk IN (1, 2, 3);


-- ---- 4/12/2025 -------
-- Write a solution to find the customer_number for the customer who has placed the largest number of orders.
-- The test cases are generated so that exactly one customer will have placed more orders than any other customer.
WITH rn AS (SELECT  customer_number, COUNT(order_number) AS num_orders
            FROM    Orders
            GROUP BY    customer_number)

SELECT  customer_number
FROM    rn
WHERE   num_orders = (SELECT MAX(num_orders) FROM rn);


-- LeetCode QUESTION
-- Write an SQL query to find for each month and country, the number of transactions and their total amount, the number of approved transactions and their total amount.
SELECT  DATE_FORMAT(trans_date, '%Y-%m') AS month,
        country,
        COUNT(id) AS trans_count,
        SUM(State = 'approved') AS approved_count,
        SUM(amount) AS trans_total_amount,
        SUM(IF(state = 'approved', amount, 0)) AS approved_total_amount
FROM    Transactions
GROUP BY    DATE_FORMAT(trans_date, '%Y-%m'), country;

-- LeetCode QUESTION
-- Write a solution to find the daily active user count for a period of 30 days ending 2019-07-27 inclusively.
-- A user was active on someday if they made at least one activity on that day.

SELECT  activity_date AS day, COUNT(DISTINCT user_id) AS active_users
FROM    Activity
WHERE   activity_date <= '2019-07-27'
AND     DATEDIFF('2019-07-27', activity_date) < 30
GROUP BY    activity_date;


/*
Write a solution to:
Find the name of the user who has rated the greatest number of movies. In case of a tie, return the lexicographically smaller user name.
Find the movie name with the highest average rating in February 2020. In case of a tie, return the lexicographically smaller movie name.
*/
# USING a CTE
WITH un AS (SELECT     u.name AS 'name'
			FROM        Movies m INNER JOIN MovieRating mr
			ON          m.movie_id = mr.movie_id
			INNER JOIN  Users u
			ON          u.user_id = mr.user_id
			GROUP BY    u.user_id, u.name
			ORDER BY    COUNT(*) DESC, u.name ASC
			LIMIT       1),

	t AS	(SELECT     m.title AS 'name'
			FROM        Movies m INNER JOIN MovieRating mr
			ON          m.movie_id = mr.movie_id
			INNER JOIN  Users u
			ON          u.user_id = mr.user_id
			WHERE       mr.created_at >= '2020-02-01' AND mr.created_at < '2020-03-01'
			GROUP BY    m.movie_id, m.title
			ORDER BY    AVG(mr.rating) DESC, m.title ASC
			LIMIT       1)
            
SELECT	name
FROM	un

UNION ALL

SELECT	name
FROM	t;


-- ---- 5/12/2025 -------
-- LeetCode QUESTION: Write a solution to report the customer ids from the Customer table that bought all the products in the Product table.

SELECT      customer_id
FROM        Customer
GROUP BY    customer_id
HAVING      COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM  product);


/*
LeetCode Question: Each node in the tree can be one of three types:

"Leaf": if the node is a leaf node.
"Root": if the node is the root of the tree.
"Inner": If the node is neither a leaf node nor a root node.
Write a solution to report the type of each node in the tree.

Return the result table in any order.
*/
# Solution
SELECT  id,
        CASE WHEN p_id IS NULL THEN 'Root'
             WHEN id IN (SELECT  p_id    FROM    Tree) THEN 'Inner'
             ELSE 'Leaf'
        END AS type
FROM    Tree;


/*
The cancellation rate is computed by dividing the number of canceled (by client or driver)
requests with unbanned users by the total number of requests with unbanned users on that day.

Write a solution to find the cancellation rate of requests with unbanned users
(both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03"
with at least one trip. Round Cancellation Rate to two decimal points.
*/
# Solution
SELECT  request_at AS Day,
        ROUND(SUM(Status IN ('cancelled_by_driver', 'cancelled_by_client'))/COUNT(*),2) AS 'Cancellation Rate'
FROM    Trips
WHERE   request_at BETWEEN '2013-10-01' AND '2013-10-03'
AND     client_id IN (SELECT users_id FROM Users WHERE banned = 'No' AND role = 'client')
AND     driver_id IN (SELECT users_id from Users WHERE banned = 'No' AND role = 'driver')
GROUP BY request_at;


-- 
# Solution
WITH cte AS (SELECT  id, num,
        LAG(num) OVER(ORDER BY id) prev,
        LEAD(num) OVER(ORDER BY id) next
FROM    logs)

SELECT  num AS 'ConsecutiveNums'
FROM    cte
WHERE   num = prev
AND     num = next;


/*
Write a solution to report the sum of all total investment values in 2016 tiv_2016, for all policyholders who:

have the same tiv_2015 value as one or more other policyholders, and
are not located in the same city as any other policyholder (i.e., the (lat, lon) attribute pairs must be unique).
*/
# Solution
WITH a AS (SELECT  pid, tiv_2015, tiv_2016,
        COUNT(*) OVER(PARTITION BY tiv_2015) AS dup_cnt,
        lat, lon
        FROM    Insurance)

SELECT  ROUND(SUM(tiv_2016),2) tiv_2016
FROM    a
WHERE   dup_cnt > 1
AND     (lat, lon) IN (
            SELECT lat, lon
            FROM Insurance
            GROUP BY lat, lon
            HAVING COUNT(*) = 1)
;