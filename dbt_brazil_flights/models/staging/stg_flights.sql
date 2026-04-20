{{ config(materialized='table') }}

SELECT  
    TRIM(CAST(icao_empresa_aerea AS STRING)) AS aircompany_code,
    TRIM(CAST(numero_voo AS STRING)) AS flight_number,
    CASE 
        WHEN codigo_autorizacao_di = '0' THEN 'Regular Leg'
        WHEN codigo_autorizacao_di = '1' THEN 'Non-Regular Leg'
        WHEN codigo_autorizacao_di = '2' THEN 'Extra Leg'
        WHEN codigo_autorizacao_di = '3' THEN 'Return Leg'
        WHEN codigo_autorizacao_di = '4' THEN 'Leg Inclusion'
        WHEN codigo_autorizacao_di = '6' THEN 'Unpaid Leg'
        WHEN codigo_autorizacao_di = '7' THEN 'Chartered Flight Leg'
        WHEN codigo_autorizacao_di = '9' THEN 'Charter Flight Leg'
        WHEN codigo_autorizacao_di = 'D' THEN 'Duplicate Flight Leg'
        ELSE 'Others'
    END AS flight_type,
    CASE 
        WHEN codigo_tipo_linha = 'N' THEN 'Domestic Mixed'
        WHEN codigo_tipo_linha = 'C' THEN 'Domestic Cargo'
        WHEN codigo_tipo_linha = 'G' THEN 'International Cargo'
        WHEN codigo_tipo_linha = 'I' THEN 'International Mixed'
        WHEN codigo_tipo_linha = 'X' THEN 'Undefined'
        ELSE 'Others'
    END AS operation_type,
    TRIM(CAST(icao_aerodromo_origem AS STRING)) AS departure_airport_code,
    TRIM(CAST(icao_aerodromo_destino AS STRING)) AS arrival_airport_code,
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', NULLIF(TRIM(partida_prevista), '')) AS est_departure_ts,
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', NULLIF(TRIM(partida_real), '')) AS real_departure_ts,
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', NULLIF(TRIM(chegada_prevista), '')) AS est_arrival_ts,
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', NULLIF(TRIM(chegada_real), '')) AS real_arrival_ts,
    CASE
        WHEN situacao_voo = 'NÃO INFORMADO' THEN 'Not Reported'
        WHEN situacao_voo = 'REALIZADO' THEN 'Done'
        WHEN situacao_voo = 'CANCELADO' THEN 'Cancelled'
        ELSE 'Others'
    END AS status_flight

FROM {{ source('raw', 'raw_brazil_flights') }}
WHERE icao_empresa_aerea IS NOT NULL
    AND numero_voo IS NOT NULL