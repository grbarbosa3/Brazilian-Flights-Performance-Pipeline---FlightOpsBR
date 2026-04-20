{{ config(materialized='view') }}

SELECT
    airport_arrival,
    city_arrival,
    COUNT(flight_number) AS number_of_flights
FROM {{ ref('fact_flights') }}
WHERE airport_arrival IS NOT NULL
GROUP BY
    airport_arrival,
    city_arrival
ORDER BY number_of_flights DESC