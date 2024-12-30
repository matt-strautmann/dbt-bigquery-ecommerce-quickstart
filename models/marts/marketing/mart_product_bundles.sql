{{ config(
    materialized = 'table',
    schema = 'marts_marketing'
) }}

with orders as (
    select * from {{ ref('stg_shopify__orders') }}
),

products as (
    select * from {{ ref('base_shopify__products') }}
),

order_products as (
    select
        o.order_id,
        array_agg(cast(items.product_id as int64)) as product_ids,
        array_agg(p.product_name) as product_names,
        count(distinct cast(items.product_id as int64)) as unique_products,
        sum(items.quantity * items.price) as bundle_revenue
    from orders o,
    unnest(o.line_items) as items
    left join products p on cast(items.product_id as int64) = p.product_id
    group by 1
    having count(distinct cast(items.product_id as int64)) > 1
),

product_pairs as (
    select
        p1.product_id as product_1_id,
        p1.product_name as product_1_name,
        p2.product_id as product_2_id,
        p2.product_name as product_2_name,
        count(*) as times_bought_together,
        avg(op.bundle_revenue) as avg_bundle_revenue
    from order_products op
    cross join unnest(op.product_ids) as product_id_1
    cross join unnest(op.product_ids) as product_id_2
    join products p1 on product_id_1 = p1.product_id
    join products p2 on product_id_2 = p2.product_id
    where product_id_1 < product_id_2
    group by 1, 2, 3, 4
    having count(*) > 1
),

final as (
    select
        product_1_id,
        product_1_name,
        product_2_id,
        product_2_name,
        times_bought_together,
        avg_bundle_revenue,
        -- Bundle strength metrics
        safe_divide(times_bought_together, 
            (select count(distinct order_id) from orders)) as bundle_frequency,
        case
            when times_bought_together >= 10 then 'Strong Bundle'
            when times_bought_together >= 5 then 'Medium Bundle'
            else 'Weak Bundle'
        end as bundle_strength,
        CURRENT_TIMESTAMP() as dbt_updated_at
    from product_pairs
    order by times_bought_together desc
)

select * from final
