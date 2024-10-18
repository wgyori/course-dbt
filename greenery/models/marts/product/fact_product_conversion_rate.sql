{{
  config(
    materialized='table'
  )
}}

WITH products AS (
    SELECT * FROM {{ref('stg_postgres__products')}}
),

product_views AS (
    SELECT * FROM {{ref('int_daily_product_views')}}
),

product_orders AS (
    SELECT * FROM {{ref('int_daily_product_orders')}}
)

SELECT
    products.product_id
    , products.name
    , product_views.avg_daily_page_views
    , product_orders.avg_daily_orders
    , DIV0(avg_daily_orders, avg_daily_page_views) AS conversion_rate
FROM products
LEFT JOIN product_views
    ON products.product_id = product_views.product_id
LEFT JOIN product_orders
    ON products.product_id = product_orders.product_id