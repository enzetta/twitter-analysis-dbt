{{ 
  config(
    materialized = "table",
    unique_key = "tweet_id",
    cluster_by = ["tweet_id"]
  ) 
}}

WITH predictions AS (
    SELECT 
        sentiment.tweet_id,
        sentiment.user_id,
        interactions.created_at,
        -- Safe Cast: Converts values to FLOAT64 while preventing errors 
        -- that could arise from incompatible data types or NULL values.
        -- If a conversion fails, SAFE_CAST returns NULL instead of throwing an error.
        SAFE_CAST(sentiment.toxicity_score AS FLOAT64) AS toxicity_score,
        SAFE_CAST(sentiment.positive_probability AS FLOAT64) AS positive_probability,
        SAFE_CAST(sentiment.negative_probability AS FLOAT64) AS negative_probability,
        SAFE_CAST(sentiment.neutral_probability AS FLOAT64) AS neutral_probability,
        CASE 
            WHEN sentiment.toxicity_label = "toxic" THEN sentiment.toxicity_score
            ELSE 1 - sentiment.toxicity_score
        END AS adjusted_toxicity_score,
        (sentiment.positive_probability - sentiment.negative_probability) AS sentiment_score
    FROM {{ ref("tweet_sentiment_analysis") }} AS sentiment
    -- FROM {{ source("base_twitter_python", "tweet_sentiment_analysis") }} sentiment
    LEFT JOIN {{ ref('interactions') }} AS interactions
        ON sentiment.tweet_id = interactions.tweet_id
)

SELECT 
    tweet_id,
    user_id,
    created_at,
    adjusted_toxicity_score AS toxicity_score,
    sentiment_score,
    positive_probability,
    negative_probability
FROM predictions