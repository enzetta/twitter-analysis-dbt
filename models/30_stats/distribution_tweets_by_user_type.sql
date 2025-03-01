-- File: distribution_tweets_by_user_type.sql

{{ 
  config(
    materialized = "table",
    unique_key = "user_type"
  ) 
}}

WITH user_type_tweet_distribution AS (
    SELECT 
        CASE 
            WHEN party IS NOT NULL THEN 'politician'
            ELSE 'general_user'
        END AS user_type,
        COUNT(*) AS tweet_count
    FROM {{ ref('tweets_relevant_with_predictions') }}
    GROUP BY user_type
)

SELECT * FROM user_type_tweet_distribution
ORDER BY tweet_count DESC