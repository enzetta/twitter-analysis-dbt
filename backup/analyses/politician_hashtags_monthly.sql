{{ 
  config(
    materialized = "table",
    unique_key = ["user_id", "hashtag", "month_date"],
    partition_by = {
      "field": "month_date",
      "data_type": "date",
      "granularity": "month"
    },
    cluster_by = ["party", "user_id", "hashtag"]
  ) 
}}

WITH politician_tweets AS (
    SELECT
        i.tweet_id,
        i.user_id,
        pe.party,
        pe.institution,
        pe.office,
        pe.region,
        pe.gender,
        pe.year_of_birth,
        LOWER(hashtag) AS hashtag,
        DATE(DATE_TRUNC(DATE(i.created_at), MONTH)) AS month_date,
        EXTRACT(MONTH FROM i.created_at) AS month,
        EXTRACT(YEAR FROM i.created_at) AS year
    FROM {{ ref('00_interactions_referrers') }} AS i
    CROSS JOIN UNNEST(i.hashtags) AS hashtag
    INNER JOIN {{ ref('02_politically_engaged_users') }} AS pe
        ON i.user_id = pe.user_id
    WHERE
        i.hashtags IS NOT NULL
        AND pe.is_politician = TRUE
        AND DATE(i.created_at) BETWEEN '2020-01-01' AND '2021-12-31'
),

final AS (
    SELECT
        pt.user_id,
        pt.party,
        pt.institution,
        pt.office,
        pt.region,
        pt.gender,
        pt.year_of_birth,
        pt.hashtag,
        pt.month_date,
        pt.month,
        pt.year,
        -- Political hashtag categories (as array)
        hc.categories,
        -- Usage metrics
        COUNT(DISTINCT pt.tweet_id) AS tweet_count,
        MIN(pt.month_date) AS first_used_month,
        MAX(pt.month_date) AS last_used_month
    FROM politician_tweets AS pt
    LEFT JOIN {{ ref('hashtag_categories_aggregated') }} AS hc
        ON pt.hashtag = LOWER(hc.hashtag)
    GROUP BY
        user_id,
        institution,
        office,
        region,
        gender,
        party,
        year_of_birth,
        hashtag,
        month_date,
        month,
        year,
        categories
)

SELECT * FROM final
