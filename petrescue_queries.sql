select sum(cost)
from petrescue.petrescue;

select sum(cost) as SUM_OF_COST
from petrescue.petrescue;

select max(quantity) as 'Maximum Rescues'
from petrescue.petrescue;

select avg(cost) as 'Average Cost'
from petrescue.petrescue;

-- Query A5: Enter a function that displays the average cost of rescuing a dog.
select animal, avg(cost/quantity) as 'Average Cost'
from petrescue.petrescue
where animal like 'Dog'
group by animal;

-- Enter a function that displays the rounded cost of each rescue.
select animal, round(cost)
from petrescue.petrescue;

-- Enter a function that displays the length of each animal name.
select animal, length(animal)
from petrescue.petrescue
group by animal;

-- Query B3: Enter a function that displays the animal name in each rescue in uppercase.
select upper(animal)
from petrescue.petrescue;

-- Query B4: Enter a function that displays the animal name in each rescue in uppercase without duplications.
select distinct upper(animal)
from petrescue.petrescue;

-- Query B5: Enter a query that displays all the columns from the PETRESCUE table, where the animal(s) rescued are cats. Use cat in lower case in the query.
select * from petrescue.petrescue
where lower(animal) like 'cat';


-- Query C1: Enter a function that displays the day of the month when cats have been rescued.
select day(rescuedate)
from petrescue.petrescue
where upper(animal) like 'cat';

-- Query C2: Enter a function that displays the number of rescues on the 5th month.
select animal, count(quantity)
from petrescue.petrescue
where month(rescuedate) = 5
group by animal;

-- Query C3: Enter a function that displays the number of rescues on the 14th day of the month.
select animal, count(quantity)
from petrescue.petrescue
where day(rescuedate) = 14
group by animal;

-- Query C4: Animals rescued should see the vet within three days of arrivals. Enter a function that displays the third day from each rescue.
select animal, rescuedate as 'Rescue_Date', (rescuedate + 3)
from petrescue.petrescue;

-- Query C4: Animals rescued should see the vet within three days of arrivals. Enter a function that displays the third day from each rescue.
select animal, rescuedate as 'Rescue_Date', (rescuedate + 3)
from petrescue.petrescue;

-- Query C5: Enter a function that displays the length of time the animals have been rescued; the difference between todays date and the rescue date.
select (current_date - rescuedate)
from petrescue.petrescue;

select *
from petrescue.petrescue
where animal like '%do%';