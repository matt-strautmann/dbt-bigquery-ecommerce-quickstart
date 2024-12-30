{{ config(
    materialized = 'table',
    schema = 'staging',
    unique_key = 'customer_id'
) }}

with base as (
    select * from {{ ref('base_stripe__customers') }}
),

cleaned as (
    select
        customer_id,
        NULLIF(email, '') as email,
        NULLIF(customer_name, '') as customer_name,
        NULLIF(description, '') as description,
        created_at,
        default_currency,
        is_delinquent,
        ingested_at,
        -- Add standardized fields
        'stripe' as source_system,
        CURRENT_TIMESTAMP() as dbt_updated_at,
        '{{ invocation_id }}' as dbt_job_id,
        '{{ this.schema }}' as dbt_schema_name,
        '{{ this.identifier }}' as dbt_table_name
    from base
    where customer_id is not null  -- Filter out invalid records
)

select * from cleaned
