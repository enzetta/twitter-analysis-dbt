{{ 
 config(
   materialized = "table",
   unique_key = "user_id",
   partition_by = {
     "field": "recorded_at", 
     "data_type": "timestamp",
   },
   cluster_by = ["created_at", "screen_name"]
 ) 
}}

-- Lade Basisdaten
WITH source AS (
    SELECT *
    FROM {{ ref("users") }}
),

-- Lade EpiNetz Daten
epi_netz_de AS (
    SELECT *
    FROM {{ ref("ext_epi_netz_de") }}
),

-- Verbinde User-Daten mit EpiNetz-Daten über Handle und ID
matched_users AS (
    SELECT
        source.user_id,
        source.screen_name,
        source.name,
        source.description,
        source.location,
        source.url,
        source.created_at,
        source.lang,
        source.recorded_at,
        -- Nimm Partei-Info entweder vom Handle- oder ID-Match
        COALESCE(epi_netz_handle.party, epi_netz_id.party) AS party,
        COALESCE(epi_netz_handle.twitter_name, epi_netz_id.twitter_name) AS twitter_name,
        COALESCE(epi_netz_handle.twitter_handle, epi_netz_id.twitter_handle) AS twitter_handle,
        COALESCE(epi_netz_handle.wikidata_id, epi_netz_id.wikidata_id) AS wikidata_id
    FROM source
    -- Join über Twitter Handle (screen_name)
    LEFT JOIN epi_netz_de AS epi_netz_handle ON LOWER(source.screen_name) = epi_netz_handle.twitter_handle
    -- Join über Twitter ID (user_id) 
    LEFT JOIN epi_netz_de AS epi_netz_id ON source.user_id = epi_netz_id.user_id
),

-- Finale Ergebnismenge: Nur Nutzer mit Partei-Information
final AS (
    SELECT * FROM matched_users
    WHERE party IS NOT NULL
)

SELECT * FROM final
