{{ 
  config(
    materialized = "table"
  ) 
}}

SELECT
    hashtag,
    usage_count,
    unique_users,
    politician_users,
    first_used_at,
    last_used_at,
    pct_political_users,
    days_active,
    ARRAY_AGG(TRIM(cat)) AS categories
FROM {{ ref('bigquery_ready_v2') }},
    UNNEST(SPLIT(categories, ';')) AS cat
GROUP BY
    hashtag,
    usage_count,
    unique_users,
    politician_users,
    first_used_at,
    last_used_at,
    pct_political_users,
    days_active
