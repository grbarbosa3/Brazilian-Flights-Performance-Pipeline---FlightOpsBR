{{ config(materialized='table') }}

WITH base AS ( 
    SELECT 
        CAST(airport_code AS STRING) AS airport_code, 
        CAST(name AS STRING) AS name, 
        CAST(city AS STRING) AS city, 
        CAST(state AS STRING) AS state, 

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(latgeopoint AS STRING)), ''), ',', '.')
            AS FLOAT64
        ) AS latgeopoint, 

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(longeopoint AS STRING)), ''), ',', '.')
            AS FLOAT64
        ) AS longeopoint,

        CAST(daytime_operation AS STRING) AS daytime_operation,
        CAST(nighttime_operation AS STRING) AS nighttime_operation,
        'private' AS airport_type

    FROM {{ ref('stg_private_airports') }}
    WHERE airport_code IS NOT NULL

    UNION ALL

    SELECT 
        CAST(airport_code AS STRING) AS airport_code, 
        CAST(name AS STRING) AS name, 
        CAST(city AS STRING) AS city, 
        CAST(state AS STRING) AS state, 

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(latgeopoint AS STRING)), ''), ',', '.')
            AS FLOAT64
        ) AS latgeopoint, 

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(longeopoint AS STRING)), ''), ',', '.')
            AS FLOAT64
        ) AS longeopoint,

        CAST(daytime_operation AS STRING) AS daytime_operation,
        CAST(nighttime_operation AS STRING) AS nighttime_operation,
        'public' AS airport_type

    FROM {{ ref('stg_public_airports') }}
    WHERE airport_code IS NOT NULL
),

dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY airport_code
            ORDER BY 
                CASE 
                    WHEN airport_type = 'public' THEN 1
                    WHEN airport_type = 'private' THEN 2
                    ELSE 3
                END
        ) AS rn
    FROM base
)

SELECT
    ROW_NUMBER() OVER (ORDER BY airport_code) AS airport_id,
    airport_code, 
    name, 
    city, 
    state, 
    latgeopoint, 
    longeopoint,
    daytime_operation,
    nighttime_operation,
    airport_type
FROM dedup
WHERE rn = 1