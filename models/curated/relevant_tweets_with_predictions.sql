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
    FROM {{ ref('relevant_tweets') }}
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
    FROM {{ ref('toxcity_predictions') }}
),

politician_data AS (
    SELECT
        user_id,
        party,
        office,
        institution,
        region,
        gender,
        year_of_birth
    FROM {{ ref('01_political_users') }}
),

hashtag_categories AS (
    SELECT
        LOWER(hashtag) AS hashtag,
        ARRAY_AGG(DISTINCT category) AS categories
    FROM {{ ref('hashtag_categories_exploded') }}
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

final AS (
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
        st.toxicity_score,
        st.sentiment_score,
        pd.party,
        pd.office,
        pd.institution,
        pd.region,
        pd.gender,
        pd.year_of_birth,
        tc.aggregated_categories
    FROM relevant_tweets AS td
    LEFT JOIN sentiment_toxicity AS st ON td.tweet_id = st.tweet_id
    LEFT JOIN politician_data AS pd ON td.user_id = pd.user_id
    LEFT JOIN users AS u ON td.user_id = u.user_id
    LEFT JOIN tweet_categories AS tc ON td.tweet_id = tc.tweet_id
)

SELECT * 
FROM final