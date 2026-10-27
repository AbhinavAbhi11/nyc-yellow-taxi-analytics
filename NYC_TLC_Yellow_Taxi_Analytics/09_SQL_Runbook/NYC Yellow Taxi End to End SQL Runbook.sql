/*
NYC YELLOW TAXI ANALYTICS — END-TO-END SQL RUNBOOK
Database: nyc_taxi_analytics | MySQL Workbench

IMPORTANT:
- Save a backup before running DDL/DML.
- Run sections in order and execute expensive queries individually.
- This is a documented runbook, not a destructive reset script.
- Existing table names are based on the project schema.
- Verify source column names with SHOW COLUMNS before re-running raw ingestion
  or cleaning transformations; the original full ETL statements were not
  available to reconstruct verbatim.
- Current business-table timestamps report February 2026. Confirm source period
  and timestamp lineage before describing the source as February 2025.
*/

-- 00 | DATABASE
CREATE DATABASE IF NOT EXISTS nyc_taxi_analytics;
USE nyc_taxi_analytics;
SELECT DATABASE() AS active_database, VERSION() AS mysql_version;
SHOW FULL TABLES;

-- 01 | DISCOVER SOURCE AND PIPELINE SCHEMAS
SHOW COLUMNS FROM raw_yellow_taxi;
SHOW COLUMNS FROM raw_yellow_taxi_sample;
SHOW COLUMNS FROM stg_yellow_taxi;
SHOW COLUMNS FROM analytics_yellow_taxi;
SHOW COLUMNS FROM analytics_yellow_taxi_cleaned;
SHOW COLUMNS FROM analytics_yellow_taxi_distance_valid;
SHOW COLUMNS FROM analytics_yellow_taxi_final;
SHOW COLUMNS FROM analytics_yellow_taxi_business;

-- 02 | ROW COUNTS ACROSS PIPELINE LAYERS
SELECT 'raw_yellow_taxi' AS table_name, COUNT(*) AS row_count FROM raw_yellow_taxi
UNION ALL SELECT 'stg_yellow_taxi', COUNT(*) FROM stg_yellow_taxi
UNION ALL SELECT 'analytics_yellow_taxi', COUNT(*) FROM analytics_yellow_taxi
UNION ALL SELECT 'analytics_yellow_taxi_cleaned', COUNT(*) FROM analytics_yellow_taxi_cleaned
UNION ALL SELECT 'analytics_yellow_taxi_distance_valid', COUNT(*) FROM analytics_yellow_taxi_distance_valid
UNION ALL SELECT 'analytics_yellow_taxi_final', COUNT(*) FROM analytics_yellow_taxi_final
UNION ALL SELECT 'analytics_yellow_taxi_business', COUNT(*) FROM analytics_yellow_taxi_business;

SELECT * FROM raw_yellow_taxi LIMIT 10;

-- 03 | RAW INGESTION AND DATA-CLEANING WORKFLOW
-- Import the source CSV into raw_yellow_taxi with the source columns unchanged.
-- Preserve the raw layer. Record filename, source period and imported row count.
-- The original LOAD DATA / CREATE TABLE commands are not reproduced here:
-- verify exact CSV path, encoding, delimiter, column order and schema first.
--
-- Standard TLC column names often include tpep_pickup_datetime,
-- tpep_dropoff_datetime, trip_distance, fare_amount and total_amount.
-- Verify with SHOW COLUMNS before uncommenting/adapting these audit templates.

-- SELECT
--   COUNT(*) AS rows_checked,
--   SUM(tpep_pickup_datetime IS NULL) AS null_pickup,
--   SUM(tpep_dropoff_datetime IS NULL) AS null_dropoff,
--   SUM(trip_distance IS NULL) AS null_distance,
--   SUM(fare_amount IS NULL) AS null_fare,
--   SUM(total_amount IS NULL) AS null_total
-- FROM raw_yellow_taxi;

