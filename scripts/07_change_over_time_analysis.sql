SELECT
	YEAR(order_date) order_year,
	MONTH(order_date) order_month,
	SUM(quantity) total_quantity,
	COUNT(customer_key) total_customer,
	SUM(sales_amount) total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

-- OR

SELECT
	DATETRUNC(MONTH,order_date) order_date,
	SUM(quantity) total_quantity,
	COUNT(customer_key) total_customer,
	SUM(sales_amount) total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(MONTH,order_date)

-- OR 

SELECT
	FORMAT(order_date,'yyy-MM') order_date,
	SUM(quantity) total_quantity,
	COUNT(customer_key) total_customer,
	SUM(sales_amount) total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date,'yyy-MM') 
ORDER BY FORMAT(order_date,'yyy-MM') 
