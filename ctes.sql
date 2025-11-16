-- Filtering the remark column using the WITH CTE
USE sales;

WITH remark as (
	select o.orderID as `Order ID`,
	companyName as `Customer Name`,
	concat_ws(' ', firstName, lastName) as `Employee Name`,
	concat('$ ',format(sum(Quantity * p.UnitPrice),2)) as `Purchasing Price`,
	concat('$ ',format(sum(od.UnitPrice * Quantity),2)) as `Selling Price`,
	concat('$ ',format(sum(abs(od.UnitPrice * Quantity - Quantity * p.UnitPrice)),2)) as `Absolute Profit/Loss`,
	(case
		when sum(od.UnitPrice * Quantity - Quantity * p.UnitPrice) < 0
		then concat('Loss of ', concat('$ ',format(sum(abs(od.UnitPrice * Quantity - Quantity * p.UnitPrice)),2)))
		when sum(od.UnitPrice * Quantity - Quantity * p.UnitPrice) = 0
		then 'No Profit / Loss'
		else concat('Profit of ', concat('$ ',format(sum(abs(od.UnitPrice * Quantity - Quantity * p.UnitPrice)),2)))
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
    concat(format(((tlo.`Number of Late Orders`/toe.`Number of Orders`)*100),2), '%') as `Percentage of Late Orders`
from employees e
inner join totalOrdersByEmployee toe
on e.EmployeeID = toe.employeeID
inner join totalNumberofLateOrdersByEmployee tlo
on toe.EmployeeID = tlo.EmployeeID
where ((tlo.`Number of Late Orders`/toe.`Number of Orders`)*100) > 5
order by ((tlo.`Number of Late Orders`/toe.`Number of Orders`)*100) desc
; 


-- Return all orders over $200 and also the number of orders over $200
WITH total_amount_spent AS (SELECT	order_id, FORMAT(SUM(o.units * p.unit_price),2) AS Total_Order
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


-- Get the reporting hierarchy for each employee
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
