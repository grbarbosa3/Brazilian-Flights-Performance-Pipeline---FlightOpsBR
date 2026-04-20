{{ config(materialized='view') }}

SELECT
    airline_name,
    SUM(cancelled_flag) AS n_cancelled_flights
FROM {{ ref('fact_flights') }}
WHERE airline_name IS NOT NULL
GROUP BY airline_name
ORDER BY n_cancelled_flights DESC