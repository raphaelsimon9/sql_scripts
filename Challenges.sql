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

