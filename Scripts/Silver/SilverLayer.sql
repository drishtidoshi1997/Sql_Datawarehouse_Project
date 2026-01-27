USE master


/* -- Load table names under schema 'bronze'
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_TYPE = 'BASE TABLE';
GO

SELECT DB_NAME() AS current_database;
GO
SELECT name
FROM sys.schemas
WHERE name = 'bronze'; */


/*-- delete all tables in silver schema
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_TYPE = 'BASE TABLE';

DROP TABLE silver.crm_cust_info;
DROP TABLE silver.crm_prd_info;
DROP TABLE silver.crm_sales_details;
DROP TABLE silver.erp_loc_a101;
DROP TABLE silver.erp_cust_az12;
DROP TABLE silver.erp_px_cat_g1v2;
*/

SELECT name 
FROM sys.schemas;

-- Create Tables in Silver Schema
CREATE TABLE silver.crm_cust_info (
    cst_id INT ,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE ,
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);

CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

CREATE TABLE silver.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

CREATE TABLE silver.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
-- List all tables in the DataWarehouse database
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;
GO

 -- CREATE OR ALTER PROCEDURE 
 
CREATE OR ALTER PROCEDURE silver.load_bronze AS 
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

        PRINT '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: silver.crm_cust_info';
        BULK INSERT silver.crm_cust_info

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
        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>> Inserting Data Into: silver.crm_prd_info';

        BULK INSERT silver.crm_prd_info
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
        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> Inserting Data Into: silver.crm_sales_details';

        BULK INSERT silver.crm_sales_details
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
        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> Inserting Data Into: silver.erp_cust_az12';

        BULK INSERT silver.erp_cust_az12
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
        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> Inserting Data Into: silver.erp_loc_a101';

        BULK INSERT silver.erp_loc_a101
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
        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';

        BULK INSERT silver.erp_px_cat_g1v2
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

EXEC silver.load_bronze;

-- Claculate the duration of loading whole batch of Brionze Layer Tables
DECLARE @batch_start_time DATETIME;
DECLARE @batch_end_time DATETIME;
SET @batch_start_time = GETDATE();
EXEC silver.load_bronze;
SET @batch_end_time = GETDATE();
PRINT 'Total Bronze Layer Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(10)) + ' seconds';

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_TYPE = 'BASE TABLE';
GO

SELECT 
    DB_NAME() AS database_name,
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id;
