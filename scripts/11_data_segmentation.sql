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
