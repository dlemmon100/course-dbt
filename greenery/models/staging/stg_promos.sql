with source as (
    select * from {{ source('src_postgres', 'promos')}}
),

renamed as (
    
    select 
        promo_id,
        discount,
        initcap(status) as promo_status

    from source
)

select * from renamed