{{
  config(
    materialized='table'
  )
}}

SELECT
  product_id
  , COUNT(DISTINCT session_id) AS page_views
FROM {{ref('stg_postgres__events')}}
WHERE event_type = 'page_view'
GROUP BY ALL