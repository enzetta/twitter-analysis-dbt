{{ 
  config(
    materialized = "table",
    unique_key = "user_id",
    partition_by = {
      "field": "recorded_at",
      "data_type": "timestamp",
    },
    cluster_by = ["created_at", "screen_name"]
  ) 
}}

WITH all_tables AS (

    SELECT 
        *
    FROM 
        {{ source("base_twitter_raw", "raw_zenodo") }}

    UNION ALL
    
    SELECT 
        *
    FROM {{ source("base_twitter_raw", "raw_zenodo_2020_11") }}
),

source AS (
    SELECT *
    FROM all_tables
    WHERE
        type = 'user'
        AND created_at <= '2021-12-31'

),

latest_recorded AS (
    SELECT
        id AS user_id,
        name,
        LOWER(screen_name) AS screen_name,
        location,
        description,
        url,
        lang,
        CAST(verified AS BOOL) AS verified,
        CAST(followers AS INT64) AS followers_count,
        CAST(friends AS INT64) AS friends_count,
        CAST(listed AS INT64) AS listed_count,
        CAST(statuses AS INT64) AS statuses_count,
        CAST(favourites AS INT64) AS favourites_count,
        DATE(created_at) AS created_at_date,
        DATE(recorded_at) AS recorded_at_date,
        TIMESTAMP(created_at) AS created_at,
        TIMESTAMP(recorded_at) AS recorded_at,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY recorded_at DESC
        ) AS row_num
    FROM source
),

final AS (
    SELECT
        user_id,
        name,
        screen_name,
        location,
        description,
        url,
        lang,
        verified,
        followers_count,
        friends_count,
        listed_count,
        statuses_count,
        favourites_count,
        created_at_date,
        recorded_at_date,
        created_at,
        recorded_at,
        row_num
    FROM latest_recorded
    WHERE row_num = 1
)

SELECT *
FROM final
