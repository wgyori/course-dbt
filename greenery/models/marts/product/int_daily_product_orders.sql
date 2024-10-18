{{
  config(
    materialized='table'
  )
}}

WITH order_items AS (
    SELECT * FROM {{ref('stg_postgres__order_items')}}
),

orders AS (
    SELECT * FROM {{ref('stg_postgres__orders')}}
)

SELECT
    order_items.product_id
    , COUNT(DISTINCT DATE_TRUNC(DAY, orders.created_at)) AS day_count
    , COUNT(DISTINCT orders.order_id) AS order_count
    , DIV0(order_count, day_count) AS avg_daily_orders
FROM order_items
LEFT JOIN orders
    ON order_items.order_id = orders.order_id
GROUP BY ALL