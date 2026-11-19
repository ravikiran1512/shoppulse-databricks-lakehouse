"""OPTIONAL Lakeflow AUTO CDC SCD2 example.

Config required in a SEPARATE Lakeflow Pipeline:
  shoppulse.cdc_source = /Volumes/workspace/shoppulse_bronze/source_files/customer_cdc/
Provide JSON events: customer_id, channel, event_ts (ISO timestamp), op ('U'/'D').
Use ordered event_ts; duplicate/tied timestamps need an additional sequence field.
"""
from pyspark import pipelines as dp
from pyspark.sql import functions as F

source_path = spark.conf.get("shoppulse.cdc_source")


@dp.table(name="customer_preference_events", comment="Synthetic CDC event stream")
def customer_preference_events():
    schema = "customer_id STRING, channel STRING, event_ts TIMESTAMP, op STRING"
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", "json")
        .schema(schema)
        .load(source_path)
        .where("customer_id IS NOT NULL AND event_ts IS NOT NULL")
    )


dp.create_streaming_table("customer_preferences_scd2")

dp.create_auto_cdc_flow(
    target="customer_preferences_scd2",
    source="customer_preference_events",
    keys=["customer_id"],
    sequence_by=F.col("event_ts"),
    apply_as_deletes=F.expr("op = 'D'"),
    except_column_list=["op", "event_ts"],
    stored_as_scd_type=2,
)

