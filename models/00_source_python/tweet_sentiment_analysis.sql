{{ 
  config(
    materialized = "table",
    unique_key = "tweet_id",
    cluster_by = ["tweet_id", "recorded_at"]
  ) 
}}

WITH source AS (
    SELECT * 
    FROM {{ source("base_twitter_python", "tweet_sentiment_analysis") }}
),

final AS (
    SELECT
        SAFE_CAST(tweet_id AS STRING) AS tweet_id,
        SAFE_CAST(user_id AS STRING) AS user_id,
        SAFE_CAST(recorded_at AS TIMESTAMP) AS recorded_at,
        CAST(text AS STRING) AS text,
        SAFE_CAST(sentiment AS STRING) AS sentiment,
        SAFE_CAST(positive_probability AS FLOAT64) AS positive_probability,
        SAFE_CAST(neutral_probability AS FLOAT64) AS neutral_probability,
        SAFE_CAST(negative_probability AS FLOAT64) AS negative_probability,
        SAFE_CAST(toxicity_label AS STRING) AS toxicity_label,
        SAFE_CAST(toxicity_score AS FLOAT64) AS toxicity_score
    FROM source
)

SELECT * FROM final