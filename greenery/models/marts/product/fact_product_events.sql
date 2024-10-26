{{
  config(
    materialized = 'table'
    , post_hook = 'grant select on {{ this }} to role REPORTING'
  )
}}

SELECT
    product_id
    , DATE_TRUNC(DAY, created_at) AS created_at_day
    {{event_types('stg_postgres__events', 'event_type')}}
FROM {{ref('stg_postgres__events')}}
GROUP BY ALL