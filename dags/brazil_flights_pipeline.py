from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator


with DAG(
    dag_id="brazil_flights_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["zoomcamp", "bigquery", "dbt"],
) as dag:

    load_raw_to_bigquery = BashOperator(
        task_id="load_raw_to_bigquery",
        bash_command="cd /opt/airflow/project && python scripts/load_raw_to_bigquery.py",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            "cd /opt/airflow/project/dbt_brazil_flights && "
            "dbt run --profiles-dir /opt/airflow/project/profiles"
        ),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            "cd /opt/airflow/project/dbt_brazil_flights && "
            "dbt test --profiles-dir /opt/airflow/project/profiles"
        ),
    )

    load_raw_to_bigquery >> dbt_run >> dbt_test