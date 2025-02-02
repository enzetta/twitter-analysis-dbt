{{ 
  config(
    materialized = "table",
    unique_key = ["user_id", "hashtag"],
    cluster_by = ["user_id", "hashtag"]
  ) 
}}

WITH hashtag_counts AS (
    SELECT
        i.user_id,
        hashtag,
        COUNT(DISTINCT i.tweet_id) AS usage_count,
        MIN(i.created_at) AS first_used_at,
        MAX(i.created_at) AS last_used_at
    FROM {{ ref("00_interactions_referrers") }} AS i,
        UNNEST(hashtags) AS hashtag
    WHERE hashtags IS NOT NULL
    GROUP BY 1, 2
),

final AS (

    SELECT
        h.*,
        u.name,
        u.screen_name,
        u.followers_count,
        u.friends_count,
        -- Political information
        p.is_politician,
        p.party,
        p.institution,
        p.office,
        p.region,
        p.gender,
        p.year_of_birth
    FROM hashtag_counts AS h
    LEFT JOIN {{ ref("users") }} AS u ON h.user_id = u.user_id
    LEFT JOIN {{ ref("02_politically_engaged_users") }} AS p ON h.user_id = p.user_id
)

SELECT * FROM final
