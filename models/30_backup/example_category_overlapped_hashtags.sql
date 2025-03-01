SELECT
  hashtag,
  STRING_AGG(DISTINCT category, ', ') AS categories,
  COUNT(DISTINCT category) AS category_count,
  SUM(usage_count) AS total_usage_count,
  SUM(unique_users) AS total_unique_users,
  SUM(politician_users) AS total_politician_users
FROM
  {{ ref("hashtags_categories_exploded")}}
WHERE
  category IN ('Migration/Refugees/Immigration', 'Climate Change/Environmental Issues')
GROUP BY
  hashtag
HAVING
  COUNT(DISTINCT category) > 1
ORDER BY
  total_usage_count DESC
LIMIT 100