# Week 1 Project Answers

## Question 1: How many users do we have?
### Answer: 130

### Query:
```SQL
SELECT COUNT(DISTINCT user_id)
FROM dev_db.dbt_willgyorikraftheinzcom.stg_postgres__users
```


## Question 2: On average, how many orders do we receive per hour?
### Answer: 7.520833

### Query:
```SQL
WITH hourly_order_count AS (

    SELECT 
        DATE_TRUNC(hour, created_at) AS hour
        , COUNT(DISTINCT order_id) AS order_count
    FROM dev_db.dbt_willgyorikraftheinzcom.stg_postgres__orders
    GROUP BY ALL
)

SELECT AVG(order_count)
FROM hourly_order_count;
```


## Question 3: On average, how long does an order take from being placed to being delivered?
### Answer: 93.403279 hours

### Query:
```SQL
WITH deliver_time AS (

    SELECT 
        order_id
        , TIMEDIFF(hour, created_at, delivered_at) AS hour_diff
    FROM dev_db.dbt_willgyorikraftheinzcom.stg_postgres__orders
)

SELECT AVG(hour_diff)
FROM deliver_time;
```


## Question 4: How many users have only made one purchase? Two purchases? Three+ purchases?
### Answer: One purchase: 25, Two purchases: 28 users, Three or more purchases: 71

### Query:
```SQL
WITH user_order_count AS (
    SELECT
        user_id
        , COUNT(DISTINCT order_id) AS order_count
    FROM dev_db.dbt_willgyorikraftheinzcom.stg_postgres__orders
    GROUP BY ALL
)

SELECT
    SUM(CASE 
        WHEN order_count = 1 THEN 1
        ELSE 0
    END) AS order_count_1
    , SUM(CASE 
        WHEN order_count = 2 THEN 1
        ELSE 0
    END) AS order_count_2
    , SUM(CASE 
        WHEN order_count > 2 THEN 1
        ELSE 0
    END) AS order_count_more_2
FROM user_order_count;
```


## Question 5: On average, how many unique sessions do we have per hour?
### Answer: 16.327586

### Query:
```SQL
WITH hourly_session_count AS (

    SELECT 
        DATE_TRUNC(hour, created_at) AS hour
        , COUNT(DISTINCT session_id) AS session_count
    FROM dev_db.dbt_willgyorikraftheinzcom.stg_postgres__events
    GROUP BY ALL
)

SELECT AVG(session_count)
FROM hourly_session_count;
```