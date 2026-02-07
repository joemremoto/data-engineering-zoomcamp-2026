-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `kestra-sandbox-485700.zoomcamp.external_yellow_tripdata_hw`
OPTIONS (
  format = 'parquet',
  uris = [
    'gs://jrem-zoomcamp-kestra-demo/2024/yellow_tripdata_2024-01.parquet',
    'gs://jrem-zoomcamp-kestra-demo/2024/yellow_tripdata_2024-02.parquet',
    'gs://jrem-zoomcamp-kestra-demo/2024/yellow_tripdata_2024-03.parquet',
    'gs://jrem-zoomcamp-kestra-demo/2024/yellow_tripdata_2024-04.parquet',
    'gs://jrem-zoomcamp-kestra-demo/2024/yellow_tripdata_2024-05.parquet',
    'gs://jrem-zoomcamp-kestra-demo/2024/yellow_tripdata_2024-06.parquet'
  ]
);
-- 0 bytes process

SELECT COUNT(*)
FROM `kestra-sandbox-485700.zoomcamp.external_yellow_tripdata_hw`;
-- 20332093

SELECT COUNT(DISTINCT PULocationID)
FROM `kestra-sandbox-485700.zoomcamp.external_yellow_tripdata_hw`;
-- 155.12 MB processed
-- 0 bytes estimated
-- 262


-- Create a non partitioned table from external table
CREATE OR REPLACE TABLE kestra-sandbox-485700.zoomcamp.non_partitioned_yellow_tripdata_hw AS
SELECT * FROM kestra-sandbox-485700.zoomcamp.external_yellow_tripdata_hw;
-- 2.72 GB processed

SELECT COUNT(DISTINCT PULocationID)
FROM `kestra-sandbox-485700.zoomcamp.non_partitioned_yellow_tripdata_hw`;
-- 155.12 MB estimated
-- 262

SELECT PULocationID
FROM `kestra-sandbox-485700.zoomcamp.non_partitioned_yellow_tripdata_hw`;
-- 155 MB

SELECT PULocationID, DOLocationID
FROM `kestra-sandbox-485700.zoomcamp.non_partitioned_yellow_tripdata_hw`;
-- 310 MB

SELECT COUNT(*)
FROM `kestra-sandbox-485700.zoomcamp.non_partitioned_yellow_tripdata_hw`
WHERE fare_amount = 0;
-- 8333

SELECT DISTINCT VendorID
FROM `kestra-sandbox-485700.zoomcamp.non_partitioned_yellow_tripdata_hw`
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' and '2024-03-15';
-- 310.24 MB
-- 1, 2, 6


CREATE OR REPLACE TABLE kestra-sandbox-485700.zoomcamp.yellow_tripdata_partitioned_clustered_hw
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM kestra-sandbox-485700.zoomcamp.external_yellow_tripdata_hw;
-- 5.5 GB processed


SELECT DISTINCT VendorID
FROM kestra-sandbox-485700.zoomcamp.yellow_tripdata_partitioned_clustered_hw
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' and '2024-03-15';
-- 26.84 MB
-- 6, 1, 2

SELECT COUNT(*)
FROM `kestra-sandbox-485700.zoomcamp.non_partitioned_yellow_tripdata_hw`
-- 0 B estimated
