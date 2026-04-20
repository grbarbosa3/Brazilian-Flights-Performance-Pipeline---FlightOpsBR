{{ config(materialized='view') }}

SELECT
    airline_code,
    airline_name,
    ROUND(AVG(arrival_delay_minutes), 2) AS avg_arr_delay_minutes
FROM {{ ref('fact_flights') }}
WHERE arrival_delay_minutes >= 10
  AND airline_name IS NOT NULL
  AND is_arrival_delay_outlier = 0
GROUP BY
    airline_code,
    airline_name
ORDER BY avg_arr_delay_minutes DESC