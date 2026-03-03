/* @bruin

# Docs:
# - SQL assets: https://getbruin.com/docs/bruin/assets/sql
# - Materialization: https://getbruin.com/docs/bruin/assets/materialization
# - Quality checks: https://getbruin.com/docs/bruin/quality/available_checks

name: reports.trips_report

type: duckdb.sql

depends:
  - staging.trips

materialization:
  type: table

columns:
  - name: pickup_date
    type: date
    description: Date of trip pickup
    primary_key: true
    checks:
      - name: not_null
  - name: taxi_type
    type: varchar
    description: Type of taxi (yellow or green)
    primary_key: true
    checks:
      - name: not_null
  - name: payment_type_name
    type: varchar
    description: Payment method description
    primary_key: true
  - name: total_trips
    type: bigint
    description: Total number of trips
    checks:
      - name: non_negative
      - name: positive
  - name: avg_trip_distance
    type: double
    description: Average trip distance in miles
    checks:
      - name: non_negative
  - name: avg_passenger_count
    type: double
    description: Average number of passengers per trip

custom_checks:
  - name: row_count_positive
    description: Ensure the staging has at least one row
    query: |
      SELECT COUNT(*) > 0 FROM staging.trips
    value: 1

@bruin */

-- Reports layer: Daily aggregation of trip metrics by taxi type and payment method
--
-- This report provides business analytics including:
-- - Daily trip counts and revenue by taxi type and payment method
-- - Average metrics for fare, distance, and passenger count
-- - Tip collection analysis
--
-- Designed for dashboards and business intelligence tools

SELECT
    -- Dimension columns (GROUP BY keys)
    CAST(pickup_datetime AS DATE) AS pickup_date,
    taxi_type,
    COALESCE(payment_type_name, 'Unknown') AS payment_type_name,
    
    -- Aggregate metrics
    COUNT(*) AS total_trips,
    SUM(total_amount) AS total_revenue,
    AVG(fare_amount) AS avg_fare_amount,
    AVG(trip_distance) AS avg_trip_distance,
    AVG(passenger_count) AS avg_passenger_count,
    SUM(tip_amount) AS total_tip_amount,
    
    -- Additional revenue breakdown
    SUM(fare_amount) AS total_fare,
    SUM(extra) AS total_extra,
    SUM(mta_tax) AS total_mta_tax,
    SUM(tolls_amount) AS total_tolls,
    SUM(improvement_surcharge) AS total_surcharge

FROM staging.trips
WHERE 
    -- Filter to requested time window for incremental processing
    pickup_datetime >= '{{ start_datetime }}'
    AND pickup_datetime < '{{ end_datetime }}'
    -- Filter out invalid trips
    AND total_amount IS NOT NULL
    AND trip_distance >= 0
GROUP BY 
    CAST(pickup_datetime AS DATE),
    taxi_type,
    COALESCE(payment_type_name, 'Unknown')
ORDER BY 
    pickup_date DESC,
    taxi_type,
    payment_type_name
