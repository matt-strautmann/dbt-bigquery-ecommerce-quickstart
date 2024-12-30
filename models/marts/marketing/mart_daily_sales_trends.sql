{{ config(
    materialized = 'table',
    schema = 'marts_marketing'
) }}

with orders as (
    select * from {{ ref('stg_shopify__orders') }}
),

daily_metrics as (
    select
        date(created_at) as sale_date,
        count(distinct order_id) as total_orders,
        count(distinct customer_id) as unique_customers,
        sum(total_price) as daily_revenue,
        avg(total_price) as average_order_value,
        -- Calculate new vs returning customers
        count(distinct case when customer_id in (
            select customer_id 
            from orders o2 
            where o2.created_at < orders.created_at
        ) then customer_id end) as returning_customers
    from orders
    group by 1
),

final as (
    select
        sale_date,
        total_orders,
        unique_customers,
        daily_revenue,
        average_order_value,
        returning_customers,
        unique_customers - returning_customers as new_customers,
        safe_divide(returning_customers, unique_customers) as returning_customer_rate,
        -- Rolling metrics
        avg(daily_revenue) over (
            order by sale_date
            rows between 6 preceding and current row
        ) as rolling_7_day_revenue,
        avg(total_orders) over (
            order by sale_date
            rows between 6 preceding and current row
        ) as rolling_7_day_orders,
        -- Growth metrics
        (daily_revenue - lag(daily_revenue) over (order by sale_date)) / 
            nullif(lag(daily_revenue) over (order by sale_date), 0) as revenue_growth_rate,
        CURRENT_TIMESTAMP() as dbt_updated_at
    from daily_metrics
)

select * from final
