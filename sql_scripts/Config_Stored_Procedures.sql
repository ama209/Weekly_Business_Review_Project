USE WBR_DB;
GO

CREATE OR ALTER PROCEDURE cfg.usp_insert_cfg_pipeline_registery AS
    DELETE FROM cfg.pipeline_registry;

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
    ('sellers','kaggle','olistbr/brazilian-ecommerce','olist_sellers_dataset.csv','stg.sellers', 'dw.dim_sellers', 'stg.sp_insert_dim_sellers');
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION
    BEGIN TRY
        EXEC cfg.usp_insert_cfg_pipeline_registery
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        PRINT ('ERROR INSERTING DATA INTO cfg.usp_insert_cfg_pipeline_registery: ' + ISNULL(ERROR_MESSAGE(),'Unknown Error'))
    END CATCH;
GO