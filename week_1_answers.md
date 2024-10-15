# Week 1 Project Answers

## Question 1: How many users do we have?
### Answer: 130

### Query:
```SQL
SELECT COUNT(DISTINCT USER_ID)
FROM DEV_DB.DBT_WILLGYORIKRAFTHEINZCOM.STG_POSTGRES__USERS
```


## Question 2: On average, how many orders do we receive per hour?
### Answer: 7.520833

### Query:
```SQL
WITH HOURLY_ORDER_COUNT AS (

    SELECT 
        DATE_TRUNC(HOUR, CREATED_AT) AS HOUR
        , COUNT(DISTINCT ORDER_ID) AS ORDER_COUNT
    FROM DEV_DB.DBT_WILLGYORIKRAFTHEINZCOM.STG_POSTGRES__ORDERS
    GROUP BY ALL
)

SELECT AVG(ORDER_COUNT)
FROM HOURLY_ORDER_COUNT
```


## Question 3: On average, how long does an order take from being placed to being delivered?
### Answer: 93.403279 hours

### Query:
```SQL
WITH DELIVER_TIME AS (

    SELECT 
        ORDER_ID
        , TIMEDIFF(HOUR, CREATED_AT, DELIVERED_AT) AS HOUR_DIFF
    FROM DEV_DB.DBT_WILLGYORIKRAFTHEINZCOM.STG_POSTGRES__ORDERS
)

SELECT AVG(HOUR_DIFF)
FROM DELIVER_TIME
```


## Question 4: How many users have only made one purchase? Two purchases? Three+ purchases?
### Answer: One purchase: 25, Two purchases: 28 users, Three or more purchases: 71

### Query:
```SQL
WITH USER_ORDER_COUNT AS (
    SELECT
        USER_ID
        , COUNT(DISTINCT ORDER_ID) AS ORDER_COUNT
    FROM DEV_DB.DBT_WILLGYORIKRAFTHEINZCOM.STG_POSTGRES__ORDERS
    GROUP BY ALL
)

SELECT
    SUM(CASE 
        WHEN ORDER_COUNT = 1 THEN 1
        ELSE 0
    END) AS ORDER_COUNT_1
    , SUM(CASE 
        WHEN ORDER_COUNT = 2 THEN 1
        ELSE 0
    END) AS ORDER_COUNT_2
    , SUM(CASE 
        WHEN ORDER_COUNT > 2 THEN 1
        ELSE 0
    END) AS ORDER_COUNT_MORE_2
FROM USER_ORDER_COUNT
```


## Question 5: On average, how many unique sessions do we have per hour?
### Answer: 16.327586

### Query:
```SQL
WITH HOURLY_SESSION_COUNT AS (

    SELECT 
        DATE_TRUNC(HOUR, CREATED_AT) AS HOUR
        , COUNT(DISTINCT SESSION_ID) AS SESSION_COUNT
    FROM DEV_DB.DBT_WILLGYORIKRAFTHEINZCOM.STG_POSTGRES__EVENTS
    GROUP BY ALL
)

SELECT AVG(SESSION_COUNT)
FROM HOURLY_SESSION_COUNT
```