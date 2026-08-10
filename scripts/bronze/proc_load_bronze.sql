/*
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
===============================================================================
*/



CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    SET @batch_start_time =GETDATE();
    BEGIN TRY
        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';

        SET @start_time=GETDATE();
        PRINT ' >> Truncating Table bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT '>> Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/import/datasets/source_crm/cust_info.csv'
        WITH(
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            TABLOCK
        )
        SET @end_time=GETDATE();
        PRINT '>>Load Duration: ' + CAST(DATEDIFF(second , @start_time,@end_time)AS NVARCHAR)+' seconds'
        PRINT '------------'
        SET @start_time=GETDATE();
        PRINT ' >> Truncating Table bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/import/datasets/source_crm/prd_info.csv'
        WITH(
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            TABLOCK
        )
        SET @end_time=GETDATE();
        PRINT '>>Load Duration: ' + CAST(DATEDIFF(second , @start_time,@end_time)AS NVARCHAR)+' seconds'
        PRINT '------------'
        SET @start_time=GETDATE();
        PRINT ' >> Truncating Table bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT '>> Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/import/datasets/source_crm/sales_details.csv'
        WITH(
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            TABLOCK
        )
        SET @end_time=GETDATE();
        PRINT '>>Load Duration: ' + CAST(DATEDIFF(second , @start_time,@end_time)AS NVARCHAR)+' seconds'
        PRINT '------------'
        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';
        SET @start_time=GETDATE();
        PRINT ' >> Truncating Table bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM '/var/opt/mssql/import/datasets/source_erp/CUST_AZ12.csv'
        WITH(
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            TABLOCK
        )
        SET @end_time=GETDATE();
        PRINT '>>Load Duration: ' + CAST(DATEDIFF(second , @start_time,@end_time)AS NVARCHAR)+' seconds'
        PRINT '------------'
        SET @start_time=GETDATE();
        PRINT ' >> Truncating Table bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/import/datasets/source_erp/LOC_A101.csv'
        WITH(
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            TABLOCK
        )
        SET @end_time=GETDATE();
        PRINT '>>Load Duration: ' + CAST(DATEDIFF(second , @start_time,@end_time)AS NVARCHAR)+' seconds'
        PRINT '------------'
        SET @start_time=GETDATE();
        PRINT '>> Truncating Table bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/import/datasets/source_erp/PX_CAT_G1V2.csv'
        WITH(
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            TABLOCK
        );
        SET @end_time=GETDATE();
        PRINT '>>Load Duration: ' + CAST(DATEDIFF(second , @start_time,@end_time)AS NVARCHAR) +' seconds'
        PRINT '------------'
        
       	SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
    END TRY
    BEGIN CATCH
        PRINT '-------------------------------------'
        PRINT 'Error Occured During loding Bronze Layer'
        PRINT 'Error Massage '+ ERROR_MESSAGE(); 
        PRINT 'Error Nubmer '+CAST(ERROR_NUMBER()AS NVARCHAR); 
        PRINT 'Error State '+CAST(ERROR_STATE()AS NVARCHAR);
        PRINT '-------------------------------------'
    END CATCH
END
