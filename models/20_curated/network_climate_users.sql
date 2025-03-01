{{ 
  config(
    materialized = "table",
    cluster_by = ["month_start"]
  ) 
}}

WITH user_replies AS (
    SELECT 
        rt.screen_name AS source,
        u2.screen_name AS target,
        'person_person' AS connection_type,
        'person' AS entity_type,
        rt.type AS interaction_type,
        DATE_TRUNC(rt.created_at, MONTH) AS month_start,
        COUNT(*) AS edge_weight,
        AVG(rt.sentiment_score) AS avg_sentiment,
        AVG(rt.toxicity_score) AS avg_toxicity,
        SUM(rt.sentiment_score) AS sum_sentiment,
        SUM(rt.toxicity_score) AS sum_toxicity
    FROM {{ ref('tweets_relevant_climate') }} rt
    LEFT JOIN {{ ref('users') }} u2 
        ON rt.refers_to_user_id = u2.user_id
    WHERE rt.refers_to_user_id IS NOT NULL
        AND rt.screen_name IS NOT NULL 
        AND u2.screen_name IS NOT NULL
    GROUP BY 1, 2, 3, 4, 5, 6
),

user_mentions AS (
    SELECT 
        rt.screen_name AS source,
        u2.screen_name AS target,
        'person_mention' AS connection_type,
        'person' AS entity_type,
        rt.type AS interaction_type,
        DATE_TRUNC(rt.created_at, MONTH) AS month_start,
        COUNT(*) AS edge_weight,
        AVG(rt.sentiment_score) AS avg_sentiment,
        AVG(rt.toxicity_score) AS avg_toxicity,
        SUM(rt.sentiment_score) AS sum_sentiment,
        SUM(rt.toxicity_score) AS sum_toxicity
    FROM {{ ref('tweets_relevant_climate') }} rt
    CROSS JOIN UNNEST(rt.mentioned_ids) AS mentioned_id
    LEFT JOIN {{ ref('users') }} u2 
        ON mentioned_id = u2.user_id
    WHERE rt.screen_name IS NOT NULL 
        AND u2.screen_name IS NOT NULL
    GROUP BY 1, 2, 3, 4, 5, 6
),

hashtag_user_connections AS (
    SELECT 
        rt.screen_name AS source,
        LOWER(hashtag) AS target,
        'person_hashtag' AS connection_type,
        'mixed' AS entity_type,
        rt.type AS interaction_type,
        DATE_TRUNC(rt.created_at, MONTH) AS month_start,
        COUNT(*) AS edge_weight,
        AVG(rt.sentiment_score) AS avg_sentiment,
        AVG(rt.toxicity_score) AS avg_toxicity,
        SUM(rt.sentiment_score) AS sum_sentiment,
        SUM(rt.toxicity_score) AS sum_toxicity
    FROM {{ ref('tweets_relevant_climate') }} rt
    CROSS JOIN UNNEST(rt.hashtags) AS hashtag
    WHERE rt.screen_name IS NOT NULL 
        AND hashtag IS NOT NULL
    GROUP BY 1, 2, 3, 4, 5, 6
),

hashtag_cooccurrence AS (
    SELECT 
        LOWER(h1) AS source,
        LOWER(h2) AS target,
        'hashtag_hashtag' AS connection_type,
        'hashtag' AS entity_type,
        rt.type AS interaction_type,
        DATE_TRUNC(rt.created_at, MONTH) AS month_start,
        COUNT(*) AS edge_weight,
        AVG(rt.sentiment_score) AS avg_sentiment,
        AVG(rt.toxicity_score) AS avg_toxicity,
        SUM(rt.sentiment_score) AS sum_sentiment,
        SUM(rt.toxicity_score) AS sum_toxicity
    FROM {{ ref('tweets_relevant_climate') }} rt
    CROSS JOIN UNNEST(rt.hashtags) AS h1
    CROSS JOIN UNNEST(rt.hashtags) AS h2
    WHERE h1 < h2
    GROUP BY 1, 2, 3, 4, 5, 6
),

combined_edges AS (
    SELECT * FROM user_replies
    UNION ALL
    SELECT * FROM user_mentions
    UNION ALL
    SELECT * FROM hashtag_user_connections
    UNION ALL
    SELECT * FROM hashtag_cooccurrence
),

pre_final AS (
    SELECT 
        source,
        target,
        connection_type,
        entity_type,
        month_start,
        SUM(edge_weight) AS edge_weight,
        SUM(sum_toxicity) / SUM(edge_weight) AS avg_toxicity,
        SUM(sum_toxicity) AS sum_toxicity
    FROM combined_edges
    WHERE source != target
    GROUP BY 1, 2, 3, 4, 5
), final AS (
    SELECT
        source AS source,
        target AS target,
        month_start AS month_start,
        SUM(edge_weight) AS weight,
        SUM(sum_toxicity) AS sum_toxicity,
        SUM(sum_toxicity) / SUM(edge_weight) AS avg_toxicity
    FROM pre_final
    WHERE
        avg_toxicity IS NOT NULL
        AND entity_type IN ("person")
    GROUP BY
        1,
        2,
        3
    ORDER BY
        month_start ASC,
        weight ASC
)

SELECT * 
FROM final