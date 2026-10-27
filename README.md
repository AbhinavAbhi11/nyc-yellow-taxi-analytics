# NYC Yellow Taxi Analytics | February 2026

An end-to-end data analytics project exploring New York City Yellow Taxi trip records for **February 2026**. The project uses **Parquet/CSV, MySQL, and Power BI** to turn trip-level data into validated performance metrics, interactive dashboards, and practical business recommendations.

> **Purpose:** Help stakeholders understand when taxi demand occurs, where pickup activity concentrates, how route patterns differ, and which operational opportunities deserve further testing.

## At a glance

| Item | Details |
|---|---|
| Reporting period | February 1–28, 2026 |
| Source | NYC Taxi & Limousine Commission (TLC) Yellow Taxi trip records |
| Data preparation | Parquet-to-CSV conversion and SQL-based processing |
| Database and analysis | MySQL |
| Visualization | Microsoft Power BI |
| Main outputs | Executive KPIs, time-based analysis, location analysis, route/airport analysis, business opportunities |
| Analytical business table | `analytics_yellow_taxi_business` |

## Business problem

Taxi operators need evidence to make operational decisions. They need to understand **when** demand is strongest, **where** trips and recorded revenue concentrate, **which routes** show directional differences, and **where to test** improvements in vehicle positioning and airport operations.

This project turns trip records into metrics and dashboards that support those questions. It is a decision-support analysis—not a live dispatch system or a causal study of what would happen after changing fleet capacity.

## Objectives

1. Prepare and inspect the February 2026 trip dataset.
2. Use MySQL to organize, clean, validate, and aggregate the data.
3. Analyze daily and hourly demand, pickup-location performance, route directionality, and airport pickup activity.
4. Build interactive Power BI dashboards for technical and non-technical audiences.
5. Translate findings into testable operational recommendations and clearly labeled illustrative scenarios.

## Technology stack

- **Parquet** — compact source-data format.
- **CSV** — intermediate format used for the project's import workflow.
- **MySQL / MySQL Workbench** — data loading, SQL transformations, quality checks, aggregations, and analytical tables.
- **Microsoft Power BI** — interactive reports, KPI cards, filters, and visual analysis.

## End-to-end workflow

```text
NYC TLC Yellow Taxi trip records (February 2026)
                    |
                    v
          Original Parquet source
                    |
                    v
           Convert Parquet to CSV
                    |
                    v
           Load records into MySQL
                    |
                    v
       Raw tables -> staging tables
                    |
                    v
     Data quality checks and cleaning
                    |
                    v
      Cleaned / final analytical data
                    |
                    v
 Daily | Hourly | Location | Route summaries
                    |
                    v
       KPI checks and SQL validation
                    |
                    v
             Power BI dashboards
                    |
                    v
 Business interpretation and pilot ideas
```

### How the flow works

1. **Collect:** Start with the TLC Yellow Taxi trip-record file for February 2026.
2. **Convert:** Convert Parquet into CSV for the MySQL import workflow. Conversion changes the file format; it does not clean or validate the data.
3. **Load:** Import records into MySQL raw tables.
4. **Prepare and clean:** Use staging and analytical tables to standardize fields and apply documented quality rules.
5. **Analyze:** Aggregate trips by date, hour, pickup location, route direction, and relevant airport pickup zones.
6. **Validate:** Reconcile row counts, date coverage, and key totals with SQL checks.
7. **Visualize:** Present prepared metrics in Power BI so stakeholders can filter and compare results.
8. **Act and measure:** Use dashboard patterns to design operational pilots, then measure service and financial outcomes before scaling.

## Dashboards

| Dashboard page | What it helps answer |
|---|---|
| Executive Dashboard | What is the overall operating picture? |
| Executive Overview | What patterns, priorities, and data-quality considerations need attention? |
| Demand & Time Intelligence | When does activity peak, and how does it vary over time? |
| Location Intelligence | Which pickup zones and boroughs contribute the most activity or recorded revenue? |
| Route & Airport Intelligence | Where are directional route differences, and how much recorded revenue is associated with airport pickups? |
| Business Opportunities | Which potential actions are worth evaluating, and what evidence supports them? |

## Selected analytical results

The following figures are from `analytics_yellow_taxi_business` and should be interpreted within the table's inclusion rules.

