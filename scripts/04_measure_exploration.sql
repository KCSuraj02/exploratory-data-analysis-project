-- Find the Total Sales
-- Find how many items are sold
-- Find the Average Selling Price
-- Find the Total Number of Orders
-- Find the Total Number of Customers that has place an order
-- Find the Total Number of Products
-- Find the Total Number of Customers

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Number of Items Sold' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Selling Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Number of Orders' AS measure_name, COUNT(DISTINCT(order_number)) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Number of Products' AS measure_name, COUNT(product_key) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Number of Customers' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers
UNION ALL
SELECT 'Total Number of Customers with order' AS measure_name, COUNT(DISTINCT(customer_key)) AS measure_value FROM gold.fact_sales
