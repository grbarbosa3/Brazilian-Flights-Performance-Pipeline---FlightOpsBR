DROP TABLE IF EXISTS stg_flights;




CREATE TABLE stg_flights as
SELECT  icao_empresa_aerea AS aircompany_code,
		numero_voo AS flight_number,
			CASE 
			 	WHEN codigo_autorizacao_di = '0' THEN 'Regular Leg'
			 	WHEN codigo_autorizacao_di = '1' THEN 'Non-Regular Leg'
			 	WHEN codigo_autorizacao_di = '2' THEN 'Extra Leg'
			 	WHEN codigo_autorizacao_di = '3' THEN 'Return Leg'
			 	WHEN codigo_autorizacao_di = '4' THEN 'Leg Inclusion'
			 	WHEN codigo_autorizacao_di = '6' THEN 'Unpaid Leg'
			 	WHEN codigo_autorizacao_di = '7' THEN 'Chartred Flight Leg'
			 	WHEN codigo_autorizacao_di = '9' THEN 'Charter Flight Leg'
			 	WHEN codigo_autorizacao_di = 'D' THEN 'Duplicate Flight Leg'
			 	ELSE 'Others'
			 		END as flight_type,
			CASE 
				WHEN codigo_tipo_linha = 'N' THEN 'Domestic Mixed'
				WHEN codigo_tipo_linha = 'C' THEN 'Domestic Cargo'
				WHEN codigo_tipo_linha = 'G' THEN 'International Cargo'
				WHEN codigo_tipo_linha = 'I' THEN 'International Mixed'
				WHEN codigo_tipo_linha = 'X' THEN 'Undefined'
				
				ELSE 'Others'
					END as operation_type,
		icao_aerodromo_origem AS departure_airport_code,
		icao_aerodromo_destino AS arrival_airport_code,
    	NULLIF(partida_prevista, '')::timestamp as est_departure_ts,
    	NULLIF(partida_real, '')::timestamp as real_departure_ts,
    	NULLIF(chegada_prevista, '')::timestamp as est_arrival_ts,
    	NULLIF(chegada_real, '')::timestamp as real_arrival_ts,
			CASE
				WHEN situacao_voo = 'NÃO INFORMADO' THEN 'Not Reported'
				WHEN situacao_voo = 'REALIZADO' THEN 'Done'
				WHEN situacao_voo = 'CANCELADO' THEN 'Cancelled'
				WHEN situacao_voo = 'CANCELADO' THEN 'Cancelled'
				ELSE 'Others'
					END AS status_flight

FROM brazil_flights
