USE [WBR_DB];
GO

SET XACT_ABORT ON;
GO


CREATE SCHEMA ctl;
GO

CREATE SCHEMA cfg;
GO

BEGIN TRANSACTION
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

INSERT INTO cfg.pipeline_registry (entity_name, source_handler, dataset_identifier, local_file_name, staging_table, permanent_table, sql_stored_procedure)
VALUES
    ('customers','kaggle','olistbr/brazilian-ecommerce','olist_customers_dataset.csv','stg.customers', 'dw.dim_customers', 'stg.sp_insert_dim_customers'),
    ('geolocation','kaggle','olistbr/brazilian-ecommerce','olist_geolocation_dataset.csv','stg.geolocation', 'dw.dim_geolocation', 'stg.sp_insert_dim_geolocation'),
    ('orders','kaggle','olistbr/brazilian-ecommerce','olist_orders_dataset.csv','stg.orders', 'dw.fact_orders', 'stg.sp_insert_fact_orders'),
    ('order_items','kaggle','olistbr/brazilian-ecommerce','olist_order_items_dataset.csv','stg.order_items', 'dw.fact_order_items', 'stg.sp_insert_fact_order_items'),
    ('order_payments','kaggle','olistbr/brazilian-ecommerce','olist_order_payments_dataset.csv','stg.order_payments', 'dw.fact_order_payments', 'stg.sp_insert_fact_order_payments'),
    ('order_reviews','kaggle','olistbr/brazilian-ecommerce','olist_order_reviews_dataset.csv','stg.order_reviews', 'dw.fact_order_reviews', 'stg.sp_insert_fact_order_reviews'),
    ('products','kaggle','olistbr/brazilian-ecommerce','olist_products_dataset.csv','stg.products','dw.dim_products','stg.sp_insert_dim_products'),
    ('product_category_name_translation','kaggle','olistbr/brazilian-ecommerce','product_category_name_translation.csv','stg.product_category_name_translation', 'dw.dim_product_category_name_translation', 'stg.sp_insert_dim_product_category_name_translation'),
    ('sellers','kaggle','olistbr/brazilian-ecommerce','olist_sellers_dataset.csv','stg.sellers', 'dw.dim_sellers', 'stg.sp_insert_dim_sellers')
COMMIT TRANSACTION;
GO