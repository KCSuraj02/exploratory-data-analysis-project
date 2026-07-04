/*
-----------------------------------------------------------------------------------------------------------------
	** Customer Report **
-----------------------------------------------------------------------------------------------------------------
	Purpose:
		- This report consolidates key customer metrics and behaviors

	Highlights:
		1. Gather essential fields such as names, ages, and transaction details.
		2. Segments customers into categories (VIP, Regular, New) and age groups.
		3. Aggregate customer-level metrics:
			- total orders
			- total sales
			- total quantity purchased
			- total products
			- lifespan (in months)
		4. Calculate valuable KPIs:
			- recency (months since last order)
			- average order value
			- average monthly spend
*/
CREATE VIEW gold.report_customers AS
	WITH base_query AS (
		SELECT 
			fs.order_number,
			fs.product_key,
			fs.order_date,
			fs.sales_amount,
			fs.quantity,
			dc.customer_key,
			dc.customer_number,
			CONCAT(dc.first_name,' ',dc.last_name) customer_name,
			DATEDIFF(YEAR,dc.birth_date,GETDATE()) age
		FROM gold.fact_sales fs
		LEFT JOIN gold.dim_customers dc
		ON fs.customer_key = dc.customer_key
		WHERE fs.order_date IS NOT NULL )

	, customer_aggregation AS (
		SELECT 
			customer_key,
			customer_number,
			customer_name,
			age,
			COUNT(DISTINCT order_number) total_orders,
			SUM(sales_amount) total_sales,
			SUM(quantity) total_quantity,
			COUNT(DISTINCT product_key) total_products,
			MAX(order_date) last_order_date,
			DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) lifespan
		FROM base_query
		GROUP BY customer_key, customer_number, customer_name, age )

	SELECT 
		customer_key,
		customer_number,
		customer_name,
		age,
		CASE WHEN age < 20 THEN 'Under 20'
			 WHEN age between 20 and 29 THEN '20-29'
			 WHEN age between 30 and 39 THEN '30-39'
			 WHEN age between 40 and 49 THEN '40-49'
			 ELSE '50 or above'
		END age_group,
		CASE WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
			 WHEN total_sales <= 5000 AND lifespan >= 12 THEN 'Regular'
			 ELSE 'New'
		END customer_segment,
		DATEDIFF(MONTH,last_order_date,GETDATE()) recency, 
		total_orders,
		total_sales,
		total_quantity,
		total_products,
		last_order_date,
		lifespan,
		-- compute average order value (AVO)
		CASE WHEN total_orders = 0 THEN 0
			 ELSE total_sales / total_orders 
		END AS avg_order_value,
		-- compute average monthly spend
		CASE WHEN lifespan = 0 THEN total_sales
			 ELSE total_sales / lifespan
		END AS avg_monthly_spend
	FROM customer_aggregation
