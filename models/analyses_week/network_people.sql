{{ 
  config(
    materialized = "table",
    cluster_by = ["week_start", "source_node"]
  ) 
}}

WITH relevant_tweets AS (
  SELECT *
  FROM {{ ref('00_relevant_tweets_week') }}
),

network AS (
    -- Extract interactions from replies
    SELECT
        week_start, -- Week starting on Monday
        screen_name,
        user_id AS source_node, 
        refers_to_user_id AS target_node,
        party,
        office,
        institution,
        gender,
        'reply' AS edge_type,
        COUNT(*) AS edge_weight,
        COUNT(*) - SUM(toxicity_score) AS agg_neutral_score,
        SUM(toxicity_score) AS agg_toxicity_score
    FROM relevant_tweets
    WHERE type = 'reply' AND refers_to_tweet_id IS NOT NULL
    GROUP BY week_start, screen_name, user_id, refers_to_user_id, party, office, institution, gender

    UNION ALL

    -- Extract interactions from quotes (use `refers_to` instead of `refers_to_user_id`)
    SELECT
        week_start,
        screen_name,
        user_id AS source_node,
        refers_to_user_id AS target_node,
        party,
        office,
        institution,
        gender,
        'quote' AS edge_type,
        COUNT(*) AS edge_weight,
        COUNT(*) - SUM(toxicity_score) AS agg_neutral_score,
        SUM(toxicity_score) AS agg_toxicity_score
    FROM relevant_tweets
    WHERE type = 'quote' AND refers_to_tweet_id IS NOT NULL
    GROUP BY week_start, screen_name, user_id, refers_to_user_id, party, office, institution, gender

    UNION ALL

    -- Extract interactions from retweets (use `refers_to`)
    SELECT
        week_start,
        screen_name,
        user_id AS source_node,
        refers_to_user_id AS target_node,
        party,
        office,
        institution,
        gender,
        'retweet' AS edge_type,
        COUNT(*) AS edge_weight,
        COUNT(*) - SUM(toxicity_score) AS agg_neutral_score,
        SUM(toxicity_score) AS agg_toxicity_score
    FROM relevant_tweets
    WHERE type = 'retweet' AND refers_to_tweet_id IS NOT NULL
    GROUP BY week_start, screen_name, user_id, refers_to_user_id, party, office, institution, gender

    UNION ALL

    -- Extract interactions from mentions (Removed unnecessary `ARRAY_LENGTH` check)
    SELECT
        week_start,
        screen_name,
        user_id AS source_node,
        mentioned_id AS target_node,
        party,
        office,
        institution,
        gender,
        'mention' AS edge_type,
        COUNT(*) AS edge_weight,
        COUNT(*) - SUM(toxicity_score) AS agg_neutral_score,
        SUM(toxicity_score) AS agg_toxicity_score
    FROM relevant_tweets,
    UNNEST(mentioned_ids) AS mentioned_id
    GROUP BY week_start, screen_name, user_id, mentioned_id, party, office, institution, gender
)

SELECT *
FROM network