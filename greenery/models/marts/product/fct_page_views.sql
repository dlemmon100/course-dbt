{{
    config(
        materialized = 'table'
    )
}}

with events as (
    select * from {{ ref('stg_events')}}
),

page_events as (
    select 
        page_url,
        count(*) as total_page_views,
        case 
            when date_trunc('month', created_at_utc) = date_trunc('month', now())
                then count(*)
            else 0
        end as page_views_this_month
    
    from events
    where event_type = 'page_view'
    group by 1, created_at_utc
)

select * from page_events