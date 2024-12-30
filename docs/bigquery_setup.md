# BigQuery Connection Setup Guide

This guide will help you set up and test your BigQuery connection for dbt using OAuth authentication.

## Prerequisites

1. **Google Cloud Platform Account**
   - Active GCP account with billing enabled
   - BigQuery API enabled
   - Appropriate IAM permissions

2. **Local Environment**
   - Python 3.7 or higher
   - dbt-bigquery package installed
   - Google Cloud SDK installed

## Setup Steps

### 1. Install Required Packages

```bash
# Create and activate a virtual environment
python -m venv dbt-env
source dbt-env/bin/activate  # For Unix/Mac
# OR
.\dbt-env\Scripts\activate  # For Windows

# Install dbt with BigQuery adapter
pip install dbt-bigquery
```

### 2. Configure Google Cloud SDK

```bash
# Install Google Cloud SDK (if not already installed)
# For Mac with Homebrew:
brew install google-cloud-sdk

# Initialize Google Cloud SDK
gcloud init

# Authenticate with your Google account
gcloud auth application-default login
```

### 3. Set Up Environment Variables

Create a `.env` file in your project root:

```bash
# BigQuery Connection
export DBT_PROJECT_ID='your-project-id'
export DBT_DEV_DATASET='dbt_dev'
export DBT_PROD_DATASET='dbt_prod'

# Optional: Additional Configuration
export DBT_EXECUTION_PROJECT='your-execution-project'
export DBT_IMPERSONATE_SA='your-service-account@project.iam.gserviceaccount.com'
```

Source the environment variables:
```bash
source .env  # For Unix/Mac
# OR
set -a; source .env; set +a  # For Windows
```

### 4. Configure dbt Profile

1. Copy the example profile:
```bash
mkdir -p ~/.dbt
cp profiles.yml.example ~/.dbt/profiles.yml
```

2. Update the profile with your specific values:
   - Update project ID
   - Set appropriate dataset names
   - Configure thread count based on your needs

## Testing the Connection

### 1. Basic Connection Test

```bash
# Test the connection
dbt debug

# Expected output:
# Connection test: OK
```

### 2. Verify Project Access

```bash
# List all relations in your dataset
dbt ls

# Run a simple dbt operation
dbt run --models example
```

### 3. Common Issues and Solutions

1. **Authentication Errors**
   ```
   Error: Could not authenticate with BigQuery
   ```
   Solution:
   ```bash
   # Re-authenticate with Google Cloud
   gcloud auth application-default login
   ```

2. **Permission Issues**
   ```
   Error: Permission denied while executing query
   ```
   Solution:
   - Verify IAM roles (minimum required: BigQuery Data Editor)
   - Check project and dataset permissions

3. **Dataset Not Found**
   ```
   Error: Dataset not found
   ```
   Solution:
   ```bash
   # Create the dataset if it doesn't exist
   bq mk --dataset \
     "${DBT_PROJECT_ID}:${DBT_DEV_DATASET}"
   ```

## Required IAM Permissions

Ensure your user account has these IAM roles:

1. **BigQuery**
   - BigQuery Data Editor
   - BigQuery Job User

2. **Optional Roles**
   - BigQuery Admin (for full access)
   - Storage Object Viewer (if accessing GCS)

## Best Practices

1. **Environment Management**
   - Use separate datasets for dev/prod
   - Set appropriate query limits
   - Configure thread count based on workload

2. **Security**
   - Regularly rotate credentials
   - Use service account impersonation when possible
   - Set appropriate maximum_bytes_billed

3. **Performance**
   - Adjust thread count based on workload
   - Set appropriate timeouts
   - Use query priority wisely

## Troubleshooting

### Debug Mode
Run dbt in debug mode for detailed information:
```bash
dbt debug --debug
```

### Profile Validation
Verify your profile configuration:
```bash
dbt debug --config-dir
```

### Connection Test
Test specific model compilation:
```bash
dbt compile --models example
```

## Additional Resources

1. [dbt BigQuery Documentation](https://docs.getdbt.com/reference/warehouse-profiles/bigquery-profile)
2. [Google Cloud Authentication Guide](https://cloud.google.com/docs/authentication/getting-started)
3. [BigQuery Best Practices](https://cloud.google.com/bigquery/docs/best-practices-performance-overview)
