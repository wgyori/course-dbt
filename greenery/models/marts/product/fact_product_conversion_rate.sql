{{
  config(
    materialized='table'
  )
}}

WITH products AS (
    SELECT * FROM {{ref('stg_postgres__products')}}
),

product_views AS (
    SELECT * FROM {{ref('int_product_views')}}
),

product_orders AS (
    SELECT * FROM {{ref('int_product_orders')}}
)

SELECT
    products.product_id
    , products.name
    , product_views.page_views
    , SUM(product_orders.order_count) AS order_count
    , DIV0(SUM(product_orders.order_count), product_views.page_views) AS conversion_rate
FROM int_product_views AS product_views
LEFT JOIN int_product_orders AS product_orders 
    ON product_views.product_id = product_orders.product_id
LEFT JOIN dev_db.dbt_willgyorikraftheinzcom.stg_postgres__products AS products
    ON product_views.product_id = products.product_id
GROUP BY ALL