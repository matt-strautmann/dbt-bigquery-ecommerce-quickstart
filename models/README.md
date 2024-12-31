# Data Modeling Guide

This dbt project follows a three-zone data architecture designed for clarity, performance, and maintainability.

## 📊 Project Architecture

```mermaid
graph TD
    subgraph Sources
        S1[Stripe Data]
        S2[Shopify Data]
        S3[Hubspot Data]
    end

    subgraph Staging[Staging Layer]
        ST1[stg_stripe__*]
        ST2[stg_shopify__*]
        ST3[stg_hubspot__*]
    end

    subgraph Core[Core Layer]
        C1[core__customer_profile]
        C2[core__product_catalog]
        C3[core__order_history]
    end

    subgraph Marts[Marts Layer]
        M1[mart_finance__*]
        M2[mart_marketing__*]
        M3[mart_sales__*]
    end

    S1 --> ST1
    S2 --> ST2
    S3 --> ST3

    ST1 --> C1
    ST2 --> C2
    ST2 --> C3
    ST1 --> C3

    C1 --> M1
    C1 --> M2
    C2 --> M2
    C2 --> M3
    C3 --> M1
    C3 --> M3

    style Sources fill:#f9f,stroke:#333,stroke-width:2px
    style Staging fill:#bbf,stroke:#333,stroke-width:2px
    style Core fill:#bfb,stroke:#333,stroke-width:2px
    style Marts fill:#ffb,stroke:#333,stroke-width:2px
```

## 📁 Project Structure

```mermaid
graph TD
    subgraph models
        A[models/]
        B[staging/]
        C[core/]
        D[marts/]
        
        subgraph staging
            B1[stripe/]
            B2[shopify/]
            B3[hubspot/]
        end
        
        subgraph core
            C1[customers/]
            C2[products/]
            C3[orders/]
        end
        
        subgraph marts
            D1[finance/]
            D2[marketing/]
            D3[sales/]
        end
        
        A --> B
        A --> C
        A --> D
        
        B --> B1
        B --> B2
        B --> B3
        
        C --> C1
        C --> C2
        C --> C3
        
        D --> D1
        D --> D2
        D --> D3
    end

    style A fill:#f9f,stroke:#333,stroke-width:2px
    style B fill:#bbf,stroke:#333,stroke-width:2px
    style C fill:#bfb,stroke:#333,stroke-width:2px
    style D fill:#ffb,stroke:#333,stroke-width:2px
```

## 🔄 Data Flow and Zone Concepts

### 1. Staging Models (RAW Zone)
```mermaid
graph LR
    A[Source Data] -->|Extract| B[Raw JSON]
    B -->|Parse| C[Typed Columns]
    C -->|Clean| D[Staging Model]
    
    style A fill:#f9f,stroke:#333,stroke-width:2px
    style B fill:#bbf,stroke:#333,stroke-width:2px
    style C fill:#bfb,stroke:#333,stroke-width:2px
    style D fill:#ffb,stroke:#333,stroke-width:2px
```

- **Purpose**: Initial data landing and basic cleanup
- **Naming**: `stg_<source>__<entity>`
- **Examples**: 
  - `stg_stripe__customers`
  - `stg_shopify__orders`
- **Properties**:
  - Minimal transformations
  - Source data grain
  - Basic cleaning and typing
  - Views for most tables
  - Incremental for event data

### 2. Core Models (PREPARED Zone)
```mermaid
graph LR
    A[Staging Models] -->|Join| B[Entity Tables]
    B -->|Aggregate| C[Metrics]
    C -->|Enrich| D[Core Model]
    
    style A fill:#f9f,stroke:#333,stroke-width:2px
    style B fill:#bbf,stroke:#333,stroke-width:2px
    style C fill:#bfb,stroke:#333,stroke-width:2px
    style D fill:#ffb,stroke:#333,stroke-width:2px
```

- **Purpose**: Core business entities and metrics
- **Naming**: `core__<entity>_<description>`
- **Examples**:
  - `core__customer_profile`
  - `core__order_metrics`
- **Properties**:
  - Business entity focused
  - Shared metrics
  - Incremental where possible
  - Well-documented business rules

