use classicmodels;

select distinct country from classicmodels.customers;

-- Group all the countries into their respective continents
with case_statement as ( -- using cte so that I can filter on the case statements everytime
	select customerNumber, customerName, country, creditLimit, orderNumber, status, paymentDate, amount,
		case 
			when country in ('France', 'Norway', 'Poland', 'Germany', 'Spain', 'Sweden', 'Portugal', 'Italy', 'UK', 'Belgium', 'Russia', 'Ireland', 'Finland')
		then 'Europe'
			when country in ('USA', 'Canada')
		then 'The Americas'
			when country in ('Japan', 'Hong Kong', 'Singapore', 'Philippines')
		then 'Asia'
			when country = 'Australia'
		then 'Australia'
		else 'Rest Of The World'
		end as Continent,

		(case -- Checks whether a customer bought or not. If there is an orderNumber, then they bought, else, they did not buy
			when orderNumber is not null
		then 'Bought'
		else 'Not Bought'
		end) as Buying_Status
	from
		(select c.customerNumber, customerName, country, creditLimit, orderNumber, status, paymentDate, amount
		from classicmodels.customers c
		left join classicmodels.orders o
		on c.customerNumber = o.customerNumber
		left join classicmodels.payments p
		on o.customerNumber = p.customerNumber) t1)

select * 
from case_statement
where buying_status = 'bought';
        
        
select c.customerNumber, customerName, country, creditLimit, orderNumber, status, paymentDate, amount
from classicmodels.customers c
left join classicmodels.orders o
on c.customerNumber = o.customerNumber
left join classicmodels.payments p
on o.customerNumber = p.customerNumber
where orderNumber is null;



-- Find all customers that have not made a purchase
select customerNumber, customerName, country, Continent, creditLimit, orderNumber, status, paymentDate, amount, `Bought or Not Bought`
from
(select customerNumber, customerName, country, creditLimit, orderNumber, status, paymentDate, amount,
case when country in ('France', 'Norway', 'Poland', 'Germany', 'Spain', 'Sweden', 'Portugal', 'Italy', 'UK', 'Belgium', 'Russia', 'Ireland', 'Finland')
then 'Europe'
when country in ('USA', 'Canada')
then 'Americas'
when country in ('Japan', 'Hong Kong', 'Singapore', 'Philippines')
then 'Asia'
when country = 'Australia'
then 'Australia'
else 'Rest Of The World'
end as 'Continent',
case
	when orderNumber is null
then 'Not Bought'
else 'Not Bought'
end as 'Bought or Not Bought'
from
(select c.customerNumber, customerName, country, creditLimit, orderNumber, status, paymentDate, amount
from classicmodels.customers c
left join classicmodels.orders o
on c.customerNumber = o.customerNumber
left join classicmodels.payments p
on o.customerNumber = p.customerNumber) t1) t2
where orderNumber is null;


-- Find all customers that have made a purchase
select customerNumber, customerName, country, Continent, creditLimit, orderNumber, status, paymentDate, amount, `Bought or Not Bought`
from
(select customerNumber, customerName, country, creditLimit, orderNumber, status, paymentDate, amount,
case when country in ('France', 'Norway', 'Poland', 'Germany', 'Spain', 'Sweden', 'Portugal', 'Italy', 'UK', 'Belgium', 'Russia', 'Ireland', 'Finland')
then 'Europe'
when country in ('USA', 'Canada')
then 'Americas'
when country in ('Japan', 'Hong Kong', 'Singapore', 'Philippines')
then 'Asia'
when country = 'Australia'
then 'Australia'
else 'Rest Of The World'
end as 'Continent',

case
	when orderNumber is not null
then 'Bought'
else 'Not Bought'
end as 'Bought or Not Bought'

from
(select c.customerNumber, customerName, country, creditLimit, orderNumber, status, paymentDate, amount
from classicmodels.customers c
left join classicmodels.orders o
on c.customerNumber = o.customerNumber
left join classicmodels.payments p
on o.customerNumber = p.customerNumber) t1) t2
where orderNumber is not null;