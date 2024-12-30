with product_orders as (
    select
        product_id,
        count(distinct order_id) as order_count,
        count(distinct customer_id) as customer_count,
        sum(quantity) as total_units_sold,
        sum(price * quantity) as total_revenue,
        max(created_at) as last_ordered_at
    from {{ ref('stg_shopify__order_items') }}
    group by 1
),

product_returns as (
    select
        product_id,
        count(*) as return_count,
        sum(quantity) as returned_units
    from {{ ref('stg_shopify__returns') }}
    group by 1
),

product_metrics as (
    select
        p.product_id,
        o.order_count,
        o.customer_count,
        o.total_units_sold,
        o.total_revenue,
        coalesce(r.return_count, 0) as return_count,
        coalesce(r.returned_units, 0) as returned_units,
        -- Calculate return rate
        safe_divide(coalesce(r.returned_units, 0), o.total_units_sold) as return_rate,
        -- Calculate average order value
        safe_divide(o.total_revenue, o.order_count) as avg_order_value,
        -- Days since last order
        date_diff(current_date, date(o.last_ordered_at), day) as days_since_last_order
    from {{ ref('stg_shopify__products') }} p
    left join product_orders o using (product_id)
    left join product_returns r using (product_id)
)

select
    -- Product dimensions
    p.product_id,
    p.product_name,
    p.product_type,
    p.category,
    p.brand,
    p.created_at as product_created_at,
    p.retail_price,
    p.wholesale_price,
    
    -- Inventory
    i.quantity_on_hand,
    i.reorder_point,
    i.supplier_id,
    
    -- Sales metrics
    coalesce(m.order_count, 0) as total_orders,
    coalesce(m.customer_count, 0) as total_customers,
    coalesce(m.total_units_sold, 0) as total_units_sold,
    coalesce(m.total_revenue, 0) as total_revenue,
    coalesce(m.return_count, 0) as total_returns,
    coalesce(m.return_rate, 0) as return_rate,
    m.avg_order_value,
    
    -- Product status
    case
        when m.days_since_last_order <= 30 then 'Active'
        when m.days_since_last_order <= 90 then 'Slowing'
        else 'Inactive'
    end as product_status,
    
    -- Profitability
    p.retail_price - p.wholesale_price as unit_margin,
    (p.retail_price - p.wholesale_price) * coalesce(m.total_units_sold, 0) as total_margin,
    
    -- Performance segment
    case
        when m.total_revenue > 10000 then 'High Performance'
        when m.total_revenue > 5000 then 'Medium Performance'
        else 'Low Performance'
    end as performance_segment

from {{ ref('stg_shopify__products') }} p
left join {{ ref('stg_shopify__inventory') }} i using (product_id)
left join product_metrics m using (product_id)
