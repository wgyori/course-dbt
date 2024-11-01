# Week 4 Project Answers

# Part 1 - dbt Snapshots
## Question 1 : Which products had their inventory change from week 3 to week 4? 
### Answer:

| NAME             | WEEK_3_INV | WEEK_4_INV |
|------------------|------------|------------|
| Philodendron     | 15         | 30         |
| Pothos           | 0          | 20         |
| Monstera         | 50         | 31         |
| String of pearls | 0          | 10         |
| Bamboo           | 44         | 23         |
| ZZ Plant         | 53         | 41         |

## Question 2 : Which products had the most fluctuations in inventory? Did we have any items go out of stock in the last 3 weeks? 
### Answer: Four products changed inventory every week, and two products changed inventory every week but week 2. All other products stayed constant. Pothos and String of Pearls both hit 0 inventory in week 3, but got restocked in week 4

| NAME             | WEEK_1_INV | WEEK_2_INV | WEEK_3_INV | WEEK_4_INV | INV_FLUCTUATION |
|------------------|------------|------------|------------|------------|-----------------|
| Philodendron     | 51         | 25         | 15         | 30         | 3               |
| Pothos           | 40         | 20         | 0          | 20         | 3               |
| Monstera         | 77         | 64         | 50         | 31         | 3               |
| String of pearls | 58         | 10         | 0          | 10         | 3               |
| Bamboo           | 56         | 56         | 44         | 23         | 2               |
| ZZ Plant         | 89         | 89         | 53         | 41         | 2               |

### Query (used for both question 1 and 2):
```SQL
WITH product_inv_week AS (
    SELECT
        product_id
        , name
        , CASE
            WHEN DATE_PART(week, dbt_updated_at) = 41 THEN inventory
            ELSE NULL
        END AS week_1_snapshot
        , CASE
            WHEN DATE_PART(week, dbt_updated_at) = 42 THEN inventory
            ELSE NULL
        END AS week_2_snapshot
        , CASE
            WHEN DATE_PART(week, dbt_updated_at) = 43 THEN inventory
            ELSE NULL
        END AS week_3_snapshot
        , CASE
            WHEN DATE_PART(week, dbt_updated_at) = 44 THEN inventory
            ELSE NULL
        END AS week_4_snapshot
    FROM dev_db.dbt_willgyorikraftheinzcom.products_snapshot
)

SELECT
    product_id
    , name
    , SUM(week_1_snapshot) AS week_1_inv
    , IFNULL(SUM(week_2_snapshot), week_1_inv) AS week_2_inv
    , IFNULL(SUM(week_3_snapshot), week_2_inv) AS week_3_inv
    , IFNULL(SUM(week_4_snapshot), week_3_inv) AS week_4_inv
    , CASE
        WHEN week_1_inv = week_2_inv THEN 0 ELSE 1
    END
    + CASE
        WHEN week_2_inv = week_3_inv THEN 0 ELSE 1
    END
    + CASE
        WHEN week_3_inv = week_4_inv THEN 0 ELSE 1
    END AS inv_fluctuation
FROM product_inv_week
GROUP BY ALL
```

# Part 2 - Modeling challenge
## Question 1 : How are our users moving through the product funnel?
### Answer: fact_product_events model was created to measure how the user progressed down the funnel for each product session. We can use this fact table to do further analysis in a BI tool 

### Query:
```SQL
WITH orders_items AS (
    SELECT * FROM {{ref('stg_postgres__order_items')}}
),

session_events AS (
    SELECT * FROM {{ref('int_session_events')}}
)

SELECT
    session_events.session_id
    , CASE
        WHEN session_events.product_id IS NULL THEN orders_items.product_id
        ELSE session_events.product_id
    END AS product_id
    , SUM(session_events.page_views) AS page_views
    , SUM(session_events.add_to_carts) AS add_to_carts
    , SUM(session_events.checkouts) AS checkouts
    , SUM(session_events.package_shippeds) AS ships
FROM session_events
LEFT JOIN orders_items
    ON session_events.order_id = orders_items.order_id
GROUP BY ALL
```

## Question 2 : Which steps in the funnel have largest drop off points?
### Answer1 : At an overall level- ~53% converted from view to cart, ~87% converted from cart to checkout, and ~92% converted from checkout to ship. This makes sense because once a user has added an item to their cart, they are pretty likely to end up purchasing the item. However, getting the user to actually add an item to the cart is a lot more difficult. So having the largest drop off at the view -> cart level makes sense.

