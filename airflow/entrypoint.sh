#!/bin/bash
set -e

# Initialize Airflow DB
airflow db migrate

# Create admin user
airflow users create \
    --username admin \
    --password admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com || true

# Execute the command passed to the container
exec "$@"
