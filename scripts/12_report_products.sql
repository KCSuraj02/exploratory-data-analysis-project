/*
-----------------------------------------------------------------------------------------------------------------
	** Product Report **
-----------------------------------------------------------------------------------------------------------------
	Purpose:
		- This report consolidates key product metrics and behaviors

	Highlights:
		1. Gather essential fields such as product names, category, subcategory, and cost.
		2. Segments product by revenue to identity High-Performers, Mid-Range, or Low-Performers.
		3. Aggregate customer-level metrics:
			- total orders
			- total sales
			- total quantity sold
			- total customers (unique)
			- lifespan (in months)
		4. Calculate valuable KPIs:
			- recency (months since last order)
			- average order revenue (AOR)
			- average monthly revenue
*/
GO
CREATE VIEW gold.report_product AS
	WITH base_query AS (
		SELECT 
			dp.product_key,
			dp.product_name,
			dp.category,
			dp.subcategory,
			dp.cost,
			fs.order_number,
			fs.sales_amount,
			fs.quantity,
			fs.customer_key,
			fs.order_date
		FROM gold.fact_sales fs
		LEFT JOIN gold.dim_products dp
		ON fs.product_key = dp.product_key
		WHERE order_date IS NOT NULL)

	, product_aggregation AS (
		SELECT 
			product_key,
			product_name,
			category,
			subcategory,
			cost,
			COUNT(DISTINCT order_number) total_orders,
			SUM(sales_amount) total_sales,
			SUM(quantity) total_quantity_sold,
			COUNT(DISTINCT customer_key) total_customers,
			MAX(order_date)	last_order_date,
			DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) lifespan
		FROM base_query
		GROUP BY product_name, category, subcategory, product_key, cost )

	SELECT 
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		last_order_date,
		total_orders,
		total_sales,
		total_quantity_sold,
		total_customers,
		lifespan,
		CASE WHEN total_sales < 500000 THEN 'Low-Performers'
			 WHEN total_sales between 500000 and 1000000 THEN 'Mid-Range'
			 ELSE 'High-Performers'
		END AS product_segment,
		DATEDIFF(MONTH, last_order_date, GETDATE()) recency,
		-- average order revenue (AOR)
		CASE WHEN total_orders = 0 THEN 0
			 ELSE total_sales / total_orders
		END AS avg_order_revenue,
		-- average monthly revenue
		CASE WHEN lifespan = 0 then total_sales
			 ELSE total_sales / lifespan 
		END AS avg_monthly_revenue
	FROM product_aggregation
