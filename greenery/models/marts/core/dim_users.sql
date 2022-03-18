{{
    config(
        materialized = 'table'
    )
}}

with stg_users as (
    select * from {{ ref('stg_users') }}
),

stg_addresses as (
    select * from {{ ref('stg_addresses')}}
),

dim_users as (
    
    select 
        users.user_guid,
        users.first_name,
        users.last_name,
        users.email,
        users.phone_number,
        users.created_at_utc,
        users.updated_at_utc,
        addresses.address as user_street,
        addresses.zip_code as user_zip_code,
        addresses.state as user_state,
        addresses.country as user_country
        
    
    from stg_users as users
    left outer join stg_addresses as addresses
    on users.address_guid = addresses.address_guid
)

select * from dim_users