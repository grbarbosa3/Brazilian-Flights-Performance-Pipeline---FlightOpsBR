<img width="1313" height="561" alt="image" src="https://github.com/user-attachments/assets/c41f24cf-0095-47ba-9415-feb1706dcbb1" />

# Brazilian Flights Performance Pipeline 2026

Final project for the **Data Engineering Zoomcamp 2026**.

This project builds an end-to-end data pipeline to analyze Brazilian flight operations using public aviation data from ANAC (National Brazilian Aviation Agency). 
The pipeline ingests raw CSV files, stores them in Google Cloud Storage and BigQuery, transforms the data with dbt, orchestrates the workflow with Airflow, and delivers a 
Power BI dashboard with operational insights about flights, delays, cancellations, airlines, routes, and airports.

### Problem Description

Brazil has a large and complex aviation network, with thousands of regular flights operated across multiple airports and airlines. 
For analysts, regulators, airport operators, and airline stakeholders, it is important to monitor operational performance such as flight volume, delays, cancellations, route behavior, 
and airport activity.

This project solves the problem of transforming raw public aviation CSV files from ANAC into a structured analytical data platform. 
The final result allows users to analyze flight performance in Brazil through clean BigQuery tables and a Power BI dashboard.

- Which airports have the highest number of departures and arrivals?
- Which airlines have the highest cancellation volume?
- What is the average departure and arrival delay by airline?
- What are the routes with the highest average delay?
- How are airports distributed by state and operation type?

## Data Sources

The project uses public datasets from ANAC:

- VRA - Active Regular Flights in January 2026
- Public aerodromes registry
- Private aerodromes registry
- Airline reference data

* https://sistemas.anac.gov.br/dadosabertos/
* https://sistemas.anac.gov.br/dadosabertos/Aerodromos/Aer%C3%B3dromos%20Privados/Lista%20de%20aer%C3%B3dromos%20privados/Aerodromos%20Privados/

## Architecture

```text
Docker Containers
        ↓
ANAC CSV files
        ↓
Terraform
        ↓
Google Cloud Storage bucket
        ↓
Python raw load script
        ↓
BigQuery raw dataset
        ↓
dbt staging models
        ↓
dbt marts and analytics models
        ↓
Airflow orchestration
        ↓
Power BI dashboard

```

### Infrastructure:
Terraform provisions the Google Cloud Storage bucket.

### Orchestration:
Airflow runs the pipeline tasks:
load_raw_to_bigquery → dbt_run → dbt_test

## How to Run

### 1. Create cloud infrastructure

```
cd terraform
terraform init
terraform apply
```
### 2. Load raw data to GCS and BigQuery
```
python scripts/load_raw_to_bigquery.py
```
### 3. Run dbt models
```
cd dbt_brazil_flights
dbt run
dbt test
```
### 4. Start Airflow
```
docker compose -f docker-compose.airflow.yml up --build
```
 * Trigger the DAG
```
brazil_flights_pipeline
```

**Infrastructure**:
Terraform provisions the Google Cloud Storage bucket.

**Orchestration**:
Airflow runs the pipeline tasks:
load_raw_to_bigquery → dbt_run → dbt_test

Terraform is used to provision the cloud storage layer. 
The Python ingestion script uploads the raw files to GCS and loads them into BigQuery.
dbt builds the staging, marts and analytics models, while Airflow orchestrates the ingestion and transformation workflow.

### PowerBI

<img width="1311" height="739" alt="image" src="https://github.com/user-attachments/assets/7fe0f482-1627-4ad7-834c-d6296aff6414" />

<img width="1313" height="737" alt="image" src="https://github.com/user-attachments/assets/c0fb7f54-6604-457f-a53b-0e46ceb61e02" />

### BigQuery

<img width="1894" height="929" alt="image" src="https://github.com/user-attachments/assets/6e0c30a6-e1f8-4e15-8d8b-de72df2a0496" />

### Tool Choices
#### Airflow

Airflow was chosen as the orchestration tool because it is widely used in production data pipelines and is commonly requested in data engineering roles in Brazil. Although the current Zoomcamp version uses Kestra, Airflow was selected to make the project more aligned with market demand.

#### BigQuery

BigQuery was used as the cloud data warehouse because it integrates well with Google Cloud Storage, dbt and Power BI, and supports scalable analytical workloads.

#### dbt

dbt was used to organize the transformation layer. It builds staging models, dimensional models, fact tables, analytics views, and data quality tests.

#### Terraform

Terraform was used to provision cloud infrastructure, specifically the Google Cloud Storage bucket used as the raw data lake layer.

### Future Improvements
* Add automatic monthly download from ANAC
* Add more months of flight data
* Add BigQuery table partitioning and clustering
* Improve outlier handling for extreme delay values
* Add weather data to analyze potential delay causes
* Add CI/CD for dbt models