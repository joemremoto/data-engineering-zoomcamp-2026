SELECT DISTINCT service_type, COUNT(*) as count
FROM taxi_rides_ny.dev.fct_trips
GROUP BY service_type
ORDER BY count DESC;