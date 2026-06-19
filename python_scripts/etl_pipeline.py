# import libraries for csv imports
print("Importing libraries...")
import os
from dotenv import load_dotenv

load_dotenv()
print(".env file loaded successfully")

import pandas as pd
import pyodbc
from sqlalchemy import create_engine, types
import urllib
from kaggle.api.kaggle_api_extended import KaggleApi
api = KaggleApi()
api.authenticate()
print("Libraries imported successfully!")

# extract secrets into variables
db_server = os.getenv("DB_SERVER")
db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
target_db = os.getenv("DB_NAME")
kaggle_dataset = os.getenv("KAGGLE_DATASET")
connection_address = os.getenv("CONNECTION_ADDRESS")

# connect to sqlserver
# create target database if it does not exist
sql_driver = "{/opt/homebrew/lib/libmsodbcsql.18.dylib}"
master_conn_str = f"DRIVER={sql_driver};SERVER={db_server}; Address={connection_address}; DATABASE=master; UID={db_user}; PWD={db_password}; Encrypt=no; TrustServerCertificate=yes;"

print(f"Checking existence of database: {target_db}...")


# check for target database existence. create if needed
with pyodbc.connect(master_conn_str, autocommit=True) as master_conn:
    with master_conn.cursor() as master_cursor:
        create_db_query = f"""
        IF NOT EXISTS( SELECT * FROM sys.databases WHERE [name] = '{target_db}')
        BEGIN
            CREATE DATABASE [{target_db}]
        END
        """
        master_cursor.execute(create_db_query)
        print("Database ready for import!")


# reconnect to sql server, but this time to the target database
target_db_conn_str = f"DRIVER={sql_driver};SERVER={db_server}; Address={connection_address}; DATABASE={target_db}; UID={db_user}; PWD={db_password}; Encrypt=no; TrustServerCertificate=yes;"


