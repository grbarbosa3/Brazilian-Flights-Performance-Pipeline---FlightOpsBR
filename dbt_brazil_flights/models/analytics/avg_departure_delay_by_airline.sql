{{ config(materialized='view') }}

SELECT
    airline_code,
    airline_name,
    ROUND(AVG(departure_delay_minutes), 2) AS avg_dep_delay_minutes
FROM {{ ref('fact_flights') }}
WHERE departure_delay_minutes > 10
  AND airline_name IS NOT NULL
  AND is_departure_delay_outlier = 0
GROUP BY
    airline_code,
    airline_name
ORDER BY avg_dep_delay_minutes DESC