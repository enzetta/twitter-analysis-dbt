{{ 
  config(
    materialized = "table",
    cluster_by = ["category", "total_tweets"]
  ) 
}}

WITH base_tweets AS (
    SELECT
        i.tweet_id,
        i.user_id,
        i.created_at,
        LOWER(hashtag) AS hashtag,
        COALESCE(pe.is_politician, FALSE) AS is_politician,
        pe.party,
        pe.office,
        pe.institution,
        pe.region,
        pe.gender,
        pe.year_of_birth
    FROM {{ ref('00_interactions_referrers') }} AS i
    CROSS JOIN UNNEST(i.hashtags) AS hashtag
    LEFT JOIN {{ ref('02_politically_engaged_users') }} AS pe ON i.user_id = pe.user_id
    WHERE i.hashtags IS NOT NULL
),

final AS (
    SELECT
        hc.category,
        hc.hashtag,
        -- Overall metrics
        COUNT(DISTINCT t.tweet_id) AS total_tweets,
        COUNT(DISTINCT t.user_id) AS total_users,
        COUNT(DISTINCT t.hashtag) AS unique_hashtags,
        MIN(t.created_at) AS first_tweet_at,
        MAX(t.created_at) AS last_tweet_at,

        -- Politician vs Non-politician metrics
        COUNT(DISTINCT CASE WHEN t.is_politician THEN t.tweet_id END) AS politician_tweets,
        COUNT(DISTINCT CASE WHEN t.is_politician THEN t.user_id END) AS politician_users,
        COUNT(DISTINCT CASE WHEN NOT t.is_politician THEN t.tweet_id END) AS non_politician_tweets,
        COUNT(DISTINCT CASE WHEN NOT t.is_politician THEN t.user_id END) AS non_politician_users,

        -- Party-specific tweet counts
        COUNT(DISTINCT CASE WHEN t.party = 'SPD' THEN t.tweet_id END) AS spd_tweets,
        COUNT(DISTINCT CASE WHEN t.party = 'DIE LINKE' THEN t.tweet_id END) AS linke_tweets,
        COUNT(DISTINCT CASE WHEN t.party = 'FDP' THEN t.tweet_id END) AS fdp_tweets,
        COUNT(DISTINCT CASE WHEN t.party = 'CSU' THEN t.tweet_id END) AS csu_tweets,
        COUNT(DISTINCT CASE WHEN t.party = 'CDU' THEN t.tweet_id END) AS cdu_tweets,
        COUNT(DISTINCT CASE WHEN t.party = 'AfD' THEN t.tweet_id END) AS afd_tweets,
        COUNT(DISTINCT CASE WHEN t.party = 'Bündnis 90/Die Grünen' THEN t.tweet_id END) AS gruene_tweets,
        COUNT(DISTINCT CASE WHEN t.party = 'DIE PARTEI' THEN t.tweet_id END) AS diepartei_tweets,

        -- Party-specific user counts
        COUNT(DISTINCT CASE WHEN t.party = 'SPD' THEN t.user_id END) AS spd_users,
        COUNT(DISTINCT CASE WHEN t.party = 'DIE LINKE' THEN t.user_id END) AS linke_users,
        COUNT(DISTINCT CASE WHEN t.party = 'FDP' THEN t.user_id END) AS fdp_users,
        COUNT(DISTINCT CASE WHEN t.party = 'CSU' THEN t.user_id END) AS csu_users,
        COUNT(DISTINCT CASE WHEN t.party = 'CDU' THEN t.user_id END) AS cdu_users,
        COUNT(DISTINCT CASE WHEN t.party = 'AfD' THEN t.user_id END) AS afd_users,
        COUNT(DISTINCT CASE WHEN t.party = 'Bündnis 90/Die Grünen' THEN t.user_id END) AS gruene_users,
        COUNT(DISTINCT CASE WHEN t.party = 'DIE PARTEI' THEN t.user_id END) AS diepartei_users

    FROM base_tweets AS t
    INNER JOIN {{ ref('hashtag_categories_exploded') }} AS hc
        ON t.hashtag = LOWER(hc.hashtag)
    WHERE DATE(t.created_at) BETWEEN '2020-01-01' AND '2021-12-31'
    GROUP BY 1, 2
)

SELECT * FROM final
