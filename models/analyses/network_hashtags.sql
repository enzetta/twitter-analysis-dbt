SELECT
  source AS source,
  target AS target,
  month_start AS month_start,
  SUM(edge_weight) AS weight,
  SUM(sum_toxicity) AS sum_toxicity,
  SUM(sum_toxicity) / SUM(edge_weight) AS avg_toxicity
FROM
  `grounded-nebula-408412.twitter_analysis_analyses.network_all`
WHERE
  avg_toxicity IS NOT NULL
  AND entity_type IN ("hashtag")
GROUP BY
  1,
  2,
  3
ORDER BY
  month_start ASC,
  weight ASC