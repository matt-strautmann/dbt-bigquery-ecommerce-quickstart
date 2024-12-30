{{ config(
    materialized = 'view',
    schema = 'staging'
) }}

with source as (
    select 
        _airbyte_data,
        _airbyte_emitted_at
    from {{ source('shopify', '_airbyte_raw_products') }}
),

renamed as (
    select
        CAST(JSON_EXTRACT_SCALAR(_airbyte_data, '$.id') AS INT64) as product_id,
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.title') as product_name,
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.product_type') as product_type,
        PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%SZ', JSON_EXTRACT_SCALAR(_airbyte_data, '$.created_at')) as created_at,
        CAST(JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(_airbyte_data, '$.variants')[0], '$.price') AS FLOAT64) as price,
        JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(_airbyte_data, '$.variants')[0], '$.sku') as sku,
        JSON_EXTRACT_ARRAY(_airbyte_data, '$.tags') as tags,
        _airbyte_emitted_at as ingested_at
    from source
)

select * from renamed
