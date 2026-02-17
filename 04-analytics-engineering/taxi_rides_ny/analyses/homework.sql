SELECT COUNT(*) AS count_records
FROM {{ref("fct_monthly_zone_revenue")}};
-- 12,184


SELECT DISTINCT revenue_month
FROM {{ref("fct_monthly_zone_revenue")}};

SELECT
    pickup_zone,
    SUM(revenue_monthly_total_amount) AS total_revenue_2020
FROM {{ref("fct_monthly_zone_revenue")}}
WHERE service_type = 'Green'
    AND revenue_month BETWEEN '2020-01-01' AND '2020-12-31'
GROUP BY pickup_zone
QUALIFY ROW_NUMBER() OVER (ORDER BY total_revenue_2020 DESC) = 1;
-- ckup_zone	total_revenue_2020
-- East Harlem North	1829283.85

SELECT
    revenue_month,
    SUM(total_monthly_trips) AS total_trips_2019_10
FROM {{ref("fct_monthly_zone_revenue")}}
WHERE service_type = 'Green'
    AND revenue_month = '2019-10-01'
GROUP BY revenue_month
QUALIFY ROW_NUMBER() OVER (ORDER BY total_trips_2019_10 DESC) = 1;
-- revenue_month	total_trips_2019_10
-- 2019-10-01	385892