{{ config(materialized='view') }}

SELECT
    CONCAT(city_departure, ' -> ', city_arrival) AS route,
    ROUND(AVG(arrival_delay_minutes), 2) AS avg_arr_delay_minutes
FROM {{ ref('fact_flights') }}
WHERE arrival_delay_minutes > 10
  AND is_arrival_delay_outlier = 0
GROUP BY route
ORDER BY avg_arr_delay_minutes DESC