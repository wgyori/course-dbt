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
  , DATE_TRUNC(DAY, orders.created_at) AS created_at_day
  , COUNT(DISTINCT orders.order_id) AS order_count
FROM order_items
LEFT JOIN orders
  ON order_items.order_id = orders.order_id
GROUP BY ALL