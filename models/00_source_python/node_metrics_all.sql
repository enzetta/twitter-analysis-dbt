-- source_python/network_node_metrics_all.sql
{{ 
  config(
    materialized = "table",
    unique_key = "node_id",
    cluster_by = ["node_id", "month_start"]
  ) 
}}

WITH source AS (
    SELECT * 
    FROM {{ source("base_twitter_python", "network_node_metrics_all") }}
),

final AS (
    SELECT
        SAFE_CAST(row_id AS STRING) AS row_id,
        SAFE_CAST(month_start AS DATE) AS month_start,
        SAFE_CAST(node_id AS STRING) AS node_id,
        SAFE_CAST(pagerank AS FLOAT64) AS pagerank,
        SAFE_CAST(degree_in AS FLOAT64) AS degree_in,
        SAFE_CAST(degree_out AS FLOAT64) AS degree_out,
        SAFE_CAST(betweenness AS FLOAT64) AS betweenness,
        SAFE_CAST(clustering AS FLOAT64) AS clustering,
        SAFE_CAST(triangles AS INT64) AS triangles,
        SAFE_CAST(core_number AS INT64) AS core_number,
        SAFE_CAST(interactions_sent AS INT64) AS interactions_sent,
        SAFE_CAST(interactions_received AS INT64) AS interactions_received,
        SAFE_CAST(interactions_total AS INT64) AS interactions_total,
        SAFE_CAST(toxicity_sent AS FLOAT64) AS toxicity_sent,
        SAFE_CAST(toxicity_received AS FLOAT64) AS toxicity_received,
        SAFE_CAST(toxicity_sent_avg AS FLOAT64) AS toxicity_sent_avg,
        SAFE_CAST(toxicity_received_avg AS FLOAT64) AS toxicity_received_avg
    FROM source
)

SELECT * FROM final