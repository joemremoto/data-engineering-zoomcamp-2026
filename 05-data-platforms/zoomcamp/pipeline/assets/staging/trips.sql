/* @bruin
# Docs:
# - Materialization: https://getbruin.com/docs/bruin/assets/materialization
# - Quality checks (built-ins): https://getbruin.com/docs/bruin/quality/available_checks
# - Custom checks: https://getbruin.com/docs/bruin/quality/custom

name: staging.trips

type: duckdb.sql

depends:
  - ingestion.trips
  - ingestion.payment_lookup

materialization:
  type: table
  strategy: time_interval
  incremental_key: pickup_datetime
  time_granularity: timestamp


columns:
  - name: pickup_datetime
    type: timestamp
    description: Pickup timestamp
    checks:
      - name: not_null
  - name: vendor_id
    type: integer
    description: Vendor ID
    checks:
      - name: not_null
  - name: payment_type
    type: integer
    description: Payment type code
  - name: payment_type_name
    type: string
    description: Payment type description

custom_checks:
  - name: row_count_positive
    description: Ensure that the ingestion table has a positive number of rows
    query: |
      SELECT COUNT(*) > 0 FROM ingestion.trips
    value: 1

@bruin */

-- Staging layer: Clean, normalize, deduplicate, and enrich trip data
-- 
-- This layer handles differences between yellow and green taxi schemas,
-- removes duplicates using ROW_NUMBER(), joins with payment lookup,
-- and filters to the requested time window for incremental processing.

WITH normalized_trips AS (
    SELECT
        -- Normalize pickup/dropoff datetime columns (different names for yellow vs green)
        COALESCE(tpep_pickup_datetime, lpep_pickup_datetime) AS pickup_datetime,
        COALESCE(tpep_dropoff_datetime, lpep_dropoff_datetime) AS dropoff_datetime,
        
        -- Identifiers
        CAST(vendor_id AS INTEGER) AS vendor_id,
        CAST(ratecode_id AS INTEGER) AS rate_code_id,
        CAST(pu_location_id AS INTEGER) AS pickup_location_id,
        CAST(do_location_id AS INTEGER) AS dropoff_location_id,
        
        -- Trip details
        store_and_fwd_flag,
        CAST(passenger_count AS INTEGER) AS passenger_count,
        CAST(trip_distance AS DOUBLE) AS trip_distance,
        CAST(trip_type AS INTEGER) AS trip_type,
        
        -- Payment details
        CAST(fare_amount AS NUMERIC) AS fare_amount,
        CAST(extra AS NUMERIC) AS extra,
        CAST(mta_tax AS NUMERIC) AS mta_tax,
        CAST(tip_amount AS NUMERIC) AS tip_amount,
        CAST(tolls_amount AS NUMERIC) AS tolls_amount,
        CAST(improvement_surcharge AS NUMERIC) AS improvement_surcharge,
        CAST(total_amount AS NUMERIC) AS total_amount,
        CAST(payment_type AS INTEGER) AS payment_type,
        
        -- Metadata from ingestion
        taxi_type,
        extracted_at
        
    FROM ingestion.trips
    WHERE 
        -- Filter to requested time window for incremental processing
        COALESCE(tpep_pickup_datetime, lpep_pickup_datetime) >= '{{ start_datetime }}'
        AND COALESCE(tpep_pickup_datetime, lpep_pickup_datetime) < '{{ end_datetime }}'
        -- Filter out invalid records
        AND vendor_id IS NOT NULL
        AND COALESCE(tpep_pickup_datetime, lpep_pickup_datetime) IS NOT NULL
),

deduplicated_trips AS (
    SELECT
        *,
        -- Use ROW_NUMBER to identify duplicates (keep most recent extraction)
        ROW_NUMBER() OVER (
            PARTITION BY pickup_datetime, dropoff_datetime, vendor_id, pickup_location_id, passenger_count
            ORDER BY extracted_at DESC
        ) AS row_num
    FROM normalized_trips
)

-- Final select: Keep only unique records and enrich with payment lookup
SELECT
    t.pickup_datetime,
    t.dropoff_datetime,
    t.vendor_id,
    t.rate_code_id,
    t.pickup_location_id,
    t.dropoff_location_id,
    t.store_and_fwd_flag,
    t.passenger_count,
    t.trip_distance,
    t.trip_type,
    t.fare_amount,
    t.extra,
    t.mta_tax,
    t.tip_amount,
    t.tolls_amount,
    t.improvement_surcharge,
    t.total_amount,
    t.payment_type,
    p.payment_type_name,
    t.taxi_type,
    t.extracted_at
FROM deduplicated_trips t
LEFT JOIN ingestion.payment_lookup p
    ON t.payment_type = p.payment_type_id
WHERE t.row_num = 1