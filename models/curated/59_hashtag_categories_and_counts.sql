SELECT 
  category,
  SUM(usage_count) AS total_usage_count,
  SUM(unique_users) AS total_unique_users,
  SUM(politician_users) AS total_politician_users
FROM 
  `grounded-nebula-408412.twitter_analysis_curated.hashtag_categories_exploded`
GROUP BY 
  category
ORDER BY 
  total_usage_count DESC;