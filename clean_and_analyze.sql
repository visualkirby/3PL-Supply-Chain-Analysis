-- ============================================================
-- SCMS Supply Chain Analysis — Cleaned Data + KPI Tables
-- Fixes:
--   1) Date parsing supports mm/dd/yy + mm/dd/yyyy + yyyy-mm-dd
--   2) Numeric fields null-out junk text BEFORE casting (Python parity)
--   3) total_logistics_cost adds freight ONLY when first_line_flag = 1
-- ============================================================

CREATE OR REPLACE TABLE `scms-supply-chain-analysis.dataset.cleaned_data` AS
WITH base AS (
  SELECT
    COALESCE(SAFE_CAST(`ID` AS INT64)) AS shipment_id,

    CAST(`Project Code` AS STRING)      AS project_code,
    CAST(`PQ #` AS STRING)              AS pq_number,
    CAST(`PO _ SO #` AS STRING)         AS po_so_number,
    CAST(`ASN_DN #` AS STRING)          AS asn_dn_number,
    CAST(`Country` AS STRING)           AS country,
    CAST(`Managed By` AS STRING)        AS managed_by,
    CAST(`Fulfill Via` AS STRING)       AS fulfill_via,
    CAST(`Vendor INCO Term` AS STRING)  AS vendor_inco_term,
    CAST(`Shipment Mode` AS STRING)     AS shipment_mode,

    -- Raw date strings (audit)
    CAST(`PQ First Sent to Client Date` AS STRING) AS pq_date,
    CAST(`PO Sent to Vendor Date` AS STRING)       AS po_date,
    CAST(`Scheduled Delivery Date` AS STRING)      AS scheduled_delivery_date,
    CAST(`Delivered to Client Date` AS STRING)     AS delivered_date,
    CAST(`Delivery Recorded Date` AS STRING)       AS delivery_recorded_date,

    CAST(`Product Group` AS STRING)      AS product_group,
    CAST(`Sub Classification` AS STRING) AS sub_classification,
    CAST(`Vendor` AS STRING)             AS vendor,

    CAST(`Unit of Measure _Per Pack_` AS STRING) AS unit_of_measure_per_pack,
    CAST(`Line Item Quantity` AS STRING)         AS line_item_quantity,
    CAST(`Line Item Value` AS STRING)            AS line_item_value,
    CAST(`Pack Price` AS STRING)                 AS pack_price,
    CAST(`Unit Price` AS STRING)                 AS unit_price,

    CAST(`Manufacturing Site` AS STRING)     AS manufacturing_site,
    CAST(`First Line Designation` AS STRING) AS first_line_designation,

    CAST(`Weight _Kilograms_` AS STRING)        AS weight_kilograms,
    CAST(`Freight Cost _USD_` AS STRING)        AS freight_cost_usd,
    CAST(`Line Item Insurance _USD_` AS STRING) AS line_item_insurance_usd

  FROM `scms-supply-chain-analysis.dataset.raw_data`
),

