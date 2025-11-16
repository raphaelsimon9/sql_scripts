-- Connect to the analytics database
USE analytics_db;
SHOW TABLES;

-- Looking at the orders and products tables, which products exist in one table, but not the other?
SELECT * FROM orders; -- Checking the Orders Table
SELECT * FROM products; -- Checking the Products Table
SELECT COUNT(DISTINCT product_id) FROM orders;
SELECT COUNT(DISTINCT product_id) FROM products;

SELECT	p.product_id 'Product Id',
		p.product_name 'Product Name',
        COALESCE(o.product_id, 'Product Has Never Been Ordered') AS 'Product Order Status'
FROM	products p LEFT JOIN orders o
ON		p.product_id = o.product_id
WHERE	o.product_id IS NULL;
        

-- Which products are within 25 cents of each other in terms of unit price?
SELECT * FROM products;

SELECT	p1.product_id, p1.product_name, p1.unit_price,
		p2.product_id, p2.product_name, p2.unit_price,
        format(abs(p1.unit_price - p2.unit_price),2) as `Price Diff`
FROM	products p1 INNER JOIN products p2
ON		p1.product_id <> p2.product_id
WHERE	ABS(p1.unit_price - p2.unit_price) < 0.25
		AND p1.product_name < p2.product_name
ORDER BY `Price Diff` DESC;


-- Using "CROSS JOIN", Which products are within 25 cents of each other in terms of unit price?
SELECT * FROM products;

SELECT	p1.product_id, p1.product_name, p1.unit_price,
		p2.product_id, p2.product_name, p2.unit_price,
        format(abs(p1.unit_price - p2.unit_price),2) as `Price Diff`
FROM	products p1 CROSS JOIN products p2
WHERE	ABS(p1.unit_price - p2.unit_price) < 0.25
		AND p1.product_name < p2.product_name
ORDER BY `Price Diff` DESC;


-- Return the product id, product name, unit price, average unit price,
-- and the difference between each unit price and the average unit price
-- Order the results from most to least expensive
SELECT	product_id,
		product_name,
        unit_price,
        (SELECT AVG(unit_price) FROM products) AS Avg_Unit_Price,
        unit_price - (SELECT AVG(unit_price) FROM products) AS Price_Diff
FROM products
ORDER BY unit_price DESC;


-- Return the factories, product names from the factory
SELECT	factory, product_name
FROM products;

-- and number of products produced by each factory
SELECT * FROM products;

SELECT	factory,
        COUNT(product_id) `Number of Products`
FROM	products
GROUP BY	factory;


-- Same Result Using SubQueries
SELECT	fp.factory, fp.product_name, fn.num_products
FROM
(SELECT	factory, product_name
FROM	products) fp
LEFT JOIN
(SELECT	 factory, COUNT(product_id) AS num_products
FROM	 products
GROUP BY factory) fn
ON fp.factory = fn.factory
ORDER BY fp.factory, fp.product_name;


-- Give a list of products from the most to the least expensive, along with how much each differs from the average unit price
SELECT	* from products;

SELECT	product_name, unit_price,
		format((SELECT AVG(unit_price) FROM products),2) `Avg Unit Price`,
        format(unit_price - (SELECT AVG(unit_price) FROM products),2) `Price Diff From Avg`
FROM	products
ORDER BY	unit_price DESC;


-- Give a list of the factories, along with the names of the products they produce and the number of products they produce
SELECT sub1.factory, sub1.product_name, sub2.`Number of Products`
FROM
	(SELECT	factory, product_name
	FROM	products) sub1

LEFT JOIN

	(SELECT	factory,
			COUNT(product_id) `Number of Products`
	FROM	products
	GROUP BY	factory) sub2
ON sub1.factory = sub2.factory
ORDER BY sub1.factory;

-- Same result using INNER JOIN
SELECT sub1.factory, sub1.product_name, sub2.`Number of Products`
FROM
	(SELECT	factory, product_name
	FROM	products) sub1

INNER JOIN

	(SELECT	factory,
			COUNT(product_id) `Number of Products`
	FROM	products
	GROUP BY	factory) sub2
ON sub1.factory = sub2.factory
ORDER BY sub2.`Number of Products` DESC;


-- Return products where the unit price is less than
-- the unit price of all products from Wicked Choccy's
SELECT	*
FROM	products
WHERE	unit_price < 
		ALL(SELECT unit_price
		FROM	products
		WHERE	factory = 'Wicked Choccy''s');
        
        
