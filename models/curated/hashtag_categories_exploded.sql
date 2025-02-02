{{ 
  config(
    materialized = "table"
  ) 
}}

WITH split_categories AS (
    SELECT
        hashtag,
        usage_count,
        unique_users,
        politician_users,
        first_used_at,
        last_used_at,
        pct_political_users,
        days_active,
        TRIM(category) AS category
    FROM {{ ref('hashtag_categorisation') }},
        UNNEST(SPLIT(categories, ';')) AS category
)

SELECT * FROM split_categories
