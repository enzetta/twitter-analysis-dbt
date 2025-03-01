{{ 
  config(
    materialized = "table",
    unique_key = "toxicity_bucket"
  ) 
}}

WITH user_toxicity_distribution AS (
    SELECT 
        user_id,
        FORMAT("%.2f", FLOOR(AVG(toxicity_score) * 20) / 20) AS toxicity_bucket, -- Binning toxicity scores
        COUNT(*) AS tweet_count
    FROM {{ ref('tweets_relevant_with_predictions') }}
    WHERE toxicity_score IS NOT NULL
    GROUP BY user_id
)

SELECT 
    toxicity_bucket, 
    COUNT(user_id) AS user_count
FROM user_toxicity_distribution
GROUP BY toxicity_bucket
ORDER BY toxicity_bucket