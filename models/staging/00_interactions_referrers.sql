{{ 
  config(
    materialized = "incremental",
    unique_key = "tweet_id",
    partition_by = {
      "field": "recorded_at",
      "data_type": "timestamp",
    },
    cluster_by = ["tweet_id"]
  ) 
}}

-- Quell-CTE, die die Basisdaten lädt
WITH source AS (
    SELECT *
    FROM {{ ref("interactions") }}
    {% if is_incremental() %}
      WHERE FALSE
    {% endif %}
),

-- Finale CTE, die die Tweet-Referenzen auflöst
final AS (
    SELECT
        a.*,
        b.user_id AS refers_to_user_id
    FROM source AS a
    LEFT JOIN source AS b
        ON a.refers_to = b.tweet_id
)

-- Gebe alle Daten aus der finalen CTE zurück
SELECT *
FROM final
