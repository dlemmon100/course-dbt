{{
    config(
        materialized='table'
    )
}}

with superheros as (
    select * from {{ source('src_postgres', 'superheroes')}}
),

renamed as (
    select 
        id as superhero_guid,
        name,
        gender,
        eye_color,
        race,
        hair_color,
        height,
        publisher,
        skin_color,
        alignment,
        weight,
        created_at,
        updated_at
    from superheros

)

select * from renamed