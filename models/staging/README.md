# Staging Models Guide

## Overview
The staging layer is your first transformation layer, responsible for cleaning and standardizing raw data from your sources. This is where we:
1. Clean and standardize column names
2. Cast data types appropriately
3. Handle NULL values
4. Apply basic data quality tests

## Structure

```
staging/
├── stg_stripe/           # Payment processing data
│   ├── base/            # Raw JSON parsing
│   │   └── *.sql       # One file per raw table
│   ├── stg_*.sql       # Cleaned staging models
│   └── _stripe__sources.yml
│
├── stg_hubspot/         # Marketing automation data
└── stg_shopify/         # E-commerce platform data
```

## Naming Conventions

1. **Base Models**: `base_{source}__{entity}.sql`
   - Example: `base_stripe__customers.sql`
   - Purpose: Initial JSON parsing and type casting

2. **Staging Models**: `stg_{source}__{entity}.sql`
   - Example: `stg_stripe__customers.sql`
   - Purpose: Clean, standardized data ready for use

## Common Patterns

### 1. Base Model Example
```sql
-- base_stripe__customers.sql
select
    id as customer_id,
    email,
    created as created_at,
    ... other fields
from {{ source('stripe', 'customers') }}
```

### 2. Staging Model Example
```sql
-- stg_stripe__customers.sql
select
    customer_id,
    lower(trim(email)) as email_address,
    date(created_at) as created_date,
    ... standardized fields
from {{ ref('base_stripe__customers') }}
```

## Best Practices

1. **Keep It Simple**
   - Staging models should do basic cleaning only
   - Save complex business logic for intermediate models

2. **Consistent Naming**
   - Use snake_case for all column names
   - Prefix date fields with `date_` or `timestamp_`
   - Suffix IDs with `_id`

3. **Testing**
   - Every primary key should have unique + not_null tests
   - Add accepted_values tests for status fields
   - Document assumptions in schema tests

## Common dbt Patterns Used

1. **Source Freshness**
   ```yaml
   sources:
     - name: stripe
       freshness:
         warn_after: {count: 12, period: hour}
         error_after: {count: 24, period: hour}
   ```

2. **Column-level Tests**
   ```yaml
   columns:
     - name: customer_id
       tests:
         - unique
         - not_null
   ```

3. **Custom Data Tests**
   ```sql
   -- tests/assert_positive_amounts.sql
   select *
   from {{ ref('stg_stripe__payments' )}}
   where amount_cents <= 0
   ```
