{{ 
  config(
    materialized = "table",
    unique_key = "hashtag",
    cluster_by = ["hashtag", "usage_count"]
  ) 
}}

WITH political_users AS (
    SELECT user_id
    FROM {{ ref("01_political_users") }}
    -- WHERE is_politician = TRUE
),

hashtag_usage AS (
    SELECT
        LOWER(hashtag) AS hashtag,
        COUNT(DISTINCT i.tweet_id) AS usage_count,
        COUNT(DISTINCT i.user_id) AS unique_users,
        COUNT(DISTINCT CASE WHEN i.user_id IN (SELECT user_id FROM political_users) THEN i.user_id END) AS politician_users,
        MIN(i.created_at) AS first_used_at,
        MAX(i.created_at) AS last_used_at
    FROM {{ ref("00_interactions_with_referrers") }} AS i,
        UNNEST(hashtags) AS hashtag
    WHERE hashtags IS NOT NULL
    GROUP BY 1
),

final AS (
    SELECT
        hashtag,
        usage_count,
        unique_users,
        politician_users,
        first_used_at,
        last_used_at,
        -- Add some useful metrics
        ROUND(politician_users / unique_users * 100, 2) AS _01_political_users,
        DATE_DIFF(CAST(last_used_at AS DATE), CAST(first_used_at AS DATE), DAY) AS days_active
    FROM hashtag_usage
    -- Only include hashtags that were used by at least one politician
    WHERE politician_users > 0
    ORDER BY usage_count DESC
)

SELECT * FROM final
