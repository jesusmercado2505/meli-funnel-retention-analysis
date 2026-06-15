-- =========================================================================
-- PROJECT: MELI FUNNEL AND RETENTION ANALYSIS
-- =========================================================================

-- PHASE 1: DATA EXPLORATION AND SCHEMA UNDERSTANDING
-- -------------------------------------------------------------------------
-- Objective: Explore the main tables and confirm the funnel event sequence.

-- 1.1 Initial table exploration
SELECT * FROM mercadolibre_funnel LIMIT 5;

SELECT * FROM mercadolibre_retention LIMIT 5;

-- 1.2 Funnel sequence validation
-- We retrieve distinct event names to understand the user journey flow
SELECT DISTINCT event_name
FROM mercadolibre_funnel
ORDER BY event_name;

-- =========================================================================
-- PHASE 2: FUNNEL SEGMENTATION BY COUNTRY
-- -------------------------------------------------------------------------
-- Objective: Update the funnel query to segment user progression by country.
-- 1) Include 'country' in all CTEs.
-- 2) Join by user_id AND country, then group by country.
-- 3) Calculate conversion rates over 'first_visit' users per country.

WITH first_visits AS (
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'first_visit'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
select_item AS (
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name IN ('select_item', 'select_promotion')
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_to_cart AS (
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'add_to_cart'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
begin_checkout AS (
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'begin_checkout'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_shipping_info AS (
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'add_shipping_info'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_payment_info AS (
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'add_payment_info'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
purchase AS (
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'purchase'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
funnel_counts AS (
  -- Aggregate user counts per funnel stage grouped by country
  SELECT
    fv.country,
    COUNT(fv.user_id) AS users_first_visit,
    COUNT(si.user_id) AS users_select_item,
    COUNT(a.user_id)  AS users_add_to_cart,
    COUNT(bc.user_id) AS users_begin_checkout,
    COUNT(asi.user_id) AS users_add_shipping_info,
    COUNT(api.user_id) AS users_add_payment_info,
    COUNT(p.user_id)  AS users_purchase
  FROM first_visits fv
  LEFT JOIN select_item si        ON fv.user_id = si.user_id      AND fv.country = si.country 
  LEFT JOIN add_to_cart a         ON fv.user_id = a.user_id       AND fv.country = a.country
  LEFT JOIN begin_checkout bc     ON fv.user_id = bc.user_id      AND fv.country = bc.country
  LEFT JOIN add_shipping_info asi ON fv.user_id = asi.user_id     AND fv.country = asi.country
  LEFT JOIN add_payment_info api  ON fv.user_id = api.user_id     AND fv.country = api.country
  LEFT JOIN purchase p            ON fv.user_id = p.user_id       AND fv.country = p.country
  GROUP BY fv.country
)

-- Final SELECT: Calculate conversion rates as percentages per country
SELECT
    country,
    users_select_item * 100.0 / NULLIF(users_first_visit, 0) AS conversion_select_item,
    users_add_to_cart * 100.0 / NULLIF(users_first_visit, 0) AS conversion_add_to_cart,
    users_begin_checkout * 100.0 / NULLIF(users_first_visit, 0) AS conversion_begin_checkout,
    users_add_shipping_info * 100.0 / NULLIF(users_first_visit, 0) AS conversion_add_shipping_info,
    users_add_payment_info * 100.0 / NULLIF(users_first_visit, 0) AS conversion_add_payment_info,
    users_purchase * 100.0 / NULLIF(users_first_visit, 0) AS conversion_purchase
FROM funnel_counts
ORDER BY conversion_purchase DESC;

-- =========================================================================
-- PHASE 3: COHORT RETENTION ANALYSIS
-- -------------------------------------------------------------------------
-- Objective: Calculate cumulative user retention at 7, 14, 21, and 28 days, 
-- grouped by monthly cohorts.

-- 1) Cohort CTE: Define the cohort based on the user's first signup month
WITH cohort AS (
  SELECT
    user_id,
    TO_CHAR(DATE_TRUNC('month', MIN(signup_date)), 'YYYY-MM') AS cohort
  FROM mercadolibre_retention
  GROUP BY user_id
),

-- 2) Activity CTE: Extract key columns from the retention table and assign the cohort
activity AS (
  SELECT 
    mr.user_id,
    c.cohort,
    mr.day_after_signup,
    mr.active
  FROM mercadolibre_retention mr
  LEFT JOIN cohort AS c ON mr.user_id = c.user_id
  WHERE mr.activity_date BETWEEN '2025-01-01' AND '2025-08-31'
)

-- 3) Final SELECT: Calculate exact cumulative counts per day / cohort size -> rounded percentage
SELECT 
    cohort,
    ROUND(COUNT(DISTINCT CASE WHEN day_after_signup >= 7 AND active = 1 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d7_pct,
    ROUND(COUNT(DISTINCT CASE WHEN day_after_signup >= 14 AND active = 1 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d14_pct,
    ROUND(COUNT(DISTINCT CASE WHEN day_after_signup >= 21 AND active = 1 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d21_pct,
    ROUND(COUNT(DISTINCT CASE WHEN day_after_signup >= 28 AND active = 1 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d28_pct
FROM activity
GROUP BY cohort
ORDER BY cohort;
