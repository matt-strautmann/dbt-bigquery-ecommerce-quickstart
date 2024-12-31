# 🚀 Getting Started with dbt and Airbyte

Welcome to your modern data stack template! This project demonstrates how to build a scalable data warehouse using:
- **Airbyte** for data ingestion
- **dbt** for transformation
- **BigQuery** for storage and computing

## Prerequisites

1. **VSCode** installed ([Download here](https://code.visualstudio.com/download))
2. **Turntable.so extension** installed in VSCode ([Install here](https://marketplace.visualstudio.com/items?itemName=Turntable.turntable))
3. **Python** installed (3.8 or higher)
4. **Google Cloud account** with BigQuery enabled
5. **Airbyte** instance set up with sources configured

## 🏗️ Project Structure

```
models/
├── staging/              # Raw data standardization
│   ├── stg_stripe/      # Payment processing
│   │   ├── base/        # Raw JSON parsing
│   │   │   └── base_stripe__customers.sql
│   │   ├── stg_stripe__customers.sql
│   │   └── _stripe_sources.yml
│   │
│   ├── stg_hubspot/     # Marketing automation
│   │   ├── base/
│   │   └── _hubspot_sources.yml
│   │
│   └── stg_shopify/     # E-commerce platform
│       ├── base/
│       └── _shopify_sources.yml
│
├── intermediate/         # Business logic layer
│   ├── finance/
│   ├── marketing/
│   └── sales/
│
└── marts/               # Business-specific models
    ├── core/            # Core business entities
    ├── finance/         # Finance-specific models
    ├── marketing/       # Marketing-specific models
    └── sales/          # Sales-specific models
```

## 🔄 Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/dbt_bq_getting_started_template.git
   cd dbt_bq_getting_started_template
   ```

2. **Set Up Environment Variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your configurations
   ```

3. **Configure dbt Profile**:
   ```bash
   cp profiles.yml.example ~/.dbt/profiles.yml
   # Edit profiles.yml with your BigQuery details
   ```

4. **Install Dependencies**:
   ```bash
   pip install dbt-core dbt-bigquery
   dbt deps
   ```

## 🔌 Airbyte Integration

This template is designed to work with Airbyte's BigQuery destination. Key points:

1. **Raw Data Structure**:
   - Airbyte creates tables with prefix `_airbyte_raw_`
   - Data is stored in JSON format in `_airbyte_data` column
   - Each record has `_airbyte_emitted_at` timestamp

2. **Base Models**:
   ```sql
   -- Example: models/staging/stg_stripe/base/base_stripe__customers.sql
   select 
       JSON_EXTRACT_SCALAR(_airbyte_data, '$.id') as customer_id,
       JSON_EXTRACT_SCALAR(_airbyte_data, '$.email') as email,
       _airbyte_emitted_at as ingested_at
   from {{ source('stripe', '_airbyte_raw_customers') }}
   ```

3. **Source Configuration**:
   ```yaml
   # Example: models/staging/stg_stripe/_stripe_sources.yml
   version: 2
   sources:
     - name: stripe
       database: "{{ env_var('DBT_PROJECT_ID') }}"
       schema: "{{ env_var('AIRBYTE_SCHEMA', 'raw') }}"
       loader: airbyte
       loaded_at_field: _airbyte_emitted_at
       tables:
         - name: _airbyte_raw_customers
   ```

## 🏭 Development Workflow

1. **Set Up Airbyte Source**:
   - Configure source in Airbyte UI
   - Set destination to BigQuery
   - Note the destination schema

2. **Update Environment Variables**:
   ```bash
   DBT_PROJECT_ID=your-project-id
   AIRBYTE_SCHEMA=raw
   DBT_STAGING_SCHEMA=staging
   ```

3. **Create Base Models**:
   - Parse JSON data from Airbyte
   - Use `JSON_EXTRACT_SCALAR` for BigQuery
   - Add basic data type conversions

4. **Create Staging Models**:
   - Add business logic and cleaning
   - Implement standard naming
   - Add data quality tests

5. **Build Marts**:
   - Combine data from multiple sources
   - Create business-specific views
   - Optimize for analysis

## 📊 Data Quality

1. **Source Freshness**:
   ```yaml
   sources:
     - name: stripe
       freshness:
         warn_after: {count: 12, period: hour}
         error_after: {count: 24, period: hour}
   ```

2. **Data Tests**:
   ```yaml
   models:
     - name: stg_stripe__customers
       columns:
         - name: customer_id
           tests:
             - unique
             - not_null
   ```

## 🔍 Monitoring

1. **Airbyte Sync Status**:
   - Check Airbyte UI for sync status
   - Monitor `_airbyte_emitted_at` for freshness

2. **dbt Run Status**:
   - Use `dbt source freshness`
   - Check model test results

## 📚 Learning Resources

1. **Airbyte Resources**:
   - [Airbyte Docs](https://docs.airbyte.io/)
   - [BigQuery Setup Guide](https://docs.airbyte.io/integrations/destinations/bigquery)

2. **dbt Resources**:
   - [dbt Docs](https://docs.getdbt.com/)
   - [BigQuery Specific Guides](https://docs.getdbt.com/reference/resource-configs/bigquery-configs)

3. **Community**:
   - [dbt Slack](https://community.getdbt.com/)
   - [Airbyte Slack](https://slack.airbyte.io/)

## 🆘 Need Help?

1. Check error messages in Turntable.so
2. Review Airbyte logs for sync issues
3. Visit [dbt Discourse](https://discourse.getdbt.com/)
4. Create an issue in this repository

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

MIT License - see [LICENSE](LICENSE) file

## BigQuery Setup Guide

For detailed instructions on setting up your BigQuery connection, including OAuth authentication and testing, see our [BigQuery Setup Guide](docs/bigquery_setup.md).
