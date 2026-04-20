{{ config(materialized='table') }}

WITH enriched AS (
    SELECT
        f.aircompany_code AS airline_code,
        air.aircompany_name AS airline_name,
        f.flight_number,
        f.flight_type,
        f.operation_type,

        f.departure_airport_code,
        dep.name AS airport_departure,
        dep.city AS city_departure,
        dep.state AS state_departure,

        f.est_departure_ts,
        f.real_departure_ts,

        ROUND(
            SAFE_CAST(
                TIMESTAMP_DIFF(f.real_departure_ts, f.est_departure_ts, SECOND) AS NUMERIC
            ) / 60,
            2
        ) AS departure_delay_minutes,

        f.arrival_airport_code,
        arr.name AS airport_arrival,
        arr.city AS city_arrival,
        arr.state AS state_arrival,

        f.est_arrival_ts,
        f.real_arrival_ts,

        ROUND(
            SAFE_CAST(
                TIMESTAMP_DIFF(f.real_arrival_ts, f.est_arrival_ts, SECOND) AS NUMERIC
            ) / 60,
            2
        ) AS arrival_delay_minutes,

        f.status_flight,

        CASE 
            WHEN f.status_flight = 'Cancelled' THEN 1 
            ELSE 0 
        END AS cancelled_flag

    FROM {{ ref('stg_flights') }} f

    LEFT JOIN {{ ref('dim_airports') }} dep
        ON f.departure_airport_code = dep.airport_code

    LEFT JOIN {{ ref('dim_airports') }} arr
        ON f.arrival_airport_code = arr.airport_code

    LEFT JOIN {{ ref('stg_aircompany') }} air 
        ON f.aircompany_code = air.aircompany_code

    WHERE air.aircompany_name IS NOT NULL
      AND f.departure_airport_code IS NOT NULL
      AND f.arrival_airport_code IS NOT NULL
),

deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                airline_code,
                flight_number,
                departure_airport_code,
                arrival_airport_code,
                est_departure_ts,
                est_arrival_ts
            ORDER BY
                CASE WHEN status_flight = 'Done' THEN 1 ELSE 2 END,
                CASE WHEN real_departure_ts IS NULL THEN 1 ELSE 0 END,
                real_departure_ts,
                CASE WHEN real_arrival_ts IS NULL THEN 1 ELSE 0 END,
                real_arrival_ts
        ) AS rn
    FROM enriched
)

SELECT
    airline_code,
    airline_name,
    flight_number,
    flight_type,
    operation_type,

    departure_airport_code,
    airport_departure,
    city_departure,
    state_departure,

    est_departure_ts,
    real_departure_ts,
    departure_delay_minutes,

    CASE
        WHEN departure_delay_minutes IS NULL THEN 0
        WHEN departure_delay_minutes < -60 THEN 1
        WHEN departure_delay_minutes > 1440 THEN 1
        ELSE 0
    END AS is_departure_delay_outlier,

    arrival_airport_code,
    airport_arrival,
    city_arrival,
    state_arrival,

    est_arrival_ts,
    real_arrival_ts,
    arrival_delay_minutes,

    CASE
        WHEN arrival_delay_minutes IS NULL THEN 0
        WHEN arrival_delay_minutes < -60 THEN 1
        WHEN arrival_delay_minutes > 1440 THEN 1
        ELSE 0
    END AS is_arrival_delay_outlier,

    status_flight,
    cancelled_flag

FROM deduped
WHERE rn = 1