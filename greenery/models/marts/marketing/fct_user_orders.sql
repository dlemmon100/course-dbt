{{
    config(
        materialized = 'table'
    )
}}

with users as (
    select * from {{ ref('stg_users')}}
),

user_orders as (
    select * from {{ ref('int_user_orders')}}
),

addresses as (
    select * from {{ ref('stg_addresses')}}
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