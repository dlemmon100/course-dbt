# Project 2 Questions

#### 1: What is our repeat user rate?
- 79.84%

``` sql 
with orders as (
  select * from dbt_dylan_l.stg_orders
),

user_orders as (
  select 
    user_guid,
    count(distinct order_guid) as user_orders
    
  from orders 
  
  group by user_guid
),

multiple_purchases as (
  select 
    count(user_guid) as user_count,
    sum(case 
          when user_orders > 1 
            then 1
            else 0 
        end) as multiple_purchases
  
  from user_orders
)

select round((multiple_purchases / user_count::numeric) * 100, 2) as repeat_rate
from multiple_purchases
```
#### 2: What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?

Indicators of users likely to purchase again:
- Users that have ordered more than once. 
- Users products were delivered in a timely fashion.
- Users that are ordering in bulk. (Perhaps for a business purpose)
- Users with recurring orders.

Indicators of users likely not to purchase again:
- Users with poor delivery times.
- Users that have never added anything to their carts.
- Users that have never purchased anything.
- Users that have not purchased in a long time.

If you had more data what features would you want to look into to answer this questions?
- Competitor prices on similar products.
- Whether users are making purchases for personal or business reasons. 

#### 3: Explain the mart models you added. Why did you organize the models in the way you did?
- Core: High level details about the essential functions of the business - revenue, cost and performance.
**dim_products**: Shows details about the products - can be joined to from fact models. 
**dim_users**: User detail dimensional model that can be joined to from fact tables to gather more information on the users.
**fct_orders**: Fact table that provides information about an order, the customer that purchased the order and shipping information.

- Marketing: Data that can be used to improve marketing tactics. 
**int_user_orders**: Performs light transformations to see user order summary information such as purchase and spending trends.
**fct_user_orders**: Shows details of users and their historical orders.

- Producs: Data the business can use to see general product information.
**fct_page_views**: Shows data about which users are visiting which pages the most frequently. 

#### 4: What assumptions are you making about each model? 
- Each model is going to have a unique, not null primary key.
- Revenue & cost values should be positive.

#### 5: Did you find any "bad" data as you added and ran tests on your models?
- No, all of the tests I have implemented on models are passing.

#### 6: Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.
- We are currently working through discussions about how to best handle this at our company. It wouldn't be a bad idea to build dbt models that report failing test data that can be used in a BI tool or reporting tool that can send the report on a subscription.

# Project 1 Questions

#### 1: How many users do we have?
- 130 users (unique)

``` sql
  select count(distinct order_guid) from dbt_dylan_l.stg_users
```

#### 2: On average, how many orders do we receive per hour?
- 7.52 order / hour

``` sql
with hourly_orders as (
  select 
    date_trunc('hour', created_at_utc) as hour_of_order,
    count(order_guid) as order_count
  
  from dbt_dylan_l.stg_orders
  group by 1
  
)

select round(avg(order_count), 2) as average_hourly_order_count 
from hourly_orders
```

#### 3: On average, how long does an order take from being placed to being delivered?
- 93.40 hours on average.
``` sql
with orders as (
  select 
    created_at_utc,
    delivered_at_utc,
    extract(epoch from (delivered_at_utc - created_at_utc))  as difference_seconds
    
  from dbt_dylan_l.stg_orders
  where order_status = 'Delivered'
),

average_delivery_time as (
  select 
    avg(difference_seconds) as avg_difference
  from orders
)

select round(cast(avg_difference as numeric) / 3600 , 2) as difference_hours
from average_delivery_time 
```

#### 4: How many users have only made one purchase? Two purchases? Three + purchases?

| orders | user count |
|--------|------------|
|1       | 25         |
|2       | 28         |
|3 +     | 71         |

``` sql
with orders as (
  select * from dbt_dylan_l.stg_orders
),

user_purchases as (
  select 
    user_guid, 
    count(user_guid) as user_order_count
  from orders
  group by user_guid
  
),

user_purchases_grouped as (
  select 
    case 
      when user_order_count = 1 
        then 'One Purchase'
      when user_order_count = 2 
        then 'Two Purchases'
      when user_order_count > 2 
        then 'Three + Purchases'
    end as order_count
  from user_purchases
)

select 
  order_count, count(*) as user_count

from user_purchases_grouped
group by order_count
order by user_count
```

#### 5: On average, how many unique sessions do we have per hour? 
- 16.33 unique sessions / hour

``` sql
with sessions as (
  select * from dbt_dylan_l.stg_events
),

unique_sessions as (
  select 
    count(distinct session_guid) as unique_session_count,
    date_trunc('hour', created_at_utc) as created_at_hour
  from sessions
  group by 2
)

select round(avg(unique_session_count), 2) from unique_sessions
```
