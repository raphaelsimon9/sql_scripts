/* Write a query to get the employee ID, Full Name, Number of Territories covered by each employee */
-- Solution
use sales;
show tables;
describe employees;
describe employeeterritories;

select e.employeeID, concat_ws(' ', e.firstname, e.lastname) as 'Full Name', count(et.territoryID) as `Number of Territories`
from employees e
join employeeterritories et
using(employeeID)
group by et.employeeID
order by `Number of Territories` desc;

# A query to get the name of customers and the number of orders placed by each
describe customers;
describe orders;

-- Solution
select companyName, count(orderID) as 'Number of Orders'
from customers c join orders o
on c.customerID = o.customerID
group by o.customerID
order by count(orderID) desc;


# Top 10 customers by number of orders
-- Solution
select companyName, count(orderID) as 'Number of Orders'
from customers c join orders o
on c.customerID = o.customerID
group by o.customerID
order by count(orderID) desc
limit 10;

# Bottom 5 customers by number of orders
-- Solution
select *
from(
	select companyName, count(orderID) as `Number of Orders`
	from customers c join orders o
	on c.customerID = o.customerID
	group by o.customerID
	order by count(orderID) asc
	limit 5
	) as bottom_customers
order by `Number of Orders` desc;

-- Get the customer names, the number of orders and the full names of employees that took care of the orders
-- Solution
select orderID, companyName, concat_ws(' ', e.firstname, e.lastname) as `Employee Name`
from customers c join orders o
using(customerID)
join employees e
using(employeeID);

-- Get the product name, category, and the suppliers of each product
-- Solution
describe products;
describe suppliers;
describe categories;
select productName `Product Name`, categoryName `Product Category`, companyName `Supplier Name`
from suppliers join products
using(supplierID)
join categories
using(categoryID);

-- Get the Order ID, Customer's Name, Grand Total of each Order, Name of Employee
show tables;
describe orderdetails;
describe employees;
describe customers;
describe orders;
describe products;

select * from orderdetails
limit 5;

select * from products limit 5;

-- Soultion
select o.orderID as `Order ID`,
companyName as `Customer Name`,
concat('$ ',format(sum(UnitPrice * Quantity),2)) as `Grand Total`,
concat_ws(' ', firstName, lastName) as `Employee Name`
from employees
join orders o
using(employeeID)
join customers
using(customerID)
join orderdetails od
on o.orderID = od.orderID
group by od.orderID
order by o.orderID asc;

-- Get the Order ID, Customer's Name, Grand absolute profit/loss, Name of Employee
-- Soultion
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
    else concat('Profit of ', concat('$ ',format(sum(abs(od.UnitPrice * Quantity - Quantity * p.UnitPrice)),2)))
    end) as Remark
from employees
join orders o using(employeeID)
join customers using(customerID)
join orderdetails od on o.orderID = od.orderID
join products p using(ProductID)
group by od.orderID
order by o.orderID asc;


-- Filtering the remark column using the WITH CTE
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

describe orders;
describe customers;
describe orderdetails;
describe products;
describe categories;

-- Get the quantity and unit price for each category per customer
 select OrderID, companyName,
 productName, categoryName, od.Quantity, od.unitPrice
 from customers
 join orders using(customerID)
 join orderdetails od using(orderID)
 join products using(productID)
 join categories using(categoryID);


-- Get the names and prices of all the products that have more than 100 units sold
select p.productID ` Product ID`, p.productName `Product Name`, p.unitPrice `Unit Price`, sum(od.Quantity) `Quantity Sold`
from products p
inner join orderdetails od
using(productID)
where productID in (
	select productID from orderdetails od
    group by productID
    having sum(od.Quantity) > 100
    )
group by productID;


select * from categories limit 10;


-- Which products have a price higher than the average price within their respective categories?
select 
	productName `Product Name`,
	categoryName `Category Name`,
    unitPrice `Unit Price`,
	(select avg(unitPrice)
		from products
		where categoryID = p.categoryID
	) `Avg Unit Price`,
    (case
		when unitPrice > (select avg(unitPrice) from products where categoryID = p.categoryID)
        then 'Above Average'
        else 'Below Average'
	end) as Remark
from products p
inner join categories using(categoryID)
where unitPrice > (
	select avg(unitPrice)
    from products
    where categoryID = p.categoryID)
group by categoryID, productName, unitPrice
order by unitPrice;


select 
	productName `Product Name`,
	categoryName `Category Name`,
    unitPrice `Unit Price`,
	(select avg(unitPrice)
		from products
		where categoryID = p.categoryID
	) `Avg Unit Price`,
    (case
		when unitPrice > (select avg(unitPrice) from products where categoryID = p.categoryID)
        then 'Above Average'
        else 'Below Average'
	end) as Remark
from products p
inner join categories using(categoryID)
order by `Remark`;


create view high_category_prices as
select 
	productName `Product Name`,
	categoryName `Category Name`,
    unitPrice `Unit Price`,
	(select avg(unitPrice)
		from products
		where categoryID = p.categoryID
	) `Avg Unit Price`,
    (case
		when unitPrice > (select avg(unitPrice) from products where categoryID = p.categoryID)
        then 'Above Average'
        else 'Below Average'
	end) as Remark
from products p
inner join categories using(categoryID)
order by `Remark`;


select * from high_category_prices;


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