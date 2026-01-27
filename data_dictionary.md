## Identifier & Reference Fields
| Column Name      | Description                                    | Data Type | Source   | Notes                               |
| ---------------- | ---------------------------------------------- | --------- | -------- | ----------------------------------- |
| shipment_id      | Primary key identifier of the shipment record  | INTEGER   | Raw (ID) | Renamed from `ID`                   |
| project_code     | Project code                                   | TEXT      | Raw      | Includes only PEPFAR project codes  |
| pq_number        | Price Quote (PQ) number                        | TEXT      | Raw      | “Pre-PQ Process” indicates pre-2009 |
| po_so_number     | Purchase Order (PO) or Sales Order (SO) number | TEXT      | Raw      | “NA - From RDC” when not applicable |
| asn_dn_number    | Shipment number (ASN or DN)                    | TEXT      | Raw      | Depends on fulfillment method       |
| country          | Destination country                            | TEXT      | Raw      | —                                   |
| managed_by       | SCMS managing office                           | TEXT      | Raw      | PMO (US) or field office            |
| fulfill_via      | Shipment fulfillment method                    | TEXT      | Raw      | Direct Drop or RDC                  |
| vendor_inco_term | Vendor Incoterm                                | TEXT      | Raw      | “NA - From RDC” when applicable     |
| shipment_mode    | Shipment transportation mode                   | TEXT      | Raw      | Air, Sea, etc.                      |
## Date Fields (Raw & Cleaned)
| Column Name                   | Description                        | Data Type | Source  | Notes                           |
| ----------------------------- | ---------------------------------- | --------- | ------- | ------------------------------- |
| pq_date                       | Date PQ first sent to client (raw) | TEXT      | Raw     | May contain “Date Not Captured” |
| pq_date_clean                 | Cleaned PQ sent date               | DATE      | Derived | Non-date values set to NULL     |
| po_date                       | Date PO sent to vendor (raw)       | TEXT      | Raw     | “NA - From RDC” possible        |
| po_date_clean                 | Cleaned PO sent date               | DATE      | Derived | Used for integrity checks       |
| scheduled_delivery_date       | Scheduled delivery date (raw)      | TEXT      | Raw     | Not client-promised date        |
| scheduled_delivery_date_clean | Cleaned scheduled delivery date    | DATE      | Derived | SLA reference date              |
| delivered_date                | Delivered-to-client date (raw)     | TEXT      | Raw     | —                               |
| delivered_date_clean          | Cleaned delivered date             | DATE      | Derived | —                               |
| delivery_recorded_date        | Delivery recorded date (raw)       | TEXT      | Raw     | Official SCMS reporting date    |
| delivery_recorded_date_clean  | Cleaned delivery recorded date     | DATE      | Derived | May lag physical delivery       |
## Product & Classification Fields
| Column Name        | Description                  | Data Type | Source | Notes                        |
| ------------------ | ---------------------------- | --------- | ------ | ---------------------------- |
| product_group      | Product group                | TEXT      | Raw    | ACT, ANTM, ARV, HRDT, MRDT   |
| sub_classification | Product sub-classification   | TEXT      | Raw    | Pediatric/adult, ACT, etc.   |
| vendor             | Vendor name                  | TEXT      | Raw    | SCMS used for RDC deliveries |
| item_description   | Product description          | TEXT      | Raw    | From PFSCM Item Master       |
| molecule_test_type | Active drug or test type     | TEXT      | Raw    | —                            |
| brand              | Brand or generic designation | TEXT      | Raw    | —                            |
| dosage             | Dosage and unit              | TEXT      | Raw    | —                            |
| dosage_form        | Dosage form                  | TEXT      | Raw    | Includes FDC/blister notes   |
| manufacturing_site | Manufacturing site           | TEXT      | Raw    | —                            |
## Quantity, Cost & Weight Fields
| Column Name                    | Description                  | Data Type | Source  | Notes                   |
| ------------------------------ | ---------------------------- | --------- | ------- | ----------------------- |
| unit_of_measure_per_pack       | Pack quantity (raw)          | TEXT      | Raw     | May contain non-numeric |
| unit_of_measure_per_pack_clean | Pack quantity                | INTEGER   | Derived | Numeric-only            |
| line_item_quantity             | Quantity per line item (raw) | TEXT      | Raw     | Packs                   |
| line_item_quantity_clean       | Quantity per line item       | INTEGER   | Derived | Numeric-only            |
| line_item_value                | Line item value (raw)        | TEXT      | Raw     | USD                     |
| line_item_value_clean          | Line item value              | FLOAT     | Derived | USD                     |
| pack_price                     | Cost per pack (raw)          | TEXT      | Raw     | USD                     |
| pack_price_clean               | Cost per pack                | FLOAT     | Derived | USD                     |
| unit_price                     | Cost per unit (raw)          | TEXT      | Raw     | USD                     |
| unit_price_clean               | Cost per unit                | FLOAT     | Derived | USD                     |
| weight_kilograms               | Shipment weight (raw)        | TEXT      | Raw     | First-line only         |
| weight_kilograms_clean         | Shipment weight              | FLOAT     | Derived | kg                      |
| freight_cost_usd               | Freight cost (raw)           | TEXT      | Raw     | First-line only         |
| freight_cost_usd_clean         | Freight cost                 | FLOAT     | Derived | USD                     |
| line_item_insurance_usd        | Insurance cost (raw)         | TEXT      | Raw     | Flat-rate derived       |
| line_item_insurance_usd_clean  | Insurance cost               | FLOAT     | Derived | USD                     |
## Derived & KPI Fields
| Column Name            | Description                  | Data Type | Source  | Notes                        |
| ---------------------- | ---------------------------- | --------- | ------- | ---------------------------- |
| first_line_designation | First-line indicator         | BINARY    | Raw     | Aggregated freight/weight    |
| delivery_delay_days    | Delivered − scheduled (days) | INTEGER   | Derived | Negative = early             |
| delivery_timing_status | Early / On Time / Late       | TEXT      | Derived | Diagnostic                   |
| on_time_flag           | On-time delivery indicator   | INTEGER   | Derived | 1 = on-time                  |
| cost_per_unit          | Total cost per unit          | FLOAT     | Derived | Includes freight & insurance |
## Data Quality & Validation Fields
| Column Name                         | Description                  | Data Type | Source     | Notes             |
| ----------------------------------- | ---------------------------- | --------- | ---------- | ----------------- |
| po_date_missing_flag                | PO date presence flag        | TEXT      | Derived    | Present / Missing |
| delivered_date_missing_flag         | Delivered date presence flag | TEXT      | Derived    | —                 |
| delivery_recorded_date_missing_flag | Recorded date presence flag  | TEXT      | Derived    | —                 |
| chk_delivered_vs_po                 | Delivered ≥ PO check         | TEXT      | Validation | PASS / FAIL       |
| chk_recorded_vs_delivered           | Recorded ≥ delivered check   | TEXT      | Validation | PASS / FAIL       |
| chk_delay_logical                   | Delay sanity check           | TEXT      | Validation | PASS / FAIL       |

