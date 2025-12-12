CREATE	DATABASE	ecommerce;
USE	ecommerce;
SHOW TABLES;

-- Converting all datetime columns to DATE to normalize the schema, since the time component isn’t needed.
ALTER TABLE orders
MODIFY	order_date DATE;

ALTER TABLE	reviews
MODIFY	review_date DATE;

ALTER TABLE customers
MODIFY	registration_date DATE;

-- Data Exploration to understand the tables
SELECT	*	FROM	customers;
SELECT	*	FROM	order_details;
SELECT	*	FROM	orders;
SELECT	*	FROM	products;
SELECT	*	FROM	reviews;
SELECT	*	FROM	suppliers;


-- QUESTION 1: List all customers from California
DESCRIBE	customers;
SELECT	*
FROM	customers
WHERE	state	=	'CA';

-- QUESTION 2: Find products in Electronics category
DESCRIBE	products;
SELECT	product_name, category
FROM	products
WHERE	category LIKE '%elect%'
ORDER BY	product_name;

-- QUESTION 3: Show products with price over $100
DESCRIBE	products;
SELECT	product_name, price
FROM	products
WHERE	price > 100
ORDER BY price;

-- QUESTION 4: How many orders have been generated so far
DESCRIBE	orders;
SELECT	COUNT(DISTINCT order_id) total_orders,
		SUM(IF(order_id > 0, 1, 0)) AS orders_total
FROM	orders;


-- QUESTION 5: Show customers with order totals
DESCRIBE	customers;
DESCRIBE	orders;

SELECT	CONCAT_WS(' ', c.first_name, c.last_name) AS Customer_Name, SUM(o.order_id) as Order_Totals
FROM	customers c	INNER JOIN	orders o
ON		c.customer_id = o.customer_id
GROUP BY	Customer_Name
ORDER BY	Order_Totals DESC;


-- QUESTION 6: List products with supplier names
DESCRIBE	products;
DESCRIBE	suppliers;

SELECT	p.product_name, s.supplier_name
FROM	products p	LEFT JOIN	suppliers s
ON		p.supplier_id = s.supplier_id
ORDER BY	product_name, supplier_name;


-- QUESTION 7: Find customers who never ordered
DESCRIBE	customers;
DESCRIBE	orders;

SELECT	CONCAT_WS(' ', c.first_name, c.last_name) AS Customer_Name, IFNULL(o.order_id, 'Never Ordered') AS Order_Status
FROM	customers c	LEFT JOIN	orders o
ON		c.customer_id = o.customer_id
WHERE	order_id IS NULL;


-- QUESTION 8: Total revenue by month
DESCRIBE	orders;
DESCRIBE	order_details;

SELECT	status	FROM	orders GROUP BY status;		-- Checking the status column to determine how many categories are available

SELECT	*	FROM	orders	LIMIT 5;

SELECT	EXTRACT(MONTH FROM order_date) AS Month,
		DATE_FORMAT(order_date, '%M') AS Month_Name,
        ROUND(SUM(total_amount), 2) AS 'Total_Revenue (Completed Orders)'
FROM	orders
WHERE	status LIKE '%complete%'
GROUP BY	EXTRACT(MONTH FROM order_date), DATE_FORMAT(order_date, '%M')
ORDER BY	Month;


-- QUESTION 9: Top 10 customers by spending
DESCRIBE	orders;
DESCRIBE	customers;

SELECT	CONCAT_WS(' ', c.first_name, c.last_name) AS Customer_Name,
		o.total_amount
FROM	orders o	INNER JOIN	customers c
ON		o.customer_id = c.customer_id
WHERE	o.status LIKE '%completed%'
ORDER BY	total_amount DESC
LIMIT 10;


-- QUESTION 10: Products with overall ratings above 4
SELECT	TABLE_NAME	FROM	INFORMATION_SCHEMA.COLUMNS	WHERE	COLUMN_NAME = 'rating' AND		TABLE_SCHEMA = 'ecommerce'; #Check all columns withthe name "rating"
DESCRIBE	reviews;
#SELECT	Distinct * FROM	products	ORDER BY	product_name LIMIT 5;

