WITH taxi_zone_lookup AS (
    SELECT
        locationid AS location_id,
        borough AS borough,
        zone,
        service_zone
    FROM {{ ref('taxi_zone_lookup') }}
)

SELECT *
FROM taxi_zone_lookup