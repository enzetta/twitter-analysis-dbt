{{ 
  config(
    materialized = "table",
    unique_key = "user_id",
    cluster_by = ["twitter_handle", "user_id"]
  ) 
}}

WITH source AS (
    SELECT *
    FROM {{ source("spreadsheets", "ext_epi_netz_de") }}
),

final AS (
    SELECT
        CAST(id AS STRING) AS user_id,
        official_name,
        party,
        region,
        institution,
        office,
        twitter_name,
        LOWER(twitter_handle) AS twitter_handle,
        SAFE_CAST(year_of_birth AS INT64) AS year_of_birth,
        SAFE_CAST(abgeordnetenwatch_id AS INT64) AS abgeordnetenwatch_id,
        gender,
        wikidata_id
    FROM source
)

SELECT * FROM final
