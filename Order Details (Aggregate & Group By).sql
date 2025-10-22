SELECT * FROM classicmodels.orderdetails;

select sum(o.quantityOrdered * o.priceEach) as Total_Amount, max(o.quantityOrdered) Highest_Qty, sum(amount)
from classicmodels.orderdetails o
inner join classicmodels.orders ord
on o.orderNumber = ord.orderNumber
inner join classicmodels.payments p
on ord.customerNumber = p.customerNumber;

select c.customerName, o.orderNumber, sum(quantityOrdered * priceEach) as Total_Amount
from classicmodels.orderdetails o
inner join classicmodels.orders ord
on o.orderNumber = ord.orderNumber
inner join classicmodels.customers c
on ord.customerNumber = c.customerNumber
group by o.orderNumber;
 
 
#select sum(o.quantityOrdered * o.priceEach) Total_Amount, max(o.quantityOrdered) Highest_Qty, sum(amount)
#from classicmodels.orderdetails o;


(select c.customerNumber, c.customerName, count(distinct(orderNumber)) as 'Total Orders',sum(amount) as 'Total Amount Spent', avg(amount) as 'Average Amount Spent Per Customer'
from classicmodels.customers c
inner join classicmodels.orders o
on c.customerNumber = o.customerNumber
inner join classicmodels.payments p
on o.customerNumber = p.customerNumber
group by c.customerNumber, c.customerName
);

select customerNumber, customerName, avg(`Total Amount`) as 'Average Amount Per Customer'
from
(select c.customerNumber, c.customerName, o.orderDate, o.orderNumber, sum(priceEach * quantityOrdered) as 'Total Amount'
from classicmodels.customers c
inner join classicmodels.orders o
on c.customerNumber = o.customerNumber
inner join classicmodels.payments p
on o.customerNumber = p.customerNumber
inner join classicmodels.orderdetails od
on od.orderNumber = o.orderNumber
group by o.orderNumber
) t2
group by customerNumber, customerName;


select c.*, p.Total_Payments, sum(p.Total_Payments - c.creditLimit) as difference
from classicmodels.customers c
inner join
(select customerNumber, sum(amount) as Total_Payments
from classicmodels.payments
group by customerNumber
) p
on c.customerNumber = p.customerNumber
group by c.customerNumber;


