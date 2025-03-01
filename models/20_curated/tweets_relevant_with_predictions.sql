{{ 
  config(
    materialized = "table",
    cluster_by = ["created_at"]
  ) 
}}

WITH relevant_tweets AS (
    SELECT
        tweet_id,
        user_id,
        created_at,
        type,
        refers_to_user_id AS refers_to_user_id,
        refers_to AS refers_to_tweet_id,
        mentioned_ids,
        hashtags,
        text
    FROM {{ ref('tweets_relevant_all') }}
),

users AS (
    SELECT
        user_id,
        screen_name,
        name,
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
        created_at_date
    FROM {{ ref('users') }}
),

sentiment_toxicity AS (
    SELECT
        tweet_id,
        sentiment_score,
        toxicity_score
    FROM {{ ref('toxicity_predictions') }}
),

politician_data AS (
    SELECT
        user_id,
        party
    FROM {{ ref('01_political_users') }}
    GROUP BY
        user_id,
        party
),

hashtag_categories AS (
    SELECT
        LOWER(hashtag) AS hashtag,
        ARRAY_AGG(DISTINCT category) AS categories
    FROM {{ ref('hashtags_categories_exploded') }}
    GROUP BY hashtag
),

tweet_categories AS (
    SELECT
        td.tweet_id,
        ARRAY_CONCAT_AGG(hc.categories) AS aggregated_categories
    FROM relevant_tweets AS td
    CROSS JOIN UNNEST(td.hashtags) AS hashtag
    LEFT JOIN hashtag_categories AS hc ON LOWER(hashtag) = hc.hashtag
    GROUP BY td.tweet_id
),

joined AS (
    SELECT
        td.tweet_id,
        td.user_id,
        u.screen_name,
        u.lang,
        u.location,
        u.name,
        td.created_at,
        td.type,
        td.refers_to_user_id,
        td.refers_to_tweet_id,
        td.mentioned_ids,
        td.hashtags,
        td.text,
        CASE 
            WHEN td.type = 'retweet' THEN st_original.toxicity_score
            ELSE st.toxicity_score
        END AS toxicity_score,
        CASE 
            WHEN td.type = 'retweet' THEN st_original.sentiment_score
            ELSE st.sentiment_score
        END AS sentiment_score,
        pd.party,
        tc.aggregated_categories
    FROM relevant_tweets AS td
    LEFT JOIN sentiment_toxicity AS st 
        ON td.tweet_id = st.tweet_id

    LEFT JOIN sentiment_toxicity AS st_original 
        ON td.refers_to_tweet_id = st_original.tweet_id
    LEFT JOIN politician_data AS pd 
        ON td.user_id = pd.user_id
    LEFT JOIN users AS u 
        ON td.user_id = u.user_id
    LEFT JOIN tweet_categories AS tc 
        ON td.tweet_id = tc.tweet_id
), rows_added AS (

    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY tweet_id ORDER BY created_at DESC, text ASC) AS row_num
    FROM joined

),
final AS (

    SELECT * EXCEPT(row_num)
    FROM rows_added
    WHERE row_num = 1

)

SELECT * 
FROM final