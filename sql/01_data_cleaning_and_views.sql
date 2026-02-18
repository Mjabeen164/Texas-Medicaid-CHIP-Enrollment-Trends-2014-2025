/* ============================================================
   1) BASIC CLEANUP: remove junk columns & header/footer rows
   ============================================================ */

ALTER TABLE tx_enrollment_clean
  DROP COLUMN MyUnknownColumn_6,
  DROP COLUMN MyUnknownColumn_7,
  DROP COLUMN MyUnknownColumn_8,
  DROP COLUMN MyUnknownColumn_9,
  DROP COLUMN MyUnknownColumn_10;

-- Remove BOM/header rows and footnotes accidentally imported
DELETE FROM tx_enrollment_clean
WHERE month IN ('ï»¿  month', 'month', 'Includes', 'STAR', 'Parents')
   OR month IS NULL;


/* ============================================================
   2) DATE NORMALIZATION
   ============================================================ */

ALTER TABLE tx_enrollment_clean
ADD COLUMN month_date DATE;

-- Convert strings like 'Nov-25' into DATE
UPDATE tx_enrollment_clean
SET month_date = STR_TO_DATE(month, '%b-%y')
WHERE month REGEXP '^[A-Za-z]{3}-[0-9]{2}$';


/* ============================================================
   3) NUMERIC CLEANING
   ============================================================ */

UPDATE tx_enrollment_clean
SET
  total = NULLIF(REPLACE(TRIM(total), ',', ''), ''),
  medicaid_caseload = NULLIF(REPLACE(TRIM(medicaid_caseload), ',', ''), ''),
  regular_chip = NULLIF(REPLACE(TRIM(regular_chip), ',', ''), '');

-- Remove rows with missing core values
DELETE FROM tx_enrollment_clean
WHERE total IS NULL
   OR medicaid_caseload IS NULL
   OR regular_chip IS NULL
   OR month_date IS NULL;


/* ============================================================
   4) FINAL TYPES
   ============================================================ */

ALTER TABLE tx_enrollment_clean
  MODIFY COLUMN total BIGINT,
  MODIFY COLUMN medicaid_caseload BIGINT,
  MODIFY COLUMN regular_chip BIGINT;


/* ============================================================
   5) ANALYTICAL VIEW (MoM + Contribution %)
   ============================================================ */

CREATE OR REPLACE VIEW vw_mom_contribution AS
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


/* ============================================================
   6) SANITY CHECKS (OPTIONAL BUT IMPRESSIVE)
   ============================================================ */

-- Check for duplicate months
SELECT month_date, COUNT(*) 
FROM tx_enrollment_clean
GROUP BY month_date
HAVING COUNT(*) > 1;

-- Check date range & record count
SELECT 
  MIN(month_date) AS start_date,
  MAX(month_date) AS end_date,
  COUNT(*) AS total_months
FROM tx_enrollment_clean;