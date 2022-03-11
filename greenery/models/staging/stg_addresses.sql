with source as (
    select * from {{ source('src_postgres', 'addresses')}}
),

renamed as (
    
    select 
        address_id as address_guid,
        address,
        zipcode as zip_code,
        state,
        country

    from source
)

select * from renamed