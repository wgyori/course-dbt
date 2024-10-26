# Week 3 Project Answers

# Part 1
## Question 1 : What is our overall conversion rate?
### Answer: 0.467209

### Query:
```SQL
SELECT
    DIV0(SUM(order_count), SUM(page_views)) AS overall_conversion_rate
FROM DEV_DB.DBT_WILLGYORIKRAFTHEINZCOM.FACT_PRODUCT_CONVERSION_RATE
```

## Question 2 : What is our conversion rate by product?
### Answer:
| NAME                | CONVERSION_RATE |
| ------------------- | --------------- |
| String of pearls    | 0.609375        |
| Arrow Head          | 0.555556        |
| Cactus              | 0.545455        |
| ZZ Plant            | 0.539683        |
| Bamboo              | 0.537313        |
| Rubber Plant        | 0.518519        |
| Monstera            | 0.510204        |
| Calathea Makoyana   | 0.509434        |
| Fiddle Leaf Fig     | 0.500000        |
| Majesty Palm        | 0.492537        |
| Aloe Vera           | 0.492308        |
| Devil's Ivy         | 0.488889        |
| Philodendron        | 0.483871        |
| Jade Plant          | 0.478261        |
| Spider Plant        | 0.474576        |
| Pilea Peperomioides | 0.474576        |
| Dragon Tree         | 0.467742        |
| Money Tree          | 0.464286        |
| Orchid              | 0.453333        |
| Bird of Paradise    | 0.450000        |
| Ficus               | 0.426471        |
| Birds Nest Fern     | 0.423077        |
| Pink Anthurium      | 0.418919        |
| Boston Fern         | 0.412698        |
| Alocasia Polly      | 0.411765        |
| Peace Lily          | 0.409091        |
| Ponytail Palm       | 0.400000        |
| Snake Plant         | 0.397260        |
| Angel Wings Begonia | 0.393443        |
| Pothos              | 0.344262        |
### Query 
```SQL
SELECT
    NAME
    , CONVERSION_RATE
FROM DEV_DB.DBT_WILLGYORIKRAFTHEINZCOM.FACT_PRODUCT_CONVERSION_RATE
ORDER BY CONVERSION_RATE DESC
```
# Part 2
## Question 1 : Create a macro to simplify part of a model
### Answer: Macro was created to simplify count by event type without having to repeat logic for each event type

### Macro Query called event_type.sql
```SQL
{%- macro event_types(table_name, column_name) -%}

{%- 
    set event_types = dbt_utils.get_column_values(
        table = ref(table_name)
        , column = column_name
    )
-%}

    {%- for event_type in event_types %}
    , sum(case when event_type = '{{ event_type }}' then 1 else 0 end) as {{ event_type }}s
    {%- endfor %}

{%- endmacro %}
```

### Macro called within fact_product_events.sql model
```SQL
SELECT
    product_id
    , DATE_TRUNC(DAY, created_at) AS created_at_day
    {{event_types('stg_postgres__events', 'event_type')}}
FROM {{ref('stg_postgres__events')}}
GROUP BY ALL
```

# Part 3
## Question 1 : Add a post hook to your project to apply grants to the role reporting
### Answer: This was applied within fact_product_events.sql model

### Model Query
```SQL
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
```

### Snowflake query history, successfully ran
```SQL
grant select on dev_db.dbt_willgyorikraftheinzcom.fact_product_events to role REPORTING
```

# Part 4
## Question 1 : Install a package and apply on of the macros to your project
### Answer: I installed dbt_utils and used the package for macro in part 2

### Macro Query called event_type.sql which is utilizing dbt_utils.get_column_values
```SQL
{%- macro event_types(table_name, column_name) -%}

{%- 
    set event_types = dbt_utils.get_column_values(
        table = ref(table_name)
        , column = column_name
    )
-%}

    {%- for event_type in event_types %}
    , sum(case when event_type = '{{ event_type }}' then 1 else 0 end) as {{ event_type }}s
    {%- endfor %}

{%- endmacro %}
```
# Part 6
## Question 1 : Which products had their inventory change from week 2 to week 3?
### Answer: Bamboo (56 -> 44), Monstera (64 -> 50), Philodendron (25 -> 15), Pothos (20 -> 0), String of pearls (10 -> 0), ZZ Plant (89 -> 53)