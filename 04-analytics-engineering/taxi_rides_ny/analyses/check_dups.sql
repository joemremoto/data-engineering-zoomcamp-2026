/*
TODO:
    - one row per trip regardless of taxi type
    - add a primary key (trip_id) to the fact table
    - understand reason for duplications and deduplicate if necessary
    - find a way to enrich the column payment_type
*/



WITH create_id AS (
    SELECT
        MD5(
            CONCAT(
                CAST(pickup_datetime AS STRING),
                CAST(dropoff_datetime AS STRING),
                CAST(pickup_location_id AS STRING),
                CAST(dropoff_location_id AS STRING),
                CAST(vendor_id AS STRING)
            )
        ) AS trip_id, -- surrogate key for the fact table
        vendor_id,
        rate_code_id,
        pickup_location_id,
        dropoff_location_id,

        -- timestamps
        pickup_datetime,
        dropoff_datetime,

        -- trip details
        store_and_fwd_flag,
        passenger_count,
        trip_distance,
        trip_type, -- 1 for street-hail, 2 for ehail

        {{ get_payment_type('payment_type') }} AS payment_type,
        fare_amount,
        "extra",
        mta_tax,
        tip_amount,
        tolls_amount,
        ehail_fee,
        improvement_surcharge,
        total_amount
    FROM {{ ref('int_trips_union') }}
)

SELECT *
FROM create_id
WHERE trip_id IN (
    SELECT trip_id
    FROM create_id
    GROUP BY trip_id
    HAVING COUNT(*) > 1
)
