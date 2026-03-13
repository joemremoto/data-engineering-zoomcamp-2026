# GCP Credentials Setup Guide

## Overview
This guide explains how to securely manage your GCP credentials across multiple machines (work and personal) while keeping them secret and out of version control.

## Setup Instructions

### 1. Create a Credentials Directory

Create a `credentials` folder in your project root (this is already gitignored via `*.json` in `.gitignore`):

```bash
mkdir credentials
```

### 2. Download Your GCP Service Account Key

1. Go to [GCP Console](https://console.cloud.google.com/)
2. Navigate to: **IAM & Admin** → **Service Accounts**
3. Find your service account (or create one for the zoomcamp)
4. Click on the service account → **Keys** tab → **Add Key** → **Create new key**
5. Choose **JSON** format
6. Save the downloaded file as `credentials/gcp-service-account.json`

### 3. Set Up Environment Variables

Create a `.env` file in your project root (already gitignored):

```bash
# .env file
GOOGLE_APPLICATION_CREDENTIALS=./credentials/gcp-service-account.json
GCP_PROJECT_ID=your-project-id-here
```

### 4. Securely Transfer Credentials Between Machines

Choose one of these methods:

#### Option A: Password Manager (Recommended)
- Store the JSON content in a secure password manager (1Password, Bitwarden, LastPass)
- Access from both machines and copy to the same local path
- Most secure and encrypted

#### Option B: Private Cloud Storage
- Upload to Google Drive, OneDrive, or Dropbox (in a private folder)
- Download on the other machine
- **Important**: Delete from cloud storage after setting up both machines

#### Option C: Encrypted USB Drive
- Copy the credential file to an encrypted USB drive
- Transfer physically between machines

#### Option D: Self-Encrypted File
- Encrypt the JSON file with a password using 7-Zip or GPG
- Share the encrypted file via email/cloud
- Decrypt on the other machine

```bash
# Example using GPG encryption
gpg --symmetric --cipher-algo AES256 credentials/gcp-service-account.json
# This creates: gcp-service-account.json.gpg (safe to share)

# To decrypt on the other machine:
gpg --decrypt credentials/gcp-service-account.json.gpg > credentials/gcp-service-account.json
```

### 5. Verify Credentials Are Gitignored

Run this command to ensure your credentials won't be committed:

```bash
git status --ignored
```

Your `credentials/` folder and `.env` file should appear in the ignored files list.

### 6. Using Credentials in Your Code

#### Python Example:

```python
import os
from google.cloud import bigquery
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Option 1: Using environment variable (recommended)
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = os.getenv('GOOGLE_APPLICATION_CREDENTIALS')
client = bigquery.Client()

# Option 2: Explicit path
from google.oauth2 import service_account
credentials = service_account.Credentials.from_service_account_file(
    'credentials/gcp-service-account.json'
)
client = bigquery.Client(credentials=credentials)
```

#### Terraform Example:

```hcl
provider "google" {
  credentials = file("credentials/gcp-service-account.json")
  project     = var.project_id
  region      = var.region
}
```

## Security Checklist

- [ ] Credentials file is in `credentials/` directory
- [ ] `.env` file contains path to credentials
- [ ] Both files are listed in `.gitignore`
- [ ] Verified with `git status --ignored` that credentials won't be committed
- [ ] Never share credentials via insecure channels (Slack, unencrypted email, etc.)
- [ ] Use the same file path structure on both machines for consistency
- [ ] Consider setting up Application Default Credentials (ADC) for easier local development

## Application Default Credentials (ADC) - Alternative Approach

Instead of managing JSON files, you can use ADC:

### Setup ADC:

```bash
# Install gcloud CLI if not already installed
# https://cloud.google.com/sdk/docs/install

# Authenticate with your personal account
gcloud auth application-default login

# This creates credentials at:
# Windows: %APPDATA%\gcloud\application_default_credentials.json
# Linux/Mac: ~/.config/gcloud/application_default_credentials.json
```

### Pros:
- No need to manage JSON files
- Same command on both machines
- Credentials stored in standard OS location

### Cons:
- Uses your personal GCP account (not a service account)
- Need to run the command on each machine

## Best Practice for Data Engineering Zoomcamp

For the zoomcamp, I recommend:

1. **Create a dedicated GCP project** for the zoomcamp
2. **Use a service account** with minimal necessary permissions
3. **Store credentials locally** using the `credentials/` folder approach
4. **Use a password manager** to securely sync the JSON between machines
5. **Never commit** credentials to git (already configured in your `.gitignore`)

## Troubleshooting

### "Credentials not found" error:
```bash
# Check if file exists
ls credentials/gcp-service-account.json

# Check if environment variable is set
echo $GOOGLE_APPLICATION_CREDENTIALS  # Linux/Mac
echo %GOOGLE_APPLICATION_CREDENTIALS%  # Windows CMD
echo $env:GOOGLE_APPLICATION_CREDENTIALS  # Windows PowerShell
```

### Verify credentials work:
```bash
# Using gcloud CLI
gcloud auth activate-service-account --key-file=credentials/gcp-service-account.json
gcloud projects list
```

## Additional Resources

- [GCP Authentication Documentation](https://cloud.google.com/docs/authentication)
- [Best practices for managing service account keys](https://cloud.google.com/iam/docs/best-practices-for-managing-service-account-keys)
- [Application Default Credentials](https://cloud.google.com/docs/authentication/application-default-credentials)
