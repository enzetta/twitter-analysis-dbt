{{ 
  config(
    materialized = "table",
    unique_key = "tweet_id",
    cluster_by = ["tweet_id"]
  ) 
}}

WITH predictions AS (
    SELECT 
        tweet_id,
        user_id,
        -- Safe Cast: Converts values to FLOAT64 while preventing errors 
        -- that could arise from incompatible data types or NULL values.
        -- If a conversion fails, SAFE_CAST returns NULL instead of throwing an error.
        SAFE_CAST(toxicity_score AS FLOAT64) AS toxicity_score,
        SAFE_CAST(positive_probability AS FLOAT64) AS positive_probability,
        SAFE_CAST(negative_probability AS FLOAT64) AS negative_probability,
        SAFE_CAST(neutral_probability AS FLOAT64) AS neutral_probability,
        CASE 
            WHEN toxicity_label = "toxic" THEN toxicity_score
            ELSE 1 - toxicity_score
        END AS adjusted_toxicity_score,
        (positive_probability - negative_probability) AS sentiment_score
    FROM {{ source("src_twitter", "backup_tweet_sentiment_analysis") }}
)

SELECT 
    tweet_id,
    user_id,
    adjusted_toxicity_score AS toxicity_score,
    sentiment_score,
    positive_probability,
    negative_probability
FROM predictions