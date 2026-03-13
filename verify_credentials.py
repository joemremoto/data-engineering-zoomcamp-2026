#!/usr/bin/env python3
"""
Verify GCP Credentials Setup
This script checks if your GCP credentials are properly configured.
"""

import os
import sys
from pathlib import Path

def check_file_exists(filepath, description):
    """Check if a file exists and print status."""
    if Path(filepath).exists():
        print(f"✓ {description} found at: {filepath}")
        return True
    else:
        print(f"✗ {description} NOT found at: {filepath}")
        return False

def check_env_var(var_name):
    """Check if environment variable is set."""
    value = os.getenv(var_name)
    if value:
        print(f"✓ Environment variable {var_name} is set to: {value}")
        return True
    else:
        print(f"✗ Environment variable {var_name} is NOT set")
        return False

def check_gitignore():
    """Check if credentials are in gitignore."""
    gitignore_path = Path(".gitignore")
    if not gitignore_path.exists():
        print("✗ .gitignore file not found")
        return False
    
    with open(gitignore_path, 'r') as f:
        content = f.read()
    
    checks = {
        "*.json": "JSON files (includes credentials)",
        ".env": ".env file",
    }
    
    all_good = True
    for pattern, description in checks.items():
        if pattern in content:
            print(f"✓ {description} is in .gitignore")
        else:
            print(f"✗ {description} is NOT in .gitignore")
            all_good = False
    
    return all_good

def test_gcp_connection():
    """Attempt to connect to GCP."""
    try:
        from google.cloud import bigquery
        from google.auth import default
        
        credentials, project = default()
        print(f"✓ GCP authentication successful!")
        print(f"  Project: {project}")
        return True
    except ImportError:
        print("⚠ google-cloud-bigquery not installed (run: pip install google-cloud-bigquery)")
        return None
    except Exception as e:
        print(f"✗ GCP authentication failed: {str(e)}")
        return False

def main():
    print("=" * 60)
    print("GCP Credentials Setup Verification")
    print("=" * 60)
    print()
    
    checks_passed = []
    
    # Check 1: Credentials directory
    print("1. Checking credentials directory...")
    creds_dir_exists = Path("credentials").exists()
    if creds_dir_exists:
        print("✓ credentials/ directory exists")
        checks_passed.append(True)
    else:
        print("✗ credentials/ directory NOT found - create it with: mkdir credentials")
        checks_passed.append(False)
    print()
    
    # Check 2: Credentials file
    print("2. Checking GCP credentials file...")
    creds_file_exists = check_file_exists(
        "credentials/gcp-service-account.json",
        "GCP service account JSON"
    )
    checks_passed.append(creds_file_exists)
    print()
    
    # Check 3: .env file
    print("3. Checking .env file...")
    env_file_exists = check_file_exists(".env", ".env configuration file")
    if not env_file_exists:
        print("  Hint: Copy .env.example to .env and fill in your values")
    checks_passed.append(env_file_exists)
    print()
    
    # Check 4: Environment variables
    print("4. Checking environment variables...")
    if env_file_exists:
        try:
            from dotenv import load_dotenv
            load_dotenv()
            print("✓ Loaded .env file")
        except ImportError:
            print("⚠ python-dotenv not installed (run: pip install python-dotenv)")
    
    env_var_exists = check_env_var("GOOGLE_APPLICATION_CREDENTIALS")
    checks_passed.append(env_var_exists)
    print()
    
    # Check 5: Gitignore
    print("5. Checking .gitignore configuration...")
    gitignore_ok = check_gitignore()
    checks_passed.append(gitignore_ok)
    print()
    
    # Check 6: GCP connection
    print("6. Testing GCP connection...")
    connection_result = test_gcp_connection()
    if connection_result is not None:
        checks_passed.append(connection_result)
    print()
    
    # Summary
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    passed = sum(1 for x in checks_passed if x)
    total = len(checks_passed)
    
    if passed == total:
        print(f"✓ All checks passed ({passed}/{total})")
        print("\n🎉 Your GCP credentials are properly configured!")
        return 0
    else:
        print(f"⚠ {passed}/{total} checks passed")
        print("\nPlease review the issues above and follow CREDENTIALS_SETUP.md")
        return 1

if __name__ == "__main__":
    sys.exit(main())
