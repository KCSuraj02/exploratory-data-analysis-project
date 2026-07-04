/* Segment products into cost ranges and count how many products fall into each segment */

WITH product_cost_range AS (
	SELECT 
		product_key,
		product_name,
		cost,
		CASE WHEN cost < 100 THEN 'Below 100'
			 WHEN cost < 500 THEN '100 - 500'
			 WHEN cost < 1000 THEN '500 - 1000'
			 ELSE 'Above 1000'
		END AS cost_range
	FROM gold.dim_products )

SELECT
	DISTINCT cost_range,
	COUNT(product_name) OVER (PARTITION BY cost_range) AS total_products
FROM product_cost_range
ORDER BY total_products DESC
	
/* 
	Group customers into three segments based on their spending behavior:
		- VIP: Customers with at least 12 months of history and spending more than $5,000.
		- Regular: Customers with at least 12 months of history but spending $5,000 or less.
		- New: Customers with a lifespan less than 12 months.
	And find the total number of customers by each group.
*/

WITH customer_status_segmentation AS (
	SELECT 
		fs.customer_key,
		SUM(fs.sales_amount) total_spending,
		MIN(fs.order_date) first_order,
		MAX(fs.order_date) last_order,
		CONCAT(DATEDIFF(MONTH, MIN(fs.order_date), MAX(fs.order_date)), ' months') lifespan,
		CASE WHEN SUM(fs.sales_amount) > 5000 AND DATEDIFF(MONTH, MIN(fs.order_date), MAX(fs.order_date)) >= 12 THEN 'VIP'
			 WHEN SUM(fs.sales_amount) <= 5000 AND DATEDIFF(MONTH, MIN(fs.order_date), MAX(fs.order_date)) >= 12 THEN 'Regular'
			 ELSE 'New'
		END customer_status
	FROM gold.fact_sales fs
	LEFT JOIN gold.dim_customers dc
	ON fs.customer_key = dc.customer_key
	GROUP BY fs.customer_key)

SELECT
	customer_status,
	COUNT(customer_key) total_customers
FROM customer_status_segmentation
GROUP BY customer_status
ORDER BY total_customers DESC
GO
------------------------------------------------OR---------------------------------------------------------------
WITH customer_spending AS (
	SELECT 
		fs.customer_key,
		SUM(fs.sales_amount) total_spending,
		MIN(fs.order_date) first_order,
		MAX(fs.order_date) last_order,
		DATEDIFF(MONTH, MIN(fs.order_date), MAX(fs.order_date)) lifespan
	FROM gold.fact_sales fs
	LEFT JOIN gold.dim_customers dc
	ON fs.customer_key = dc.customer_key
	GROUP BY fs.customer_key)

SELECT 
	customer_status,
	COUNT(customer_key) total_customers
FROM (
	SELECT
	customer_key,
		CASE WHEN total_spending > 5000 AND lifespan >= 12 THEN 'VIP'
			 WHEN total_spending <= 5000 AND lifespan >= 12 THEN 'Regular'
			 ELSE 'New'
		END customer_status	
	FROM customer_spending ) t
GROUP BY customer_status
GO