typed AS (
  SELECT
    *,

    -- -------------------------
    -- Date cleaning
    -- -------------------------
    CASE
      WHEN pq_date IS NULL THEN NULL
      WHEN LOWER(TRIM(pq_date)) IN ('pre-pq process','date not captured','n/a - from rdc','na - from rdc') THEN NULL
      ELSE COALESCE(
        SAFE_CAST(pq_date AS DATE),
        DATE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', pq_date)),
        SAFE.PARSE_DATE('%Y-%m-%d', pq_date),
        SAFE.PARSE_DATE('%m/%d/%y', pq_date),
        SAFE.PARSE_DATE('%m/%d/%Y', pq_date)
      )
    END AS pq_date_clean,

    CASE
      WHEN po_date IS NULL THEN NULL
      WHEN LOWER(TRIM(po_date)) IN ('pre-pq process','date not captured','n/a - from rdc','na - from rdc') THEN NULL
      ELSE COALESCE(
        SAFE_CAST(po_date AS DATE),
        DATE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', po_date)),
        SAFE.PARSE_DATE('%Y-%m-%d', po_date),
        SAFE.PARSE_DATE('%m/%d/%y', po_date),
        SAFE.PARSE_DATE('%m/%d/%Y', po_date)
      )
    END AS po_date_clean,

    CASE
      WHEN scheduled_delivery_date IS NULL THEN NULL
      WHEN LOWER(TRIM(scheduled_delivery_date)) IN ('pre-pq process','date not captured','n/a - from rdc','na - from rdc') THEN NULL
      ELSE COALESCE(
        SAFE_CAST(scheduled_delivery_date AS DATE),
        DATE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', scheduled_delivery_date)),
        SAFE.PARSE_DATE('%Y-%m-%d', scheduled_delivery_date),
        SAFE.PARSE_DATE('%m/%d/%y', scheduled_delivery_date),
        SAFE.PARSE_DATE('%m/%d/%Y', scheduled_delivery_date)
      )
    END AS scheduled_delivery_date_clean,

    CASE
      WHEN delivered_date IS NULL THEN NULL
      WHEN LOWER(TRIM(delivered_date)) IN ('pre-pq process','date not captured','n/a - from rdc','na - from rdc') THEN NULL
      ELSE COALESCE(
        SAFE_CAST(delivered_date AS DATE),
        DATE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', delivered_date)),
        SAFE.PARSE_DATE('%Y-%m-%d', delivered_date),
        SAFE.PARSE_DATE('%m/%d/%y', delivered_date),
        SAFE.PARSE_DATE('%m/%d/%Y', delivered_date)
      )
    END AS delivered_date_clean,

    CASE
      WHEN delivery_recorded_date IS NULL THEN NULL
      WHEN LOWER(TRIM(delivery_recorded_date)) IN ('pre-pq process','date not captured','n/a - from rdc','na - from rdc') THEN NULL
      ELSE COALESCE(
        SAFE_CAST(delivery_recorded_date AS DATE),
        DATE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', delivery_recorded_date)),
        SAFE.PARSE_DATE('%Y-%m-%d', delivery_recorded_date),
        SAFE.PARSE_DATE('%m/%d/%y', delivery_recorded_date),
        SAFE.PARSE_DATE('%m/%d/%Y', delivery_recorded_date)
      )
    END AS delivery_recorded_date_clean,

    -- -------------------------
    -- Numeric cleaning
    -- 1) NULL-out junk text first
    -- 2) strip $, commas, whitespace
    -- -------------------------
    CASE
      WHEN unit_of_measure_per_pack IS NULL THEN NULL
      WHEN REGEXP_CONTAINS(LOWER(unit_of_measure_per_pack), r'\bsee\b|\basn\b|id#|invoiced|freight included') THEN NULL
      ELSE SAFE_CAST(NULLIF(REGEXP_REPLACE(unit_of_measure_per_pack, r'[,$\s]', ''), '') AS INT64)
    END AS unit_of_measure_per_pack_clean,

    CASE
      WHEN line_item_quantity IS NULL THEN NULL
      WHEN REGEXP_CONTAINS(LOWER(line_item_quantity), r'\bsee\b|\basn\b|id#|invoiced|freight included') THEN NULL
      ELSE SAFE_CAST(NULLIF(REGEXP_REPLACE(line_item_quantity, r'[,$\s]', ''), '') AS INT64)
    END AS line_item_quantity_clean,

    CASE
      WHEN line_item_value IS NULL THEN NULL
      WHEN REGEXP_CONTAINS(LOWER(line_item_value), r'\bsee\b|\basn\b|id#|invoiced|freight included') THEN NULL
      ELSE SAFE_CAST(NULLIF(REGEXP_REPLACE(line_item_value, r'[,$\s]', ''), '') AS FLOAT64)
    END AS line_item_value_clean,

    CASE
      WHEN pack_price IS NULL THEN NULL
      WHEN REGEXP_CONTAINS(LOWER(pack_price), r'\bsee\b|\basn\b|id#|invoiced|freight included') THEN NULL
      ELSE SAFE_CAST(NULLIF(REGEXP_REPLACE(pack_price, r'[,$\s]', ''), '') AS FLOAT64)
    END AS pack_price_clean,

    CASE
      WHEN unit_price IS NULL THEN NULL
      WHEN REGEXP_CONTAINS(LOWER(unit_price), r'\bsee\b|\basn\b|id#|invoiced|freight included') THEN NULL
      ELSE SAFE_CAST(NULLIF(REGEXP_REPLACE(unit_price, r'[,$\s]', ''), '') AS FLOAT64)
    END AS unit_price_clean,

    CASE
      WHEN weight_kilograms IS NULL THEN NULL
      WHEN REGEXP_CONTAINS(LOWER(weight_kilograms), r'\bsee\b|\basn\b|id#|invoiced|freight included') THEN NULL
      ELSE SAFE_CAST(NULLIF(REGEXP_REPLACE(weight_kilograms, r'[,$\s]', ''), '') AS FLOAT64)
    END AS weight_kilograms_clean,

    CASE
      WHEN freight_cost_usd IS NULL THEN NULL
      WHEN REGEXP_CONTAINS(LOWER(freight_cost_usd), r'\bsee\b|\basn\b|id#|invoiced|freight included') THEN NULL
      ELSE SAFE_CAST(NULLIF(REGEXP_REPLACE(freight_cost_usd, r'[,$\s]', ''), '') AS FLOAT64)
    END AS freight_cost_usd_clean,

    CASE
      WHEN line_item_insurance_usd IS NULL THEN NULL
      WHEN REGEXP_CONTAINS(LOWER(line_item_insurance_usd), r'\bsee\b|\basn\b|id#|invoiced|freight included') THEN NULL
      ELSE SAFE_CAST(NULLIF(REGEXP_REPLACE(line_item_insurance_usd, r'[,$\s]', ''), '') AS FLOAT64)
    END AS line_item_insurance_usd_clean

  FROM base
),

