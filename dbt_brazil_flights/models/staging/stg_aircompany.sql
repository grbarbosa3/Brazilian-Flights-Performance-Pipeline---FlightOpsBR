{{ config(materialized='table') }}

WITH base AS (
    SELECT
        TRIM(CAST(icao_code AS STRING)) AS aircompany_code,
        TRIM(CAST(airline_name AS STRING)) AS aircompany_name,
        TRIM(CAST(country AS STRING)) AS country

    FROM {{ source('raw', 'raw_airlines') }}
    WHERE icao_code IS NOT NULL
)

SELECT
    aircompany_code,
    aircompany_name,
    country
FROM base
WHERE aircompany_code IS NOT NULL
