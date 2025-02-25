WITH full_data AS (
  SELECT * FROM `grounded-nebula-408412.twitter.raw-zenodo`
  UNION ALL
  SELECT * FROM `grounded-nebula-408412.twitter.raw-zenodo-2022-11`
),
total_tweet_count AS (
  SELECT COUNT(id) AS total FROM full_data WHERE type IN ('reply', 'quote', 'retweet', 'status')
)

SELECT * FROM (
  -- All tweets
  SELECT
    "All tweets" AS metric,
    COUNT(id) AS count,
    ROUND(COUNT(id) * 100.0 / (SELECT total FROM total_tweet_count), 2) AS percentage
  FROM full_data
  WHERE type IN ('reply', 'quote', 'retweet', 'status')

  UNION ALL

  -- Deduplicated tweets
  SELECT
    "Deduplicated tweets" AS metric,
    COUNT(DISTINCT id),
    ROUND(COUNT(DISTINCT id) * 100.0 / (SELECT total FROM total_tweet_count), 2) AS percentage
  FROM full_data
  WHERE type IN ('reply', 'quote', 'retweet', 'status')

  UNION ALL

  -- Filtered by language (tweets only)
  SELECT
    "Filtered tweets by language (de, en, null)" AS metric,
    COUNT(DISTINCT id),
    ROUND(COUNT(DISTINCT id) * 100.0 / (SELECT total FROM total_tweet_count), 2) AS percentage
  FROM full_data
  WHERE type IN ('reply', 'quote', 'retweet', 'status')
    AND (lang IN ('de', 'en') OR lang IS NULL)

  UNION ALL

  -- Filtered by language & time (tweets only)
  SELECT
    "Filtered tweets by language & time (2020-2021)" AS metric,
    COUNT(DISTINCT id),
    ROUND(COUNT(DISTINCT id) * 100.0 / (SELECT total FROM total_tweet_count), 2) AS percentage
  FROM full_data
  WHERE type IN ('reply', 'quote', 'retweet', 'status')
    AND (lang IN ('de', 'en') OR lang IS NULL)
    AND created_at BETWEEN '2020-01-01' AND '2021-12-31'

  UNION ALL

  -- Political Discourse relevant tweets
  SELECT
    "Political Discourse relevant tweets" AS metric,
    COUNT(DISTINCT id),
    ROUND(COUNT(DISTINCT id) * 100.0 / (SELECT total FROM total_tweet_count), 2) AS percentage
  FROM full_data
  WHERE type IN ('reply', 'quote', 'retweet', 'status')
    AND (lang IN ('de', 'en') OR lang IS NULL)
    AND created_at BETWEEN '2020-01-01' AND '2021-12-31'
    AND id IN (SELECT tweet_id FROM `grounded-nebula-408412.twitter_analysis_curated.relevant_tweets`)
) AS ordered_metrics
ORDER BY 
  CASE 
    WHEN metric = "All tweets" THEN 1
    WHEN metric = "Deduplicated tweets" THEN 2
    WHEN metric = "Filtered tweets by language (de, en, null)" THEN 3
    WHEN metric = "Filtered tweets by language & time (2020-2021)" THEN 4
    WHEN metric = "Political Discourse relevant tweets" THEN 5
  END;