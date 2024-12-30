# Core Models

This directory contains core business entities and metrics that are standardized across the organization. These models serve as the foundation for downstream analysis and represent our single source of truth for key business concepts.

## 🏗️ Architecture

```mermaid
graph TD
    subgraph Staging Sources
        S1[stg_shopify__customers]
        S2[stg_shopify__orders]
        S3[stg_shopify__products]
        S4[stg_stripe__payments]
    end

    subgraph Core Models
        C1[core__customer_profile]
        C2[core__product_catalog]
        C3[core__order_history]
    end

    subgraph Downstream Marts
        M1[mart_finance__*]
        M2[mart_marketing__*]
        M3[mart_sales__*]
    end

    S1 --> C1
    S2 --> C1
    S2 --> C3
    S3 --> C2
    S4 --> C3

    C1 --> M1
    C1 --> M2
    C2 --> M2
    C2 --> M3
    C3 --> M1
    C3 --> M3

    style Staging Sources fill:#bbf,stroke:#333,stroke-width:2px
    style Core Models fill:#bfb,stroke:#333,stroke-width:2px
    style Downstream Marts fill:#ffb,stroke:#333,stroke-width:2px
```

## 📁 Structure

```mermaid
graph TD
    subgraph Core Layer
        A[core/]
        
        subgraph Customers Domain
            B1[customers/]
            B2[core__customer_profile.sql]
            B3[_customers__models.yml]
        end
        
        subgraph Products Domain
            C1[products/]
            C2[core__product_catalog.sql]
            C3[_products__models.yml]
        end
        
        subgraph Orders Domain
            D1[orders/]
            D2[core__order_history.sql]
            D3[_orders__models.yml]
        end
        
        A --> B1
        A --> C1
        A --> D1
        
        B1 --> B2
        B1 --> B3
        
        C1 --> C2
        C1 --> C3
        
        D1 --> D2
        D1 --> D3
    end

    style Core Layer fill:#bfb,stroke:#333,stroke-width:2px
```

## 🔄 Data Flow

```mermaid
graph LR
    subgraph Input
        A1[Raw Data]
        A2[Staging Models]
    end

    subgraph Processing
        B1[Entity Resolution]
        B2[Metric Calculation]
        B3[Business Rules]
    end

    subgraph Output
        C1[Core Entities]
        C2[Standard Metrics]
        C3[Business Logic]
    end

    A1 --> A2
    A2 --> B1
    B1 --> B2
    B2 --> B3
    B3 --> C1
    B3 --> C2
    B3 --> C3

    style Input fill:#bbf,stroke:#333,stroke-width:2px
    style Processing fill:#bfb,stroke:#333,stroke-width:2px
    style Output fill:#ffb,stroke:#333,stroke-width:2px
```

## 📊 Key Models

### Customer Models
```mermaid
graph TD
    subgraph Inputs
        A1[stg_shopify__customers]
        A2[stg_shopify__orders]
        A3[stg_stripe__payments]
    end

    subgraph core__customer_profile
        B1[Customer Details]
        B2[Order History]
        B3[Payment History]
        B4[Customer Segments]
    end

    A1 --> B1
    A2 --> B2
    A3 --> B3
    B1 --> B4
    B2 --> B4
    B3 --> B4

    style Inputs fill:#bbf,stroke:#333,stroke-width:2px
    style core__customer_profile fill:#bfb,stroke:#333,stroke-width:2px
```

### Product Models
```mermaid
graph TD
    subgraph Inputs
        A1[stg_shopify__products]
        A2[stg_shopify__inventory]
        A3[stg_shopify__order_items]
    end

    subgraph core__product_catalog
        B1[Product Details]
        B2[Inventory Status]
        B3[Sales Metrics]
        B4[Performance Segments]
    end

    A1 --> B1
    A2 --> B2
    A3 --> B3
    B1 --> B4
    B2 --> B4
    B3 --> B4

    style Inputs fill:#bbf,stroke:#333,stroke-width:2px
    style core__product_catalog fill:#bfb,stroke:#333,stroke-width:2px
```

