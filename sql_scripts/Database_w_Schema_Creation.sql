-- Create Database-Creation User Stored Procedure (usp) in master database
CREATE OR ALTER PROCEDURE dbo.usp_create_wbr_db AS

IF DB_ID(N'WBR_DB') IS NULL
    BEGIN 
        CREATE DATABASE WBR_DB;
    END;
GO

-- Execute Database-Creation usp in master database
EXEC dbo.usp_create_wbr_db;
GO

-- Switch to WBR_DB Database
USE WBR_DB;
GO

-- Create stg schema for Staging layer if not exists
CREATE OR ALTER PROCEDURE dbo.usp_create_stg_schema AS
IF SCHEMA_ID(N'stg') IS NULL -- staging layer
    EXEC('CREATE SCHEMA stg;');

GO

-- Create dw schema for Data Warehousing layer if not exists
CREATE OR ALTER PROCEDURE dbo.usp_create_dw_schema AS
IF SCHEMA_ID(N'dw') IS NULL
    EXEC('CREATE SCHEMA dw;');

GO

-- Create cfg schema for pipeline config layer if not exists
CREATE OR ALTER PROCEDURE dbo.usp_create_cfg_schema AS
IF SCHEMA_ID(N'cfg') IS NULL
    EXEC('CREATE SCHEMA cfg;');
GO

-- Create ctl schema for pipeline control layer if not exists
CREATE OR ALTER PROCEDURE dbo.usp_create_ctl_schema AS
IF SCHEMA_ID(N'ctl') IS NULL
    EXEC('CREATE SCHEMA ctl;');
GO


-- Create a single usp to create all the necessary schema for the WBR_DB database
CREATE OR ALTER PROCEDURE dbo.usp_create_wbr_db_schema AS
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION
    EXEC dbo.usp_create_stg_schema;
    EXEC dbo.usp_create_dw_schema;
    EXEC dbo.usp_create_cfg_schema;
    EXEC dbo.usp_create_ctl_schema;
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION
        END;
    PRINT('ERROR CREATING SCHEMAS: ' + ISNULL(ERROR_MESSAGE(), 'Unknown Error'));
END CATCH
GO

-- Execute the usp to create all necessary schema for the WRB_DB database
EXEC dbo.usp_create_wbr_db_schema;