# Week 2 Project Answers

# Part 1. Models
## Question: What is our repeat user rate?
### Answer: 0.196676

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
        WHEN order_count > 2 THEN 1
        ELSE 0
    END) AS order_count_more_2
    , SUM(order_count) AS total_orders
    , DIV0(order_count_more_2, total_orders) AS user_repeat_rate
FROM user_order_count;
```

## Question: What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?
### Answer: 
#### - If we had user review data, we could measure user satisfaction with the past orders. If they leave good reviews, they are more likely to purchase from the company again. Flip side with negative reviews, they are much less likely to make another purchase.
#### - Seeing if users are saving pages, sending links, or posting the links on social media could be good indicators they are likely to purchase again or soon in the future
#### - Using existing data, we could measure how many times a user has viewed a product page. The more the view it, the more likely they are to purchase at some point soon

## Question: Explain the product mart models you added. Why did you organize the models in the way you did?
### Answer:
#### - int_daily_product_orders: Merges order and orders and order_items table to count the average daily orders. It is then referenced by fact_product_conversion_rate table to calculate conversion rate by product (orders/views)
#### - int_daily_product_views: Counts average daily page views from events table. Referenced by fact_product_daily_views to count the daily views by product and fact_product_conversion_rate tables to calculate conversion rate by product (orders/views)
#### - dim_product_url: Merges products and events tables to create a dim table that contains all product page URLs
#### - fact_product_conversion_rate: Merges intermediate tables to calculate conversion rate by product (orders/views). This showcases how many of a products pages views are actually converting to orders
#### - fact_product_daily_views: Merges intermediate tables to calculate the daily page views by product
#### - fact_product_promo: Merges staging tables to show how many promo codes have been applied to each product, and what is the total amount of promotional savings tied to each product

# Part 2. Tests
## Question: What assumptions are you making about each model? (i.e. why are you adding each test?)
### Answer: I'm assuming each primary key is not null and unique. I'm also assuming value fields like quantity and price are positive values. And lastly, I'm assuming the promo code status can only ever be "active" or "inactive"

## Question: Did you find any “bad” data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?
### Answer: No bad data on the tests I ran. I was just initally wrong on my assumption that because order_id is primary key on order_items tabe, it would be unique. However, there are multiple rows of same order_id in that table because the same order_id will be repeated if there are multiple products on the same order, which makes sense. Therefore, I removed the unique test for that column

## Question: Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.
### Answer: I would make sure the tests are run each day and set up an alert any time one of the tests failed. Making sure we can catch the issue before the data makes its way into our production BI tools

# Part 3. Snapshots
## Question: Which products had their inventory change from week 1 to week 2? 
### Answer: Pothos (40 -> 20), Philodendron (51 -> 25), Monstera (77 -> 64), and String of pearls (58 -> 10) all had their inventory change