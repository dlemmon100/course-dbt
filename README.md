# Project 3 Questions

#### 1: What is our overall conversion rate?
- 62.46%

``` sql
with purchase_events as (
  select 
    count(distinct session_guid) as purchase_events
  from dbt_dylan_l.stg_events
  where event_type = 'checkout'
  and order_guid is not null
),

total_events as (
  select 
    count(distinct session_guid) as total_events
  from dbt_dylan_l.stg_events
)

select round(a.purchase_events / b.total_events::numeric * 100,2) as conversion_rate
from 
purchase_events a, total_events b
```

#### 2: What is our conversion rate by product?

| product_guid	| product_name	| conversion_rate|
|---------------------------------------|-------------------|------|
| fb0e8be7-5ac4-4a76-a1fa-2cc4bf0b2d80	| String of pearls	|60.94|
| 74aeb414-e3dd-4e8a-beef-0fa45225214d	| Arrow Head	|55.56|
| c17e63f7-0d28-4a95-8248-b01ea354840e	| Cactus	|54.55|
| b66a7143-c18a-43bb-b5dc-06bb5d1d3160	| ZZ Plant	|53.97|
| 689fb64e-a4a2-45c5-b9f2-480c2155624d	| Bamboo	|53.73|
| 579f4cd0-1f45-49d2-af55-9ab2b72c3b35	| Rubber Plant	|51.85|
| be49171b-9f72-4fc9-bf7a-9a52e259836b	| Monstera	|51.02|
| b86ae24b-6f59-47e8-8adc-b17d88cbd367	| Calathea Makoyana	|50.94|
| e706ab70-b396-4d30-a6b2-a1ccf3625b52	| Fiddle Leaf Fig	|50|
| 5ceddd13-cf00-481f-9285-8340ab95d06d	| Majesty Palm	|49.25|
| 615695d3-8ffd-4850-bcf7-944cf6d3685b	| Aloe Vera	|49.23|
| 35550082-a52d-4301-8f06-05b30f6f3616	| Devil's Ivy	|48.89|
| 55c6a062-5f4a-4a8b-a8e5-05ea5e6715a3	| Philodendron	|48.39|
| a88a23ef-679c-4743-b151-dc7722040d8c	| Jade Plant	|47.83|
| 64d39754-03e4-4fa0-b1ea-5f4293315f67	| Spider Plant	|47.46|
| 5b50b820-1d0a-4231-9422-75e7f6b0cecf	| Pilea Peperomioides	|47.46|
| 37e0062f-bd15-4c3e-b272-558a86d90598	| Dragon Tree	|46.77|
| d3e228db-8ca5-42ad-bb0a-2148e876cc59	| Money Tree	|46.43|
| c7050c3b-a898-424d-8d98-ab0aaad7bef4	| Orchid	|45.33|
| 05df0866-1a66-41d8-9ed7-e2bbcddd6a3d	| Bird of Paradise	|45|
| 843b6553-dc6a-4fc4-bceb-02cd39af0168	| Ficus	|42.65|
| bb19d194-e1bd-4358-819e-cd1f1b401c0c	| Birds Nest Fern	|42.31|
| 80eda933-749d-4fc6-91d5-613d29eb126f	| Pink Anthurium	|41.89|
| e2e78dfc-f25c-4fec-a002-8e280d61a2f2	| Boston Fern	|41.27|
| 6f3a3072-a24d-4d11-9cef-25b0b5f8a4af	| Alocasia Polly	|41.18|
| e5ee99b6-519f-4218-8b41-62f48f59f700	| Peace Lily	|40.91|
| e18f33a6-b89a-4fbc-82ad-ccba5bb261cc	| Ponytail Palm	|40|
| e8b6528e-a830-4d03-a027-473b411c7f02	| Snake Plant	|39.73|
| 58b575f2-2192-4a53-9d21-df9a0c14fc25	| Angel Wings Begonia	|39.34|
| 4cda01b9-62e2-46c5-830f-b7f262a58fb1	| Pothos	|34.43|

``` sql
with product_views as (
  select product_guid,
    product_name,
    count(distinct session_guid)::numeric as views
  from dbt_dylan_l.fct_sessions
  where event_type = 'page_view'
  group by 1, 2 
),

product_purchases as (
  select product_guid,
    product_name,
    count(distinct session_guid)::numeric as purchases
  from dbt_dylan_l.fct_sessions
  where event_type = 'checkout'
  group by 1, 2 
),

final as (
  select
    a.product_guid,
    a.product_name,
    round((b.purchases / a.views) * 100, 2)  as conversion_rate
  from product_views as a 
  left outer join product_purchases as b
  on a.product_guid = b.product_guid
  order by 3 desc
)

select * from final
```

#### 3: Why might certain products be converting at higher / lower rates than others?
- Active promo
- Product been around longer, more trusting customers.
- Active discount



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
