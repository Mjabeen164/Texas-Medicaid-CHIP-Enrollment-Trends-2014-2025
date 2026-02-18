# Texas-Medicaid-CHIP-Enrollment-Trends-2014-2025-
Public coverage dynamics to support HHSC program monitoring and policy analysis
📌 Project Overview

This project analyzes Texas Medicaid and CHIP enrollment trends (2014–2025) using publicly available HHSC data. The goal is to demonstrate how healthcare program enrollment evolves over time, identify key drivers of change, and present actionable insights through an interactive Power BI dashboard.

The project covers:

Real-world data cleaning and preparation in SQL (MySQL)

Time-series analysis (MoM, YoY, rolling trends, volatility)

Program-level contribution analysis (Medicaid vs CHIP)

End-to-end BI workflow by connecting MySQL to Power BI via ODBC

Executive-style dashboard design with KPIs and insight annotations

🗂 Data Source

Source: Texas Health and Human Services Commission (HHSC) public enrollment data
Period Covered: September 2014 – November 2025
Programs:

Medicaid (children under 21)

CHIP (Children’s Health Insurance Program)

🛠 Tech Stack

SQL (MySQL) – data cleaning, transformations, analytical queries

Power BI – dashboard design and visualization

ODBC – connection between MySQL and Power BI

Excel – initial raw file inspection

🔄 Data Cleaning & Preparation (SQL)

Key cleaning steps performed in MySQL:

Removed duplicate header rows accidentally imported as data

Converted month text (e.g., Nov-25) into proper DATE format (month_date)

Cleaned numeric fields (removed commas, handled empty strings)

Casted columns to appropriate numeric types (BIGINT)

Created analytical SQL views for Power BI consumption

Example cleaning logic:

UPDATE tx_enrollment_clean
SET total = NULLIF(REPLACE(TRIM(total), ',', ''), '');

Converted month strings to date:

UPDATE tx_enrollment_clean
SET month_date = STR_TO_DATE(month, '%b-%y');
📐 Analytical SQL View (Used in Power BI)

A prepared SQL view was created to compute Month-over-Month (MoM) changes and program-level contributions:

CREATE VIEW vw_mom_contribution AS
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
FROM t;

This allowed Power BI to directly consume pre-aggregated metrics.

🔎 Key Analytical Questions (15 SQL Analyses)

What is the total enrollment trend over time (2014–2025)?

When did total enrollment peak?

Peak enrollment ≈ 4.4M in 2022

What is the latest total enrollment?

~3.1M as of Nov 2025

What is the Month-over-Month (MoM) change for total enrollment?

Latest MoM: –17K (Nov 2025)

What is the Year-over-Year (YoY) change?

Latest YoY: –74K

Which months experienced the largest MoM increase?

Largest spike during 2020 pandemic expansion (~+82K)

Which months saw the largest MoM decline?

Sharp declines during 2023 redetermination period (~–78K)

What is the rolling 12-month average of total enrollment?

What is the rolling 12-month volatility (CV)?

How does Medicaid enrollment trend over time?

How does CHIP enrollment trend over time?

What share of child enrollment is Medicaid vs CHIP?

Medicaid share ≈ 94.26%

CHIP share ≈ 5.74% (Nov 2025)

How much does Medicaid contribute to MoM changes?

How much does CHIP contribute to MoM changes?

During which periods was volatility highest?

2020–2023 showed elevated volatility

📊 Power BI Dashboard

The Power BI dashboard includes:

KPIs

Total Enrollment (Latest)

MoM Change (Latest)

YoY Change (Latest)

Medicaid Share of Child Coverage

CHIP Share of Child Coverage

Visuals

Medicaid vs CHIP Enrollment Over Time (split view)

Total Enrollment Over Time

Month-over-Month Change in Total Enrollment (with max/min labeling)

Medicaid vs CHIP Contribution to Monthly Change

Interactive slicers (Year range and Month range)

Key Insights Highlighted

Enrollment peaked in 2022 (~4.4M) during continuous coverage policies

Significant decline observed post-2023 due to eligibility redetermination

Medicaid drives most short-term volatility; CHIP remains relatively stable (~6%)

Volatility was highest during 2020–2023

🎯 Key Findings

Pandemic-era expansion: Enrollment steadily increased and peaked in 2022.

Post-pandemic normalization: Sharp declines occurred during 2023–2024 as eligibility redetermination resumed.

Program dynamics: Medicaid accounts for the majority of child coverage and nearly all month-to-month volatility.

CHIP stability: CHIP enrollment remains comparatively stable and represents a small share of total child coverage.

🚀 Why This Project Matters

This project mirrors real-world work performed by healthcare and public sector analysts:

Working with messy government data

Creating reproducible SQL pipelines

Translating raw enrollment data into executive-ready insights

Supporting policy monitoring and program evaluation

📸 Dashboard Preview

(Add screenshots of your Power BI dashboard here)

📬 Contact

If you have feedback or would like to discuss healthcare analytics or public policy data, feel free to connect!
