with orders as (
    select * from {{ ref('stg_orders')}}
),

final as (
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
)

select * from final