{{ config(materialized='view') }}

SELECT
    CONCAT(city_departure, ' -> ', city_arrival) AS route,
    ROUND(AVG(departure_delay_minutes), 2) AS avg_dep_delay_minutes
FROM {{ ref('fact_flights') }}
WHERE departure_delay_minutes > 10
  AND is_departure_delay_outlier = 0
GROUP BY route
ORDER BY avg_dep_delay_minutes DESC