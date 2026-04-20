-- TOP AIRPORTS BY DEPARTURES

SELECT airport_departure,city_departure, COUNT(flight_number) AS number_of_flights
FROM fact_flights
GROUP BY airport_departure,city_departure
ORDER BY number_of_flights DESC

-- TOP AIRPORTS BY ARRIVAL

SELECT airport_arrival,city_departure, COUNT(flight_number) AS number_of_flights
FROM fact_flights
GROUP BY airport_arrival,city_departure
ORDER BY number_of_flights DESC

-- AVERAGE DEPARTURE DELAY BY AIRLINE

SELECT airline_code,airline_name,AVG(departure_delay_minutes) AS avg_dep_delay_minutes
FROM fact_flights
WHERE departure_delay_minutes >10 AND airline_name IS NOT NULL
GROUP BY airline_code, airline_name
ORDER BY avg_dep_delay_minutes DESC

-- AVERAGE ARRIVAL DELAY BY AIRLINE

SELECT airline_code,airline_name,AVG(arrival_delay_minutes) AS avg_arr_delay_minutes
FROM fact_flights
WHERE arrival_delay_minutes >=10 AND airline_name IS NOT NULL
GROUP BY airline_code, airline_name
ORDER BY avg_arr_delay_minutes DESC

-- AVERAGE DEPARTURE DELAY BY AIR SHUTTLE

SELECT CONCAT(city_departure,' -> ',city_arrival) AS air_shuttle,
		AVG(departure_delay_minutes) AS avg_dep_delay_minutes
FROM fact_flights
WHERE departure_delay_minutes >10
GROUP BY air_shuttle
ORDER BY avg_dep_delay_minutes DESC

-- AVERAGE ARRIVAL DELAY BY AIR SHUTTLE

SELECT CONCAT(city_departure,' -> ',city_arrival) AS air_shuttle,
		AVG(arrival_delay_minutes) AS avg_arr_delay_minutes
FROM fact_flights
WHERE arrival_delay_minutes >10
GROUP BY air_shuttle
ORDER BY avg_arr_delay_minutes DESC

-- CANCELLED FLIGHTS BY AIRLINE

SELECT airline_name,SUM(cancelled_flag) as n_cancelled_flights
FROM fact_flights
WHERE airline_name IS NOT NULL
GROUP BY airline_name
ORDER BY n_cancelled_flights DESC