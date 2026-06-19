-- Create stored procedures
CREATE PROCEDURE dw.usp_insert_dw_dim_customers 
@pipeline_run_id INT
AS
SET XACT_ABORT ON; 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dw.dim_customers (
                customer_id,
                customer_unique_id,
                customer_zip_code_prefix,
                customer_city,
                customer_state,
                _pipeline_run_id,
                _inserted_at,
                _updated_at
            )

            SELECT
                customer_id,
                customer_unique_id,
                customer_zip_code_prefix,
                customer_city,
                customer_state,
                @pipeline_run_id,
                SYSDATETIME(),
                SYSDATETIME()
            FROM
                stg.customers;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRANSACTION;
        PRINT 'EXEC FAILURE IN: usp_insert_dw_dim_customers';
        ;THROW;
    END CATCH;
END;

GO

CREATE PROCEDURE dw.usp_insert_dw_dim_geolocation
@pipeline_run_id INT
AS
SET XACT_ABORT ON; 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dw.dim_geolocation(
                geolocation_zip_code_prefix,
                geolocation_lat,
                geolocation_lng,
                geolocation_city,
                geolocation_state,
                _pipeline_run_id,
                _inserted_at,
                _updated_at
            )

            SELECT
                geolocation_zip_code_prefix,
                geolocation_lat,
                geolocation_lng,
                geolocation_city,
                geolocation_state,
                @pipeline_run_id,
                SYSDATETIME(),
                SYSDATETIME()
            FROM
                stg.geolocation;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRANSACTION;
        PRINT 'EXEC FAILURE IN: usp_insert_dw_dim_geolocation';
        ;THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE dw.usp_insert_dw_dim_products
@pipeline_run_id INT
AS
SET XACT_ABORT ON; 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dw.dim_products(
                product_id,
                product_category_name,
                product_name_length,
                product_description_length,
                product_photos_qty,
                product_weight_g,
                product_length_cm,
                product_heigth_cm,
                product_width_cm,
                _pipeline_run_id,
                _inserted_at,
                _updated_at
            )
            SELECT
                product_id,
                product_category_name,
                product_name_lenght,
                product_description_lenght,
                product_photos_qty,
                product_weight_g,
                product_length_cm,
                product_height_cm,
                product_width_cm,
                @pipeline_run_id,
                SYSDATETIME(),
                SYSDATETIME()
            FROM
                stg.products;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRANSACTION;
        PRINT 'EXEC FAILURE IN: usp_insert_dw_dim_products';
        ;THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE dw.usp_insert_dw_dim_product_category_name_translation
@pipeline_run_id INT
AS
SET XACT_ABORT ON; 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dw.dim_product_category_name_translation(
                product_category_name,
                product_category_name_english,
                _pipeline_run_id,
                _inserted_at,
                _updated_at
            )
            SELECT
                product_category_name,
                product_category_name_english,
                @pipeline_run_id,
                SYSDATETIME(),
                SYSDATETIME()
            FROM
                stg.product_category_name_translation;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRANSACTION;
        PRINT 'EXEC FAILURE IN: usp_insert_dw_dim_product_category_name_translation';
        ;THROW;
    END CATCH;
END;
GO


CREATE PROCEDURE dw.usp_insert_dw_dim_sellers
@pipeline_run_id INT
AS
SET XACT_ABORT ON; 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dw.dim_sellers(
                seller_id,
                seller_zip_code_prefix,
                seller_city,
                seller_state,
                _pipeline_run_id,
                _inserted_at,
                _updated_at
            )
            SELECT
                seller_id,
                seller_zip_code_prefix,
                seller_city,
                seller_state,
                @pipeline_run_id,
                SYSDATETIME(),
                SYSDATETIME()
            FROM
                stg.sellers;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRANSACTION;
        PRINT 'EXEC FAILURE IN: usp_insert_dw_dim_product_category_name_translation';
        ;THROW;
    END CATCH;
END;
GO


CREATE PROCEDURE dw.usp_insert_dw_fact_orders
@pipeline_run_id INT
AS
SET XACT_ABORT ON; 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dw.fact_orders(
               order_id,
               customer_id,
               order_status,
               order_purchase_timestamp,
               order_approved_at,
               order_delivered_carrier_date,
               order_delivered_customer_date,
               order_estimated_delivery_date,
               _pipeline_run_id,
               _inserted_at,
               _updated_at 
            )
            SELECT
                order_id,
               customer_id,
               order_status,
               order_purchase_timestamp,
               order_approved_at,
               order_delivered_carrier_date,
               order_delivered_customer_date,
               order_estimated_delivery_date,
               @pipeline_run_id,
               SYSDATETIME(),
               SYSDATETIME() 
            FROM
                stg.orders;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE()) <> 0 ROLLBACK TRANSACTION;
        PRINT 'EXEC FAILURE IN: usp_insert_dw_fact_orders';
        ;THROW;
    END CATCH;
END
GO


CREATE PROCEDURE dw.usp_insert_dw_fact_order_items
@pipeline_run_id INT
AS
SET XACT_ABORT ON; 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dw.fact_order_items(
                order_id,
                order_item_id,
                product_id,
                seller_id,
                shipping_limit_date,
                price,
                freight_value,
                _pipeline_run_id,
                _inserted_at,
                _updated_at
            )
            SELECT
                order_id,
                order_item_id,
                product_id,
                seller_id,
                shipping_limit_date,
                price,
                freight_value,
                @pipeline_run_id,
                SYSDATETIME(),
                SYSDATETIME()
            FROM
                stg.order_items;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE()) <> 0 ROLLBACK TRANSACTION;
        PRINT 'EXEC FAILURE IN: usp_insert_dw_fact_order_items';
        ;THROW;
    END CATCH;
END
GO



CREATE PROCEDURE dw.usp_insert_dw_fact_order_payments
@pipeline_run_id INT
AS
SET XACT_ABORT ON; 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dw.fact_order_payments(
                order_id,
                payment_sequential,
                payment_type,
                payment_installments,
                payment_value,
                _pipeline_run_id,
                _inserted_at,
                _updated_at
            )
            SELECT
                order_id,
                payment_sequential,
                payment_type,
                payment_installments,
                payment_value,
                @pipeline_run_id,
                SYSDATETIME(),
                SYSDATETIME()
            FROM
                stg.order_payments;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE()) <> 0 ROLLBACK TRANSACTION;
        PRINT 'EXEC FAILURE IN: usp_insert_dw_fact_order_payments';
        ;THROW;
    END CATCH;
END
GO


CREATE PROCEDURE dw.usp_insert_dw_fact_order_reviews
@pipeline_run_id INT
AS
SET XACT_ABORT ON; 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dw.fact_order_reviews(
                review_id,
                order_id,
                review_score,
                review_comment_title,
                review_comment_message,
                review_creation_date,
                review_answer_timestamp,
                _pipeline_run_id,
                _inserted_at,
                _updated_at
            )
            SELECT
                review_id,
                order_id,
                review_score,
                review_comment_title,
                review_comment_message,
                review_creation_date,
                review_answer_timestamp,
                @pipeline_run_id,
                SYSDATETIME(),
                SYSDATETIME()
            FROM
                stg.order_reviews;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE()) <> 0 ROLLBACK TRANSACTION;
        PRINT 'EXEC FAILURE IN: usp_insert_dw_fact_order_reviews';
        ;THROW;
    END CATCH;
END
GO