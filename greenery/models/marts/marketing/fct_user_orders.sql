{{
    config(
        materialized = 'table'
    )
}}

with users as (
    select * from {{ ref('stg_users')}}
),

orders as (
    select * from {{ ref('stg_orders')}}
),

addresses as (
    select * from {{ ref('stg_addresses')}}
),

user_orders as (
    select 
        orders.user_guid,
        min(created_at_utc) as first_order_date,
        max(created_at_utc) as last_order_date,
        sum(
            case 
                when order_status <> 'Delivered' 
                    then 1
                else 0
            end
        ) as open_orders,
        now() - max(created_at_utc) as days_since_last_order,
        avg(orders.delivered_at_utc - orders.created_at_utc) as avg_delivery_time,
        count(distinct orders.order_guid) as total_orders,
        sum(shipping_cost) as total_shipping_spend,
        sum(order_cost) as total_order_spend,
        sum(order_total) as total_spend
    from orders 
    group by 1
),

user_addresses as (
    select 
        users.*,
        addresses.address as user_address,
        addresses.zip_code as user_zip_code,
        addresses.state as user_state,
        addresses.country as user_country

    from users
    left outer join addresses 
        on users.address_guid = addresses.address_guid
),

final as (
    select
        users.user_guid,
        users.first_name,
        users.last_name,
        users.email,
        users.phone_number,
        users.user_address,
        users.user_zip_code,
        users.user_state,
        users.user_country,
        orders.open_orders,
        orders.first_order_date,
        orders.last_order_date,
        orders.days_since_last_order,
        orders.total_orders,
        orders.avg_delivery_time,
        orders.total_shipping_spend,
        orders.total_order_spend,
        orders.total_spend
    
    from user_addresses as users
    left outer join user_orders as orders
        on users.user_guid = orders.user_guid
)

select * from final