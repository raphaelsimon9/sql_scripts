/* Converts values or expressions from one datatype to another.
The syntax is CAST(expression AS datatype)
*/

SELECT CAST('123' AS UNSIGNED INTEGER) AS 'Result as Integer'; -- Converts a string to an unsigned integer

use sales;

show tables;
describe orders;

select orderdate from orders;

select cast(orderdate as date) -- Extracts only the date from a datetime column
from orders;

select cast(orderdate as time) -- Extracts only the time from a datetime column
from orders;

select orderid, orderdate, cast(orderdate as char(7)) 'Month Year' -- Extracts only the month and year from the orderdate column
from orders;

select orderid, orderdate, date_format(orderdate, '%Y-%m') 'Month Year' -- Extracts only the month and year from the orderdate column
from orders;