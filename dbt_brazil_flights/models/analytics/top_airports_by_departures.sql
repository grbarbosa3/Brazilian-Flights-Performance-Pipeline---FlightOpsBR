{{ config(materialized='view') }}

SELECT
    airport_departure,
    city_departure,
    COUNT(flight_number) AS number_of_flights
FROM {{ ref('fact_flights') }}
WHERE airport_departure IS NOT NULL
GROUP BY
    airport_departure,
    city_departure
ORDER BY number_of_flights DESC