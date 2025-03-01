{{ 
  config(
    materialized = "table",
    unique_key = "toxicity_bucket"
  ) 
}}

WITH toxicity_distribution AS (
    SELECT 
        FORMAT("%.2f", FLOOR(toxicity_score * 20) / 20) AS toxicity_bucket, -- Only the starting point
        COUNT(*) AS tweet_count
    FROM {{ ref('tweets_relevant_with_predictions') }}
    WHERE toxicity_score IS NOT NULL
    GROUP BY toxicity_bucket
)

SELECT * FROM toxicity_distribution
ORDER BY toxicity_bucket