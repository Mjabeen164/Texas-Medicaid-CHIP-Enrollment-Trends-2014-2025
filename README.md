<p align="center">
  <img src="banner.png" alt="Munawer Jabeen | Data Analyst" width="850"/>
</p>


# Texas Medicaid & CHIP Enrollment Trends (2014–2025)

Public coverage dynamics to support HHSC program monitoring and policy analysis

## 📌 Project Overview

This project analyzes **Texas Medicaid and CHIP child enrollment trends (Sep 2014 – Nov 2025)** using publicly available **HHSC** data. The goal is to demonstrate how enrollment evolves over time, identify key drivers of change, and communicate actionable insights through an **interactive Power BI dashboard**.

**What this project demonstrates**

* Real-world data cleaning & preparation in **SQL (MySQL)**
* Time-series analysis: **MoM, YoY, rolling trends, volatility**
* Program-level dynamics: **Medicaid vs CHIP**
* End-to-end BI workflow: **MySQL → Power BI (ODBC)**
* Executive-style dashboard design: **KPIs + annotated insights**

---

## 🗂 Data Source

**Source:** Texas Health and Human Services Commission (HHSC) public enrollment data
**Period:** September 2014 – November 2025
**Programs:**

* **Medicaid (children under 21)**
* **CHIP (Children’s Health Insurance Program)**

> Note: This is a portfolio project using public data. It is not an official HHSC product.

---

## 🛠 Tech Stack

* **SQL (MySQL):** cleaning, transformations, analytical queries/views
* **Power BI:** dashboard design and visualization
* **ODBC:** connection between MySQL and Power BI
* **Excel:** initial inspection of raw files

---

## 📂 Repository Structure (suggested)

```
Texas-Medicaid-CHIP-Enrollment-Trends-2014-2025/
├─ README.md
├─ sql/
│  ├─ 01_data_cleaning_and_views.sql   ← cleaning + final views (the script we polished)
│  └─ 02_analytical_queries.sql        ← your 15 questions (this script)
├─ powerbi/
│  └─ texas_medicaid_chip_enrollment.pbix
└─ assets/
   └─ images/
```

---

## 🔄 Data Cleaning & Preparation (SQL)

Key cleaning steps performed in **MySQL**:

* Removed duplicate header rows accidentally imported as data
* Converted month text (e.g., `Nov-25`) into proper **DATE** format (`month_date`)
* Cleaned numeric fields (removed commas, handled empty strings)
* Casted columns to appropriate numeric types (e.g., **BIGINT**)
* Created analytical SQL views for Power BI consumption

### Example cleaning logic

```sql
UPDATE tx_enrollment_clean
SET total = NULLIF(REPLACE(TRIM(total), ',', ''), '');
```

### Convert month strings to date

```sql
UPDATE tx_enrollment_clean
SET month_date = STR_TO_DATE(month, '%b-%y');
```

---

## 📐 Analytical SQL View (used in Power BI)

A prepared SQL view computes **Month-over-Month (MoM)** changes and program-level contributions:

```sql
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
```

---

## 🔎 Key Analytical Questions (15 SQL Analyses)

This project includes a curated set of analytical queries used to explore enrollment trends, volatility, seasonality, and program contributions.

- SQL file: `sql/02_analytical_queries.sql`
- These queries feed exploratory analysis and inform Power BI dashboard design.

* What is the total enrollment trend over time (2014–2025)?
* When did total enrollment peak?

  * Peak enrollment **≈ 4.4M in 2022**
* What is the latest total enrollment?

  * **~3.1M as of Nov 2025**
* What is the latest Month-over-Month (MoM) change?

  * Latest MoM: **–17K (Nov 2025)**
* What is the latest Year-over-Year (YoY) change?

  * Latest YoY: **–74K**
* Which months experienced the largest MoM increase?

  * Largest spike during **2020 pandemic expansion (~+82K)**
* Which months saw the largest MoM decline?

  * Sharp declines during **2023 redetermination period (~–78K)**
* Rolling 12-month average and volatility (CV)
* Medicaid trend vs CHIP trend
* Program share of child enrollment

  * **Medicaid share ≈ 94.26%**
  * **CHIP share ≈ 5.74% (Nov 2025)**
* Medicaid vs CHIP contribution to monthly change
* Periods with highest volatility

  * **2020–2023** showed elevated volatility

---

## 📊 Power BI Dashboard

### KPIs

* Total Enrollment (Latest)
* MoM Change (Latest)
* YoY Change (Latest)
* Medicaid Share of Child Coverage
* CHIP Share of Child Coverage

### Visuals

* Medicaid vs CHIP Enrollment Over Time (split view)
* Total Enrollment Over Time
* Month-over-Month Change in Total Enrollment (max/min labeling)
* Medicaid vs CHIP Contribution to Monthly Change
* Interactive slicers (Year range and Month range)

### Key insights highlighted

* Enrollment peaked in **2022 (~4.4M)** during continuous coverage policies
* Significant decline observed post-**2023** due to eligibility redetermination
* Medicaid drives most short-term volatility; CHIP remains relatively stable (~6%)
* Volatility was highest during **2020–2023**

---

## 🎯 Key Findings

* **Pandemic-era expansion:** Enrollment increased steadily and peaked in 2022
* **Post-pandemic normalization:** Sharp declines occurred during 2023–2024 as redetermination resumed
* **Program dynamics:** Medicaid accounts for most child coverage and nearly all MoM volatility
* **CHIP stability:** CHIP remains comparatively stable and a small share of total child coverage

---

## 🚀 Why This Project Matters

This project mirrors real-world work performed by healthcare and public sector analysts:

* Working with messy government data
* Creating reproducible SQL pipelines
* Translating enrollment data into executive-ready insights
* Supporting policy monitoring and program evaluation

---

## 📸 Dashboard Preview
![Dashboard Overview](dashboard.png)


---

## 📬 Contact

If you have feedback or would like to discuss healthcare analytics or public policy data, feel free to connect:

* **LinkedIn:** https://www.linkedin.com/in/munawer-jabeen-900811380/
* **GitHub:** https://github.com/Mjabeen164
* **Email:** [munawerjabeen703@gmail.com](mailto:munawerjabeen703@gmail.com)
