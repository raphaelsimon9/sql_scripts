#SELECT * FROM netflix.cast
#LEFT JOIN netflix.show_cast
#ON netflix.cast.cast_id = netflix.show_cast.cast_id

select * from netflix.netflix_titles;

select * from netflix.netflix_titles titles
where release_year in (2020, 2021)
and show_id like '%1%';

SELECT name FROM netflix.cast
WHERE cast.name = 'Ama Qamata'
UNION
SELECT Director_Name FROM netflix.directors
WHERE directors.Director_Name = 'Ama Qamata';

SELECT name FROM cast
#WHERE cast.name = 'Ama Qamata'
UNION ALL
SELECT Director_Name FROM directors;
#WHERE directors.Director_Name = 'Robert Cullen';

#select * from directors;

select sum(o.quantityOrdered)  from orderdetails o;

select paymentDate, SUM(amount) 'Total Payments'
from classicmodels.payments
group by paymentDate
order by paymentDate;

select c.customerNumber, c.customerName, count(distinct(orderNumber)) as 'Total Orders',sum(amount) as 'Total Amount Spent'
from classicmodels.customers c
inner join classicmodels.orders o
on c.customerNumber = o.customerNumber
inner join classicmodels.payments p
on o.customerNumber = p.customerNumber
group by c.customerNumber, c.customerName;
