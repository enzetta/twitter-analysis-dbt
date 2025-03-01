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
        'Human Rights/Abuse/Violations',
        'International Relations/Geopolitics/Conflict',
        'Government Institutions/Regulations/Bureaucracy',
        'TV/Media/Journalism/News Outlets',
        'Crime/Police/Law Enforcement/Security',
        'Democracy/Rule of Law/Constitution',
        'Racism/Anti-Racism/Extremism',
        'Gender/Diversity/Equality',
        'Jobs/Careers/Employment',
        'Migration/Refugees/Immigration',
        'Housing/Rent/Affordable Living',
        'Cultural Appropriation/Ethnic Stereotypes/Minority Groups',
        'Unemployment/Economic Crisis/Recession',
        'Armed Conflict/Wars/Violence',
        'Anti-Semitism/Anti-Zionism',
        'Religion/Religious Movements/Sects',
        'Cybersecurity and Cyber Warfare',
        'Culture/Arts/Traditions',
        'Military/Weapons/Arms'
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