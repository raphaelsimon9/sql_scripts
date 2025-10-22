use classicmodels;

show tables;

describe customers;

select customerName from customers
where customerName like '%anna%';


-- This combines the values across multiple rows and merges them into one group
select country,
group_concat(customerName order by customerName separator ' - ') as `Customer Name`
from customers
group by country;

-- Formats the result to include the country for each of the customers
select country,
group_concat(concat(customerName, ' ', '(',left(upper(country),3),')') order by customerName separator ' | ') as `Customer Name`
from customers
group by country;

select concat_ws(' is from ' , customerName, country) as `Customer and Country`
from customers;