{{
  config(
    materialized='table'
  )
}}

SELECT
    product_id
    , COUNT(DISTINCT DATE_TRUNC(DAY, created_at)) AS day_count
    , COUNT(DISTINCT event_id) AS event_count
    , DIV0(event_count, day_count) as avg_daily_page_views
FROM {{ref('stg_postgres__events')}}
WHERE event_type = 'page_view'
GROUP BY ALL