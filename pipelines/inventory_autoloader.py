"""OPTIONAL Lakeflow Declarative Pipelines example, not the batch job entrypoint.

Configure a pipeline with this source file, a target catalog/schema, and setting:
  shoppulse.inventory_source = /Volumes/workspace/shoppulse_bronze/source_files/inventory_stream/
This is separate from the batch JSONL inventory demo.
"""
from pyspark import pipelines as dp
from pyspark.sql import functions as F

source_path = spark.conf.get("shoppulse.inventory_source")


@dp.table(name="inventory_events_stream", comment="Incremental Auto Loader inventory feed")
def inventory_events_stream():
    schema = (
        "event_id STRING, warehouse_id STRING, sku_id STRING, "
        "event_ts STRING, movement_type STRING, qty_delta STRING, source_version STRING"
    )
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", "json")
        .schema(schema)
        .load(source_path)
        .withColumn("ingested_at", F.current_timestamp())
    )


@dp.table(name="inventory_valid_stream", comment="Validated inventory change events")
@dp.expect_or_drop("has_keys", "event_id IS NOT NULL AND warehouse_id IS NOT NULL AND sku_id IS NOT NULL")
@dp.expect_or_drop("nonzero_quantity", "try_cast(qty_delta AS BIGINT) <> 0")
def inventory_valid_stream():
    return (
        spark.readStream.table("inventory_events_stream")
        .withColumn("event_ts", F.to_timestamp("event_ts"))
        .withColumn("qty_delta", F.expr("try_cast(qty_delta AS BIGINT)"))
    )

