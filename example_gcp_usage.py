"""
Example script demonstrating how to use GCP credentials
in your Data Engineering Zoomcamp projects.
"""

import os
from pathlib import Path

# Load environment variables from .env file
try:
    from dotenv import load_dotenv
    load_dotenv()
    print("✓ Loaded environment variables from .env")
except ImportError:
    print("⚠ python-dotenv not installed. Install with: pip install python-dotenv")
    print("  Continuing without .env file...")

# Get configuration from environment variables
GCP_PROJECT_ID = os.getenv('GCP_PROJECT_ID', 'your-project-id')
CREDENTIALS_PATH = os.getenv('GOOGLE_APPLICATION_CREDENTIALS', './credentials/gcp-service-account.json')

print(f"\nConfiguration:")
print(f"  Project ID: {GCP_PROJECT_ID}")
print(f"  Credentials: {CREDENTIALS_PATH}")
print(f"  Credentials exist: {Path(CREDENTIALS_PATH).exists()}")


def example_bigquery():
    """Example: Using BigQuery client with credentials."""
    try:
        from google.cloud import bigquery
        
        # Method 1: Using environment variable (recommended)
        # The client will automatically use GOOGLE_APPLICATION_CREDENTIALS
        client = bigquery.Client(project=GCP_PROJECT_ID)
        
        print(f"\n✓ BigQuery client created for project: {client.project}")
        
        # Example query
        query = """
            SELECT 
                name,
                SUM(number) as total
            FROM `bigquery-public-data.usa_names.usa_1910_current`
            WHERE name = 'John'
            GROUP BY name
            LIMIT 1
        """
        
        print("\nRunning sample query...")
        query_job = client.query(query)
        results = query_job.result()
        
        for row in results:
            print(f"  Name: {row.name}, Total: {row.total:,}")
        
        print("✓ BigQuery query successful!")
        return True
        
    except ImportError:
        print("\n⚠ google-cloud-bigquery not installed")
        print("  Install with: pip install google-cloud-bigquery")
        return False
    except Exception as e:
        print(f"\n✗ Error with BigQuery: {str(e)}")
        return False


def example_cloud_storage():
    """Example: Using Cloud Storage client with credentials."""
    try:
        from google.cloud import storage
        
        client = storage.Client(project=GCP_PROJECT_ID)
        print(f"\n✓ Cloud Storage client created for project: {client.project}")
        
        # List buckets
        print("\nListing first 5 buckets in your project:")
        buckets = list(client.list_buckets(max_results=5))
        
        if buckets:
            for bucket in buckets:
                print(f"  - {bucket.name}")
        else:
            print("  No buckets found or no access")
        
        print("✓ Cloud Storage access successful!")
        return True
        
    except ImportError:
        print("\n⚠ google-cloud-storage not installed")
        print("  Install with: pip install google-cloud-storage")
        return False
    except Exception as e:
        print(f"\n✗ Error with Cloud Storage: {str(e)}")
        return False


def example_explicit_credentials():
    """Example: Using explicit credentials file (alternative method)."""
    try:
        from google.oauth2 import service_account
        from google.cloud import bigquery
        
        # Method 2: Explicitly load credentials from file
        credentials = service_account.Credentials.from_service_account_file(
            CREDENTIALS_PATH,
            scopes=['https://www.googleapis.com/auth/cloud-platform']
        )
        
        client = bigquery.Client(
            credentials=credentials,
            project=GCP_PROJECT_ID
        )
        
        print(f"\n✓ BigQuery client created with explicit credentials")
        print(f"  Project: {client.project}")
        return True
        
    except FileNotFoundError:
        print(f"\n✗ Credentials file not found: {CREDENTIALS_PATH}")
        return False
    except ImportError:
        print("\n⚠ google-cloud-bigquery not installed")
        return False
    except Exception as e:
        print(f"\n✗ Error loading credentials: {str(e)}")
        return False


if __name__ == "__main__":
    print("=" * 60)
    print("GCP Credentials Usage Examples")
    print("=" * 60)
    
    # Check if credentials file exists
    if not Path(CREDENTIALS_PATH).exists():
        print(f"\n⚠ WARNING: Credentials file not found at: {CREDENTIALS_PATH}")
        print("\nPlease follow the setup instructions in CREDENTIALS_SETUP.md")
        print("\nQuick setup:")
        print("  1. Create credentials directory: mkdir credentials")
        print("  2. Download your GCP service account JSON key")
        print("  3. Save it as: credentials/gcp-service-account.json")
        print("  4. Copy .env.example to .env and update values")
        exit(1)
    
    # Run examples
    print("\n" + "-" * 60)
    print("Example 1: BigQuery with environment variables")
    print("-" * 60)
    example_bigquery()
    
    print("\n" + "-" * 60)
    print("Example 2: Cloud Storage")
    print("-" * 60)
    example_cloud_storage()
    
    print("\n" + "-" * 60)
    print("Example 3: Explicit credentials loading")
    print("-" * 60)
    example_explicit_credentials()
    
    print("\n" + "=" * 60)
    print("Examples completed!")
    print("=" * 60)
