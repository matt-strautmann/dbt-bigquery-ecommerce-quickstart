{{ config(
    materialized = 'table',
    schema = 'staging',
    unique_key = 'order_id'
) }}

with base as (
    select * from {{ ref('base_shopify__orders') }}
),

line_items as (
    select
        order_id,
        JSON_EXTRACT_SCALAR(item, '$.product_id') as product_id,
        CAST(JSON_EXTRACT_SCALAR(item, '$.quantity') AS INT64) as quantity,
        CAST(JSON_EXTRACT_SCALAR(item, '$.price') AS FLOAT64) as price
    from base,
    UNNEST(line_items) as item
),

final as (
    select
        base.order_id,
        base.customer_id,
        base.customer_email,
        base.created_at,
        base.total_price,
        base.currency,
        ARRAY_AGG(STRUCT(
            CAST(line_items.product_id AS INT64) as product_id,
            line_items.quantity,
            line_items.price
        )) as line_items,
        base.ingested_at,
        CURRENT_TIMESTAMP() as dbt_updated_at,
        '{{ invocation_id }}' as dbt_job_id
    from base
    left join line_items using (order_id)
    group by 1, 2, 3, 4, 5, 6, 8
)

select * from final
