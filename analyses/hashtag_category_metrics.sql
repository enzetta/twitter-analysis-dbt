WITH HashtagUsage AS (
    SELECT
        hc.category,
        ht,
        COUNT(rt.tweet_id) AS usage_count,
        COUNT(DISTINCT rt.user_id) AS unique_users
    FROM `grounded-nebula-408412.twitter_analysis_curated.relevant_tweets` rt
    CROSS JOIN UNNEST(rt.hashtags) AS ht
    LEFT JOIN `grounded-nebula-408412.twitter_analysis_curated.hashtags_categories_exploded` hc
        ON hc.hashtag = ht
    GROUP BY hc.category, ht
),

PoliticalUsers AS (
    SELECT DISTINCT user_id
    FROM `grounded-nebula-408412.twitter_analysis_staging.01_political_users`
),

HashtagPoliticalUsage AS (
    SELECT
        hc.category,
        ht,
        COUNT(rt.tweet_id) AS politician_usage_count,  -- Count of tweets from politicians
        COUNT(DISTINCT rt.user_id) AS politician_users
    FROM `grounded-nebula-408412.twitter_analysis_curated.relevant_tweets` rt
    CROSS JOIN UNNEST(rt.hashtags) AS ht
    LEFT JOIN `grounded-nebula-408412.twitter_analysis_curated.hashtags_categories_exploded` hc
        ON hc.hashtag = ht
    INNER JOIN PoliticalUsers pu
        ON rt.user_id = pu.user_id
    GROUP BY hc.category, ht
)

SELECT
    hu.category,
    SUM(hu.usage_count) AS total_usage,
    SUM(hu.unique_users) AS total_unique_users,
    COALESCE(SUM(hpu.politician_users), 0) AS total_politician_users,
    COALESCE(SUM(hpu.politician_usage_count), 0) AS total_politician_usage -- New column for tweet count from politicians
FROM HashtagUsage hu
LEFT JOIN HashtagPoliticalUsage hpu
    ON hu.category = hpu.category AND hu.ht = hpu.ht
GROUP BY hu.category
ORDER BY total_politician_users DESC;