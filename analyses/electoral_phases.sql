WITH full_data AS (
  SELECT tweet_id, created_at 
  FROM `grounded-nebula-408412.twitter_analysis_curated.relevant_tweets`
  WHERE created_at IS NOT NULL 
    AND created_at BETWEEN '2020-01-01' AND '2021-12-31'
),
phase_counts AS (
  SELECT
    CASE 
      WHEN created_at BETWEEN '2020-01-01' AND '2020-09-30' THEN 'Non-Electoral Phase'
      WHEN created_at BETWEEN '2020-10-01' AND '2021-03-31' THEN 'Pre-Campaign'  -- FIXED START DATE
      WHEN created_at BETWEEN '2021-04-01' AND '2021-06-30' THEN 'Campaign'
      WHEN created_at BETWEEN '2021-07-01' AND '2021-08-31' THEN 'Intensive Campaign'
      WHEN created_at BETWEEN '2021-09-01' AND '2021-09-30' THEN 'Final Sprint'
      WHEN created_at BETWEEN '2021-10-01' AND '2021-12-31' THEN 'Post-Election'
      ELSE 'Out of Range' -- DEBUGGING NULL ISSUE
    END AS phase,
    COUNT(*) AS tweet_count
  FROM full_data
  GROUP BY phase
)
SELECT phase, tweet_count
FROM phase_counts
ORDER BY 
  CASE 
    WHEN phase = 'Non-Electoral Phase' THEN 1
    WHEN phase = 'Pre-Campaign' THEN 2
    WHEN phase = 'Campaign' THEN 3
    WHEN phase = 'Intensive Campaign' THEN 4
    WHEN phase = 'Final Sprint' THEN 5
    WHEN phase = 'Post-Election' THEN 6
    ELSE 7
  END;