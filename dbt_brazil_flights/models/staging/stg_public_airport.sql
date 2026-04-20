{{ config(materialized='table') }}

WITH base AS (
    SELECT
        NULLIF(TRIM(CAST(codigo_oaci AS STRING)), '') AS airport_code,

        INITCAP(TRIM(CAST(nome AS STRING))) 
            || ' (' || TRIM(CAST(codigo_oaci AS STRING)) || ')' AS name,

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
            WHEN operacao_diurna = 'VFR / IRF Não Precisão' THEN 'Visual and Non-Precision Instrument'
            WHEN operacao_diurna = 'VFR / IFR - CAT II' THEN 'Instrument CAT II'
            WHEN operacao_diurna = 'VFR / IFR - CAT I' THEN 'Instrument CAT I'
            WHEN operacao_diurna = 'VFR / IFR - CAT III A' THEN 'Instrument CAT III A'
            WHEN operacao_diurna = 'VFR' THEN 'Visual Flight'
            ELSE 'No Info'
        END AS daytime_operation,

        CASE
            WHEN operacao_noturna = 'VFR / IRF Não Precisão' THEN 'Visual and Non-Precision Instrument'
            WHEN operacao_noturna = 'VFR / IFR - CAT II' THEN 'Instrument CAT II'
            WHEN operacao_noturna = 'VFR / IFR - CAT I' THEN 'Instrument CAT I'
            WHEN operacao_noturna = 'VFR / IFR - CAT III A' THEN 'Instrument CAT III A'
            WHEN operacao_noturna = 'VFR' THEN 'Visual Flight'
            WHEN operacao_noturna = 'IFR Não Precisão' THEN 'Non-Precision Instrument'
            WHEN operacao_noturna = 'Sem Operação' THEN 'No Operation'
            ELSE 'No Info'
        END AS nighttime_operation,

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(latgeopoint AS STRING)), ''), ',', '.') 
            AS FLOAT64
        ) AS latgeopoint,

        SAFE_CAST(
            REPLACE(NULLIF(TRIM(CAST(longeopoint AS STRING)), ''), ',', '.') 
            AS FLOAT64
        ) AS longeopoint

    FROM {{ source('raw', 'raw_public_airports') }}
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
    latgeopoint,
    longeopoint
FROM dedup
WHERE rn = 1