# dbt Development Workflow Guide

This document outlines the standard development workflow for collaborating on dbt projects using a zone-based data architecture.

## Development Environment Setup

### 1. Prerequisites
- Git installed
- GitHub account with repository access
- VSCode with dbt extension
- Python 3.8+ installed
- BigQuery access configured

### 2. Local Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/dbt-bq-getting-started-template.git

# Create Python virtual environment
python -m venv dbt-env
source dbt-env/bin/activate  # or `dbt-env\Scripts\activate` on Windows

# Install dependencies
pip install dbt-bigquery
pip install pre-commit

# Configure dbt profile
cp profiles.yml.example ~/.dbt/profiles.yml
# Edit profiles.yml with your BigQuery credentials
```

## Branching Strategy

### 1. Main Branches
- `main`: Production code
- `development`: Integration branch for feature testing

### 2. Feature Branches
Branch names should follow the pattern:
```
<zone>/<type>/<description>
```

Examples:
- `raw/feature/add-stripe-events`
- `prepared/fix/customer-profile-dedup`
- `curated/enhance/marketing-360-view`

### 3. Zone-Based Development
Each data zone has specific development guidelines:

#### RAW Zone
- Minimal transformations
- Focus on data quality
- Branch example: `raw/feature/add-shopify-source`

```sql
-- Example commit: Adding Shopify orders source
with source as (
    select * from {{ source('shopify', 'orders') }}
),

renamed as (
    select
        id as order_id,
        created_at,
        ...
)
```

#### PREPARED Zone
- Core business entities
- Shared metrics
- Branch example: `prepared/feature/customer-profile`

```sql
-- Example commit: Adding customer profile model
with customer_orders as (
    select
        customer_id,
        count(*) as order_count,
        sum(amount) as total_spent
    from {{ ref('raw_shopify__orders') }}
    group by 1
)
```

#### CURATED Zone
- Business-specific marts
- Reporting optimization
- Branch example: `curated/feature/marketing-dashboard`

```sql
-- Example commit: Adding marketing dashboard model
select
    date_trunc(date, month) as month,
    customer_segment,
    sum(revenue) as total_revenue,
    count(distinct customer_id) as customer_count
from {{ ref('prep_core__customer_profile') }}
group by 1, 2
```

## Development Workflow

1. **Start New Feature**
```bash
git checkout development
git pull origin development
git checkout -b <zone>/<type>/<description>
```

2. **Development Process**
- Write models following zone conventions
- Add tests and documentation
- Run local tests:
```bash
dbt debug
dbt deps
dbt build --select state:modified+
```

3. **Code Review Process**
- Create pull request to development
- Ensure CI/CD checks pass
- Get approval from data team
- Merge to development

4. **Production Deployment**
- Create release PR from development to main
- Run full test suite
- Deploy to production

## Testing Standards

### 1. RAW Zone Tests
```yaml
models:
  - name: raw_stripe__payments
    columns:
      - name: payment_id
        tests:
          - unique
          - not_null
```

### 2. PREPARED Zone Tests
```yaml
models:
  - name: prep_core__customer_profile
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
          - relationships:
              to: ref('raw_shopify__customers')
              field: customer_id
```

### 3. CURATED Zone Tests
```yaml
models:
  - name: curated_marketing__customer_360
    columns:
      - name: total_revenue
        tests:
          - not_null
          - positive_values
```

## Documentation Requirements

Each PR should include:
1. Model documentation in .yml files
2. Updated README if needed
3. Example queries for new models
4. Impact analysis for changes

## CI/CD Pipeline

1. **PR Checks**
- Linting (SQL formatting)
- Model dependency validation
- Incremental model checks
- Test coverage

2. **Deployment Stages**
- Development (automatic)
- Staging (manual approval)
- Production (manual approval)

## Best Practices

1. **Commit Messages**
```
[ZONE] Brief description

- Detailed bullet points
- Impact on downstream models
- Testing approach
```

2. **PR Description Template**
```markdown
## Changes
- List of changes

## Testing
- Test cases covered
- Performance impact

## Documentation
- Links to updated docs
- Example queries
```

3. **Code Review Checklist**
- [ ] Follows zone conventions
- [ ] Tests added
- [ ] Documentation updated
- [ ] Performance considered
- [ ] Impact analyzed
