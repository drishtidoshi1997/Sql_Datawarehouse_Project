
-- Check for Nulls & Duplicates in a Table
-- Expected Output: No Nulls or Duplicates

USE master

SELECT 
cst_id,
COUNT(*) 
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL ;

-- Remove Nulls & Duplicates from a Table using flag
SELECT * 
FROM 
    (SELECT * ,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info )t
WHERE flag_last != 1;

-- Check for unwanted spaces in a Table: for all string values
-- Expectation: No results
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_marital_status
FROM bronze.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

-- Data Standarization & Consitency Checks
-- Example: Standardize cst_gndr values to 'M' and 'F' only
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

-- Transformed Data Query to Load into Silver Layer
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date)

SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE WHEN UPPER(cst_marital_status) = 'S' THEN 'Single'
         WHEN UPPER(cst_marital_status) = 'M' THEN 'Married'
         ELSE 'n/a'
    END AS cst_marital_status,
    CASE WHEN UPPER(cst_gndr) = 'M' THEN 'Male'
        WHEN UPPER(cst_gndr) = 'F' THEN 'Female'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM 
    (SELECT * ,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info 
    WHERE cst_id IS NOT NULL
    )t
WHERE flag_last = 1;

--------------------------------------------------------------------------

-- bronze.crm_prd_info to silver.crm_prd_info
-- Check for Nulls & Duplicates in a Table
USE master;

SELECT * FROM bronze.crm_prd_info;
SELECT * FROM bronze.crm_cust_info;

SELECT 
prd_id,
COUNT(*) 
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL ;

-- Remove Nulls & Duplicates from a Table using flag
SELECT * 
FROM 
    (SELECT * ,
    ROW_NUMBER() OVER (PARTITION BY prd_id ORDER BY prd_start_dt DESC) AS flag_last
    FROM bronze.crm_prd_info )t
WHERE flag_last != 1;

-- Check for unwanted spaces in a Table: for all string values
-- Expectation: No results
SELECT *
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Data Standarization & Consitency Checks
/*WHERE SUBSTRING(prd_key,7, LEN(prd_key)) NOT IN 
(SELECT DISTINCT sls_prd_key FROM bronze.crm_sales_details);
-- Find out if cat_id is present in erp_px_cat_g1v2 table where filter
WHERE REPLACE(SUBSTRING(prd_key, 1,5), '-', '_') NOT IN 
(SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2);

-- Check for Nulls & Negative Numbers in prd_cost
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Check for Invalid Date Orders: prd_start_dt should be less than prd_end_dt
SELECT 
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt)OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt_check
FROM bronze.crm_prd_info*/
--------------------------------------------------------------------------
-- Transformed Data Query to Load into Silver Layer

IF OBJECT_ID('silver.crm_prd_info','U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    cat_id       NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt)
SELECT 
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1,5), '-', '_')AS cat_id,
    SUBSTRING(prd_key,7, LEN(prd_key)) AS prd_key ,
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(LEAD(prd_start_dt)OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE )AS prd_end_dt_check
FROM bronze.crm_prd_info


--------------------------------------------------
-- crm_sales_details to silver.crm_sales_details

SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    NULLIF(sls_order_dt, 0) AS sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 --check for invalid dates

/*check for spaces
--WHERE sls_ord_num != TRIM(sls_ord_num)
-- check for integrity of foreign keys
SELECT DISTINCT prd_key FROM bronze.crm_prd_info;
SELECT DISTINCT prd_key FROM silver.crm_prd_info;
SELECT DISTINCT sls_prd_key FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT  cst_id FROM silver.crm_cust_info)*/
/*Sql server does not convert integer to date directly, first casting to varchar
sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 OR sls_order_dt > 20500101
--check for invalid dates
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Negative to positive: using ABS() function
WHERE sls_sales != sls_quantity*sls_price OR 
sls_sales IS NULL OR sls_price IS NULL OR sls_quantity IS NULL OR 
sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 */


IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price)
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 OR sls_order_dt > 20500101 THEN NULL
         ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
    CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 OR sls_ship_dt > 20500101 THEN NULL
         ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
    CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 OR sls_due_dt > 20500101 THEN NULL
         ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales!= sls_quantity*ABS(sls_price) 
    THEN sls_quantity* ABS(sls_price)
    ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE WHEN sls_price IS NULL OR sls_price <=0 OR sls_price != ABS (sls_price)
    THEN ABS(sls_sales/NULLIF(sls_quantity,0))
    ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details


