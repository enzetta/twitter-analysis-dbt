SELECT 
  hashtag,
  SUM(usage_count) AS total_usage_count,
  SUM(unique_users) AS total_unique_users,
  SUM(politician_users) AS total_politician_users
FROM 
  {{ ref('hashtags_categories_exploded') }}
WHERE 
  category IN (
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
  -- AND LOWER(hashtag) LIKE '%migrat%'
GROUP BY 
  hashtag
ORDER BY 
  total_politician_users DESC
LIMIT 25

 