# Solution
SELECT	p.product_id, p.product_name, p.category, p.price,
		ROUND(AVG(r.rating),2) AS Avg_Rating,
        COUNT(r.review_id) AS Total_Reviews
FROM	products p INNER JOIN reviews r
ON		p.product_id = r.product_id
GROUP BY	p.product_id, p.product_name, p.category, p.price
HAVING		ROUND(AVG(r.rating),2) >= 4
ORDER BY	Avg_Rating DESC;

SELECT	*	FROM	reviews	WHERE	product_id = 7;

-- QUESTION 11: Customer Cohort Analysis
DESCRIBE	customers;
DESCRIBE	orders;

SELECT	DATE_FORMAT(c.registration_date, '%Y-%m') AS Cohort_Month,
		COUNT(DISTINCT c.customer_id) AS Customers_in_Cohort,
        ROUND(SUM(o.total_amount)) 'Total Revenue',
        ROUND(AVG(o.total_amount)) AS 'Average Order Value',
        COUNT(DISTINCT o.order_id) AS 'Total Orders'
FROM	customers c	LEFT JOIN	orders o
ON		c.customer_id = o.customer_id
GROUP BY	DATE_FORMAT(c.registration_date, '%Y-%m')
ORDER BY	Cohort_Month;


-- QUESTION 12: Month on Month Customer Cohort Retention after Registration
DESCRIBE	customers;
DESCRIBE	orders;

WITH cohort AS (
				SELECT	customer_id,
						DATE_FORMAT(registration_date, '%Y-%m') AS cohort_month,
						registration_date
				FROM	customers
                ),
	customer_orders AS (
						SELECT	c.customer_id,
								c.cohort_month,
                                c.registration_date,
                                o.order_date,
                                o.total_amount,
                                TIMESTAMPDIFF(MONTH, c.registration_date, o.order_date) Months_Since_Reg
						FROM	cohort c	LEFT JOIN	orders o
                        ON		c.customer_id = o.customer_id
                        )
                        
SELECT	cohort_month,
		Months_Since_Reg,
		COUNT(DISTINCT customer_id) AS Active_Customers,
        ROUND(SUM(total_amount)) AS Revenue
FROM	customer_orders
WHERE	Months_Since_Reg >= 0
AND		cohort_month LIKE '%2024%'
GROUP BY	cohort_month, Months_Since_Reg;