### 3. Mart Models (CURATED Zone)
```mermaid
graph LR
    A[Core Models] -->|Transform| B[Domain Tables]
    B -->|Optimize| C[Analytics]
    C -->|Deliver| D[BI Tools]
    
    style A fill:#f9f,stroke:#333,stroke-width:2px
    style B fill:#bbf,stroke:#333,stroke-width:2px
    style C fill:#bfb,stroke:#333,stroke-width:2px
    style D fill:#ffb,stroke:#333,stroke-width:2px
```

- **Purpose**: Business-specific analytics
- **Naming**: `mart_<domain>__<description>`
- **Examples**:
  - `mart_finance__revenue_analysis`
  - `mart_marketing__customer_360`
- **Properties**:
  - Always materialized as tables
  - Optimized for BI tools
  - Domain-specific metrics
  - Often denormalized

## 📝 Model Development Guidelines

### 1. Staging Models
```sql
-- Example: stg_stripe__customers.sql
with source as (
    select * from {{ source('stripe', 'customers') }}
),
renamed as (
    select
        id as customer_id,
        email,
        created as created_at
    from source
)
select * from renamed
```

### 2. Core Models
```sql
-- Example: core__customer_profile.sql
with customer_orders as (
    select
        customer_id,
        count(*) as order_count,
        sum(amount) as total_spent
    from {{ ref('stg_shopify__orders') }}
    group by 1
)
select
    c.customer_id,
    c.email,
    o.order_count,
    o.total_spent
from {{ ref('stg_shopify__customers') }} c
left join customer_orders o using (customer_id)
```

### 3. Mart Models
```sql
-- Example: mart_marketing__customer_360.sql
select
    c.customer_id,
    c.email,
    c.customer_segment,
    o.total_orders,
    o.total_revenue,
    m.campaign_response_rate
from {{ ref('core__customer_profile') }} c
left join {{ ref('core__order_metrics') }} o using (customer_id)
left join {{ ref('core__marketing_metrics') }} m using (customer_id)
```

## 🔍 Testing Strategy

```mermaid
graph TD
    subgraph Staging Tests
        ST1[Unique Keys]
        ST2[Not Null]
        ST3[Accepted Values]
    end
    
    subgraph Core Tests
        CT1[Relationships]
        CT2[Business Rules]
        CT3[Data Quality]
    end
    
    subgraph Mart Tests
        MT1[Reconciliation]
        MT2[Performance]
        MT3[Consistency]
    end
    
    ST1 --> CT1
    ST2 --> CT2
    ST3 --> CT3
    
    CT1 --> MT1
    CT2 --> MT2
    CT3 --> MT3
    
    style Staging Tests fill:#bbf,stroke:#333,stroke-width:2px
    style Core Tests fill:#bfb,stroke:#333,stroke-width:2px
    style Mart Tests fill:#ffb,stroke:#333,stroke-width:2px
```

### 1. Staging Tests
```yaml
# staging/stripe/_stripe__models.yml
models:
  - name: stg_stripe__customers
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
```

### 2. Core Tests
```yaml
# core/customers/_customers__models.yml
models:
  - name: core__customer_profile
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
          - relationships:
              to: ref('stg_stripe__customers')
              field: customer_id
```

### 3. Mart Tests
```yaml
# marts/marketing/_marketing__models.yml
models:
  - name: mart_marketing__customer_360
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
      - name: total_revenue
        tests:
          - not_null
          - positive_values
```

## 🚀 Performance Optimization

```mermaid
graph TD
    subgraph Staging Optimization
        SO1[Views]
        SO2[Incremental]
        SO3[Partitioning]
    end
    
    subgraph Core Optimization
        CO1[Incremental]
        CO2[Clustering]
        CO3[Materialization]
    end
    
    subgraph Mart Optimization
        MO1[Tables]
        MO2[Pre-aggregation]
        MO3[Partitioning]
    end
    
    SO1 --> CO1
    SO2 --> CO2
    SO3 --> CO3
    
    CO1 --> MO1
    CO2 --> MO2
    CO3 --> MO3
    
    style Staging Optimization fill:#bbf,stroke:#333,stroke-width:2px
    style Core Optimization fill:#bfb,stroke:#333,stroke-width:2px
    style Mart Optimization fill:#ffb,stroke:#333,stroke-width:2px
```

### 1. Staging Layer
- Use views for reference data
- Incremental models for event data
- Partition by ingestion date

### 2. Core Layer
- Incremental processing where possible
- Partition by business dates
- Cluster by common join keys

### 3. Mart Layer
- Always use table materialization
- Partition by analysis dates
- Cluster by common filters
- Pre-aggregate where possible
