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