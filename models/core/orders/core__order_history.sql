with order_items as (
    select
        order_id,
        count(*) as item_count,
        sum(quantity) as total_units,
        sum(price * quantity) as items_subtotal,
        array_agg(struct(
            product_id,
            quantity,
            price,
            price * quantity as line_total
        )) as line_items
    from {{ ref('stg_shopify__order_items') }}
    group by 1
),

order_payments as (
    select
        order_id,
        sum(amount) as total_paid,
        array_agg(struct(
            payment_id,
            payment_method,
            amount,
            status
        )) as payments
    from {{ ref('stg_shopify__payments') }}
    where status = 'success'
    group by 1
),

order_shipments as (
    select
        order_id,
        count(*) as shipment_count,
        min(shipped_at) as first_shipped_at,
        max(shipped_at) as last_shipped_at,
        array_agg(struct(
            shipment_id,
            tracking_number,
            carrier,
            shipped_at
        )) as shipments
    from {{ ref('stg_shopify__shipments') }}
    group by 1
),

order_discounts as (
    select
        order_id,
        sum(amount) as total_discounts,
        array_agg(struct(
            discount_id,
            code,
            amount,
            type
        )) as discounts
    from {{ ref('stg_shopify__discounts') }}
    group by 1
)

select
    -- Order dimensions
    o.order_id,
    o.customer_id,
    o.order_number,
    o.created_at as order_created_at,
    o.status as order_status,
    
    -- Customer information
    c.email as customer_email,
    c.first_name as customer_first_name,
    c.last_name as customer_last_name,
    
    -- Order items
    i.item_count,
    i.total_units,
    i.items_subtotal,
    i.line_items,
    
    -- Payments
    p.total_paid,
    p.payments,
    
    -- Shipping
    s.shipment_count,
    s.first_shipped_at,
    s.last_shipped_at,
    s.shipments,
    
    -- Discounts
    coalesce(d.total_discounts, 0) as total_discounts,
    d.discounts,
    
    -- Order totals
    i.items_subtotal as subtotal,
    coalesce(d.total_discounts, 0) as discount_amount,
    o.shipping_amount,
    o.tax_amount,
    o.total_amount,
    
    -- Fulfillment metrics
    timestamp_diff(
        coalesce(s.first_shipped_at, current_timestamp()),
        o.created_at,
        hour
    ) as hours_to_first_shipment,
    
    -- Order type
    case
        when i.item_count = 1 then 'Single Item'
        else 'Multi Item'
    end as order_type,
    
    -- Order size segment
    case
        when total_amount >= 100 then 'Large Order'
        when total_amount >= 50 then 'Medium Order'
        else 'Small Order'
    end as order_size_segment

from {{ ref('stg_shopify__orders') }} o
left join {{ ref('stg_shopify__customers') }} c using (customer_id)
left join order_items i using (order_id)
left join order_payments p using (order_id)
left join order_shipments s using (order_id)
left join order_discounts d using (order_id)
