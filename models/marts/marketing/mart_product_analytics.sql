{{ config(
    materialized = 'table',
    schema = 'marts_marketing'
) }}

with products as (
    select * from {{ ref('base_shopify__products') }}
),

orders as (
    select * from {{ ref('stg_shopify__orders') }}
),

product_orders as (
    select
        cast(items.product_id as int64) as product_id,
        count(distinct o.order_id) as total_orders,
        sum(items.quantity) as total_units_sold,
        sum(items.price * items.quantity) as total_revenue,
        min(o.created_at) as first_order_date,
        max(o.created_at) as last_order_date
    from orders o,
    unnest(o.line_items) as items
    group by 1
),

final as (
    select
        p.product_id,
        p.product_name,
        p.product_type,
        p.price as current_price,
        p.sku,
        p.tags as product_tags,
        po.total_orders,
        po.total_units_sold,
        po.total_revenue,
        po.first_order_date,
        po.last_order_date,
        -- Product Performance Metrics
        safe_divide(po.total_revenue, po.total_units_sold) as average_order_value,
        safe_divide(po.total_units_sold, po.total_orders) as average_units_per_order,
        -- Product Categories
        case
            when po.total_revenue > 1000 then 'High Revenue'
            when po.total_revenue > 500 then 'Medium Revenue'
            else 'Low Revenue'
        end as revenue_category,
        case
            when date_diff(CURRENT_TIMESTAMP(), po.last_order_date, DAY) <= 30 then 'Active'
            when date_diff(CURRENT_TIMESTAMP(), po.last_order_date, DAY) <= 90 then 'Slowing'
            else 'Inactive'
        end as product_status,
        CURRENT_TIMESTAMP() as dbt_updated_at
    from products p
    left join product_orders po using (product_id)
)

select * from final
