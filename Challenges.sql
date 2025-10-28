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
