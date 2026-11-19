# Data contracts and input dictionary

**Origin:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), historical orders 2016–2018. All source files are user-provided downloads placed in a Databricks UC volume. Original source column spellings (including `product_name_lenght`) are preserved at Bronze.

| File | Bronze table | Natural grain / key | Required upstream columns |
|---|---|---|---|
| `olist_orders_dataset.csv` | `olist_orders_raw` | order; `order_id` | order_id, customer_id, order_status, 5 order/delivery timestamps |
| `olist_order_items_dataset.csv` | `olist_order_items_raw` | line; (`order_id`, `order_item_id`) | order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value |
| `olist_customers_dataset.csv` | `olist_customers_raw` | address/customer record; `customer_id` | customer_id, customer_unique_id, zip prefix, city, state |
| `olist_products_dataset.csv` | `olist_products_raw` | product; `product_id` | product_id, category, textual lengths, photos, weight, dimensions |
| `olist_sellers_dataset.csv` | `olist_sellers_raw` | seller; `seller_id` | seller_id, zip prefix, city, state |
| `olist_order_payments_dataset.csv` | `olist_order_payments_raw` | payment component; (`order_id`, `payment_sequential`) | order_id, payment_sequential, payment_type, payment_installments, payment_value |
| `olist_order_reviews_dataset.csv` | `olist_order_reviews_raw` | review association; (`review_id`, `order_id`) | review_id, order_id, review_score, title, message, creation date, answer date |
| `product_category_name_translation.csv` | `olist_category_translation_raw` | Portuguese category | product_category_name, product_category_name_english |

## Silver validation and quarantine

- **Orders:** nonempty order/customer ID, parseable purchase timestamp, known order status; latest row per order_id retained. Superseded/invalid rows in `orders_rejected`.
- **Items:** nonempty order/product/seller key, positive integer item index, valid shipping timestamp, positive decimal item price, nonnegative decimal freight, parent order must exist. Rejected rows in `order_items_rejected`.
- **Payments:** sequential component ID > 0; payment value >= 0 (legitimate zero-value voucher components may occur). Missing/bad entries excluded from clean table; add a dedicated payments quarantine if adopting this for operations.
- **Customers:** `customer_id` is order-level customer/address; `customer_unique_id` represents repeat shopper identity. Do **not** use customer_id as the repeat purchase key.
- **Reviews:** score between 1 and 5. Current implementation only selects valid scores; production-grade review rejection logging would need an additional audit table.

## Contract checks and exceptions

| Check | Required expectation | Action |
|---|---|---|
| Bronze source row count | Nonzero, profile against landed file | Stop on empty |
| Clean order ID | Unique | Fail quality task |
| Clean item key | Unique combination | Fail quality task |
| Item→order reference | Valid parent order | Quarantine, then fail if orphan remains |
| Item price & freight | Price > 0, freight >= 0 | Quarantine |
| Order status | Olist recognized vocabulary | Quarantine |
| Payment reconciliation | Investigate large variance | Informational until policy defined |

## Privacy and money
Olist contains buyer and location-related fields. Restrict access to Bronze and avoid committing raw datasets to GitHub. Currency amounts are **BRL**. Use `DECIMAL` for money and do not mix payment amounts, shipping charges and item sales without explicit business rules.

## Synthetic event feed
`tools/generate_inventory.py` creates JSONL with keys `event_id`, `warehouse_id`, `sku_id`, `event_ts`, `movement_type`, `qty_delta`, `source_version`. It deliberately includes a repeated event ID, an invalid quantity and a newer correction. These events are *not* Olist transactions and cannot legitimately be joined to Olist products without a mapping table.

