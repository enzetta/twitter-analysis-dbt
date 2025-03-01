-- File: toxicity_distribution_users_by_party.sql

{{ 
  config(
    materialized = "table",
    unique_key = ["party", "toxicity_bucket"]
  ) 
}}

WITH user_avg_toxicity AS (
    SELECT 
        user_id,
        party,
        AVG(toxicity_score) AS avg_toxicity_score
    FROM {{ ref('tweets_relevant_with_predictions') }}
    WHERE toxicity_score IS NOT NULL AND party IS NOT NULL
    GROUP BY user_id, party
),

user_toxicity_by_party AS (
    SELECT 
        party,
        FORMAT("%.2f", FLOOR(avg_toxicity_score * 20) / 20) AS toxicity_bucket, -- Binning toxicity scores
        COUNT(DISTINCT user_id) AS user_count
    FROM user_avg_toxicity
    GROUP BY party, toxicity_bucket
)

SELECT 
    party, 
    toxicity_bucket, 
    user_count
FROM user_toxicity_by_party
ORDER BY party, toxicity_bucket