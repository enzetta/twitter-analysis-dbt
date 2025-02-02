WITH
hashtag_aggregations AS (
    SELECT
        hashtag,
        ARRAY_TO_STRING(categories, ' ## ') AS flattened_categories,
        SUM(total_tweets) AS total_tweets,
        SUM(total_users) AS total_users,
        SUM(politician_tweets) AS politician_tweets,
        SUM(politician_users) AS politician_users,
        SUM(non_politician_users) AS non_politician_users,
        SUM(non_politician_tweets) AS non_politician_tweets,
        SUM(spd_tweets) AS spd_tweets,
        SUM(spd_users) AS spd_users,
        SUM(cdu_tweets) AS cdu_tweets,
        SUM(cdu_users) AS cdu_users,
        SUM(fdp_tweets) AS fdp_tweets,
        SUM(fdp_users) AS fdp_users,
        SUM(afd_tweets) AS afd_tweets,
        SUM(afd_users) AS afd_users,
        SUM(csu_tweets) AS csu_tweets,
        SUM(csu_users) AS csu_users,
        SUM(gruene_tweets) AS gruene_tweets,
        SUM(gruene_users) AS gruene_users,
        SUM(SUM(spd_tweets)) OVER () AS total_spd_tweets,
        SUM(SUM(cdu_tweets)) OVER () AS total_cdu_tweets,
        SUM(SUM(fdp_tweets)) OVER () AS total_fdp_tweets,
        SUM(SUM(afd_tweets)) OVER () AS total_afd_tweets,
        SUM(SUM(csu_tweets)) OVER () AS total_csu_tweets,
        SUM(SUM(gruene_tweets)) OVER () AS total_gruene_tweets,
        SUM(SUM(politician_tweets)) OVER () AS total_tweets_politicians,
        SUM(SUM(total_tweets)) OVER () AS total_tweets_all
    FROM
        {{ ref('hashtags_monthly') }}
    WHERE
        categories IS NOT NULL
    GROUP BY
        hashtag,
        categories
)

SELECT
    hashtag,
    flattened_categories,
    total_tweets,
    total_users,
    politician_tweets,
    politician_users,
    non_politician_users,
    non_politician_tweets,
    spd_tweets,
    spd_users,
    cdu_tweets,
    cdu_users,
    fdp_tweets,
    fdp_users,
    afd_tweets,
    afd_users,
    csu_tweets,
    csu_users,
    gruene_tweets,
    gruene_users,
    -- Calculate ratios for each party relative to all tweets
    SAFE_DIVIDE(SAFE_DIVIDE(spd_tweets, total_spd_tweets), SAFE_DIVIDE(total_tweets, total_tweets_all)) AS spd_ratio_to_all,
    SAFE_DIVIDE(SAFE_DIVIDE(cdu_tweets, total_cdu_tweets), SAFE_DIVIDE(total_tweets, total_tweets_all)) AS cdu_ratio_to_all,
    SAFE_DIVIDE(SAFE_DIVIDE(fdp_tweets, total_fdp_tweets), SAFE_DIVIDE(total_tweets, total_tweets_all)) AS fdp_ratio_to_all,
    SAFE_DIVIDE(SAFE_DIVIDE(afd_tweets, total_afd_tweets), SAFE_DIVIDE(total_tweets, total_tweets_all)) AS afd_ratio_to_all,
    SAFE_DIVIDE(SAFE_DIVIDE(csu_tweets, total_csu_tweets), SAFE_DIVIDE(total_tweets, total_tweets_all)) AS csu_ratio_to_all,
    SAFE_DIVIDE(SAFE_DIVIDE(gruene_tweets, total_gruene_tweets), SAFE_DIVIDE(total_tweets, total_tweets_all)) AS gruene_ratio_to_all,
    -- Calculate ratios for each party relative to all parties (politicians)
    SAFE_DIVIDE(SAFE_DIVIDE(spd_tweets, total_spd_tweets), SAFE_DIVIDE(politician_tweets, total_tweets_politicians)) AS spd_ratio_to_parties,
    SAFE_DIVIDE(SAFE_DIVIDE(cdu_tweets, total_cdu_tweets), SAFE_DIVIDE(politician_tweets, total_tweets_politicians)) AS cdu_ratio_to_parties,
    SAFE_DIVIDE(SAFE_DIVIDE(fdp_tweets, total_fdp_tweets), SAFE_DIVIDE(politician_tweets, total_tweets_politicians)) AS fdp_ratio_to_parties,
    SAFE_DIVIDE(SAFE_DIVIDE(afd_tweets, total_afd_tweets), SAFE_DIVIDE(politician_tweets, total_tweets_politicians)) AS afd_ratio_to_parties,
    SAFE_DIVIDE(SAFE_DIVIDE(csu_tweets, total_csu_tweets), SAFE_DIVIDE(politician_tweets, total_tweets_politicians)) AS csu_ratio_to_parties,
    SAFE_DIVIDE(SAFE_DIVIDE(gruene_tweets, total_gruene_tweets), SAFE_DIVIDE(politician_tweets, total_tweets_politicians)) AS gruene_ratio_to_parties
FROM
    hashtag_aggregations
ORDER BY
    politician_tweets DESC
LIMIT
    25000;
