{{
  config(
    materialized='table',
    pre_hook="SET preserve_insertion_order = false"
  )
}}

WITH create_id AS (
    SELECT
        {{dbt_utils.generate_surrogate_key([
            'itu.pickup_datetime',
            'itu.dropoff_datetime',
            'itu.pickup_location_id',
            'itu.dropoff_location_id',
            'itu.vendor_id'
        ])
        }} AS trip_id,
        itu.vendor_id,
        itu.service_type,
        itu.rate_code_id,

        -- location details
        itu.pickup_location_id,
        dz_pickup.borough AS pickup_borough,
        dz_pickup.zone AS pickup_zone,
        itu.dropoff_location_id,
        dz_dropoff.borough AS dropoff_borough,
        dz_dropoff.zone AS dropoff_zone,

        -- timestamps
        itu.pickup_datetime,
        itu.dropoff_datetime,

        -- trip details
        itu.store_and_fwd_flag,
        itu.passenger_count,
        CAST(itu.trip_distance AS NUMERIC) AS trip_distance,
        itu.trip_type,
        DATE_DIFF('minute', itu.pickup_datetime, itu.dropoff_datetime) AS trip_duration_minutes,
        
        CAST(itu.fare_amount AS NUMERIC) AS fare_amount,
        CAST(itu.extra AS NUMERIC) AS extra,
        CAST(itu.mta_tax AS NUMERIC) AS mta_tax,
        CAST(itu.tip_amount AS NUMERIC) AS tip_amount,
        CAST(itu.tolls_amount AS NUMERIC) AS tolls_amount,
        CAST(itu.ehail_fee AS NUMERIC) AS ehail_fee,
        CAST(itu.improvement_surcharge AS NUMERIC) AS improvement_surcharge,
        CAST(itu.total_amount AS NUMERIC) AS total_amount,

        itu.payment_type,
        {{ get_payment_type('itu.payment_type') }} AS payment_type_description,
        ROW_NUMBER() OVER (PARTITION BY
            itu.pickup_datetime,
            itu.dropoff_datetime,
            itu.pickup_location_id,
            itu.dropoff_location_id,
            itu.vendor_id  -- Now properly prefixed
        ) AS row_num
    FROM {{ ref('int_trips_union') }} itu
    LEFT JOIN {{ ref("dim_vendors")}} dv
        ON itu.vendor_id = dv.vendor_id
    LEFT JOIN {{ ref("dim_zones")}} dz_pickup
        ON itu.pickup_location_id = dz_pickup.location_id
    LEFT JOIN {{ ref("dim_zones")}} dz_dropoff
        ON itu.dropoff_location_id = dz_dropoff.location_id
)

SELECT 
    trip_id,
    vendor_id,
    service_type,
    rate_code_id,
    pickup_location_id,
    pickup_borough,
    pickup_zone,
    dropoff_location_id,
    dropoff_borough,
    dropoff_zone,
    pickup_datetime,
    dropoff_datetime,
    store_and_fwd_flag,
    passenger_count,
    trip_distance,
    trip_type,
    trip_duration_minutes,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    ehail_fee,
    improvement_surcharge,
    total_amount,
    payment_type,
    payment_type_description
FROM create_id
WHERE row_num = 1