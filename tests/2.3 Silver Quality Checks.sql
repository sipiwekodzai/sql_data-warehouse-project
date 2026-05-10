/*
=============================================================================
  Script:     2.3 Silver Quality Checks
  Purpose:    Data quality validation queries to run against Silver tables
              after the silver.load_silver procedure has completed.
  
=============================================================================
*/

USE DataWarehouse;
GO

-- =================================================================
-- Duplicate and NULL check on silver.crm_cust_info
-- After deduplication, no cst_id should appear more than once,
-- and no cst_id should be NULL.
-- Expected result: 0 rows (all duplicates and NULLs resolved).
-- =================================================================
PRINT '>> CHECK 1: Duplicate / NULL check on crm_cust_info';

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
GO


-- =================================================================
-- NULL check on primary/foreign key columns
-- Ensures no key columns have NULL values across all six Silver
-- tables. 
-- =================================================================
PRINT '>> CHECK 2: NULL key columns across all Silver tables';

-- 2a. crm_cust_info — cst_id should never be NULL
SELECT 'silver.crm_cust_info' AS table_name, 'cst_id' AS column_name, COUNT(*) AS null_count
FROM silver.crm_cust_info WHERE cst_id IS NULL
UNION ALL
-- 2b. crm_prd_info — prd_id and prd_key should never be NULL
SELECT 'silver.crm_prd_info', 'prd_id', COUNT(*)
FROM silver.crm_prd_info WHERE prd_id IS NULL
UNION ALL
SELECT 'silver.crm_prd_info', 'prd_key', COUNT(*)
FROM silver.crm_prd_info WHERE prd_key IS NULL
UNION ALL
-- 2c. crm_sales_details — order number, product key and customer ID
SELECT 'silver.crm_sales_details', 'sls_ord_num', COUNT(*)
FROM silver.crm_sales_details WHERE sls_ord_num IS NULL
UNION ALL
SELECT 'silver.crm_sales_details', 'sls_prd_key', COUNT(*)
FROM silver.crm_sales_details WHERE sls_prd_key IS NULL
UNION ALL
SELECT 'silver.crm_sales_details', 'sls_cust_id', COUNT(*)
FROM silver.crm_sales_details WHERE sls_cust_id IS NULL
UNION ALL
-- 2d. erp_cust_az12 — cid
SELECT 'silver.erp_cust_az12', 'cid', COUNT(*)
FROM silver.erp_cust_az12 WHERE cid IS NULL
UNION ALL
-- 2e. erp_loc_a101 — cid
SELECT 'silver.erp_loc_a101', 'cid', COUNT(*)
FROM silver.erp_loc_a101 WHERE cid IS NULL
UNION ALL
-- 2f. erp_px_cat_g1v2 — id
SELECT 'silver.erp_px_cat_g1v2', 'id', COUNT(*)
FROM silver.erp_px_cat_g1v2 WHERE id IS NULL;
GO


-- =================================================================
-- Date logic check on silver.crm_sales_details
-.
-- =================================================================
PRINT '>> CHECK 3: Order date vs. ship date logic check';

SELECT
    sls_ord_num     AS order_number,
    sls_order_dt    AS order_date,
    sls_ship_dt     AS shipping_date,
    DATEDIFF(DAY, sls_order_dt, sls_ship_dt) AS days_diff
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
  AND sls_order_dt IS NOT NULL
  AND sls_ship_dt  IS NOT NULL;
GO


-- =================================================================
-- Referential integrity check
-- Every product key in the sales table should have a corresponding
-- record,all product keys are valid.
-- =================================================================
PRINT '>> CHECK 4: Referential integrity — sales product keys vs. product master';

SELECT DISTINCT
    sd.sls_prd_key      AS orphaned_product_key
FROM silver.crm_sales_details sd
    LEFT JOIN silver.crm_prd_info pdi
        ON sd.sls_prd_key = pdi.prd_key
WHERE pdi.prd_key IS NULL;
GO


-- =================================================================
-- Verify that sls_sales approximately equals sls_quantity * sls_price
-- for all rows. A small tolerance accounts for rounding.
-- =================================================================
PRINT '>> CHECK 5: Sales amount consistency (qty * price = sales)';

SELECT
    sls_ord_num,
    sls_sales,
    sls_quantity,
    sls_price,
    sls_quantity * sls_price AS calculated_sales,
    ABS(sls_sales - (sls_quantity * sls_price)) AS discrepancy
FROM silver.crm_sales_details
WHERE ABS(sls_sales - (sls_quantity * sls_price)) > 1   -- tolerance of 1 for rounding
  AND sls_sales IS NOT NULL
  AND sls_quantity IS NOT NULL
  AND sls_price IS NOT NULL;
GO

PRINT '>> All quality checks completed. Review results above.';
GO