# start pipeline - retrieve list of active pipelines from sql server config table and append records into sql server control table
print("Starting pipeline...")
with pyodbc.connect(target_db_conn_str, autocommit=False) as target_db_conn:
    with target_db_conn.cursor() as target_db_cursor:
        target_db_cursor.execute(
            """
            SELECT 
                registry_id
                ,entity_name
                ,local_file_name
                ,staging_table
                ,permanent_table
                ,sql_stored_procedure
            FROM
                cfg.pipeline_registry
            WHERE
                is_active = 1
            """
        )
        active_pipelines = target_db_cursor.fetchall()
        
        # import kaggle dataset
        dataset = kaggle_dataset
        target_folder = "Documents/Data_Projects/Weekly_Business_Review_Project/data/raw"
        api.dataset_download_files(dataset, path=target_folder, unzip=True)
        print("Data downloaded and unzipped successfully!")
        
        dfs={}
        expected_raw_files = []
        registry_id_list = []
        pipeline_id_list = []
        
        for pipeline in active_pipelines:
            (
                registry_id,
                entity_name,
                local_file_name,
                staging_table,
                permanent_table,
                sql_stored_procedure,
            ) = pipeline

            raw_files = f"{target_folder}/{local_file_name}"
            expected_raw_files.append(raw_files)
            df_name = f"{entity_name}"
            dfs.update({df_name:raw_files})
            registry_id_list.append(registry_id)

            target_db_cursor.execute(
                """
                INSERT INTO
                    ctl.pipeline_runtime (
                    registry_id
                    ,run_date
                    ,phase
                    ,log_status
                    ,start_time
                    ,end_time
                    ,rows_affected
                    ,error_messages
                    )
                OUTPUT INSERTED.run_id
                VALUES(
                    ?
                    ,CAST(SYSDATETIME() AS DATE)
                    ,'Extract'
                    ,'Running'
                    ,SYSDATETIME()
                    ,NULL
                    ,NULL
                    ,NULL
                )
                """,registry_id)
            pipeline_ids = target_db_cursor.fetchone()
            pipeline_id_list.append(pipeline_ids[0])
            target_db_conn.commit()

        missing_files = []

        # if file is missing append to missing_files variable
        print("Searching for csv files...")
        for file in expected_raw_files:
            if not os.path.exists(file):
                missing_files.append(file)
        if missing_files:
            raise FileNotFoundError(f"Process failure due to the following missing files: {missing_files}")
        print("All csv files found...")

        # store files in dataframes
        print("Creating Dataframes...")
        for df_name,raw_files in dfs.items():
            dfs[df_name] = pd.read_csv(raw_files)
        # ensure column types are the right data type
        print("Assigning column data types...")
        column_mapping_dictionary = {'customer_id':str, 'customer_unique_id':str, 'customer_zip_code_prefix':"Int64", 'customer_city':str, 'customer_state':str, 'geolocation_zip_code_prefix':"Int64", 'geolocation_lat':float, 'geolocation_long':float, 'geolocation_city':str, 'geolocation_state':str, 'order_id':str, 'order_item_id':str, 'product_id':str,'seller_id':str, 'price':"Int64", 'freight_value':float, 'payment_sequential':"Int64", 'payment_card':str, 'payment installments':"Int64", 'payment_value':float, 'review_id':str, 'review_score':"Int64", 'review_comment_title':str, 'review_comment_message':str, 'order_status':str, 'product_category_name':str, 'product_name_length':"Int64", 'product_description_length':"Int64", 'product_photos_qty':"Int64", 'product_weight_g':"Int64", 'product_length_cm':"Int64", 'product_height_cm':"Int64", 'product_width_cm':"Int64", 'seller_zip_code_prefix':"Int64", 'seller_city':str, 'seller_state':str}

        datetime_columns = ['shipping_limit_date', 'review_creation_date', 'review_answer_timestamp', 'order_purchase_timestamp', 'order_approved_at', 'order_delivered_carrier_date', 'order_delivered_customer_date', 'order_estimated_delivery_date']


        # Turn off autocommit to speed up the transaction
        params = urllib.parse.quote_plus(target_db_conn_str)
        engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")
      
        for name, df_name in dfs.items():
            for col in df_name.columns:
                if col in datetime_columns:
                    df_name[col] = pd.to_datetime(df_name[col], errors='coerce')
                    
                elif col in column_mapping_dictionary:
                    target_type = column_mapping_dictionary[col]
                    
                    # FIX: Safely downcast float decimals into nullable Int64
                    if target_type == "Int64":
                        # 1. Force string/mixed values to numeric floats first
                        numeric_col = pd.to_numeric(df_name[col], errors='coerce')
                        # 2. Round the decimals explicitly so they can become integers safely
                        df_name[col] = numeric_col.round().astype("Int64")
                    else:
                        # Normal conversion for standard text strings and float fields
                        df_name[col] = df_name[col].astype(target_type)
                        
                else:
                    pass
            print(f"Data types for {name} table succesfully assigned...")
        
          
        for table_name,df_name in dfs.items():
            print(f"Uploading table: stg.{table_name}...")
            sql_types = {
                col: types.String(255)
                for col, dtype in df_name.dtypes.items()
                if dtype=="object"
            }
            df_name.to_sql(
                name=table_name,
                con=engine,
                schema="stg",
                if_exists="replace",
                index=False,
                dtype=sql_types
            )
            print(f"Successfully uploaded {len(df_name)} rows to SQL Server.")

        print("Moving staging data to warehouse tables...")    
        for ids in pipeline_id_list:
            target_db_cursor.execute(
                """
                -- Declare Variables
                DECLARE @usp VARCHAR(255);
                DECLARE @usp_rowcount INT;
                DECLARE @sql_string NVARCHAR(MAX);

                -- Assign Variables
                SET @usp = (SELECT sql_stored_procedure FROM ctl.pipeline_runtime INNER JOIN cfg.pipeline_registry ON pipeline_runtime.registry_id = pipeline_registry.registry_id WHERE run_id = ?);

                SET @sql_string = N'EXEC ' + @usp + N' @pipeline_run_id = @param_id; SET @rc = @@ROWCOUNT;';

                -- Begin runnnig stored procedures. Update pipeline log_status to 'completed' if no errors
                BEGIN TRY
                EXEC sp_executesql 
                    @sql_string, 
                    N'@param_id INT, @rc INT OUTPUT', 
                    ?, @rc = @usp_rowcount OUTPUT;

                UPDATE ctl.pipeline_runtime
                SET 
                    phase = 'load',
                    log_status = 'completed',
                    end_time = SYSDATETIME(),
                    rows_affected = @usp_rowcount
                WHERE run_id = ?
                    ;
                END TRY
                -- Update pipeline log_status to 'failed' if errors
                BEGIN CATCH
                UPDATE ctl.pipeline_runtime
                SET 
                    phase = 'load',
                    log_status = 'failed',
                    end_time = SYSDATETIME(),
                    rows_affected = COALESCE(@usp_rowcount,0),
                    error_messages = ERROR_MESSAGE()
                WHERE run_id = ?
                END CATCH;
                """, ids,ids,ids, ids)
    
    # commit transactions and print success message
    target_db_conn.commit()
    print("All tables successfully processed!")

# Close cursors, connections, and engine
master_cursor.close()
print("master database cursor closed successfully!")
master_conn.close()
print("master database connection closed successfully!")
target_db_cursor.close()
print("target_db cursor closed succesfully!")
target_db_conn.close()
print("target_db connection closed succesfully!")
engine.dispose()
print("sqlalchemy engine closed successfully!")