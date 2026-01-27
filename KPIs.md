# Executive KPIs
## Total Shipments
- *Question:*  How much volume are we managing?
- *Definition:*  Count of shipment records in the cleaned dataset.
- *Formula:* =COUNTA(Cleaned_Data!shipment_id)
- *Inclusion Rules:* Include all records
- *Assumption:* shipment_id is unique per record

## On-Time Delivery %
- *Question:* How reliable is our delivery performance?
- *Definition:* Percent of shipments delivered on or before the scheduled delivery date.
- *Formula:* =AVERAGE(Cleaned_Data!on_time_flag)
- *Logic:* on_time_flag = 1 if delivered_date_clean ≤ scheduled_delivery_date_clean; 0 otherwise
- *Inclusion Rules:* scheduled_delivery_date_clean and delivered_date_clean must NOT be NULL
- *Exclusions:* Shipments missing scheduled delivery dates

## Average Delivery Delay (Days)
- *Question:* When deliveries deviate from schedule, by how much?
- *Definition:* Average number of days early or late relative to scheduled delivery.
- *Formula:* =AVERAGE(Cleaned_Data!delivery_delay_days)
- *Rules:* Only include rows where delivery_delay_days is NOT NULL
- *Interpretation:* Negative values indicate early delivery; positive values indicate late delivery

## Total Logistics Cost
- *Question:* How much are we spending to move goods?
- *Definition:* Total logistics cost across all shipment line items.
- *Formula:* =SUM(Cleaned_Data!total_logistics_cost)
- *Rules:* Use cleaned numeric fields only
- *Note:* Calculated at the line-item level and summed across records

## Cost per Unit
- *Question:* How efficient is our logistics spend relative to volume?
- *Definition:* Average logistics cost per unit shipped.
- *Formula:* =AVERAGE(Cleaned_Data!cost_per_unit)
- *Logic:* cost_per_unit = total_logistics_cost ÷ line_item_quantity_clean
- *Rules:* Only include rows with non-null quantity values

# Operational Drivers

## Late Shipment Rate
- *Definition:* Percent of shipments delivered after the scheduled delivery date.
- *Formula:*
COUNTIF(delivery_timing_status = "Late") ÷ eligible SLA shipments
- *Rules:* Only include shipments with
  - scheduled_delivery_date_clean NOT NULL
  - Average Freight Cost (First Line Only)
- *Definition:* Average freight cost for first-line designated shipment records.
- *Formula:* =AVERAGEIFS(
  Cleaned_Data!freight_cost_usd_clean,
  Cleaned_Data!first_line_designation,1
)
- *Rules:* first_line_designation = 1

## On-Time % by Shipment Mode / Vendor / Country
- *Definition:* Breakdown of On-Time Delivery % by operational dimension
- *Metric Used:* AVG(on_time_flag)
- *Purpose:* Identify performance drivers and optimization opportunities