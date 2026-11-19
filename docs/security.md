# ShopPulse security, privacy and governance

**No production security certification is claimed.**

1. **Least privilege:** provide analysts SELECT on approved Gold objects, not unrestricted Bronze volume access. Use Unity Catalog grants and inheritance deliberately; refer to `sql/71_security_examples.sql` for read-only inspection.
2. **PII classification:** treat customer identifiers, location and review text as potentially personal. Do not commit Olist raw CSVs, workspace logs, emails, tokens or screenshots to the public repository.
3. **Masking / ABAC:** design column masks, row filters, governed tags and ABAC for sensitive data when an authorized admin is available. A hashed customer key is not by itself complete anonymization.
4. **Secret management:** never embed Databricks PATs. Use Databricks auth profiles locally and approved workload identity / GitHub environments for future deployments. CI here deliberately does not deploy.
5. **Retention:** establish documented data and audit retention periods. `VACUUM` affects old files and Delta time-travel availability; do not disable retention safeguards.
6. **Erasure:** a right-to-erasure workflow requires identifying subjects, deleting relevant rows in all copies/snapshots and downstream systems, honoring legal retention, and validating purge. This repo does **not** implement compliant erasure.
7. **External sharing:** Delta Sharing / OpenSharing and Clean Rooms require approved recipients, governance review, and controlled credentials. These are exam topics, not deployed assets in this repo.
8. **Supply chain:** treat source CSV/JSON as untrusted, validate input schema, pin reviewed dependencies when introduced, and restrict execution privileges.

## GitHub publishing checklist
- Check `git diff --cached` for personal content and data.
- Avoid committing any `data/raw`, `data/generated`, `.env`, `.databrickscfg`, secrets or token-bearing logs.
- Publish only aggregated/sanitized evidence, include limitations and genuine performance measurements.
- Honor Olist dataset licensing/terms, and use a synthetic replacement for any sensitive operational exercise.

