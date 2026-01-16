
-- Create Database 'DataWarehouse' by using if exists check

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    DROP DATABASE DataWarehouse;
END

USE master;
CREATE DATABASE DataWarehouse;
USE DataWarehouse ;

-- Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