derived AS (
  SELECT
    *,

    CASE WHEN LOWER(TRIM(first_line_designation)) IN ('yes','y','1','true') THEN 1 ELSE 0 END AS first_line_flag,

    CASE
      WHEN scheduled_delivery_date_clean IS NULL OR delivered_date_clean IS NULL THEN NULL
      WHEN delivered_date_clean <= scheduled_delivery_date_clean THEN 1 ELSE 0
    END AS on_time_flag,

    CASE
      WHEN scheduled_delivery_date_clean IS NULL OR delivered_date_clean IS NULL THEN NULL
      ELSE DATE_DIFF(delivered_date_clean, scheduled_delivery_date_clean, DAY)
    END AS delivery_delay_days,

    CASE
      WHEN scheduled_delivery_date_clean IS NULL OR delivered_date_clean IS NULL THEN NULL
      WHEN delivered_date_clean < scheduled_delivery_date_clean THEN 'Early'
      WHEN delivered_date_clean = scheduled_delivery_date_clean THEN 'On Time'
      ELSE 'Late'
    END AS delivery_timing_status,

    -- freight only if first_line_flag = 1
    (
      COALESCE(line_item_value_clean, 0)
      + COALESCE(line_item_insurance_usd_clean, 0)
      + CASE WHEN (CASE WHEN LOWER(TRIM(first_line_designation)) IN ('yes','y','1','true') THEN 1 ELSE 0 END) = 1
             THEN COALESCE(freight_cost_usd_clean, 0) ELSE 0 END
    ) AS total_logistics_cost,

    SAFE_DIVIDE(
      (
        COALESCE(line_item_value_clean, 0)
        + COALESCE(line_item_insurance_usd_clean, 0)
        + CASE WHEN (CASE WHEN LOWER(TRIM(first_line_designation)) IN ('yes','y','1','true') THEN 1 ELSE 0 END) = 1
               THEN COALESCE(freight_cost_usd_clean, 0) ELSE 0 END
      ),
      NULLIF(CAST(line_item_quantity_clean AS FLOAT64), 0)
    ) AS cost_per_unit

  FROM typed
)

