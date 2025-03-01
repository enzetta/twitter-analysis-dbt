{{ 
  config(
    materialized = "table"
  ) 
}}

SELECT
  month_start,
  party,
  SAFE_DIVIDE(SUM(toxicity_sent), SUM(interactions_sent)) AS avg_tox_sent,
  SAFE_DIVIDE(SUM(toxicity_received), SUM(interactions_received)) AS avg_tox_received,
  SAFE_DIVIDE(SUM(toxicity_received) + SUM(toxicity_sent), SUM(interactions_sent) + SUM(interactions_received)) AS avg_tox
FROM
 {{ ref("nodes_all")}}
GROUP BY
  1,
  2
ORDER BY
  month_start,
  party