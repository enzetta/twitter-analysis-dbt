{{ 
  config(
    materialized = "table",
    unique_key = "user_id",
    cluster_by = ["twitter_handle", "user_id"]
  ) 
}}

WITH source AS (
    SELECT *
    FROM {{ source("base_twitter_raw", "ext_epi_netz_de") }}
),

final AS (
    SELECT
        CAST(user_id AS STRING) AS user_id,
        CAST(official_name AS STRING) AS official_name,
        CAST(party AS STRING) AS party,
        CAST(region AS STRING) AS region,
        CAST(institution AS STRING) AS institution,
        CAST(office AS STRING) AS office,
        CAST(twitter_name AS STRING) AS twitter_name,
        LOWER(CAST(twitter_handle AS STRING)) AS twitter_handle,
        SAFE_CAST(year_of_birth AS INT64) AS year_of_birth,
        SAFE_CAST(abgeordnetenwatch_id AS INT64) AS abgeordnetenwatch_id,
        CAST(gender AS STRING) AS gender,
        CAST(wikidata_id AS STRING) AS wikidata_id
    FROM source
)

SELECT * FROM final