/* Write a query to get the employee ID, Full Name, Number of Territories covered by each employee */
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

select companyName, count(orderID) as 'Number of Orders'
from customers c join orders o
on c.customerID = o.customerID
group by o.customerID
order by count(orderID) desc;


# Top 10 customers by number of orders
select companyName, count(orderID) as 'Number of Orders'
from customers c join orders o
on c.customerID = o.customerID
group by o.customerID
order by count(orderID) desc
limit 10;

# Bottom 5 customers by number of orders
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
select orderID, companyName, concat_ws(' ', e.firstname, e.lastname) as `Employee Name`
from customers c join orders o
using(customerID)
join employees e
using(employeeID);

-- Get the product name, category, and the suppliers of each product
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

select * from orderdetails
limit 5;
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