with customer_orders as (
    select
        customer_id,
        count(*) as total_orders,
        sum(amount) as total_revenue,
        min(created_at) as first_order_date,
        max(created_at) as last_order_date
    from {{ ref('stg_shopify__orders') }}
    group by 1
),

customer_metrics as (
    select
        customer_id,
        total_orders,
        total_revenue,
        first_order_date,
        last_order_date,
        -- Calculate customer lifetime in days
        date_diff(last_order_date, first_order_date, day) as customer_lifetime_days,
        -- Calculate average order value
        total_revenue / nullif(total_orders, 0) as avg_order_value
    from customer_orders
)

select
    -- Customer dimensions
    c.customer_id,
    c.email,
    c.first_name,
    c.last_name,
    c.created_at as customer_created_at,
    
    -- Order metrics
    coalesce(m.total_orders, 0) as total_orders,
    coalesce(m.total_revenue, 0) as total_revenue,
    m.first_order_date,
    m.last_order_date,
    m.customer_lifetime_days,
    m.avg_order_value,
    
    -- Customer segments
    case
        when m.total_orders >= 5 then 'High Value'
        when m.total_orders >= 2 then 'Medium Value'
        else 'Low Value'
    end as value_segment,
    
    case
        when date_diff(current_date, m.last_order_date, day) <= 90 then 'Active'
        when date_diff(current_date, m.last_order_date, day) <= 180 then 'At Risk'
        else 'Churned'
    end as engagement_segment

from {{ ref('stg_shopify__customers') }} c
left join customer_metrics m using (customer_id)