-- Month on Month Retention Rate
WITH monthly_customers AS (
							SELECT
								DATE_FORMAT(order_date, '%Y-%m') AS order_month,
                                customer_id,
                                SUM(total_amount) total_amount
							FROM	orders
                            GROUP BY	DATE_FORMAT(order_date, '%Y-%m'), customer_id
						),
	retained_customers AS (
							SELECT
								m.order_month,
                                ROUND(SUM(m.total_amount)) AS Revenue,
                                ROUND(SUM(mm.total_amount)) AS Revenue2,
								COUNT(DISTINCT m.customer_id) AS Current_Customers,
                                COUNT(DISTINCT mm.customer_id) AS Retained_Customers
							FROM	monthly_customers m LEFT JOIN monthly_customers mm
                            ON		m.customer_id = mm.customer_id
                            AND		mm.order_month = DATE_FORMAT(DATE_SUB(STR_TO_DATE(CONCAT(m.order_month, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH), '%Y-%m')
                            GROUP BY	m.order_month
                            )

SELECT	order_month AS Month,
		Current_Customers,
		Retained_Customers,
        IFNULL(ROUND(Retained_Customers / LAG(Current_Customers) OVER(ORDER BY order_month) * 100, 2), 100) AS 'Retention_Rate (%)',
        Revenue,
        IFNULL(Revenue2, 0) `Revenue From Retained Customers`
FROM	retained_customers
ORDER BY	Month;


-- QUESTION 14: Customers with repeat purchase (bought more than once) within the same month
WITH customer_order_counts AS (
    SELECT 
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m') AS Months,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id, DATE_FORMAT(order_date, '%Y-%m')
)

SELECT 
	Months,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_purchase,
    ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS repeat_rate_pct
FROM customer_order_counts
GROUP BY	Months
ORDER BY	Months;


-- QUESTION 16: Products bought together
SELECT	*	FROM	order_details LIMIT 5;

SELECT	p.product_name,
        pp.product_name,
        COUNT(*) AS times_bought_together
FROM	order_details o	INNER JOIN	order_details oo
ON		o.order_id = oo.order_id
AND		o.product_id < oo.product_id
JOIN	products p		ON		o.product_id = p.product_id
JOIN	products pp		ON		oo.product_id = pp.product_id
GROUP BY	p.product_id, p.product_name, pp.product_id, pp.product_name;

# A simpler alternative to Products bought together with group_concat
SELECT	o.order_id,
		GROUP_CONCAT(product_name ORDER BY product_name SEPARATOR ' > ') AS products_in_pair,
        COUNT(*) AS Count_of_Products
FROM	order_details o	JOIN	products p
ON		o.product_id = p.product_id
GROUP BY	order_id;


-- QUESTION 17: Products frequently bought together
WITH products AS ( SELECT	o.order_id,
		GROUP_CONCAT(product_name ORDER BY product_name SEPARATOR ', ') AS product_list,
        COUNT(DISTINCT o.product_id) Number_of_items_bought_together
FROM	order_details o	INNER JOIN	products p
ON		o.product_id = p.product_id
GROUP BY	order_id)

SELECT	product_list,
		Number_of_items_bought_together,
		COUNT(*) Frequency
FROM	products
WHERE	Number_of_items_bought_together > 1
GROUP BY	product_list, Number_of_items_bought_together
ORDER BY	frequency DESC;



-- QUESTION 18: RFM Analysis (Recency, Frequency & Monetary)
SELECT	customer_id,
		DATEDIFF((SELECT MAX(order_date) FROM orders), MAX(order_date)) AS Recency,
        COUNT(DISTINCT order_id) AS Frequency,
		SUM(total_amount) AS Monetary
FROM	orders
GROUP BY	customer_id
ORDER BY	Frequency DESC;

SELECT	customer_id, MAX(order_date), DATE_SUB(MAX(order_date), INTERVAL 180 DAY), DATEDIFF(MAX(order_date), DATE_SUB(MAX(order_date), INTERVAL 180 DAY))
FROM	orders
GROUP BY	customer_id;


-- QUESTION 19: Customer Lifetime Value (CLV) - By State
DESCRIBE	customers;
SELECT	c.state,
		COUNT(DISTINCT c.customer_id) Total_Customers,
        ROUND(AVG(customer_order_value.total_spent)) AS Average_CLV,
        ROUND(SUM(customer_order_value.total_spent)) Total_CLV,
        ROUND(AVG(customer_order_value.order_count)) AS Average_Order_Count
FROM	customers c	
LEFT JOIN	(SELECT customer_id, COUNT(*) AS order_count, SUM(total_amount) AS total_spent
			 FROM orders
			 GROUP BY customer_id) AS customer_order_value 
ON		c.customer_id = customer_order_value.customer_id
GROUP BY	c.state
ORDER BY	Total_CLV DESC;


-- QUESTION 19: Customer Lifetime Value (CLV) - By State & City
DESCRIBE	customers;

SELECT	c.State, c.City,
		COUNT(DISTINCT c.customer_id) Total_Customers,
        ROUND(AVG(customer_order_value.total_spent)) AS Average_CLV,
        ROUND(SUM(customer_order_value.total_spent)) Total_CLV,
        ROUND(AVG(customer_order_value.order_count)) AS Average_Order_Count
FROM	customers c	
LEFT JOIN	(SELECT customer_id, COUNT(*) AS order_count, SUM(total_amount) AS total_spent
			 FROM orders
			 GROUP BY customer_id) AS customer_order_value 
ON		c.customer_id = customer_order_value.customer_id
GROUP BY	c.state, c.City
ORDER BY	c.state, c.City;


-- QUESTION 20: Customer Churn (Identifying customers who have not ordered recently)
WITH last_ordered AS (SELECT	customer_id,
							MAX(order_date) last_order_date,
							DATEDIFF((SELECT MAX(order_date) FROM orders), MAX(order_date)) AS days_since_last_ordered
					FROM	orders
					GROUP BY	customer_id),

	period AS (SELECT	*,
						CASE WHEN (days_since_last_ordered <= 30) THEN '0 - 30'
							 WHEN (days_since_last_ordered <= 60) THEN '31 - 60'
							 WHEN (days_since_last_ordered <= 90) THEN '61 - 90'
							 WHEN (days_since_last_ordered <= 180) THEN '91 - 180'
						ELSE 'Over 180 Days (Customer Churned)'
						END AS Inactivity_period
				FROM	last_ordered)

SELECT	p.customer_id,
		CONCAT_WS(' ',c.first_name, c.last_name) Customer_Name,
        last_order_date,
		days_since_last_ordered,
        Inactivity_period
FROM	period p	LEFT JOIN	customers c
ON		p.customer_id = c.customer_id
WHERE	Inactivity_period LIKE '%churn%'
;



WITH last_ordered AS (SELECT	customer_id,
							MAX(order_date) last_order_date,
							DATEDIFF((SELECT MAX(order_date) FROM orders), MAX(order_date)) AS days_since_last_ordered
					FROM	orders
					GROUP BY	customer_id)

SELECT	
		CASE WHEN (days_since_last_ordered <= 30) THEN '0 - 30'
			 WHEN (days_since_last_ordered <= 60) THEN '31 - 60'
			 WHEN (days_since_last_ordered <= 90) THEN '61 - 90'
			 WHEN (days_since_last_ordered <= 180) THEN '91 - 180'
		ELSE 'Over 180 Days (Customer Churned)'
		END AS Inactivity_period,
        COUNT(*) Customer_Count
FROM	last_ordered
GROUP BY	CASE	WHEN (days_since_last_ordered <= 30) THEN '0 - 30'
					WHEN (days_since_last_ordered <= 60) THEN '31 - 60'
					WHEN (days_since_last_ordered <= 90) THEN '61 - 90'
					WHEN (days_since_last_ordered <= 180) THEN '91 - 180'
			ELSE 'Over 180 Days (Customer Churned)'
			END;
            
            
-- QUESTION 21: Customer Churn (Monthly)
WITH monthly_customers AS (SELECT	DATE_FORMAT(order_date, '%Y-%m') AS CurrMonth,
								customer_id
						  FROM	orders
						  GROUP BY	currMonth, customer_id)

SELECT	curr.currMonth,
		COUNT(curr.customer_id) AS current_month_customers,
        COUNT(prev.customer_id) AS previous_month_customers,
        SUM(prev.customer_id IS NULL) AS Customers_Lost
FROM	monthly_customers curr	LEFT JOIN	monthly_customers	prev
ON		curr.customer_id = prev.customer_id
AND		prev.currmonth = DATE_FORMAT(DATE_SUB(STR_TO_DATE(CONCAT(curr.currmonth, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH), '%Y-%m')
GROUP BY	curr.currMonth
ORDER BY	curr.currMonth;




WITH monthly_customers AS (SELECT	DATE_FORMAT(order_date, '%Y-%m') AS CurrMonth,
								customer_id
						  FROM	orders
						  GROUP BY	currMonth, customer_id),

	churned AS (SELECT	prev.currMonth AS Month,
		COUNT(DISTINCT prev.customer_id) AS previous_month_customers,
        COUNT(DISTINCT curr.customer_id) AS retained_customers,
        SUM(curr.customer_id IS NULL) AS Customers_Lost
FROM	monthly_customers prev	LEFT JOIN	monthly_customers	curr
ON		prev.customer_id = curr.customer_id
AND		prev.currmonth = DATE_FORMAT(DATE_ADD(STR_TO_DATE(CONCAT(curr.currmonth, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH), '%Y-%m')
GROUP BY	prev.currMonth
ORDER BY	prev.currMonth)


SELECT	Month,
		previous_month_customers,
        Retained_Customers,
        Customers_Lost,
        ROUND(Customers_Lost/previous_month_customers * 100, 2) AS Churn_Rate
FROM churned;



-- QUESTION 22: Supplier Performance (Monthly, Number of Products, Number of Orders, Sales Volume, Revenue Generated)
WITH sup_analysis AS (SELECT	DATE_FORMAT(o.order_date, '%Y-%m') Month,
							supplier_name,
							COUNT(DISTINCT p.product_id) NumProducts,
							COUNT(DISTINCT od.order_id) NumOrders,
							SUM(quantity) SalesVolume,
							ROUND(SUM(line_total)) RevenueGenerated,
							DENSE_RANK() OVER(PARTITION BY DATE_FORMAT(o.order_date, '%Y-%m') ORDER BY ROUND(SUM(line_total)) DESC) AS rnk
					FROM	products p
					LEFT JOIN suppliers s
					ON		p.supplier_id = s.supplier_id
					LEFT JOIN	order_details od
					ON			p.product_id = od.product_id
					LEFT JOIN	orders o
					ON			od.order_id = o.order_id
					GROUP BY	Month, supplier_name)

SELECT	Month,
		supplier_name,
        NumProducts,
        NumOrders,
        SalesVolume,
        RevenueGenerated
FROM	sup_analysis;


SELECT * FROM products LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_details LIMIT 5;
SELECT * FROM suppliers LIMIT 100;


-- QUESTION 23: Slow-Moving Products (Products with high stock but low sales within the last 30 days)
SELECT	p.product_id,
		p.product_name,
        p.stock_quantity,
        COALESCE(SUM(od.quantity),0) Quantity_Sold,
        COALESCE(SUM(CASE WHEN o.order_date >= DATE_SUB((SELECT MAX(order_date) FROM orders), INTERVAL 30 DAY)
				 THEN od.quantity ELSE 0 END), 0) AS Quantity_Sold_Last_30_Days,
        DATEDIFF((SELECT MAX(order_date) FROM orders), MAX(order_date)) AS dt_diff
FROM	products p
LEFT JOIN	order_details od
ON			p.product_id = od.product_id
LEFT JOIN	orders o
ON			od.order_id = o.order_id
WHERE		p.stock_quantity >= 350
GROUP BY	p.product_id, p.product_name, p.stock_quantity
HAVING		Quantity_Sold_Last_30_Days <= 150 AND dt_diff <= 30;



-- QUESTION 24: Customer Purchase Journey (First Order, Most Recent Order, Total Orders, Total Spent, Average Time Between Orders)
SELECT	o.customer_id,
		CONCAT_WS(' ', first_name, last_name) Customer_Name,
		MIN(order_date) First_Order_Date, MAX(order_date) Last_Order_Date,
		COUNT(*) Total_Orders,
        ROUND(SUM(total_amount)) Total_Spent,
        CASE
			WHEN (COUNT(*) = 1) THEN 0
		ELSE	ROUND(DATEDIFF(MAX(order_date), MIN(order_date)) / (COUNT(*) - 1)) 
		END AS Average_Time_Between_Orders
FROM	orders o	LEFT JOIN	customers c
ON		o.customer_id = c.customer_id
GROUP BY	o.customer_id, customer_name;


/*
# Alternative solution is multiplying the total orders by itself and the total_spent is multiplying by an equivalent amount
SELECT	o.customer_id,
		MIN(o.order_date) First_Order_Date, MAX(o.order_date) Last_Order_Date,
		COUNT(o.order_id) Total_Orders,
        SUM(o.total_amount) Total_Spent,
		ROUND(AVG(days_since_last_order)) Average_Time_Between_Orders
FROM	orders o LEFT JOIN	
		(SELECT customer_id,
				order_date,
				LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
				DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_since_last_order
		FROM orders) s
ON	o.customer_id = s.customer_id
GROUP BY	o.customer_id;


# Alternative solution is multiplying the total orders by itself and the total_spent is multiplying by an equivalent amount
WITH order_gaps AS (
    SELECT 
        customer_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
        DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_since_last_order
    FROM orders
)

SELECT  
    o.customer_id,
    MIN(o.order_date) AS First_Order_Date,
    MAX(o.order_date) AS Last_Order_Date,
    COUNT(o.order_id) AS Total_Orders,
    ROUND(SUM(o.total_amount), 2) AS Total_Spent,
   ROUND(AVG(og.days_since_last_order), 1) AS Avg_Days_Between_Orders
FROM orders o
LEFT JOIN order_gaps og ON o.customer_id = og.customer_id
GROUP BY o.customer_id;
*/


-- Revenue and Number of Customers By State
DESCRIBE	orders;
DESCRIBE	customers;

SELECT	state,
		COUNT(c.customer_id) Num_of_Customers,
		ROUND(SUM(o.total_amount)) Total_Revenue_Generated
FROM	customers c	JOIN	orders o
ON		c.customer_id = o.customer_id
GROUP BY	state
ORDER BY	Num_of_Customers DESC;


-- Revenue and Number of Customers By City
SELECT	state, city,
		COUNT(c.customer_id) Num_of_Customers,
		ROUND(SUM(o.total_amount)) Total_Revenue_Generated
FROM	customers c	JOIN	orders o
ON		c.customer_id = o.customer_id
GROUP BY	state, city
ORDER BY	state, city, Total_Revenue_Generated DESC;


-- Products with Declining Ratings. Compare recent ratings (last 3 months) vs older ratings. (Find products getting worse reviews now)
WITH recent_reviews AS (SELECT	product_id,
							AVG(rating) recent_review
					FROM	reviews
					WHERE	review_date >= DATE_SUB((SELECT MAX(review_date) FROM reviews), INTERVAL 3 MONTH)
					GROUP BY	product_id),

	older_reviews AS (SELECT	product_id,
							AVG(rating) older_review
					FROM	reviews
					WHERE	review_date < DATE_SUB((SELECT MAX(review_date) FROM reviews), INTERVAL 3 MONTH)
					GROUP BY	product_id)

SELECT	r.product_id, older_review, recent_review,
        CASE
			WHEN	(recent_review - older_review) > 0 THEN 'Improved'
            WHEN	(recent_review - older_review) = 0 THEN 'Stable'
            ELSE	'Declined'
		END	AS Review_Classification
FROM	recent_reviews r JOIN older_reviews o
ON	r.product_id = o.product_id
ORDER BY	r.product_id ASC;


-- Cleaner and Faster approach
WITH cut AS (SELECT	DATE_SUB(MAX(review_date), INTERVAL 3 MONTH) AS cut_off
					FROM	reviews),

	older_reviews AS (SELECT	product_id,
								AVG(CASE WHEN review_date >= (SELECT cut_off FROM cut) THEN rating END) AS recent_review,
                                AVG(CASE WHEN review_date < (SELECT cut_off FROM cut) THEN rating END) AS older_review
					FROM	reviews
					GROUP BY	product_id)

SELECT	product_id, older_review, recent_review,
        CASE
			WHEN	(recent_review - older_review) > 0 THEN 'Improved'
            WHEN	(recent_review - older_review) = 0 THEN 'Stable'
            ELSE	'Declined'
		END	AS Review_Classification
FROM	older_reviews
ORDER BY	product_id ASC;