with events as (
    select 
         *
    from {{ ref('stg_events')}}
),

products as (
    select * from {{ ref('stg_products')}}
),

order_items as (
    select * from {{ ref('stg_order_items')}}
),

event_productid as (
    select 
        events.event_guid,
        events.session_guid,
        events.user_guid,
        events.page_url,
        events.created_at_utc,
        events.order_guid,
        events.event_type,
        coalesce(events.product_guid, order_items.product_guid) as product_guid
    from events
    left outer join order_items
    on events.order_guid = order_items.order_guid
),

event_product_names as (
    select events.*,
        products.product_name
    from event_productid as events
    left outer join products on events.product_guid = products.product_guid
)

select * from event_product_names