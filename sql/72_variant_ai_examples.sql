-- Semi-structured JSON handling with Delta SQL VARIANT.
SELECT parse_json('{"event_id":"S1","source":{"app":"shop"},"total":129.50}') AS payload;

SELECT variant_get(
         parse_json('{"event_id":"S1","source":{"app":"shop"},"total":129.50}'),
         '$.source.app', 'STRING') AS source_app;

-- AI enrichment requires a configured and permitted model endpoint. Example
-- syntax only; DO NOT execute or send personal data to a model by default:
-- SELECT ai_query('<approved-endpoint>', 'Classify inventory issue: late delivery');

