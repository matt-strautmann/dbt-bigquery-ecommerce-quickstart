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

- **Purpose**: Core business entit