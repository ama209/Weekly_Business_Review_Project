USE WBR_DB;
GO

-- Store SQL syntax for table creation
CREATE OR ALTER PROCEDURE dw.usp_create_dim_customers AS

    CREATE TABLE dw.dim_customers(
        customer_surrogate_id INT IDENTITY(1,1) CONSTRAINT PK_dim_customers PRIMARY KEY,
        customer_id VARCHAR(50) NOT NULL,
        customer_unique_id VARCHAR(50) NOT NULL,
        customer_zip_code_prefix VARCHAR(5) NOT NULL,
        customer_city NVARCHAR(255) NOT NULL,
        customer_state NVARCHAR(255) NOT NULL,
        _pipeline_run_id INT NOT NULL,
        _inserted_at DATETIME2 NOT NULL CONSTRAINT DF_dim_customers_inserted_at DEFAULT SYSDATETIME(),
        _updated_at DATETIME2 NOT NULL CONSTRAINT DF_dim_customers_updated_at DEFAULT SYSDATETIME()
    );
GO

CREATE OR ALTER PROCEDURE dw.usp_create_dim_geolocation AS

    CREATE TABLE dw.dim_geolocation(
        geolocation_surrogate_id INT IDENTITY(1,1) CONSTRAINT PK_dim_geolocation PRIMARY KEY,
        geolocation_zip_code_prefix VARCHAR(5) NOT NULL,
        geolocation_lat DECIMAL(11,8) NOT NULL,
        geolocation_lng DECIMAL(11,8) NOT NULL,
        geolocation_city NVARCHAR(255) NOT NULL,
        geolocation_state NVARCHAR(255) NOT NULL,
        _pipeline_run_id INT NOT NULL,
        _inserted_at DATETIME2 NOT NULL CONSTRAINT DF_dim_geolocation_inserted_at DEFAULT SYSDATETIME(),
        _updated_at DATETIME2 NOT NULL CONSTRAINT DF_dim_geolocation_updated_at DEFAULT SYSDATETIME()
    );
GO

CREATE OR ALTER PROCEDURE dw.usp_create_fact_orders AS

    CREATE TABLE dw.fact_orders(
        order_surrogate_id INT IDENTITY(1,1) CONSTRAINT PK_fact_orders PRIMARY KEY,
        order_id VARCHAR(50) NOT NULL,
        customer_id VARCHAR(50) NOT NULL,
        order_status VARCHAR(20) NOT NULL,
        order_purchase_timestamp DATETIME2 NOT NULL,
        order_approved_at DATETIME2 NULL,
        order_delivered_carrier_date DATETIME2 NULL,
        order_delivered_customer_date DATETIME2 NULL,
        order_estimated_delivery_date DATETIME2 NOT NULL,
        _pipeline_run_id INT NOT NULL,
        _inserted_at DATETIME2 NOT NULL CONSTRAINT DF_fact_orders_inserted_at DEFAULT SYSDATETIME(),
        _updated_at DATETIME2 NOT NULL CONSTRAINT DF_fact_orders_updated_at DEFAULT SYSDATETIME()
    );
GO

CREATE OR ALTER PROCEDURE dw.usp_create_fact_order_items AS

    CREATE TABLE dw.fact_order_items(
        order_item_surrogate_id INT IDENTITY(1,1) CONSTRAINT PK_fact_order_items PRIMARY KEY,
        order_id VARCHAR(50) NOT NULL,
        order_item_id VARCHAR(50) NOT NULL,
        product_id VARCHAR(50) NOT NULL,
        seller_id VARCHAR(50) NOT NULL,
        shipping_limit_date DATETIME2 NOT NULL,
        price DECIMAL(19,4) NOT NULL,
        freight_value DECIMAL(19,4) NOT NULL,
        _pipeline_run_id INT NOT NULL,
        _inserted_at DATETIME2 NOT NULL CONSTRAINT DF_fact_order_items_inserted_at DEFAULT SYSDATETIME(),
        _updated_at DATETIME2 NOT NULL CONSTRAINT DF_fact_order_items_updated_at DEFAULT SYSDATETIME()
    );
GO

CREATE OR ALTER PROCEDURE dw.usp_create_fact_order_payments AS

    CREATE TABLE dw.fact_order_payments(
        order_payment_surrogate_id INT IDENTITY(1,1) CONSTRAINT PK_facts_order_payments PRIMARY KEY,
        order_id VARCHAR(50) NOT NULL,
        payment_sequential TINYINT NOT NULL,
        payment_type VARCHAR(50) NOT NULL,
        payment_installments INT NOT NULL,
        payment_value DECIMAL(19,4) NOT NULL,
        _pipeline_run_id INT NOT NULL,
        _inserted_at DATETIME2 NOT NULL CONSTRAINT DF_fact_order_payments_inserted_at DEFAULT SYSDATETIME(),
        _updated_at DATETIME2 NOT NULL CONSTRAINT DF_fact_order_payments_updated_at DEFAULT SYSDATETIME()
    );
GO

CREATE OR ALTER PROCEDURE dw.usp_create_fact_order_reviews AS

    CREATE TABLE dw.fact_order_reviews(
        order_review_surrogate_id INT IDENTITY(1,1) CONSTRAINT PK_fact_order_reviews PRIMARY KEY,
        review_id VARCHAR(50) NOT NULL,
        order_id VARCHAR(50) NOT NULL,
        review_score TINYINT NOT NULL,
        review_comment_title NVARCHAR(255) NULL,
        review_comment_message NVARCHAR(MAX) NULL,
        review_creation_date DATETIME2 NOT NULL,
        review_answer_timestamp DATETIME2 NOT NULL,
        _pipeline_run_id INT NOT NULL,
        _inserted_at DATETIME2 NOT NULL CONSTRAINT DF_fact_order_reviews_inserted_at DEFAULT SYSDATETIME(),
        _updated_at DATETIME2 NOT NULL CONSTRAINT DF_fact_order_reviews_updated_at DEFAULT SYSDATETIME()
    );
