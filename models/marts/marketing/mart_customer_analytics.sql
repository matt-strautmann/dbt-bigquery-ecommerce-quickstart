{{ config(
    materialized = 'table',
    schema = 'marts_marketing'
) }}

with customers as (
    select * from {{ ref('base_shopify__customers') }}
),

orders as (
    select * from {{ ref('stg_shopify__orders') }}
),

products as (
    select * from {{ ref('base_shopify__products') }}
),

customer_orders as (
    select
        customer_id,
        count(*) as total_orders,
        sum(total_price) as total_revenue,
        min(created_at) as first_order_date,
        max(created_at) as last_order_date
    from orders
    group by 1
),

customer_products as (
    select
        o.customer_id,
        array_agg(distinct p.product_type) as purchased_product_types,
        array_agg(distinct p.product_name) as purchased_products
    from orders o,
    unnest(o.line_items) as items
    left join products p on cast(items.product_id as int64) = p.product_id
    group by 1
),

final as (
    select
        c.customer_id,
        c.email,
        c.first_name,
        c.last_name,
        c.created_at as customer_created_at,
        co.total_orders,
        co.total_revenue,
        co.first_order_date,
        co.last_order_date,
        date_diff(co.last_order_date, co.first_order_date, DAY) as customer_lifetime_days,
        cp.purchased_product_types,
        cp.purchased_products,
        c.tags as customer_tags,
        -- Customer Segments
        case
            when co.total_revenue > 500 then 'High Value'
            when co.total_revenue > 200 then 'Medium Value'
            else 'Low Value'
        end as value_segment,
        case
            when date_diff(CURRENT_TIMESTAMP(), co.last_order_date, DAY) <= 30 then 'Active'
            when date_diff(CURRENT_TIMESTAMP(), co.last_order_date, DAY) <= 90 then 'At Risk'
            else 'Churned'
        end as engagement_segment,
        CURRENT_TIMESTAMP() as dbt_updated_at
    from customers c
    left join customer_orders co using (customer_id)
    left join customer_products cp using (customer_id)
)

select * from final
