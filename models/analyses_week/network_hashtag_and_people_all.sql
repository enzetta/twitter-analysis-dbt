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

-- Extract interactions between people
people_network AS (
    -- Replies
    SELECT
        week_start, 
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

    -- Quotes
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

    -- Retweets
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

    -- Mentions
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
),

-- Extract people using hashtags
hashtag_network AS (
    SELECT
        week_start,
        screen_name,
        user_id AS source_node,
        LOWER(hashtag) AS target_node, -- Hashtag as target node
        party,
        office,
        institution,
        gender,
        'hashtag_usage' AS edge_type, -- Distinguish from person-to-person edges
        COUNT(*) AS edge_weight,
        COUNT(*) - SUM(toxicity_score) AS agg_neutral_score,
        SUM(toxicity_score) AS agg_toxicity_score
    FROM relevant_tweets,
    UNNEST(hashtags) AS hashtag
    GROUP BY week_start, screen_name, user_id, hashtag, party, office, institution, gender
)

-- Combine both networks into one
SELECT * FROM people_network
UNION ALL
SELECT * FROM hashtag_network