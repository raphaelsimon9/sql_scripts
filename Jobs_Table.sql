-- SET GLOBAL local_infile = 1;

-- LOAD DATA LOCAL INFILE 'C:/Users/Rafael/Downloads/jobs.csv' 
-- INTO TABLE jobs
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"' 
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (JOB_IDENT, JOB_TITLE, MIN_SALARY, MAX_SALARY);

-- select * from hr.employees
-- having dep_id < 6;

-- select dep_id, count(*)
-- from hr.employees
-- group by employees.dep_id;

-- select dep_id, count(*), avg(salary)
-- from hr.employees
-- group by dep_id;

-- SELECT DEP_ID, COUNT(*) AS "NUM_EMPLOYEES", AVG(SALARY) AS "AVG_SALARY"
-- FROM hr.employees
-- GROUP BY DEP_ID;

-- SELECT DEP_ID, COUNT(*) AS "NUM_EMPLOYEES", AVG(SALARY) AS "AVG_SALARY"
-- FROM HR.EMPLOYEES
-- GROUP BY DEP_ID
-- ORDER BY AVG_SALARY DESC;

-- SELECT DEP_ID, COUNT(*) AS "NUM_EMPLOYEES", AVG(SALARY) AS "AVG_SALARY"
-- FROM HR.EMPLOYEES
-- GROUP BY DEP_ID
-- HAVING count(*) < 4
-- ORDER BY AVG_SALARY;

-- select F_NAME, L_NAME
-- from hr.employees
-- where F_NAME like 'S%';

-- select * from hr.employees
-- order by b_date;

-- select dep_id, avg(salary) as 'Average Salary'
-- from hr.employees
-- group by dep_id
-- having avg(salary) >= 60000;

-- select dep_id, avg(salary) as 'Average Salary'
-- from hr.employees
-- group by dep_id
-- having avg(salary) >= 60000
-- order by avg(salary) desc;

-- select * from hr.employees
-- where address like '%Elgin,IL%';

-- select f_name, l_name
-- from hr.employees
-- where b_date like '197%';

-- select f_name, l_name
-- from hr.employees
-- where dep_id = 5 and salary in (60000, 70000);

-- select f_name, l_name
-- from hr.employees
-- where dep_id = 5 and salary between 60000 and 70000;

-- select f_name, l_name, dep_id
-- from hr.employees
-- order by dep_id;

-- select f_name, l_name, dep_id
-- from hr.employees
-- order by dep_id desc, l_name desc;

-- select e.f_name, e.l_name, d.dep_name
-- from hr.employees as e, hr.departments as d
-- where e.dep_id = d.dept_id_dep
-- order by d.dep_name, e.l_name desc;

-- select e.dep_id, count(dep_id) as 'Number of Emp'
-- from hr.employees as e
-- group by e.dep_id;

-- select e.dep_id, count(*) as 'NUM_EMPLOYEES', avg(salary) as 'AVG_SALARY'
-- from hr.employees as e
-- group by e.dep_id
-- having num_employees < 4
-- order by avg_salary;

-- SELECT * FROM EMPLOYEES
-- WHERE SALARY < AVG(SALARY); -- Invalid use of a group function error

-- SELECT * FROM EMPLOYEES
-- WHERE SALARY < (SELECT AVG(SALARY) FROM EMPLOYEES);

-- SELECT EMP_ID, SALARY, (SELECT MAX(SALARY) FROM EMPLOYEES) AS 'MAX SALARY'
-- FROM EMPLOYEES;

-- SELECT F_NAME, L_NAME
-- FROM EMPLOYEES
-- WHERE B_DATE = (SELECT MIN(B_DATE) FROM EMPLOYEES);

-- SELECT SALARY 
--       FROM EMPLOYEES 
--       ORDER BY SALARY DESC;

-- SELECT SALARY 
--       FROM EMPLOYEES 
--       ORDER BY SALARY DESC LIMIT 5;

-- SELECT AVG(SALARY) 
-- FROM (SELECT SALARY 
--       FROM EMPLOYEES 
--       ORDER BY SALARY DESC 
--       LIMIT 5) AS SALARY_TABLE;

-- SELECT SALARY FROM EMPLOYEES
-- 		ORDER BY SALARY LIMIT 5;

-- SELECT AVG(SALARY)
-- FROM (SELECT SALARY FROM EMPLOYEES
-- 		ORDER BY SALARY LIMIT 5) AS SALARY_TABLE;

-- (SELECT AVG(YEAR(FROM_DAYS(DATEDIFF(CURRENT_DATE, B_DATE)))) FROM EMPLOYEES);

-- SELECT * FROM EMPLOYEES
-- WHERE DATEDIFF(CURRENT_DATE, B_DATE) >
-- 		(SELECT AVG(DATEDIFF(CURRENT_DATE, B_DATE)) FROM EMPLOYEES);

-- SELECT * 
-- FROM EMPLOYEES 
-- WHERE YEAR(FROM_DAYS(DATEDIFF(CURRENT_DATE,B_DATE))) > 
--     (SELECT AVG(YEAR(FROM_DAYS(DATEDIFF(CURRENT_DATE,B_DATE)))) 
--     FROM EMPLOYEES);

-- SELECT * FROM JOB_HISTORY;

