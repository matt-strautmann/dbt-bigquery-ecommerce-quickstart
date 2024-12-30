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

customer_first_order as (
    select
        customer_id,
        min(created_at) as first_order_date
    from orders
    group by 1
),

cohort_orders as (
    select
        date_trunc(cfo.first_order_date, MONTH) as cohort_month,
        date_diff(date_trunc(o.created_at, MONTH), 
                 date_trunc(cfo.first_order_date, MONTH), MONTH) as months_since_first_order,
        count(distinct o.customer_id) as active_customers,
        sum(o.total_price) as cohort_revenue,
        count(distinct o.order_id) as cohort_orders
    from orders o
    join customer_first_order cfo using (customer_id)
    group by 1, 2
),

cohort_size as (
    select
        date_trunc(first_order_date, MONTH) as cohort_month,
        count(distinct customer_id) as cohort_customers
    from customer_first_order
    group by 1
),

final as (
    select
        co.cohort_month,
        cs.cohort_customers,
        co.months_since_first_order,
        co.active_customers,
        co.cohort_revenue,
        co.cohort_orders,
        safe_divide(co.active_customers, cs.cohort_customers) as retention_rate,
        safe_divide(co.cohort_revenue, cs.cohort_customers) as revenue_per_cohort_customer,
        safe_divide(co.cohort_orders, co.active_customers) as orders_per_active_customer,
        CURRENT_TIMESTAMP() as dbt_updated_at
    from cohort_orders co
    join cohort_size cs using (cohort_month)
)

select * from final
