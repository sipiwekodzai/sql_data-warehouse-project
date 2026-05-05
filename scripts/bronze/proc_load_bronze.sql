*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
BEGIN TRY
	PRINT '=================================================================================='
	PRINT 'Loading Bronze Layer'
	PRINT '=================================================================================='

	PRINT '----------------------------------------------------------------------------------'
	PRINT 'Loading CRM Tables'
	PRINT '----------------------------------------------------------------------------------'
	SET @start_time = GETDATE();
	PRINT '>> Truncating Table: bronze.crm_cust_info';

TRUNCATE TABLE bronze.crm_cust_info;
	PRINT '>> Inserting Data into Table : bronze.crm_cust_info';
BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\Test\Documents\1. SEMESTER 2\DSI 143\Data Warehouse  Assign\CRM\cust_info.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR)+ ' seconds';
	PRINT '>> ---------------------';

	SET @start_time = GETDATE();
	PRINT '>> Truncating Table: bronze.crm_prd_info';

TRUNCATE TABLE bronze.crm_prd_info;

PRINT '>> Inserting Data into Table : crm_prd_info';

BULK INSERT bronze.crm_prd_info
FROM 'C:\Users\Test\Documents\1. SEMESTER 2\DSI 143\Data Warehouse  Assign\CRM\prd_info.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);
	SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR)+ ' seconds';
		PRINT '>> ---------------------';
	PRINT '>> Truncating Table: bronze.crm_sales_details';
	
	SET @start_time = GETDATE();

	TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting Data into Table : crm_sales_details';

BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\Test\Documents\1. SEMESTER 2\DSI 143\Data Warehouse  Assign\CRM\sales_details.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);
	SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR)+ ' seconds';
		PRINT '>> ---------------------';
	PRINT '----------------------------------------------------------------------------------'
	PRINT 'Loading ERP Tables'
	PRINT '----------------------------------------------------------------------------------'
		SET @start_time = GETDATE();

	PRINT '>> Truncating Table: bronze.erp_loc_a101';

	TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting Data into Table : erp_loc_a101';
BULK INSERT bronze.erp_loc_a101
FROM 'C:\Users\Test\Documents\1. SEMESTER 2\DSI 143\Data Warehouse  Assign\ERP\loc_a101.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);
	SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR)+ ' seconds';
		PRINT '>> ---------------------';

	PRINT ' >> Truncating Table: bronze.erp_cust_az12';
	SET @start_time = GETDATE();

	TRUNCATE TABLE bronze.erp_cust_az12;

	PRINT '>> Inserting Data into Table : erp_cust_az12';
BULK INSERT bronze.erp_cust_az12
FROM 'C:\Users\Test\Documents\1. SEMESTER 2\DSI 143\Data Warehouse  Assign\ERP\cust_az12.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);
	SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR)+ ' seconds';
		PRINT '>> ---------------------';

	PRINT ' >> Truncating Table: bronze.erp_px_cat_g1v2';
	SET @start_time = GETDATE();

TRUNCATE TABLE bronze.erp_px_cat_g1v2;

PRINT '>> Inserting Data into Table : erp_px_cat_g1v2';
BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\Users\Test\Documents\1. SEMESTER 2\DSI 143\Data Warehouse  Assign\ERP\px_cat_g1v2.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);
	SET @end_time = GETDATE();
		
	   PRINT '>> ---------------------';
		SET @end_time = GETDATE();

		PRINT '======================================'
		PRINT 'Loading Bronze layer is Completed';
		PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '======================================'
	END TRY
	BEGIN CATCH
	PRINT '===================================================================================='
	
	PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
	PRINT 'Error Message ' + ERROR_MESSAGE();
	PRINT 'Error Message ' + CAST (ERROR_NUMBER () AS NVARCHAR);
	PRINT 'Error Message ' + CAST ( ERROR_STATE() AS NVARCHAR);

	PRINT '===================================================================================='
	END CATCH
	END
