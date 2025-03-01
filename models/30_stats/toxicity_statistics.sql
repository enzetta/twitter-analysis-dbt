{{ 
  config(
    materialized = "table"
  ) 
}}

WITH toxicity_stats AS (
    SELECT 
        COUNT(*) AS total_tweets,
        COUNT(toxicity_score) AS tweets_with_toxicity,
        SAFE_CAST(AVG(toxicity_score) AS FLOAT64) AS mean_toxicity,
        SAFE_CAST(STDDEV(toxicity_score) AS FLOAT64) AS stddev_toxicity,
        SAFE_CAST(MIN(toxicity_score) AS FLOAT64) AS min_toxicity,
        SAFE_CAST(MAX(toxicity_score) AS FLOAT64) AS max_toxicity
    FROM {{ ref('tweets_relevant_with_predictions') }}
),

toxicity_percentiles AS (
    SELECT 
        APPROX_QUANTILES(toxicity_score, 100) AS percentiles
    FROM {{ ref('tweets_relevant_with_predictions') }}
    WHERE toxicity_score IS NOT NULL
)

SELECT 
    'Basic Stats' AS metric,
    total_tweets,
    tweets_with_toxicity,
    mean_toxicity,
    stddev_toxicity,
    min_toxicity,
    max_toxicity,
    NULL AS p10,
    NULL AS p25,
    NULL AS median,
    NULL AS p75,
    NULL AS p90,
    NULL AS p95,
    NULL AS p99
FROM toxicity_stats

UNION ALL

SELECT 
    'Percentiles' AS metric,
    NULL AS total_tweets,
    NULL AS tweets_with_toxicity,
    NULL AS mean_toxicity,
    NULL AS stddev_toxicity,
    NULL AS min_toxicity,
    NULL AS max_toxicity,
    percentiles[10] AS p10,
    percentiles[25] AS p25,
    percentiles[50] AS median,
    percentiles[75] AS p75,
    percentiles[90] AS p90,
    percentiles[95] AS p95,
    percentiles[99] AS p99
FROM toxicity_percentiles