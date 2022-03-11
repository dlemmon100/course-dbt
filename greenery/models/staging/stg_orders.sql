with source as (
    select * from {{ source('src_postgres', 'orders')}}
),

renamed as (

    select 
        order_id as order_guid,
        user_id as user_guid,
        promo_id,
        address_id as address_guid,
        order_cost,
        shipping_cost,
        order_total,
        tracking_id,
        upper(shipping_service) as shipping_service,
        created_at as created_at_utc,
        estimated_delivery_at as estimated_delivery_at_utc,
        delivered_at as delivered_at_utc,
        initcap(status) as order_status

    from source
)

select * from renamed
