SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY DATETRUNC(YEAR,order_date)) running_total,
	average_price,
	AVG(average_price) OVER (ORDER BY DATETRUNC(YEAR,order_date)) moving_average_price
FROM (
	SELECT
		DATETRUNC(YEAR,order_date) order_date,
		SUM(sales_amount) total_sales,
		AVG(price) average_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR,order_date)) t
