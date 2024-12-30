{{ config(
    materialized = 'view',
    schema = 'staging'
) }}

with source as (
    select 
        _airbyte_data,
        _airbyte_emitted_at
    from {{ source('shopify', '_airbyte_raw_customers') }}
),

renamed as (
    select
        CAST(JSON_EXTRACT_SCALAR(_airbyte_data, '$.id') AS INT64) as customer_id,
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.email') as email,
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.first_name') as first_name,
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.last_name') as last_name,
        PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%SZ', JSON_EXTRACT_SCALAR(_airbyte_data, '$.created_at')) as created_at,
        CAST(JSON_EXTRACT_SCALAR(_airbyte_data, '$.orders_count') AS INT64) as orders_count,
        CAST(JSON_EXTRACT_SCALAR(_airbyte_data, '$.total_spent') AS FLOAT64) as total_spent,
        JSON_EXTRACT_ARRAY(_airbyte_data, '$.tags') as tags,
        _airbyte_emitted_at as ingested_at
    from source
)

select * from renamed
