{{ 
  config(
    materialized = "table",
    cluster_by = ["source_hashtag"]
  ) 
}}

WITH relevant_tweets AS (
  SELECT *
  FROM {{ ref('00_relevant_tweets_week') }}
),

hashtag_pairs AS (
    -- Generate all unique hashtag pairs within the same tweet
    SELECT
        tweet_id,
        LOWER(h1) AS source_hashtag,  -- Standardized lowercase hashtag
        LOWER(h2) AS target_hashtag,  -- Standardized lowercase hashtag
        toxicity_score
    FROM relevant_tweets,
    UNNEST(hashtags) AS h1,
    UNNEST(hashtags) AS h2
    WHERE h1 <> h2 -- Avoid self-loops (hashtags co-occurring with themselves)
),

network AS (
    -- Aggregate hashtag co-occurrence metrics
    SELECT
        source_hashtag,
        target_hashtag,
        'co-mention' AS edge_type,
        COUNT(*) AS edge_weight,  -- Number of times this hashtag pair co-occurred
        COUNT(*) - SUM(toxicity_score) AS agg_neutral_score,
        SUM(toxicity_score) AS agg_toxicity_score
    FROM hashtag_pairs
    GROUP BY source_hashtag, target_hashtag
)

SELECT *
FROM network