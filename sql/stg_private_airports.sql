DROP TABLE IF EXISTS stg_private_airports

CREATE TABLE stg_private_airports as
WITH base AS (
SELECT 
		codigo_oaci AS airport_code,
		INITCAP(nome) || ' (' || codigo_oaci || ')' AS "name",
		INITCAP(municipio) AS city,
		uf as "state",
		longitude,
		latitude,
		CAST(REPLACE(altitude, ',','.') as NUMERIC) AS altitude,
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
			designacao_1 AS runway_designation_1,
			REPLACE(comprimento_1,',','.') AS runway_lenght_1,
			REPLACE(largura_1,',','.') AS runway_width_1,
			REPLACE(resistencia_1,',','.') AS pavement_strength_1,
			superficie_1 AS surface_type_1,
			designacao_2 AS runway_designation_2,
			REPLACE(comprimento_2,',','.') AS runway_lenght_2,
			REPLACE(largura_2,',','.') AS runway_width_2,
			REPLACE(resistencia_2,',','.') AS pavement_strength_2,
			superficie_2 AS surface_type_2,
			portaria_de_registro AS reg_ordinance,
			link_portaria AS ordinance_url,
			REPLACE(latgeopoint,',','.')::DOUBLE PRECISION AS latgeopoint,
			REPLACE(longeopoint,',','.')::DOUBLE PRECISION AS longeopoint
			
FROM private_airports
)

SELECT DISTINCT ON (airport_code)
	airport_code,
	"name",
	city,
	"state",
	longitude,
	latitude,
	altitude,
	daytime_operation,
	nighttime_operation,
	runway_designation_1,
	runway_lenght_1,
	runway_width_1,
	pavement_strength_1,
	surface_type_1,
	runway_designation_2,
	runway_lenght_2,
	runway_width_2,
	pavement_strength_2,
	surface_type_2,
	reg_ordinance,
	ordinance_url,
	latgeopoint,
	longeopoint
FROM base
WHERE airport_code IS NOT NULL
ORDER BY airport_code, "name";