GO

CREATE OR ALTER PROCEDURE dw.usp_create_dim_products AS

    CREATE TABLE dw.dim_products(
        product_surrogate_id INT IDENTITY(1,1) CONSTRAINT PK_dim_products PRIMARY KEY,
        product_id VARCHAR(50) NOT NULL,
        product_category_name NVARCHAR(100) NULL,
        product_name_length SMALLINT NULL,
        product_description_length INT NULL,
        product_photos_qty SMALLINT NULL,
        product_weight_g INT NULL,
        product_length_cm SMALLINT NULL,
        product_heigth_cm SMALLINT NULL,
        product_width_cm SMALLINT NULL,
        _pipeline_run_id INT NOT NULL,
        _inserted_at DATETIME2 NOT NULL CONSTRAINT DF_dim_products_inserted_at DEFAULT SYSDATETIME(),
        _updated_at DATETIME2 NOT NULL CONSTRAINT DF_dim_products_updated_at DEFAULT SYSDATETIME()
    );
GO

CREATE OR ALTER PROCEDURE dw.usp_create_dim_product_category_name_translation AS

    CREATE TABLE dw.dim_product_category_name_translation(
        product_category_name_translation_surrogate_id INT IDENTITY(1,1) CONSTRAINT PK_dim_product_category_name_translation PRIMARY KEY,
        product_category_name NVARCHAR(100) NOT NULL,
        product_category_name_english VARCHAR(100) NOT NULL,
        _pipeline_run_id INT NOT NULL,
        _inserted_at DATETIME2 NOT NULL CONSTRAINT DF_dim_product_category_name_translation_inserted_at DEFAULT SYSDATETIME(),
        _updated_at DATETIME2 NOT NULL CONSTRAINT DF_dim_product_category_name_translation_updated_at DEFAULT SYSDATETIME()
    );
GO

CREATE OR ALTER PROCEDURE dw.usp_create_dim_sellers AS

    CREATE TABLE dw.dim_sellers(
        seller_surrogate_id INT IDENTITY(1,1) CONSTRAINT PK_dim_sellers PRIMARY KEY,
        seller_id VARCHAR(50) NOT NULL,
        seller_zip_code_prefix VARCHAR(5) NOT NULL,
        seller_city NVARCHAR(255) NOT NULL,
        seller_state NVARCHAR(255) NOT NULL,
        _pipeline_run_id INT NOT NULL,
        _inserted_at DATETIME2 NOT NULL CONSTRAINT DF_dim_sellers_inserted_at DEFAULT SYSDATETIME(),
        _updated_at DATETIME2 NOT NULL CONSTRAINT DF_dim_sellers_updated_at DEFAULT SYSDATETIME()
    );
GO

CREATE OR ALTER PROCEDURE cfg.usp_create_pipeline_registry AS

    CREATE TABLE cfg.pipeline_registry(
        registry_id INT IDENTITY(1,1) PRIMARY KEY,
        entity_name NVARCHAR(100) NOT NULL,
        source_handler NVARCHAR(50) NOT NULL,
        dataset_identifier NVARCHAR(255) NOT NULL,
        local_file_name VARCHAR(255) NOT NULL,
        staging_table VARCHAR(100) NOT NULL,
        permanent_table VARCHAR(100) NOT NULL,
        sql_stored_procedure VARCHAR(100) NOT NULL,
        is_active BIT DEFAULT 1,
        modified_date DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        modified_by NVARCHAR(100) NOT NULL DEFAULT SUSER_SNAME()
    );
GO

CREATE OR ALTER PROCEDURE ctl.usp_create_pipeline_runtime AS

    CREATE TABLE ctl.pipeline_runtime(
        run_id INT IDENTITY(1,1) PRIMARY KEY,
        registry_id INT FOREIGN KEY REFERENCES cfg.pipeline_registry(registry_id),
        run_date DATE NOT NULL,
        phase VARCHAR(30) NOT NULL,
        log_status VARCHAR(20) DEFAULT 'New',
        start_time DATETIME2 DEFAULT SYSDATETIME(),
        end_time DATETIME2,
        rows_affected INT DEFAULT 0,
        error_messages VARCHAR(MAX) NULL
    );
GO


-- Create permanent tables
CREATE OR ALTER PROCEDURE dw.usp_create_olist_wbr_tables AS

SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY
    EXEC dw.usp_create_dim_customers;
    EXEC dw.usp_create_dim_geolocation;
    EXEC dw.usp_create_fact_orders;
    EXEC dw.usp_create_fact_order_items;
    EXEC dw.usp_create_fact_order_payments;
    EXEC dw.usp_create_fact_order_reviews;
    EXEC dw.usp_create_dim_products;
    EXEC dw.usp_create_dim_product_category_name_translation;
    EXEC dw.usp_create_dim_sellers;
    EXEC cfg.usp_create_pipeline_registry;
    EXEC ctl.usp_create_pipeline_runtime;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION
    END;
    PRINT(ISNULL(ERROR_MESSAGE(),'Unknown Error'))
END CATCH;
GO

EXEC dw.usp_create_olist_wbr_tables;
GO