-- SELECT
--   SUM(trip_distance < 0) AS negative_distance_rows,
--   SUM(fare_amount < 0) AS negative_fare_rows,
--   SUM(total_amount < 0) AS negative_total_rows,
--   SUM(tpep_dropoff_datetime < tpep_pickup_datetime) AS negative_duration_rows,
--   SUM(tpep_dropoff_datetime = tpep_pickup_datetime) AS zero_duration_rows
-- FROM raw_yellow_taxi;

-- SELECT DATE(tpep_pickup_datetime) AS trip_date, COUNT(*) AS trips
-- FROM raw_yellow_taxi
-- GROUP BY DATE(tpep_pickup_datetime)
-- ORDER BY trip_date;

-- 04 | CLEANED / FINAL / BUSINESS LAYER CHECKS
SELECT COUNT(*) AS total_rows FROM analytics_yellow_taxi_business;

SELECT MIN(pickup_datetime) AS first_pickup,
       MAX(pickup_datetime) AS last_pickup,
       COUNT(*) AS total_rows
FROM analytics_yellow_taxi_business;

-- Verified project KPIs: expected 3,329,782 trips, $100,340,136.16 revenue,
-- $30.13 average revenue/trip, $4.78 revenue/mile, 17.64 minutes duration.
SELECT COUNT(*) AS total_trips,
       ROUND(SUM(total_amount), 2) AS total_revenue,
       ROUND(AVG(total_amount), 2) AS avg_revenue_per_trip,
       ROUND(SUM(total_amount) / NULLIF(SUM(trip_distance), 0), 2) AS revenue_per_mile,
       ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes
FROM analytics_yellow_taxi_business;

-- Observed date range is February 2026. February 23 is expected to be excluded.
SELECT DATE(pickup_datetime) AS trip_date,
       COUNT(*) AS total_trips,
       ROUND(SUM(total_amount), 2) AS total_revenue
FROM analytics_yellow_taxi_business
WHERE pickup_datetime >= '2026-02-22'
  AND pickup_datetime < '2026-02-25'
GROUP BY DATE(pickup_datetime)
ORDER BY trip_date;

SELECT COUNT(*) AS february_23_rows
FROM analytics_yellow_taxi_business
WHERE pickup_datetime >= '2026-02-23'
  AND pickup_datetime < '2026-02-24';

-- 05 | DAILY PERFORMANCE
SELECT * FROM business_daily_summary ORDER BY 1;
SELECT * FROM dm_daily_performance ORDER BY 1;
SELECT * FROM vw_daily_performance ORDER BY 1;

SELECT DATE(pickup_datetime) AS trip_date,
       COUNT(*) AS total_trips,
       ROUND(SUM(total_amount), 2) AS total_revenue,
       ROUND(AVG(total_amount), 2) AS avg_revenue_per_trip,
       ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes,
       ROUND(SUM(total_amount) / NULLIF(SUM(trip_distance), 0), 2) AS revenue_per_mile
FROM analytics_yellow_taxi_business
GROUP BY DATE(pickup_datetime)
ORDER BY trip_date;

-- 06 | HOURLY / DEMAND PERFORMANCE
SELECT * FROM analytics_hourly_summary ORDER BY 1;
SELECT * FROM dm_hourly_performance ORDER BY 1;
SELECT * FROM vw_hourly_performance ORDER BY 1;

SELECT HOUR(pickup_datetime) AS pickup_hour,
       COUNT(*) AS total_trips,
       ROUND(SUM(total_amount), 2) AS total_revenue,
       ROUND(AVG(total_amount), 2) AS avg_revenue_per_trip,
       ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes
FROM analytics_yellow_taxi_business
GROUP BY HOUR(pickup_datetime)
ORDER BY pickup_hour;

-- 07 | LOCATION AND AIRPORT TABLES
SELECT * FROM location_summary ORDER BY 1;
SELECT * FROM dm_location_performance ORDER BY 1;
SELECT * FROM analytics_pickup_location_summary ORDER BY 1;
SELECT * FROM location_efficiency ORDER BY 1;
SELECT * FROM location_opportunity_score ORDER BY 1;
SELECT * FROM location_strategy ORDER BY 1;

