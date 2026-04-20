{{ config(materialized='table') }}

WITH base AS (
    SELECT 
        NULLIF(TRIM(CAST(codigo_oaci AS STRING)), '') AS airport_code,

        CONCAT(
            INITCAP(TRIM(CAST(nome AS STRING))),
            ' (',
            TRIM(CAST(codigo_oaci AS STRING)),
            ')'
        ) AS name,

        INITCAP(TRIM(CAST(municipio AS STRING))) AS city,
        TRIM(CAST(uf AS STRING)) AS state,

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(longitude AS STRING)), ''), ',', '.')
            AS FLOAT64
        ) AS longitude,

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(latitude AS STRING)), ''), ',', '.')
            AS FLOAT64
        ) AS latitude,

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(altitude AS STRING)), ''), ',', '.')
            AS NUMERIC
        ) AS altitude,

        CASE 
            WHEN operacao_diurna = 'VFR' THEN 'Visual Flight'
            WHEN operacao_diurna = 'VFR / IFR' THEN 'Visual and Instrument Flight'
            ELSE 'No Info'
        END AS daytime_operation,

        CASE
            WHEN operacao_noturna = 'VFR' THEN 'Visual Flight'
            WHEN operacao_noturna = 'VFR / IFR' THEN 'Visual and Instrument Flight'
            WHEN operacao_noturna = 'Sem Operação' THEN 'No Operation'
            ELSE 'No Info'
        END AS nighttime_operation,

        TRIM(CAST(designacao_1 AS STRING)) AS runway_designation_1,

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(comprimento_1 AS STRING)), ''), ',', '.')
            AS NUMERIC
        ) AS runway_length_1,

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(largura_1 AS STRING)), ''), ',', '.')
            AS NUMERIC
        ) AS runway_width_1,

        TRIM(CAST(resistencia_1 AS STRING)) AS pavement_strength_1,
        TRIM(CAST(superficie_1 AS STRING)) AS surface_type_1,

        TRIM(CAST(designacao_2 AS STRING)) AS runway_designation_2,

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(comprimento_2 AS STRING)), ''), ',', '.')
            AS NUMERIC
        ) AS runway_length_2,

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(largura_2 AS STRING)), ''), ',', '.')
            AS NUMERIC
        ) AS runway_width_2,

        TRIM(CAST(resistencia_2 AS STRING)) AS pavement_strength_2,
        TRIM(CAST(superficie_2 AS STRING)) AS surface_type_2,

        TRIM(CAST(portaria_de_registro AS STRING)) AS reg_ordinance,
        TRIM(CAST(link_portaria AS STRING)) AS ordinance_url,

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(latgeopoint AS STRING)), ''), ',', '.')
            AS FLOAT64
        ) AS latgeopoint,

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(longeopoint AS STRING)), ''), ',', '.')
            AS FLOAT64
        ) AS longeopoint

    FROM {{ source('raw', 'raw_private_airports') }}
),

dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY airport_code
            ORDER BY name
        ) AS rn
    FROM base
    WHERE airport_code IS NOT NULL
)

SELECT
    airport_code,
    name,
    city,
    state,
    longitude,
    latitude,
    altitude,
    daytime_operation,
    nighttime_operation,
    runway_designation_1,
    runway_length_1,
    runway_width_1,
    pavement_strength_1,
    surface_type_1,
    runway_designation_2,
    runway_length_2,
    runway_width_2,
    pavement_strength_2,
    surface_type_2,
    reg_ordinance,
    ordinance_url,
    latgeopoint,
    longeopoint
FROM dedup
WHERE rn = 1
