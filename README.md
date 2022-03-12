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
