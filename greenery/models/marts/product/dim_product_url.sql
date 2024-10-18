{{
  config(
    materialized='table'
  )
}}

WITH products AS (
    SELECT * FROM {{ref('stg_postgres__products')}}
),

events AS (
    SELECT * FROM {{ref('stg_postgres__events')}}
)

SELECT 
    products.product_id
    , products.name
    , events.page_url
FROM products
LEFT JOIN events
    ON products.product_id = events.product_id
GROUP BY ALL