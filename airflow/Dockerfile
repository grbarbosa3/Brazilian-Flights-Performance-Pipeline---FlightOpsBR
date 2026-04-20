FROM apache/airflow:2.10.5-python3.11

WORKDIR /opt/airflow

# Install additional Python packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    dbt-bigquery==1.11.1 \
    google-cloud-storage \
    google-cloud-bigquery \
    pandas \
    pyarrow \
    python-dotenv