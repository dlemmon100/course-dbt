with orders as (
    select * from {{ ref('stg_orders')}}
),

promos as (
    select * from {{ ref('stg_promos')}}
),

users as (
    select * from {{ ref('stg_users')}}
),

addresses as (
    select * from {{ ref('stg_addresses')}}
),

order_items as (
    select * from {{ ref('stg_order_items')}}
),

order_item_counts as (
    select 
        order_guid,
        count(distinct product_guid) as distinct_products,
        sum(order_quantity) as total_order_item_count
    
    from order_items
    group by 1
),


orders_with_order_items_and_shipping_detail as (
    select 
        orders.*,
        order_items.distinct_products,
        order_items.total_order_item_count,
        addresses.address as shipping_address,
        addresses.zip_code as shipping_zip_code,
        addresses.state as shipping_state,
        addresses.country as shipping_country
    
    from orders
    left outer join order_item_counts as order_items
        on orders.order_guid = order_items.order_guid
    left outer join addresses 
        on orders.address_guid = addresses.address_guid
    
),

orders_with_promo_details as (
    select
        orders.*,
        promos.discount,
        promos.promo_status

    from orders_with_order_items_and_shipping_detail as orders
    left outer join promos 
        on orders.promo_id = promos.promo_id
),

orders_with_user_details as (
    select 
        orders.*,
        users.first_name as customer_first_name,
        users.last_name as customer_last_name,
        users.email as customer_email,
        users.phone_number as customer_phone_number


    from orders_with_promo_details as orders
    left outer join users 
        on users.user_guid = orders.user_guid
    left outer join addresses
        on users.address_guid = addresses.address_guid
),

final as (
    select 
        order_guid,
        order_cost,
        shipping_cost,
        order_total,
        discount,
        promo_status,
        customer_first_name,
        customer_last_name,
        customer_email,
        customer_phone_number,
        shipping_service,
        created_at_utc,
        estimated_delivery_at_utc,
        delivered_at_utc,
        order_status,
        distinct_products,
        total_order_item_count,
        shipping_address,
        shipping_zip_code,
        shipping_state,
        shipping_country
    from orders_with_user_details

)

select * from final