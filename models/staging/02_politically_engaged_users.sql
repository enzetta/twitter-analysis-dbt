{{ 
  config(
    materialized = "table",
    unique_key = "user_id",
    cluster_by = ["user_id"]
  ) 
}}

-- Basistabelle der politischen Nutzer mit ihren Attributen
WITH political_users AS (
    SELECT DISTINCT
        user_id,
        party,
        institution,
        office,
        region,
        twitter_name,
        twitter_handle,
        year_of_birth,
        gender,
        wikidata_id
    FROM {{ ref("01_political_users") }}
),

-- Basistabelle für alle Interaktionen
interactions AS (
    SELECT DISTINCT
        user_id,
        refers_to_user_id,
        mentioned_ids
    FROM {{ ref("00_interactions_referrers") }}
),

-- Zählt Erwähnungen von Politikern je Nutzer
mentions_of_politicians AS (
    SELECT
        user_id,
        COUNT(*) AS mentions_made_count
    FROM interactions,
        UNNEST(mentioned_ids) AS mentioned_id
    WHERE mentioned_id IN (SELECT user_id FROM political_users)
    GROUP BY 1
),

-- Zählt wie oft ein Nutzer von Politikern erwähnt wurde
mentions_by_politicians AS (
    SELECT
        mentioned_id AS user_id,
        COUNT(*) AS times_mentioned_count
    FROM interactions,
        UNNEST(mentioned_ids) AS mentioned_id
    WHERE user_id IN (SELECT user_id FROM political_users)
    GROUP BY 1
),

-- Zählt direkte Interaktionen (Replies, Quotes, Retweets) mit Politikern
direct_interactions AS (
    SELECT
        user_id,
        COUNT(*) AS direct_interactions_count
    FROM interactions
    WHERE
        refers_to_user_id IN (SELECT user_id FROM political_users)
        OR user_id IN (SELECT user_id FROM political_users)
    GROUP BY 1
),

-- Aggregiert alle Interaktionsmetriken pro Nutzer mit FULL OUTER JOIN
-- um keine Interaktionen zu verlieren
user_metrics AS (
    SELECT
        COALESCE(d.user_id, mo.user_id, mb.user_id) AS user_id,
        COALESCE(mo.mentions_made_count, 0) AS mentions_made_count,
        COALESCE(mb.times_mentioned_count, 0) AS times_mentioned_count,
        COALESCE(d.direct_interactions_count, 0) AS direct_interactions_count
    FROM direct_interactions AS d
    FULL OUTER JOIN mentions_of_politicians AS mo ON d.user_id = mo.user_id
    FULL OUTER JOIN mentions_by_politicians AS mb ON d.user_id = mb.user_id
),

-- Kombiniert alle Nutzerinformationen und berechnet Gesamtinteraktionen
final AS (
    SELECT
        u.*,
        COALESCE(p.user_id IS NOT NULL, FALSE) AS is_politician,
        p.party,
        p.institution,
        p.office,
        p.region,
        p.twitter_name AS political_twitter_name,
        p.twitter_handle AS political_twitter_handle,
        p.year_of_birth,
        p.gender,
        p.wikidata_id,
        COALESCE(m.mentions_made_count, 0) AS mentions_made_count,
        COALESCE(m.times_mentioned_count, 0) AS times_mentioned_count,
        COALESCE(m.direct_interactions_count, 0) AS direct_interactions_count,
        COALESCE(m.mentions_made_count, 0)
        + COALESCE(m.times_mentioned_count, 0)
        + COALESCE(m.direct_interactions_count, 0) AS total_interactions
    FROM {{ ref("users") }} AS u
    LEFT JOIN political_users AS p ON u.user_id = p.user_id
    INNER JOIN user_metrics AS m ON u.user_id = m.user_id
)

SELECT * FROM final
WHERE total_interactions > 0 OR is_politician = TRUE
