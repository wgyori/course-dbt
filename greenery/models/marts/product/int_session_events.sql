{{
  config(
    materialized = 'table'
    , post_hook = 'grant select on {{ this }} to role REPORTING'
  )
}}

SELECT
    session_id
    , order_id
    , product_id
    {{event_types('stg_postgres__events', 'event_type')}}
FROM {{ref('stg_postgres__events')}}
GROUP BY ALL