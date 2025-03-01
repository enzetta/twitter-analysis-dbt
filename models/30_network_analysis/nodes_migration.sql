{{ 
  config(
    materialized = "table",
    unique_key = "node_id",
    cluster_by = ["node_id", "month_start"]
  ) 
}}

WITH nodes AS (
    SELECT * 
    FROM {{ ref("node_metrics_migration") }}
),

politicians AS (
    SELECT 
        LOWER(twitter_handle) AS twitter_handle,
        party,
    FROM {{ ref("ext_epi_netz_de") }}
    GROUP BY
        1,2
),

final AS (
    SELECT
        nodes.*,
        politicians.party
    FROM nodes
    LEFT JOIN politicians
    ON LOWER(nodes.node_id) = politicians.twitter_handle
)

SELECT * FROM final