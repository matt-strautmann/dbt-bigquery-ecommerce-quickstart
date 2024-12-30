{{ config(
    materialized = 'view',
    schema = 'staging'
) }}

with source as (
    select 
        _airbyte_data,
        _airbyte_emitted_at
    from {{ source('stripe', '_airbyte_raw_customers') }}
),

renamed as (
    select
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.id') as customer_id,
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.email') as email,
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.name') as customer_name,
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.description') as description,
        PARSE_TIMESTAMP('%s', JSON_EXTRACT_SCALAR(_airbyte_data, '$.created')) as created_at,
        JSON_EXTRACT_SCALAR(_airbyte_data, '$.currency') as default_currency,
        CAST(JSON_EXTRACT_SCALAR(_airbyte_data, '$.delinquent') as BOOLEAN) as is_delinquent,
        _airbyte_emitted_at as ingested_at
    from source
)

select * from renamed
