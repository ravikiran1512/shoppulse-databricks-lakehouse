-- Security template: inspection is safe; grants, masks and retention need
-- workspace administrators and approved principals. Nothing here grants access.
SHOW GRANTS ON SCHEMA {{catalog}}.shoppulse_gold;
DESCRIBE EXTENDED {{catalog}}.shoppulse_gold.dim_customer;

-- EXAMPLE ONLY: replace the role with an authorized identity and evaluate
-- catalog/schema usage inheritance BEFORE applying in a governed environment.
-- GRANT USE CATALOG ON CATALOG {{catalog}} TO `retail_analysts`;
-- GRANT USE SCHEMA ON SCHEMA {{catalog}}.shoppulse_gold TO `retail_analysts`;
-- GRANT SELECT ON SCHEMA {{catalog}}.shoppulse_gold TO `retail_analysts`;
--
-- In a real workspace: tag customer_unique_id as sensitive; apply a UC
-- column mask or ABAC policy; review audit logs and data deletion procedures.

