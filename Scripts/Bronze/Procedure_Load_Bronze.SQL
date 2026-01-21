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
-- CREATE OR ALTER PROCEDURE 
 
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
    DECLARE @start_time DATETIME;
    DECLARE @end_time DATETIME;
    
    BEGIN TRY
        PRINT '==============================' ;
        PRINT 'Loading Bronze Layer Tables';
        PRINT '==============================';

        PRINT '------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------';

        SET @start_time = GETDATE();
        -- Bulk Insert Statements to load data into Bronze Layer Tables

        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info

        FROM 'C:\Users\Drishti Doshi\Desktop\Data Analytics\SQL\sql-ultimate-course\Project\Source_CRM\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Data Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
        PRINT '------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT '>> Inserting Data Into: bronze.crm_prd_info';

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\Drishti Doshi\Desktop\Data Analytics\SQL\sql-ultimate-course\Project\Source_CRM\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Data Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
        PRINT '------------------------------';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT '>> Inserting Data Into: bronze.crm_sales_details';

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\Drishti Doshi\Desktop\Data Analytics\SQL\sql-ultimate-course\Project\Source_CRM\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Data Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
        PRINT '------------------------------';

        PRINT '------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\Drishti Doshi\Desktop\Data Analytics\SQL\sql-ultimate-course\Project\Source_ERP\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Data Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
        PRINT '------------------------------';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\Drishti Doshi\Desktop\Data Analytics\SQL\sql-ultimate-course\Project\Source_ERP\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Data Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
        PRINT '------------------------------';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\Drishti Doshi\Desktop\Data Analytics\SQL\sql-ultimate-course\Project\Source_ERP\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Data Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
        PRINT '------------------------------';

    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while loading Bronze Layer Tables: ' + ERROR_MESSAGE() + CAST(ERROR_NUMBER() AS NVARCHAR(10));
    END CATCH

END 

EXEC bronze.load_bronze;

-- Claculate the duration of loading whole batch of Brionze Layer Tables
DECLARE @batch_start_time DATETIME;
DECLARE @batch_end_time DATETIME;
SET @batch_start_time = GETDATE();
EXEC bronze.load_bronze;
SET @batch_end_time = GETDATE();
PRINT 'Total Bronze Layer Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(10)) + ' seconds';

