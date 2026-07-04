/* Analyze the yearly performance of products by comparing each product's sales to both its average sales
   performance and the previous year's sales */

WITH yearly_product_sales AS (
	SELECT
		YEAR(fs.order_date) order_year,
		dp.product_name,
		SUM(fs.sales_amount) current_sales
	FROM gold.fact_sales fs
	LEFT JOIN gold.dim_products dp
	ON fs.product_key = dp.product_key
	WHERE YEAR(fs.order_date) IS NOT NULL
	GROUP BY YEAR(fs.order_date), dp.product_name
	)

SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) AS avg_product_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS average_difference,
	CASE WHEN (current_sales - AVG(current_sales) OVER (PARTITION BY product_name)) > 0 THEN 'Above Average'
		 WHEN (current_sales - AVG(current_sales) OVER (PARTITION BY product_name)) < 0 THEN 'Below Average'
		 ELSE 'Average'
	END performance_avg,
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_sales,
	(current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY product_name, order_year)) AS sales_difference,
	CASE WHEN (current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)) > 0 THEN 'Increasing'
		 WHEN (current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)) < 0 THEN 'Decreasing'
		 ELSE 'No Change'
	END sales_change
FROM yearly_product_sales
ORDER BY product_name, order_year
