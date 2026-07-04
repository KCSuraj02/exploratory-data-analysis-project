/*  Which categories contribute the most to overall sales?  */

WITH category_sales AS (
	SELECT 
		dp.category,
		SUM(fs.sales_amount) AS total_sales
	FROM gold.fact_sales fs
	LEFT JOIN gold.dim_products dp
	ON fs.product_key = dp.product_key
	GROUP BY category )

SELECT 
	category,
	total_sales,
	SUM(total_sales) OVER () AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100 , 2),'%') AS sales_percentage
FROM category_sales
ORDER BY total_sales DESC
