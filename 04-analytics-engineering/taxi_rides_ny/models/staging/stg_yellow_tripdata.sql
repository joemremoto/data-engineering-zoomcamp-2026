SELECT
    CAST(vendorid AS INT) AS  vendor_id,
    CAST(ratecodeid AS INT) AS  rate_code_id,
    CAST(PULOCATIONID AS INT) AS  pickup_location_id,
    CAST(DOLOCATIONID AS INT) AS  dropoff_location_id,

    CAST(tpep_pickup_datetime AS TIMESTAMP) AS pickup_datetime,
    CAST(tpep_dropoff_datetime AS TIMESTAMP) AS dropoff_datetime,

    store_and_fwd_flag,
    CAST(passenger_count AS INT) AS passenger_count,
    CAST(trip_distance AS FLOAT) AS trip_distance,
    1 AS trip_type, -- yellow taxi can only do street-hail trips

    CAST(fare_amount AS NUMERIC) AS fare_amount,
    CAST(extra AS NUMERIC) AS extra,
    CAST(mta_tax AS NUMERIC) AS mta_tax,
    CAST(tip_amount AS NUMERIC) AS tip_amount,
    CAST(tolls_amount AS NUMERIC) AS tolls_amount,
    0 AS ehail_fee, -- yellow taxi doesn't have ehail fee
    CAST(improvement_surcharge AS NUMERIC) AS improvement_surcharge,
    CAST(total_amount AS NUMERIC) AS total_amount,
    CAST(payment_type AS INT) AS payment_type

FROM {{ source('raw_data', 'yellow_tripdata') }} -- taxi_rides_ny.prod.yellow_tripdata if hardcoded
WHERE vendorid IS NOT NULL