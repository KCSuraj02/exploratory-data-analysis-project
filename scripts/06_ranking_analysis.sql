-- Which 5 products generate the highest revenue?

-- USING TOP N
SELECT TOP 5
	dp.product_name, 
	SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON fs.product_key = dp.product_key
GROUP BY dp.product_key, dp.product_name
ORDER BY total_revenue DESC

-- USING WINDOW FUNCTION
SELECT * FROM (
	SELECT
		dp.product_name, 
		SUM(fs.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS rank_product
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_products AS dp
	ON fs.product_key = dp.product_key
	GROUP BY dp.product_key, dp.product_name) t
WHERE rank_product <= 5


-- What are the 5 worst-performing products in terms of sales?

-- USING TOP N
SELECT TOP 5
	dp.product_name, 
	SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON fs.product_key = dp.product_key
GROUP BY dp.product_key, dp.product_name
ORDER BY total_revenue

-- USING WINDOW FUNCTION
SELECT * FROM (
	SELECT
		dp.product_name, 
		SUM(fs.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(fs.sales_amount)) AS rank_product
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_products AS dp
	ON fs.product_key = dp.product_key
	GROUP BY dp.product_key, dp.product_name) t
WHERE rank_product <= 5

-- Find the Top 10 customers who have generated the highest revenue

-- USING TOP N
SELECT TOP 10
	dc.customer_key,
	dc.first_name,
	dc.last_name,
	SUM(fs.sales_amount) AS	total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.first_name, dc.last_name
ORDER BY total_revenue DESC

-- USING WINDOW FUNCTION
SELECT * FROM (
	SELECT
		dc.customer_key,
		dc.first_name,
		dc.last_name,
		SUM(fs.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS rank_customer
	FROM gold.fact_sales fs
	LEFT JOIN gold.dim_customers dc
	ON fs.customer_key = dc.customer_key
	GROUP BY dc.customer_key, dc.first_name, dc.last_name) t
WHERE rank_customer <= 10



-- Find the 3 customers with the fewest orders placed

-- USING TOP N
SELECT TOP 3
	dc.customer_key,
	dc.first_name,
	dc.last_name,
	COUNT(DISTINCT order_number) AS total_order
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.first_name, dc.last_name
ORDER BY total_order

-- USING WINDOW FUNCTION
SELECT * FROM (
	SELECT
		dc.customer_key,
		dc.first_name,
		dc.last_name,
		COUNT(DISTINCT order_number) total_order,
		ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT order_number)) AS rank_customer
	FROM gold.fact_sales fs
	LEFT JOIN gold.dim_customers dc
	ON fs.customer_key = dc.customer_key
	GROUP BY dc.customer_key, dc.first_name, dc.last_name) t
WHERE rank_customer <= 3
