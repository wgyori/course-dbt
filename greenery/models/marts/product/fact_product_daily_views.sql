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
)

SELECT
    products.product_id
    , products.name
    , product_views.avg_daily_page_views
FROM products
LEFT JOIN product_views
    ON products.product_id = product_views.product_id