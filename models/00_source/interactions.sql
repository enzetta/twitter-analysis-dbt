{{ 
  config(
    materialized = "table",
    unique_key = "tweet_id",
    partition_by = {
      "field": "recorded_at",
      "data_type": "timestamp",
    },
    cluster_by = ["tweet_id"]
  ) 
}}

WITH source_data AS (

    SELECT *
    FROM {{ source("base_twitter_raw", "raw_zenodo") }}

    UNION ALL
    
    SELECT *
    FROM {{ source("base_twitter_raw", "raw_zenodo_2020_11") }}
),

raw_data AS (
    SELECT *
    FROM source_data
    WHERE
        type NOT IN ('user')
        -- AND created_at >= '2020-09-01'
        AND created_at >= '2020-01-01'
        AND created_at <= '2021-12-31'
        AND lang IN ('de', 'en', null)
),

latest_recorded AS (
    SELECT
        id AS tweet_id,
        user AS user_id,
        source AS source_application,
        CAST(retweets AS INT64) AS retweet_count,
        CAST(favourites AS INT64) AS favourite_count,
        lang,
        type,
        hashtags,
        urls,
        mentioned_ids,
        text AS raw_text,
        -- First pass of cleaning
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    text,
                    r'(https?:\/\/\S+)|((www\.)?\S+\.[a-z]{2,6}(\S*)?)|(\S+://\S+)|([^\s]+t\.\.\.)',
                    ''
                ),
                r'\s+',
                ' '
            ),
            r'^\s+|\s+$',
            ''
        ) AS partially_cleaned_text,
        refers_to,
        DATE(created_at) AS created_at_date,
        DATE(recorded_at) AS recorded_at_date,
        TIMESTAMP(created_at) AS created_at,
        TIMESTAMP(recorded_at) AS recorded_at,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY recorded_at DESC
        ) AS row_num
    FROM raw_data
),

final_cleaned AS (
    SELECT
        tweet_id,
        user_id,
        source_application,
        retweet_count,
        favourite_count,
        lang,
        type,
        hashtags,
        urls,
        mentioned_ids,
        raw_text,
        -- Second pass of cleaning
        REGEXP_REPLACE(
            partially_cleaned_text,
            r'https?:\/\/',
            ''
        ) AS text,
        refers_to,
        created_at_date,
        recorded_at_date,
        created_at,
        recorded_at,
        row_num
    FROM latest_recorded
),

final AS (
    SELECT *
    FROM final_cleaned
    WHERE row_num = 1
)

SELECT *
FROM final
