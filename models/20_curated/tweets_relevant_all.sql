WITH categories_of_interest AS (
    SELECT category FROM UNNEST([
        'Extremism/Right-Wing/Left-Wing',
        'Religion/Religious Movements/Sects',
        'Political Parties/Political Systems',
        'Wokeness/Identity Politics/Cancel Culture',
        'Comedy/Humor/Satire',
        'Migration/Refugees/Immigration',
        'TV/Media/Journalism/News Outlets',
        'Political Theories/Ideologies',
        'Celebrities/Artists/Influencers',
        'Politicians/Elected Officials',
        'Globalization/Trade/Interconnectedness',
        'Misinformation/Propaganda/Conspiracy Theories/Disinformation',
        'Cultural Appropriation/Ethnic Stereotypes/Minority Groups',
        'Government Institutions/Regulations/Bureaucracy',
        'Democracy/Rule of Law/Constitution',
        'Cryptocurrency/Blockchain/DeFi',
        'COVID-19/Pandemic/Vaccines',
        'Culture/Arts/Traditions',
        'Racism/Anti-Racism/Extremism',
        'Armed Conflict/Wars/Violence',
        'Geo/Cities/Countries/Locations',
        'International Relations/Geopolitics/Conflict',
        'Health/Healthcare/Medicine',
        'Crime/Police/Law Enforcement/Security',
        'Human Rights/Abuse/Violations',
        'Cybersecurity and Cyber Warfare',
        'Surveillance/Privacy/Data Protection',
        'Social Movements/Protests/Activism',
        'Anti-Semitism/Anti-Zionism',
        'Internet/Social Media/Online Communities',
        'Other/Uncategorized',
        'Energy/Renewables/Fossil Fuels',
        'Unemployment/Economic Crisis/Recession',
        'Sports/Football',
        'Food/Vegan/Vegetarian/Diet',
        'Economy/Finance/Business',
        'Industry/Manufacturing/Infrastructure',
        'Energy/Climate Change/Renewable Policies',
        'Military/Weapons/Arms',
        'Gender/Diversity/Equality',
        'Mental Health and Wellbeing',
        'Transport Revolution/Public Transit/Electric Vehicles',
        'Music/Musicians',
        'Talkshows/News TV/Current Affairs Programs',
        'LGBTQ+/LGBTQ+ Rights/Community',
        'Climate Change/Environmental Issues',
        'Weather',
        'Conferences/Summits/Events',
        'Jobs/Careers/Employment',
        'Nature/Wildlife/Ecology',
        'Technology/AI/Robotics',
        'Biodiversity/Animal Conservation',
        'Digitalization/E-Governance/Digital Infrastructure',
        'Mobility/Transport/Public Infrastructure',
        'Housing/Rent/Affordable Living',
        'Innovation/Patents/Startups',
        'Renewable Energy/Sustainability',
        'Future of Work/Digital Workspaces/Automation',
        'Space Exploration/Satellites/Space Policy',
        'Mental Health and Wellbeing'
    ]) AS category
),

-- 1. Tweet IDs mit kategorisierten Hashtags
categorized_hashtags AS (
    SELECT DISTINCT hc.hashtag
    FROM {{ ref('hashtags_categories_exploded') }} AS hc
    INNER JOIN categories_of_interest AS coi
        ON hc.category = coi.category
),

-- 2. Tweets die kategorisierte Hashtags enthalten
hashtag_tweet_ids AS (
    SELECT DISTINCT ir.tweet_id
    FROM {{ ref('00_interactions_with_referrers') }} AS ir
    CROSS JOIN UNNEST(ir.hashtags) AS tweet_hashtag
    INNER JOIN categorized_hashtags AS ch
        ON LOWER(tweet_hashtag) = LOWER(ch.hashtag)
),

-- 3. Tweet IDs von Politikern
politician_tweet_ids AS (
    SELECT DISTINCT tweet_id
    FROM {{ ref('00_interactions_with_referrers') }}
    WHERE user_id IN (SELECT user_id FROM {{ ref('01_political_users') }})
    -- WHERE user_id IN (SELECT user_id FROM {{ ref('01_political_users') }})
),

-- 4. Tweet IDs die Politiker erwähnen
politician_mention_tweet_ids AS (
    SELECT DISTINCT ir.tweet_id
    FROM {{ ref('00_interactions_with_referrers') }} AS ir
    CROSS JOIN UNNEST(ir.mentioned_ids) AS mentioned_user
    INNER JOIN {{ ref('01_political_users') }} AS pu
        ON mentioned_user = pu.user_id
),




-- Kombination von 1 und 2
base_tweet_ids AS (
    SELECT tweet_id FROM hashtag_tweet_ids
    UNION DISTINCT
    SELECT tweet_id FROM politician_tweet_ids
    UNION DISTINCT
    SELECT tweet_id FROM politician_mention_tweet_ids
),

-- 3. IDs der Tweets die sich auf 1 oder 2 beziehen
referenced_tweet_ids AS (
    SELECT DISTINCT r.refers_to AS tweet_id
    FROM {{ ref('00_interactions_with_referrers') }} AS r
    INNER JOIN base_tweet_ids AS b
        ON r.tweet_id = b.tweet_id
),

-- Alle relevanten IDs
all_tweet_ids AS (
    SELECT tweet_id FROM base_tweet_ids
    UNION DISTINCT
    SELECT tweet_id FROM referenced_tweet_ids
), 

joined AS (

    SELECT 
        ir.*
    FROM 
        {{ ref('00_interactions_with_referrers') }} AS ir
    INNER JOIN all_tweet_ids AS a
        ON ir.tweet_id = a.tweet_id

), 

including_rows AS ( 

    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY tweet_id ORDER BY created_at DESC, text ASC) AS row_num
    FROM joined


), truncated AS (

    SELECT 
        * EXCEPT(row_num)
    FROM 
        including_rows
    WHERE 
        row_num = 1

)

SELECT * 
FROM truncated