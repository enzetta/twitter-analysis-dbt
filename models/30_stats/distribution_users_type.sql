-- File: distribution_users_type.sql

{{ 
  config(
    materialized = "table",
    unique_key = "user_type"
  ) 
}}

WITH user_type_distribution AS (
    SELECT 
        CASE 
            WHEN party IS NOT NULL THEN 'politician'
            ELSE 'general_user'
        END AS user_type,
        COUNT(DISTINCT user_id) AS user_count
    FROM {{ ref('tweets_relevant_with_predictions') }}
    GROUP BY user_type
)

SELECT * FROM user_type_distribution
ORDER BY user_count DESC