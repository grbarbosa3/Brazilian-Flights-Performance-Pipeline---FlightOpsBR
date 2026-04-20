CREATE TABLE dim_airports AS
WITH base AS ( 
    SELECT 
        airport_code::text AS airport_code, 
        "name"::text AS "name", 
        city::text AS city, 
        "state"::text AS "state", 
        NULLIF(REPLACE(latgeopoint::text, ',', '.'), '')::double precision AS latgeopoint, 
        NULLIF(REPLACE(longeopoint::text, ',', '.'), '')::double precision AS longeopoint,
        daytime_operation::text AS daytime_operation,
        nighttime_operation::text AS nighttime_operation,
        'private'::text AS airport_type
    FROM stg_private_airports
    WHERE airport_code IS NOT NULL

    UNION ALL

    SELECT 
        airport_code::text, 
        "name"::text, 
        city::text, 
        "state"::text, 
        NULLIF(REPLACE(latgeopoint::text, ',', '.'), '')::double precision, 
        NULLIF(REPLACE(longeopoint::text, ',', '.'), '')::double precision,
        daytime_operation::text,
        nighttime_operation::text,
        'public'::text AS airport_type
    FROM stg_public_airports
    WHERE airport_code IS NOT NULL

    UNION ALL 

    SELECT 
        airport_code::text,
        "name"::text,
        city::text,
        "state"::text,
        NULLIF(REPLACE(latgeopoint::text, ',', '.'), '')::double precision,
        NULLIF(REPLACE(longeopoint::text, ',', '.'), '')::double precision,
        daytime_operation::text,
        nighttime_operation::text,
        airport_type::text
    FROM stg_international_airports
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
    "name", 
    city, 
    "state", 
    latgeopoint, 
    longeopoint,
    daytime_operation,
    nighttime_operation,
    airport_type
FROM dedup
WHERE rn = 1;
