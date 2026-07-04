-- Find the date of the first and last order
-- How many years of sales are available?
SELECT 
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(year,MIN(order_date),MAX(order_date)) AS order_range_years
FROM gold.fact_sales

-- Find the youngest and the oldest customer
SELECT
	MIN(birth_date) AS oldest_customer_birth_date,
	DATEDIFF(year,MIN(birth_date),GETDATE()) AS oldest_customer_age,
	MAX(birth_date) AS youngest_customer_birth_date,
	DATEDIFF(year,MAX(birth_date),GETDATE()) AS youngest_customer_age
FROM gold.dim_customers
