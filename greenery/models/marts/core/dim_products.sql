with products as (
    select * from {{ ref('stg_products')}}

),

final as (

    select 
        product_guid,
        product_name,
        product_price,
        inventory

    from products
    
)

select * from final