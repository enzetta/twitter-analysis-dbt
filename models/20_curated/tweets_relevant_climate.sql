{{ 
  config(
    materialized = "table",
    cluster_by = ["created_at"]
  ) 
}}

WITH categories_of_interest AS (
    SELECT DISTINCT category 
    FROM {{ ref('hashtags_categories_exploded') }}
    WHERE category IN (
        'Talkshows/News TV/Current Affairs Programs',
        'Political Parties/Political Systems',
        'Extremism/Right-Wing/Left-Wing',
        'Social Movements/Protests/Activism',
        'Politicians/Elected Officials',
        'Misinformation/Propaganda/Conspiracy Theories/Disinformation',
        'Geo/Cities/Countries/Locations',
        'Globalization/Trade/Interconnectedness',
        'Economy/Finance/Business',
        'Biodiversity/Animal Conservation',
        'Nature/Wildlife/Ecology',
        'Innovation/Patents/Startups',
        'Energy/Renewables/Fossil Fuels',
        'Mobility/Transport/Public Infrastructure',
        'Transport Revolution/Public Transit/Electric Vehicles',
        'Energy/Climate Change/Renewable Policies',
        'Renewable Energy/Sustainability',
        'Climate Change/Environmental Issues',
        'Food/Vegan/Vegetarian/Diet',
        'Industry/Manufacturing/Infrastructure',
        'Weather/Climate/Weather Events'
    )
),
filtered_tweets AS (
    SELECT *
    FROM {{ ref('tweets_relevant_with_predictions') }} tweets
    WHERE EXISTS (
        SELECT 1
        FROM UNNEST(tweets.aggregated_categories) category
        JOIN categories_of_interest coi
        ON category = coi.category
    )
)
SELECT * FROM filtered_tweets