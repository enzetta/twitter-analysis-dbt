-- source_python/network_network_metrics_migration.sql
{{ 
  config(
    materialized = "table",
    unique_key = "row_id",
    cluster_by = ["month_start"]
  ) 
}}

WITH source AS (
    SELECT * 
    FROM {{ source("base_twitter_python", "network_network_metrics_migration") }}
),

final AS (
    SELECT
        SAFE_CAST(row_id AS STRING) AS row_id,
        SAFE_CAST(month_start AS DATE) AS month_start,
        SAFE_CAST(table_name AS STRING) AS table_name,
        SAFE_CAST(nodes AS INT64) AS nodes,
        SAFE_CAST(edges AS INT64) AS edges,
        SAFE_CAST(density AS FLOAT64) AS density,
        SAFE_CAST(connected_components AS INT64) AS connected_components,
        SAFE_CAST(transitivity AS FLOAT64) AS transitivity,
        SAFE_CAST(modularity AS FLOAT64) AS modularity,
        SAFE_CAST(modularity_classes AS INT64) AS modularity_classes,
        SAFE_CAST(assortativity AS FLOAT64) AS assortativity,
        SAFE_CAST(network_avg_toxicity AS FLOAT64) AS network_avg_toxicity,
        SAFE_CAST(median_node_toxicity AS FLOAT64) AS median_node_toxicity,
        SAFE_CAST(max_core_number AS INT64) AS max_core_number,
        SAFE_CAST(avg_core_number AS FLOAT64) AS avg_core_number,
        SAFE_CAST(rich_club_coefficient AS FLOAT64) AS rich_club_coefficient,
        SAFE_CAST(average_clustering AS FLOAT64) AS average_clustering
    FROM source
)

SELECT * FROM final