| PAGE_VIEWS | ADD_TO_CARTS | CHECKOUTS | SHIPS | ADD_TO_CARTS_PERCENT_TOTAL | CHECKOUTS_PERCENT_TOTAL | SHIPS_PERCENT_TOTAL | CHECKOUTS_PERCENT_PREVIOUS | SHIPS_PERCENT_PREVIOUS |
|------------|--------------|-----------|-------|----------------------------|-------------------------|---------------------|----------------------------|------------------------|
| 1871       | 986          | 862       | 794   | 0.526991                   | 0.460716                | 0.424372            | 0.874239                   | 0.921114               |

### Query:
```SQL
SELECT
    SUM(page_views) AS page_views
    , SUM(add_to_carts) AS add_to_carts
    , SUM(checkouts) AS checkouts
    , SUM(ships) AS ships
    , SUM(add_to_carts) / SUM(page_views) AS add_to_carts_percent_total
    , SUM(checkouts) / SUM(page_views) AS checkouts_percent_total
    , SUM(ships) / SUM(page_views) AS ships_percent_total
    , SUM(checkouts) / SUM(add_to_carts) AS checkouts_percent_previous
    , SUM(ships) / SUM(checkouts) AS ships_percent_previous
FROM dev_db.dbt_willgyorikraftheinzcom.fact_product_events AS product_events
```

### Answer2 : At a product level, below table shows the highest and lowest conversion rates for each step. The Cart->Checkout and Checkout->Ship steps are probably less valuable at a product level, since the user experience should be relatively the same between products. However, the view->cart step could have a much bigger variance by product from UI/UX perspective. So I would start my analysis there and see why a product like Pothos is performing much worse than a product like String of Pearls 

| Step             | Highest                         | Lowest                   |
|------------------|---------------------------------|--------------------------|
| View to Cart     | String of pearls, 68%           | Pothos, 38%              |
| Cart to Checkout | Money Tree, 100%                | Angel Wings Begonia, 75% |
| Checkout to Ship | Dragon Tree/Ponytail Palm, 100% | Spider Plant, 82%        |

### Query:
```SQL
SELECT
    product_events.product_id
    , products.name
    , SUM(page_views) AS page_views
    , SUM(add_to_carts) AS add_to_carts
    , SUM(checkouts) AS checkouts
    , SUM(ships) AS ships
    , SUM(add_to_carts) / SUM(page_views) AS add_to_carts_percent_total
    , SUM(checkouts) / SUM(page_views) AS checkouts_percent_total
    , SUM(ships) / SUM(page_views) AS ships_percent_total
    , SUM(checkouts) / SUM(add_to_carts) AS checkouts_percent_previous
    , SUM(ships) / SUM(checkouts) AS ships_percent_previous
FROM dev_db.dbt_willgyorikraftheinzcom.fact_product_events AS product_events
LEFT JOIN dev_db.dbt_willgyorikraftheinzcom.stg_postgres__products AS products
    ON product_events.product_id = products.product_id
GROUP BY ALL
```

## Question 3 : Use an exposure on your product analytics model to represent that this is being used in downstream BI tools
### Answer: Created exposures.yml file within models folder showing how the fact_product_events table used in above query answers would be referenced by BI funnel dashboard

### Query:
```SQL
version: 2

exposures:  
  - name: Product Funnel Dashboard
    description: >
      Models that are critical to our product funnel dashboard
    type: dashboard
    maturity: high
    owner:
      name: Will Gyori
      email: will.gyori@kraftheinz.com
    depends_on:
      - ref('fact_product_events')
```

# Part 3 - Reflection

## Question 3A.1: If your organization is thinking about using dbt, how would you pitch the value of dbt/analytics engineering to a decision maker at your organization?
### Answer: Organization is already using dbt

## Question 3A.2: If your organization is using dbt, what are 1-2 things you might do differently / recommend to your organization based on learning from this course?
### Answer: I would recommend stricter rules around staging, intermediate, and fact tables to ensure the organization throughout the company is standarized with the goal to reduce the number of potential repeated data sets

## Question 3A.3: If you are thinking about moving to analytics engineering, what skills have you picked that give you the most confidence in pursuing this next step?
### Answer: Have never used dbt prior to this course, so just becoming familiar with it has been a huge help and will aid me in conversations with data engineering team and future career prospects. I would like to start using it in a day-to-day basis within the BI team moving forward