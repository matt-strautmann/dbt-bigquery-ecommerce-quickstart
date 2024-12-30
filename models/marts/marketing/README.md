# Marketing Analytics Models

This directory contains models specifically designed for marketing analytics using Shopify data.

## Models Overview

### 1. Customer Analytics (mart_customer_analytics)
Provides a comprehensive view of customer behavior and value:
- Customer demographics and contact info
- Purchase history and lifetime value
- Product preferences
- Segmentation by value and engagement

Key metrics:
- Total orders and revenue
- Customer lifetime
- Product categories purchased
- Value segmentation (High/Medium/Low)
- Engagement status (Active/At Risk/Churned)

### 2. Product Analytics (mart_product_analytics)
Analyzes product performance and trends:
- Product details and categorization
- Sales metrics
- Performance indicators
- Status tracking

Key metrics:
- Total orders and units sold
- Revenue metrics
- Average order value
- Product status (Active/Slowing/Inactive)

## Usage Examples

### Customer Segmentation Query
```sql
select
    value_segment,
    engagement_segment,
    count(*) as customer_count,
    sum(total_revenue) as segment_revenue
from {{ ref('mart_customer_analytics') }}
group by 1, 2
order by 4 desc
```

### Product Performance Query
```sql
select
    product_type,
    revenue_category,
    count(*) as product_count,
    sum(total_revenue) as category_revenue,
    avg(average_order_value) as avg_order_value
from {{ ref('mart_product_analytics') }}
group by 1, 2
order by 4 desc
```

## Data Freshness
- Models are refreshed daily
- Customer segments are calculated based on 30/90 day windows
- Revenue categories are updated with each refresh

## Dependencies
- Requires Shopify source data
- Uses base and staging models from stg_shopify