-- SELECT EMPL_ID, YEAR(FROM_DAYS(DATEDIFF(CURRENT_DATE, START_DATE))) AS ' YEARS OF SERVICE',
-- 		(SELECT AVG(YEAR(FROM_DAYS(DATEDIFF(CURRENT_DATE, START_DATE)))) FROM JOB_HISTORY) AS ' AVERAGE YEARS OF SERVICE'
--         FROM JOB_HISTORY;

-- SELECT * FROM EMPLOYEES
-- 	WHERE JOB_ID IN (SELECT JOB_IDENT FROM JOBS);

-- SELECT JOB_TITLE, MIN_SALARY, MAX_SALARY, JOB_IDENT
-- FROM JOBS
-- WHERE JOB_IDENT IN (select JOB_ID from EMPLOYEES where SALARY > 70000 );

-- Inplicit Joins to access multiple tables. This uses the FULL OUTER JOIN built-in function
-- SELECT * FROM EMPLOYEES E, JOBS J
-- WHERE E.JOB_ID = J.JOB_IDENT;

-- SELECT * FROM JOBS;

-- SELECT EMP_ID, F_NAME, JOB_TITLE FROM EMPLOYEES E, JOBS J
-- WHERE E.JOB_ID = J.JOB_IDENT;

-- SELECT E.EMP_ID, E.F_NAME, E.L_NAME, J.JOB_TITLE
-- FROM EMPLOYEES E, JOBS J
-- WHERE E.JOB_ID = J.JOB_IDENT;

-- SELECT E.EMP_ID, E.F_NAME, E.L_NAME
-- FROM EMPLOYEES E
-- WHERE JOB_ID IN (SELECT JOB_IDENT FROM JOBS WHERE JOB_TITLE = 'Jr. Designer');

-- SELECT E.EMP_ID, E.F_NAME, E.L_NAME, J.JOB_TITLE
-- FROM EMPLOYEES E, JOBS J
-- WHERE E.JOB_ID = J.JOB_IDENT AND J.JOB_TITLE LIKE '%jr. designer%';

SELECT JOB_TITLE, MIN_SALARY, MAX_SALARY, JOB_IDENT
FROM JOBS
WHERE JOB_IDENT IN (SELECT JOB_ID
                    FROM EMPLOYEES
                    WHERE YEAR(B_DATE)>1976 );
                    
                    
SELECT J.JOB_TITLE, J.MIN_SALARY, J.MAX_SALARY, J.JOB_IDENT
FROM JOBS J, EMPLOYEES E
WHERE E.JOB_ID = J.JOB_IDENT AND YEAR(E.B_DATE)>1976;

SELECT * FROM EMPLOYEES E
WHERE SALARY < (SELECT AVG(SALARY) FROM EMPLOYEES);

SELECT EMP_ID, SALARY, (SELECT MAX(SALARY) FROM EMPLOYEES) AS MAX_SALARY
FROM EMPLOYEES;

select * from ( select EMP_ID, F_NAME, L_NAME, DEP_ID from employees) AS EMP4ALL;

SELECT * FROM EMPLOYEES WHERE JOB_ID IN (SELECT JOB_IDENT FROM JOBS);

SELECT F_NAME, L_NAME FROM EMPLOYEES WHERE JOB_ID IN (SELECT JOB_IDENT FROM JOBS WHERE JOB_TITLE LIKE '%JR. DESIGNER%');

SELECT * FROM employees;

SELECT F_NAME, L_NAME, JOB_ID, JOB_TITLE, SALARY FROM EMPLOYEES, JOBS WHERE SALARY > 70000;

SELECT * FROM JOBS WHERE JOB_IDENT IN (SELECT JOB_ID FROM EMPLOYEES WHERE SALARY > 70000);

SELECT * FROM JOBS WHERE JOB_IDENT IN (SELECT JOB_ID FROM EMPLOYEES WHERE YEAR(B_DATE) > 1976);

SELECT * FROM JOBS WHERE JOB_IDENT IN (SELECT JOB_ID FROM EMPLOYEES WHERE SEX = 'F' AND YEAR(B_DATE) > 1976);

-- Perform an implicit cartesian/cross join between EMPLOYEES and JOBS tables.
SELECT * FROM EMPLOYEES, JOBS;

-- Retrieve only the EMPLOYEES records that correspond to jobs in the JOBS table.
SELECT * FROM EMPLOYEES E, JOBS J WHERE E.JOB_ID = J.JOB_IDENT;

SELECT EMP_ID, F_NAME, L_NAME, JOB_TITLE FROM EMPLOYEES E, JOBS J WHERE E.JOB_ID = J.JOB_IDENT;

-- Redo the previous query, but specify the fully qualified column names with aliases in the SELECT clause.
SELECT E.EMP_ID,E.F_NAME,E.L_NAME, J.JOB_TITLE from employees E, jobs J where E.JOB_ID = J.JOB_IDENT;

SELECT DAYOFWEEK(RESCUEDATE) FROM petrescue.PETRESCUE WHERE ANIMAL = 'Dog';

SELECT DAY(RESCUEDATE) FROM petrescue.PETRESCUE WHERE ANIMAL = 'Dog';


-- SELECT * FROM EMPLOYEES;