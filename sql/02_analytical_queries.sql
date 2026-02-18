/* ============================================================
   02_analytical_queries.sql
   Texas Medicaid & CHIP Enrollment Trends (2014–2025)

   Purpose:
   - Exploratory & monitoring queries on top of cleaned enrollment data
   - Supports dashboard design (MoM, YoY, rolling trends, volatility)
   - Program mix analysis (Medicaid vs CHIP)
   ============================================================ */


/* 1) Month-over-Month (MoM) change – Total enrollment */
WITH t AS (
  SELECT
    month_date,
    total,
    total - LAG(total) OVER (ORDER BY month_date) AS mom_change
  FROM tx_enrollment_clean
)
SELECT *
FROM t
ORDER BY month_date;


/* 2) MoM % change – Total enrollment */
WITH t AS (
  SELECT
    month_date,
    total,
    ROUND(
      (total - LAG(total) OVER (ORDER BY month_date)) * 100.0 /
      NULLIF(LAG(total) OVER (ORDER BY month_date), 0),
      2
    ) AS mom_pct
  FROM tx_enrollment_clean
)
SELECT *
FROM t
ORDER BY month_date;


/* 3) Year-over-Year (YoY) change – Total enrollment */
WITH t AS (
  SELECT
    month_date,
    total,
    total - LAG(total, 12) OVER (ORDER BY month_date) AS yoy_change
  FROM tx_enrollment_clean
)
SELECT *
FROM t
ORDER BY month_date;


/* 4) YoY % change – Total enrollment */
WITH t AS (
  SELECT
    month_date,
    total,
    ROUND(
      (total - LAG(total, 12) OVER (ORDER BY month_date)) * 100.0 /
      NULLIF(LAG(total, 12) OVER (ORDER BY month_date), 0),
      2
    ) AS yoy_pct
  FROM tx_enrollment_clean
)
SELECT *
FROM t
ORDER BY month_date;


/* 5) 12-month rolling average – Total enrollment */
WITH roll AS (
  SELECT
    month_date,
    total,
    AVG(total) OVER (
      ORDER BY month_date
      ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ) AS roll12_avg
  FROM tx_enrollment_clean
)
SELECT *
FROM roll
ORDER BY month_date;


/* 6) 12-month rolling volatility (std dev) – Total enrollment */
WITH roll AS (
  SELECT
    month_date,
    total,
    STDDEV_SAMP(total) OVER (
      ORDER BY month_date
      ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ) AS roll12_std
  FROM tx_enrollment_clean
)
SELECT *
FROM roll
ORDER BY month_date;


/* 7) Medicaid vs CHIP share of total enrollment */
SELECT
  month_date,
  ROUND(medicaid_caseload * 100.0 / total, 2) AS medicaid_share_pct,
  ROUND(regular_chip * 100.0 / total, 2) AS chip_share_pct
FROM tx_enrollment_clean
ORDER BY month_date;


/* 8) Contribution to MoM change (Medicaid vs CHIP) */
WITH t AS (
  SELECT
    month_date,
    medicaid_caseload - LAG(medicaid_caseload) OVER (ORDER BY month_date) AS medicaid_mom,
    regular_chip - LAG(regular_chip) OVER (ORDER BY month_date) AS chip_mom,
    total - LAG(total) OVER (ORDER BY month_date) AS total_mom
  FROM tx_enrollment_clean
)
SELECT
  month_date,
  medicaid_mom,
  chip_mom,
  total_mom,
  ROUND(medicaid_mom * 100.0 / NULLIF(total_mom, 0), 2) AS medicaid_contrib_pct,
  ROUND(chip_mom * 100.0 / NULLIF(total_mom, 0), 2) AS chip_contrib_pct
FROM t
ORDER BY month_date;


/* 9) Top 5 biggest monthly increases (MoM) */
WITH t AS (
  SELECT
    month_date,
    total - LAG(total) OVER (ORDER BY month_date) AS mom_change
  FROM tx_enrollment_clean
)
SELECT *
FROM t
ORDER BY mom_change DESC
LIMIT 5;


/* 10) Top 5 biggest monthly drops (MoM) */
WITH t AS (
  SELECT
    month_date,
    total - LAG(total) OVER (ORDER BY month_date) AS mom_change
  FROM tx_enrollment_clean
)
SELECT *
FROM t
ORDER BY mom_change ASC
LIMIT 5;


/* 11) Quarterly averages – Total enrollment */
SELECT
  DATE_FORMAT(month_date, '%Y-Q%q') AS quarter,
  ROUND(AVG(total), 0) AS avg_total
FROM tx_enrollment_clean
GROUP BY quarter
ORDER BY quarter;


/* 12) Seasonality: average MoM change by calendar month */
WITH t AS (
  SELECT
    month_date,
    total - LAG(total) OVER (ORDER BY month_date) AS mom_change
  FROM tx_enrollment_clean
)
SELECT
  MONTH(month_date) AS cal_month,
  ROUND(AVG(mom_change), 0) AS avg_mom_change
FROM t
GROUP BY cal_month
ORDER BY cal_month;


/* 13) Longest growth streak (consecutive months with increases) */
WITH d AS (
  SELECT
    month_date,
    CASE
      WHEN total > LAG(total) OVER (ORDER BY month_date) THEN 1
      ELSE 0
    END AS is_up
  FROM tx_enrollment_clean
),
g AS (
  SELECT
    month_date,
    is_up,
    SUM(CASE WHEN is_up = 0 THEN 1 ELSE 0 END)
      OVER (ORDER BY month_date) AS grp
  FROM d
)
SELECT
  grp,
  COUNT(*) AS months_up
FROM g
WHERE is_up = 1
GROUP BY grp
ORDER BY months_up DESC
LIMIT 1;


/* 14) YoY change series (trend proxy for longer-term growth) */
WITH t AS (
  SELECT
    month_date,
    total - LAG(total, 12) OVER (ORDER BY month_date) AS yoy_change
  FROM tx_enrollment_clean
)
SELECT
  month_date,
  yoy_change
FROM t
ORDER BY month_date;


/* 15) Recent 12 months snapshot (dashboard monitoring feed) */
SELECT *
FROM tx_enrollment_clean
ORDER BY month_date DESC
LIMIT 12;