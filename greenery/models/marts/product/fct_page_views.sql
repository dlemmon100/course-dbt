{{
    config(
        materialized = 'table'
    )
}}

with events as (
    select * from {{ ref('stg_events')}}
),

users as (
    select * from {{ ref('stg_users')}}
),

user_page_views as (
    select 
        events.user_guid,
        events.page_url,
        events.event_type,
        users.first_name,
        users.last_name,
        users.phone_number,
        users.email,
        count(events.user_guid) as number_of_views,
        min(events.created_at_utc) as first_view_date,
        max(events.created_at_utc) as last_view_date
    
    from events
    left outer join users 
        on events.user_guid = users.user_guid
    where event_type = 'page_view'
    group by 1,2,3,4,5,6,7
    
),

final as (
    
    select 
        page_url,
        first_name,
        last_name,
        phone_number,
        email,
        number_of_views,
        first_view_date,
        last_view_date

    from user_page_views
)

select * from user_page_views