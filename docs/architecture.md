# ShopPulse technical architecture & architectural decisions

**Status**: implemented batch SQL design, not yet full workspace-verified. The platform is intentionally split into historical marketplace analytics and *synthetic* operational event streams.

## Source systems & ingestion contracts
1. Eight original Olist CSVs (orders, items, customers, products, sellers, payments, reviews, category translation) uploaded to a UC managed volume. No data committed to this repository.
2. `COPY INTO` with file-level tracking loads raw string columns and adds `source_file` and `ingested_at`.
3. Re-running unchanged file paths is normally idempotent. It cannot distinguish identical records contained in a **different** source file; the Silver layer deduplicates by business key.
4. Optional separate JSONL event generator simulates warehouse net movements, revisions and invalid records. Not actual Olist inventory.

## Tables and grain

| Layer | Table | Grain |
|---|---|---|
| Bronze | `olist_orders_raw` | every received CSV row |
| Bronze | `olist_order_items_raw` | every received CSV item row |
| Bronze | other `olist_*_raw` | every received CSV row |
| Silver | `orders_clean` | one latest valid `order_id` |
| Silver | `order_items_clean` | one valid (`order_id`, `order_item_id`) |
| Silver | `orders_rejected` / `order_items_rejected` | each invalid or superseded source row |
| Silver | `customers_clean` | `customer_id`; related `customer_unique_id` spans orders |
| Silver | `payments_clean` | (`order_id`, `payment_sequential`) |
| Gold | `fact_order_item` | one item within one order |
| Gold | `fact_order_payment` | one order (preaggregated payments) |
| Gold | `daily_delivered_sales` | purchase date |
| Gold | `customer_lifetime_value` | shopper `customer_unique_id` |
| Gold | `delivery_performance` | purchase date |
| Gold | `order_payment_reconciliation` | order |
| Optional Gold | `inventory_net_movement` | warehouse and SKU |

**Data lineage:** order source → Bronze orders → Silver orders → Gold order item fact; items source → Bronze items → Silver item → Gold fact; payments source → Bronze payments → Silver payments → order-level payment fact. Other dimensions join only after their unique keys have been enforced.

## Business metric definitions

- `item_sales_brl`: sum of item prices on item rows belonging to orders whose **current status** is delivered. It is historical delivered-order merchandise value, not net of refunds, taxes, or GAAP/IFRS recognized revenue.
- `freight_brl`: sum of freight associated with those same item lines.
- `delivered_orders`: `COUNT(DISTINCT order_id)`, never `COUNT(*)` when the input is item grain.
- `late_delivery_pct`: delivered orders with actual delivery later than the estimated delivery timestamp, divided by delivered orders with a non-null delivery and estimate.
- `paid_amount_brl`: sum of per-order payment components. Separate payment grain avoids item/payment fanout.
- `difference_brl`: order-level paid minus gross item + freight. This is diagnostic, not automatically fraud, because vouchers/adjustments/partial payments may apply.
- `net_quantity_change`: cumulative movement delta. Without an initial stock snapshot it is **not** current on-hand inventory.

## Batch vs streaming
- **Default working path:** `COPY INTO` (batch) → deterministic CTAS Silver/Gold → quality gates in a four-task Lakeflow Job bundle.
- **Optional advanced event-processing implementations:** Auto Loader and Lakeflow expectations for incremental JSON, plus `AUTO CDC` SCD2 on synthetic preferences. They are kept separate from the batch source path and need a configured Lakeflow Pipeline to run.
- **CDC correctness:** sequence events by business event time/sequence and use delete handling; SCD2 is not identical to a simple SQL `MERGE`.

## Limitations / decisions
- No transactional guarantee across separate CTAS outputs: a failure after a subset of tables can temporarily leave inconsistent generations. A stronger production design would use publishing strategies, quality gates and a controlled switch/refresh window.
- Rerunning Silver/Gold is deterministic for fixed Bronze inputs; repeated source key updates that tie on ingestion timestamp are resolved by secondary sort columns, and further source-specific sequence metadata would be preferable.
- SQL Gold materialization is CTAS, not a streaming materialized view; materialized-view alternatives require separate evaluation.
- Fully managed Olist historical data is small compared with enterprise-scale production; performance exercises require larger workloads and measured timings.
- The pipeline has no automated legally compliant data subject deletion flow. See [security](security.md).

## Relevant official documentation
- [Medallion architecture](https://docs.databricks.com/aws/en/lakehouse/medallion)
- [COPY INTO](https://docs.databricks.com/aws/en/sql/language-manual/delta-copy-into)
- [Declarative Automation Bundles](https://docs.databricks.com/aws/en/dev-tools/bundles/)
- [Lakeflow AUTO CDC](https://docs.databricks.com/aws/en/ldp/cdc)

