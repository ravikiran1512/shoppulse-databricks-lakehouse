# Operations, monitoring & production incident playbook

**Status:** Standard operating procedure for the coded reference project; not a claim of a monitored production deployment.

## Operational checks
| Signal | Query/tool | Proposed response |
|---|---|---|
| Source freshness | `ingested_at` max by Bronze table; compare landed file dates | Investigate upstream delivery |
| Source volume | Bronze row counts, unique keys and file provenance | Flag unexpected zero/double counts |
| Quality rejects | `orders_rejected` and `order_items_rejected` counts and reasons | Alert owner if above accepted threshold |
| Contract breach | `runner.py --stage quality` returns non-zero on duplicate/orphan/invalid money | Stop downstream publication |
| Inconsistent payments | `gold.order_payment_reconciliation` | Investigate voucher, refund, partial payment, errors |
| Late deliveries | `gold.delivery_performance` | Notify fulfillment analysts |
| Job failures | Lakeflow Jobs run details and task logs | Retry failed task only after checking idempotency |
| Cost spikes | `system.billing.usage` (if accessible) | Review job/warehouse usage and cost drivers |

## Incident simulations

### Incident A: A second CSV contains duplicate order IDs
Symptoms: Bronze row count grows, cleaned row count stays stable, rejected duplicates rise. Preserve Bronze, check file metadata, confirm source precedence, inspect Silver `ROW_NUMBER`, publish a corrected data-quality report. Do not blindly delete original CSV entries.

### Incident B: Pipeline failed after Silver orders, before Silver items
The Silver task is not atomic across all tables. Investigate task logs. Repair the job starting with Silver, rerun Gold and quality, and ensure readers do not consume partial refreshes. For enterprise production, adopt publication gating.

### Incident C: Payment total differs from gross item charges
First confirm grain. Olist payments and items are both many-per-order; aggregating payments **before** a join prevents fanout. Examine voucher, partial, and time-lagged payments. Do not assume fraud.

### Incident D: A historical Delta version is unavailable
Check `DESCRIBE HISTORY` and whether retained data files exist. `VACUUM` can remove obsolete files required for time travel. Historical version visibility is not perpetual backup.

### Incident E: Late arriving stock event
Silver inventory correction uses highest `source_version` per `event_id`, not last physical file order. It still needs duplicate sequence and conflicting tie-resolution rules in a genuine streaming CDC platform.

### Incident F: Job shows a slow shuffle join
Inspect the query profile, row explosion and physical join plan. If the join duplicates facts, fix the data model before tuning cluster resources. Capture baseline, apply one optimization and measure again.

## Cost / governance reference snippets
Read-only example; system tables may be unavailable in Free Edition:

```sql
SELECT usage_date, sku_name, SUM(usage_quantity) AS dbus
FROM system.billing.usage
GROUP BY usage_date, sku_name
ORDER BY usage_date DESC;
```

For actual cost attribution, join authorized pricing data and apply date/currency-specific rates; DBUs alone are not total invoice cost.

## Reliability improvements before calling it production
- Explicit source contracts, freshness SLAs, per-table quality thresholds and alert destinations.
- Typed quarantines for *all* source entities, not just orders/items.
- Atomic publish/swap or snapshot/version-gated reporting for multi-table Gold releases.
- Schema evolution policy, change feed, replay controls, and full disaster-recovery plan.
- Automated integration tests on the target Databricks runtime and CI/CD release approvals.

