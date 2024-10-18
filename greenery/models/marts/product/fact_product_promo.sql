{{
  config(
    materialized='table'
  )
}}

WITH products AS (
    SELECT * FROM {{ref('stg_postgres__products')}}
),

order_items AS (
    SELECT * FROM {{ref('stg_postgres__order_items')}}
),

orders AS (
    SELECT * FROM {{ref('stg_postgres__orders')}}
),

promos AS (
    SELECT * FROM {{ref('stg_postgres__promos')}}
)

SELECT 
    products.product_id
    , products.name
    , COUNT(DISTINCT promos.promo_id) AS promo_count
    , SUM(promos.discount) AS promo_total
FROM products
LEFT JOIN order_items
    ON products.product_id = order_items.product_id
LEFT JOIN orders
    ON order_items.order_id = orders.order_id
LEFT JOIN promos
    ON orders.promo_id = promos.promo_id
GROUP BY ALL