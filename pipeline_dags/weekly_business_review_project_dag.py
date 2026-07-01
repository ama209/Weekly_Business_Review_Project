# This DAG file is used to run the etl_pipeline.py script in the Weekly_Business_Review data engineering project
print("Importing libraries...")
from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

with DAG(
    dag_id='weekly_business_review_monday_4am_pipeline',
    schedule='0 4 * * 1', # <-- Runs every monday at 4am
    start_date=datetime(2026,6,21), # <-- Set sometime in the past (ex: 2 days ago) so it doesn't skip the next run
    catchup=False, # <-- Set to false so it doesn't try to rerun for dates in the past
) as dag:
    run_script = BashOperator(
        task_id='execute_external_python_file',
        bash_command=(
            'python3 /usr/local/airflow/dags/pipeline_scripts/python_scripts/weekly_business_review_etl_pipeline.py'
        )
    )
