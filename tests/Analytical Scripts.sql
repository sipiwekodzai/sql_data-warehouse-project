/*
=============================================================================
  These queries demonstrate the analytical power of the star schema
  by answering key business questions about sales performance, customer
  behaviour and product trends.
=============================================================================
*/

USE DataWarehouse;
GO

-- =================================================================
-- Query 4.1: Total Sales Revenue by Product Category
-- total sales revenue (SUM of sales_amount) grouped by product category ordered by total revenue descending.
-- =================================================================
SELECT
    dp.category                             AS product_category,
    SUM(fs.sales_amount)                    AS total_revenue,
    COUNT(fs.order_number)                  AS total_orders
FROM gold.fact_sales fs
    INNER JOIN gold.dim_products dp
        ON fs.product_key = dp.product_key
GROUP BY
    dp.category
ORDER BY
    total_revenue DESC;

-- =================================================================
-- Query 4.2: Monthly Sales Trend
-- Purpose: returns total sales revenue and total quantity sold per month (YEAR and MONTH of order_date
-- =================================================================
SELECT
    YEAR(fs.order_date)                     AS order_year,
    MONTH(fs.order_date)                    AS order_month,
    SUM(fs.sales_amount)                    AS total_revenue,
    SUM(fs.quantity)                        AS total_quantity
FROM gold.fact_sales fs
WHERE fs.order_date IS NOT NULL
GROUP BY
    YEAR(fs.order_date),
    MONTH(fs.order_date)
ORDER BY
    order_year,
    order_month;


-- =================================================================
-- Query 4.3: Top 10 Products by Revenue
-- Purpose: List top 10 products (product_name) by total sales revenue
-- =================================================================
SELECT TOP 10
    dp.product_name                         AS product_name,
    dp.product_line                         AS product_line,
    SUM(fs.sales_amount)                    AS total_revenue,
    SUM(fs.quantity)                        AS total_quantity_sold
FROM gold.fact_sales fs
    INNER JOIN gold.dim_products dp
        ON fs.product_key = dp.product_key
GROUP BY
    dp.product_name,
    dp.product_line
ORDER BY
    total_revenue DESC;

-- =================================================================
-- Query 4.4: Customer Segmentation by Country
-- Purpose: the count of customers, total orders and total revenue grouped by country
-- =================================================================
SELECT
    dc.country                              AS country,
    COUNT(DISTINCT dc.customer_key)         AS customer_count,
    COUNT(fs.order_number)                  AS total_orders,
    SUM(fs.sales_amount)                    AS total_revenue
FROM gold.fact_sales fs
    INNER JOIN gold.dim_customers dc
        ON fs.customer_key = dc.customer_key
GROUP BY
    dc.country
ORDER BY
    total_revenue DESC;

-- =================================================================
-- Query 4.5: Average Order Value by Customer Gender
-- Average order value (sales_amount per order) for each gender category in gold.dim_customers
-- =================================================================
SELECT
    dc.gender                               AS gender,
    COUNT(fs.order_number)                  AS total_orders,
    AVG(fs.sales_amount)                    AS avg_order_value,
    SUM(fs.sales_amount)                    AS total_revenue
FROM gold.fact_sales fs
    INNER JOIN gold.dim_customers dc
        ON fs.customer_key = dc.customer_key
WHERE dc.gender <> 'n/a'           -- exclude records with unknown gender
GROUP BY
    dc.gender
ORDER BY
    avg_order_value DESC;

-- =================================================================
-- Query 4.6: Product Subcategory Profitability Analysis
-- Purpose: Calculate revenue, cost and profit margin per subcategory
--          to identify the most and least profitable product lines.
-- =================================================================
SELECT
    dp.subcategory                          AS subcategory,
    SUM(fs.sales_amount)                    AS total_revenue,
    SUM(dp.product_cost * fs.quantity)      AS total_cost,
    -- Profit margin %: guard against division by zero with NULLIF
    CAST(
        (SUM(fs.sales_amount) - SUM(dp.product_cost * fs.quantity))
        / NULLIF(SUM(fs.sales_amount), 0) * 100
    AS DECIMAL(5,2))                        AS profit_margin_pct
FROM gold.fact_sales fs
    INNER JOIN gold.dim_products dp
        ON fs.product_key = dp.product_key
GROUP BY
    dp.subcategory
ORDER BY
    profit_margin_pct DESC;

-- =================================================================
-- Query 4.7: Shipping Delay Analysis
-- Purpose: the average number of days between order_date and shipping_date (shipping delay in days) grouped by product category. 
-- Identify which category has the longest average shipping delay.
-- =================================================================
SELECT
    dp.category                             AS product_category,
    AVG(DATEDIFF(DAY, fs.order_date, fs.shipping_date))
                                            AS avg_shipping_delay_days,
    MIN(DATEDIFF(DAY, fs.order_date, fs.shipping_date))
                                            AS min_shipping_delay_days,
    MAX(DATEDIFF(DAY, fs.order_date, fs.shipping_date))
                                            AS max_shipping_delay_days,
    COUNT(fs.order_number)                  AS total_orders
FROM gold.fact_sales fs
    INNER JOIN gold.dim_products dp
        ON fs.product_key = dp.product_key
WHERE fs.order_date IS NOT NULL
  AND fs.shipping_date IS NOT NULL
GROUP BY
    dp.category
ORDER BY
    avg_shipping_delay_days DESC;