SELECT * FROM derived;

-- ============================================================
-- KPI tiles
-- ============================================================
CREATE OR REPLACE TABLE `scms-supply-chain-analysis.dataset.kpi_tiles` AS
SELECT
  COUNT(shipment_id) AS total_shipments,
  AVG(on_time_flag) AS on_time_pct,
  AVG(delivery_delay_days) AS avg_delay_days,
  SUM(total_logistics_cost) AS total_logistics_cost,
  AVG(cost_per_unit) AS avg_cost_per_unit
FROM `scms-supply-chain-analysis.dataset.cleaned_data`
WHERE shipment_mode IS NULL OR LOWER(TRIM(shipment_mode)) <> 'n/a';

-- ============================================================
-- Mode comparison
-- ============================================================
CREATE OR REPLACE TABLE `scms-supply-chain-analysis.dataset.on_time_by_mode` AS
SELECT
  shipment_mode,
  COUNT(*) AS shipments,
  AVG(on_time_flag) AS on_time_pct,
  AVG(delivery_delay_days) AS avg_delay_days,
  AVG(cost_per_unit) AS avg_cost_per_unit
FROM `scms-supply-chain-analysis.dataset.cleaned_data`
WHERE shipment_mode IS NOT NULL AND LOWER(TRIM(shipment_mode)) <> 'n/a'
GROUP BY shipment_mode
ORDER BY on_time_pct DESC;

-- ============================================================
-- Vendor risk (min sample size)
-- ============================================================
CREATE OR REPLACE TABLE `scms-supply-chain-analysis.dataset.vendor_risk` AS
SELECT
  vendor,
  COUNT(*) AS shipments,
  AVG(on_time_flag) AS on_time_pct,
  AVG(delivery_delay_days) AS avg_delay_days,
  AVG(cost_per_unit) AS avg_cost_per_unit
FROM `scms-supply-chain-analysis.dataset.cleaned_data`
WHERE vendor IS NOT NULL
GROUP BY vendor
HAVING COUNT(*) >= 20
ORDER BY on_time_pct ASC;

-- ============================================================
-- Country priority lanes
-- ============================================================
CREATE OR REPLACE TABLE `scms-supply-chain-analysis.dataset.country_priority` AS
SELECT
  country,
  COUNT(*) AS shipments,
  AVG(on_time_flag) AS on_time_pct,
  AVG(delivery_delay_days) AS avg_delay_days
FROM `scms-supply-chain-analysis.dataset.cleaned_data`
WHERE country IS NOT NULL
GROUP BY country
HAVING COUNT(*) >= 50
ORDER BY shipments DESC, on_time_pct ASC;

-- ============================================================
-- Freight first line
-- ============================================================
CREATE OR REPLACE TABLE `scms-supply-chain-analysis.dataset.freight_first_line` AS
SELECT
  shipment_mode,
  COUNT(*) AS first_line_rows,
  AVG(freight_cost_usd_clean) AS avg_freight_cost,
  SUM(freight_cost_usd_clean) AS total_freight_cost
FROM `scms-supply-chain-analysis.dataset.cleaned_data`
WHERE first_line_flag = 1
  AND freight_cost_usd_clean IS NOT NULL
  AND shipment_mode IS NOT NULL AND LOWER(TRIM(shipment_mode)) <> 'n/a'
GROUP BY shipment_mode
ORDER BY total_freight_cost DESC;
