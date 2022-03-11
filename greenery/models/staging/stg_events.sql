with source as (
    select * from {{ source('src_postgres', 'events')}}
),

renamed as (

    select 
        event_id as event_guid,
        session_id as session_guid,
        user_id as user_guid,
        order_id as order_guid,
        product_id as product_guid,
        page_url,
        created_at as created_at_utc,
        event_type
    
    from source
)

select * from renamed