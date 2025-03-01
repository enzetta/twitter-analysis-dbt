{{ 
  config(
    materialized = "table",
    unique_key = "hashtag",
    cluster_by = ["hashtag", "usage_count"]
  ) 
}}

WITH source AS (
    SELECT *
    FROM {{ source("base_twitter_raw", "hashtag_categorisation") }}
),

final AS (
    SELECT
        LOWER(TRIM(hashtag)) AS hashtag,
        SAFE_CAST(usage_count AS INT64) AS usage_count,
        SAFE_CAST(unique_users AS INT64) AS unique_users,
        SAFE_CAST(politician_users AS INT64) AS politician_users,
        SAFE_CAST(first_used_at AS TIMESTAMP) AS first_used_at,
        SAFE_CAST(last_used_at AS TIMESTAMP) AS last_used_at,
        SAFE_CAST(pct_political_users AS FLOAT64) AS pct_political_users,
        SAFE_CAST(days_active AS INT64) AS days_active,
        TRIM(categories) AS categories,
        SAFE_CAST(confidence AS FLOAT64) AS confidence
    FROM source
)

SELECT * FROM final