-- Inspect columns before filtering JFK / LaGuardia:
SHOW COLUMNS FROM location_summary;
-- Airport revenue here means pickup-zone revenue, not all airport-related trips.
-- Adapt after schema inspection:
-- SELECT <zone_name_column>, SUM(<revenue_column>) AS pickup_revenue
-- FROM location_summary
-- WHERE <zone_name_column> IN ('JFK Airport', 'LaGuardia Airport')
-- GROUP BY <zone_name_column>;

-- 08 | ROUTE ANALYTICS
SELECT * FROM route_summary ORDER BY 1;
SELECT * FROM route_performance ORDER BY 1;
SELECT * FROM route_directionality ORDER BY 1;
SELECT * FROM route_directionality_analysis ORDER BY 1;
SELECT * FROM route_intelligence ORDER BY 1;
SELECT * FROM route_strategy ORDER BY 1;

SHOW COLUMNS FROM route_directionality_analysis;

SELECT COUNT(*) AS route_rows,
       SUM(imbalance_pct >= 50) AS rows_with_imbalance_at_least_50_pct,
       ROUND(SUM(ABS(revenue_difference)), 2) AS gross_absolute_revenue_difference
FROM route_directionality_analysis;

-- Gross absolute revenue difference is NOT recoverable revenue or profit.

-- 09 | OPPORTUNITIES AND EXECUTIVE TABLES
SELECT * FROM business_opportunities ORDER BY 1;
SELECT * FROM dm_business_opportunities ORDER BY 1;
SELECT * FROM executive_dashboard ORDER BY 1;
SELECT * FROM dm_executive_dashboard ORDER BY 1;
SELECT * FROM executive_kpi ORDER BY 1;
SELECT * FROM executive_insights ORDER BY 1;

SELECT priority, COUNT(DISTINCT opportunity_id) AS opportunity_count
FROM business_opportunities
GROUP BY priority
ORDER BY opportunity_count DESC;

SELECT opportunity_type, priority,
       COUNT(DISTINCT opportunity_id) AS opportunity_count
FROM business_opportunities
GROUP BY opportunity_type, priority
ORDER BY opportunity_type, priority;

-- 10 | REVENUE SCENARIOS
SELECT * FROM revenue_scenarios ORDER BY 1;
SELECT * FROM revenue_scenario_analysis ORDER BY 1;

-- Illustrative scenario only; not a forecast or guaranteed recoverable revenue.
SELECT improvement_rate_pct,
       ROUND(100340136.16 * improvement_rate_pct / 100, 2) AS illustrative_revenue_upside,
       ROUND(100340136.16 * (1 + improvement_rate_pct / 100), 2) AS illustrative_projected_revenue
FROM (
    SELECT 1 AS improvement_rate_pct
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 5
) AS scenarios
ORDER BY improvement_rate_pct;

-- 11 | FINAL DATA-QUALITY RECONCILIATION
SELECT SUM(pickup_datetime IS NULL) AS null_pickup_datetime,
       SUM(total_amount IS NULL) AS null_total_amount,
       SUM(trip_distance IS NULL) AS null_trip_distance,
       SUM(trip_duration_minutes IS NULL) AS null_trip_duration
FROM analytics_yellow_taxi_business;

SELECT SUM(trip_distance < 0) AS negative_distance_rows,
       SUM(total_amount < 0) AS negative_total_amount_rows,
       SUM(trip_duration_minutes < 0) AS negative_duration_rows
FROM analytics_yellow_taxi_business;

-- 12 | PORTFOLIO CHECKLIST
-- [ ] Record the exact TLC source URL, source filename, and actual source month/year.
-- [ ] Document row counts at raw, staging, cleaned, final and business layers.
-- [ ] Document each cleaning rule and the evidence for excluding February 23.
-- [ ] Resolve the current February 2026 timestamp range vs. originally described
--     February 2025 source before publishing.
-- [ ] Describe JFK/LaGuardia results as pickup-zone revenue.
-- [ ] Label 1/2/3/5% revenue calculations as illustrative scenarios.
-- [ ] Test the full ETL on a fresh database copy before claiming reproducibility.
-- END
