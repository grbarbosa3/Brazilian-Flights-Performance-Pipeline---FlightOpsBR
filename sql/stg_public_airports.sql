DROP TABLE IF EXISTS stg_public_airports;

CREATE TABLE stg_public_airports AS
WITH base AS (
    SELECT
        NULLIF(TRIM(codigo_oaci), '') AS airport_code,
        INITCAP(TRIM(nome)) || ' (' || TRIM(codigo_oaci) || ')' AS name,
        INITCAP(TRIM(municipio)) AS city,
        TRIM(uf) AS state,
        longitude,
        latitude,
        CAST(REPLACE(NULLIF(TRIM(altitude), ''), ',', '.') AS NUMERIC) AS altitude,
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
        latgeopoint,
        longeopoint
    FROM public_airports
)
SELECT DISTINCT ON (airport_code)
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
FROM base
WHERE airport_code IS NOT NULL
ORDER BY airport_code, name;