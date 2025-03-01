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
  -- AND LOWER(hashtag) LIKE '%migrat%'
GROUP BY 
  hashtag
ORDER BY 
  total_politician_users DESC
LIMIT 25