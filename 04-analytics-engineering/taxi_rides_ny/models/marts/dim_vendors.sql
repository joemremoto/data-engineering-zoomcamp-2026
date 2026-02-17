WITH trips_union AS (
    SELECT *
    FROM {{ ref('int_trips_union') }}
)

, vendors AS (
    SELECT DISTINCT
        vendor_id
    FROM trips_union
)

SELECT
    *
    , {{get_vendor_names('vendor_id') }} AS vendor_name
FROM vendors