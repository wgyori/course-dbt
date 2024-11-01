{{
  config(
    materialized = 'table'
    , post_hook = 'grant select on {{ this }} to role REPORTING'
  )
}}

WITH orders_items AS (
    SELECT * FROM {{ref('stg_postgres__order_items')}}
),

session_events AS (
    SELECT * FROM {{ref('int_session_events')}}
)

SELECT
    session_events.session_id
    , CASE
        WHEN session_events.product_id IS NULL THEN orders_items.product_id
        ELSE session_events.product_id
    END AS product_id
    , SUM(session_events.page_views) AS page_views
    , SUM(session_events.add_to_carts) AS add_to_carts
    , SUM(session_events.checkouts) AS checkouts
    , SUM(session_events.package_shippeds) AS ships
FROM session_events
LEFT JOIN orders_items
    ON session_events.order_id = orders_items.order_id
GROUP BY ALL