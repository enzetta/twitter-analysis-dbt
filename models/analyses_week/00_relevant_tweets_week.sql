{{ 
  config(
    materialized = "table",
    cluster_by = ["created_at"]
  ) 
}}

WITH relevant_tweets AS (
  SELECT *,
  DATE_TRUNC(DATE(created_at), WEEK(MONDAY)) AS week_start
  FROM {{ ref('relevant_tweets_with_predictions') }}
  WHERE aggregated_categories IS NOT NULL
)

SELECT *
FROM relevant_tweets