| Metric | Result |
|---|---:|
| Trips represented | 3,329,782 |
| Sum of recorded `total_amount` | $100,340,136.16 |
| Average recorded `total_amount` per trip | $30.13 |
| Recorded amount per aggregate trip mile | $4.78 |
| Average trip duration | 17.64 minutes |
| Pickup timestamp coverage | February 1–28, 2026 |

**Metric notes**

- `total_amount` is the recorded trip amount; it is not operator profit.
- `$4.78 per mile` is total recorded amount divided by total recorded trip distance, not the average of each trip's per-mile ratio.
- The timestamp range describes the business table. Validate raw-file coverage separately when documenting ingestion completeness.

## Business recommendations to evaluate

These are **testable opportunities**, not guaranteed outcomes. The dashboard identifies where to investigate; pilots determine whether a change works.

### 1. Test evening vehicle positioning
If hourly analysis confirms a recurring evening demand peak, pilot pre-positioning a limited number of available vehicles near high-demand pickup zones before the peak. Compare completed trips per available vehicle-hour, passenger wait time, empty miles, and net contribution with a comparable baseline.

### 2. Evaluate airport operations separately
Analyze JFK and LaGuardia pickup activity as separate operating markets. Review demand timing, queue or waiting time, trip mix, empty repositioning, and costs before changing airport vehicle allocation. Airport pickup revenue is not the same as total airport-related revenue for both trip directions.

### 3. Investigate high-activity pickup zones
Prioritize zones with sustained trip volume and strong recorded revenue, but account for operating costs, congestion, empty miles, and driver availability. High gross revenue alone does not prove that adding vehicles to a zone will improve profit.

### 4. Review directional route imbalances
Use route-direction analysis to identify routes with material differences in trip volume or recorded revenue by direction. Consider targeted repositioning or driver guidance only after validating sample sizes, time-of-day effects, and the cost of moving vehicles empty.

### 5. Treat revenue scenarios as hypotheses
Illustrative uplifts of 1%, 2%, 3%, or 5% applied to the recorded revenue baseline are scenario calculations—not forecasts, causal estimates, or guaranteed recoverable revenue. Any business case should use incremental revenue less incremental operating costs.

### Pilot scorecard
- Trips served per available vehicle-hour
- Passenger wait time / service availability
- Empty miles and repositioning time
- Recorded revenue and net contribution per vehicle-hour
- Driver utilization and operating cost
- Results against a comparable baseline or control area

## Data quality and interpretation

The project documentation describes a data-quality alert associated with February 23 and reports 27 reliable days for comparative analysis. Consult the full documentation and actual SQL inclusion rules to understand exactly how that date affects each metric.

Results can be affected by missing or invalid timestamps, unusual distances or amounts, duplicate records, and the choice of included records. Operational decisions should confirm relevant filters and compare results on a like-for-like basis.

## Full documentation

See the accompanying **NYC Yellow Taxi Analytics — Documentation** for detailed business context, data understanding, workflow, system explanation, KPI definitions, dashboard screenshots, recommendations, limitations, and references.

- - [Full Project Documentation (Word)](NYC_TLC_Yellow_Taxi_Analytics/08_Project_Documentation/NYC_Yellow_Taxi_Analytics_Documentation.docx)

Keep the documentation files in the same GitHub repository as this README and preserve these filenames, or update the links if you rename them.

## Data source and references

- **NYC Taxi & Limousine Commission (TLC), Trip Record Data:** https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
- **Microsoft Power BI documentation:** https://learn.microsoft.com/power-bi/
- **MySQL documentation:** https://dev.mysql.com/doc/

Use the official TLC source page to confirm the specific February 2026 file and its published data dictionary. Field definitions should be checked against the source data dictionary and the transformations described in the accompanying project documentation.

## Limitations

- This is retrospective analysis of recorded trips, not a real-time demand forecast.
- Recorded trip amounts are not net profit.
- Pickup-zone revenue describes revenue associated with trips picked up in that zone; it should not be presented as total revenue generated by all trips involving that location.
- Route imbalance is a signal for investigation, not proof that revenue can be recovered.
- Fleet expansion, driver repositioning, or airport allocation changes should be tested with operational and cost measures before scaling.

---

**Project focus:** turning large-scale trip records into understandable, validated, and actionable business intelligence.