### Order Models
```mermaid
graph TD
    subgraph Inputs
        A1[stg_shopify__orders]
        A2[stg_stripe__payments]
        A3[stg_shopify__shipments]
    end

    subgraph core__order_history
        B1[Order Details]
        B2[Payment Status]
        B3[Fulfillment Status]
        B4[Order Metrics]
    end

    A1 --> B1
    A2 --> B2
    A3 --> B3
    B1 --> B4
    B2 --> B4
    B3 --> B4

    style Inputs fill:#bbf,stroke:#333,stroke-width:2px
    style core__order_history fill:#bfb,stroke:#333,stroke-width:2px
```

## 🧪 Testing Strategy

```mermaid
graph TD
    subgraph Data Quality
        T1[Primary Keys]
        T2[Foreign Keys]
        T3[Not Null Fields]
    end

    subgraph Business Rules
        B1[Value Ranges]
        B2[Calculations]
        B3[Aggregations]
    end

    subgraph Performance
        P1[Query Speed]
        P2[Resource Usage]
        P3[Scalability]
    end

    T1 --> B1
    T2 --> B2
    T3 --> B3
    B1 --> P1
    B2 --> P2
    B3 --> P3

    style Data Quality fill:#bbf,stroke:#333,stroke-width:2px
    style Business Rules fill:#bfb,stroke:#333,stroke-width:2px
    style Performance fill:#ffb,stroke:#333,stroke-width:2px
```

## 🚀 Performance Optimization

```mermaid
graph TD
    subgraph Strategy
        S1[Partitioning]
        S2[Clustering]
        S3[Materialization]
    end

    subgraph Implementation
        I1[Date-based Partitions]
        I2[Common Join Keys]
        I3[Incremental Processing]
    end

    subgraph Results
        R1[Query Performance]
        R2[Resource Efficiency]
        R3[Cost Optimization]
    end

    S1 --> I1
    S2 --> I2
    S3 --> I3
    I1 --> R1
    I2 --> R2
    I3 --> R3

    style Strategy fill:#bbf,stroke:#333,stroke-width:2px
    style Implementation fill:#bfb,stroke:#333,stroke-width:2px
    style Results fill:#ffb,stroke:#333,stroke-width:2px
```

## 📝 Development Guidelines

1. **Naming Conventions**
   - Model names: prefix with `core__`
   - Test files: prefix with `test_`
   - Documentation files: suffix with `__models.yml`

2. **Model Configuration**
   - Use incremental models where appropriate
   - Implement proper partitioning and clustering
   - Include comprehensive testing

3. **Documentation**
   - All models must have descriptions
   - Document key columns and business logic
   - Include links to relevant documentation

4. **Testing**
   - Unique and not null tests for primary keys
   - Relationship tests for foreign keys
   - Custom tests for business logic validation

## 🛠️ Common Macros

The following macros are available for use in core models:

```mermaid
graph LR
    subgraph Calculation Macros
        C1[calculate_growth_rate]
        C2[rolling_average]
    end

    subgraph Utility Macros
        U1[date_spine]
        U2[safe_divide]
    end

    subgraph Testing Macros
        T1[positive_values]
        T2[total_equals_sum]
    end

    C1 --> U1
    C2 --> U2
    U1 --> T1
    U2 --> T2

    style Calculation Macros fill:#bbf,stroke:#333,stroke-width:2px
    style Utility Macros fill:#bfb,stroke:#333,stroke-width:2px
    style Testing Macros fill:#ffb,stroke:#333,stroke-width:2px
```

## 📈 Example Usage

```sql
-- Calculate customer lifetime value
select
    customer_id,
    sum(total_amount) as lifetime_value,
    {{ calculate_growth_rate('current_month_revenue', 'previous_month_revenue') }} as revenue_growth
from {{ ref('core__order_history') }}
group by 1
```
