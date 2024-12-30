{{ config(
    materialized = 'view',
    schema = 'staging'
) }}

with source as (
    select 
        _airbyte_data,
        _airbyte_emitted_at
    from {{ source('shopify', '_airbyte_raw_orders') }}
),

renamed as (
    select
        CAST(JSON_EXTRACT_SCALAR(_airbyte_data, '$.id') AS INT64) as order_id,
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.email') as customer_email,
        PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%SZ', JSON_EXTRACT_SCALAR(_airbyte_data, '$.created_at')) as created_at,
        CAST(JSON_EXTRACT_SCALAR(_airbyte_data, '$.total_price') AS FLOAT64) as total_price,
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.currency') as currency,
        CAST(JSON_EXTRACT_SCALAR(_airbyte_data, '$.customer.id') AS INT64) as customer_id,
        JSON_EXTRACT_ARRAY(_airbyte_data, '$.line_items') as line_items,
        _airbyte_emitted_at as ingested_at
    from source
)

select * from renamed
