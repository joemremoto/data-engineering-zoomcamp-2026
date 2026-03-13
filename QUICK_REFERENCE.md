# Quick Reference: GCP Credentials Management

## TL;DR - Quick Setup

```bash
# 0. Install uv (if not already installed)
# Windows: powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
# Mac/Linux: curl -LsSf https://astral.sh/uv/install.sh | sh

# 1. Create virtual environment and install dependencies
uv venv
source .venv/bin/activate  # Mac/Linux
# OR: .venv\Scripts\Activate.ps1  # Windows
uv pip install -r requirements-gcp.txt

# 2. Create credentials folder
mkdir credentials

# 3. Copy your GCP service account JSON to:
#    credentials/gcp-service-account.json

# 4. Setup environment
cp .env.example .env
# Edit .env with your GCP project ID

# 5. Verify setup
python verify_credentials.py
```

## Files Overview

| File | Purpose | Should Commit? |
|------|---------|----------------|
| `credentials/gcp-service-account.json` | GCP service account key | ❌ NO (gitignored) |
| `.env` | Environment variables | ❌ NO (gitignored) |
| `.env.example` | Template for .env | ✅ YES |
| `CREDENTIALS_SETUP.md` | Detailed setup guide | ✅ YES |
| `SECURITY_CHECKLIST.md` | Security checklist | ✅ YES |
| `verify_credentials.py` | Python verification script | ✅ YES |
| `verify_credentials.ps1` | PowerShell verification script | ✅ YES |
| `example_gcp_usage.py` | Example usage code | ✅ YES |
| `requirements-gcp.txt` | GCP dependencies | ✅ YES |

## Transferring Credentials Between Machines

### Recommended: Password Manager
1. Copy JSON content to password manager (1Password, Bitwarden, etc.)
2. Access from other machine
3. Paste into `credentials/gcp-service-account.json`

### Alternative: Encrypted Transfer
```bash
# On machine 1: Encrypt
gpg --symmetric --cipher-algo AES256 credentials/gcp-service-account.json

# Transfer the .gpg file to machine 2

# On machine 2: Decrypt
gpg --decrypt credentials/gcp-service-account.json.gpg > credentials/gcp-service-account.json
```

## Verification Commands

```bash
# Check credentials are gitignored
git check-ignore credentials/gcp-service-account.json .env

# Run verification script
python verify_credentials.py

# Test GCP connection
python example_gcp_usage.py
```

## Common Issues

### "Credentials not found"
- Ensure file is at: `credentials/gcp-service-account.json`
- Check file permissions (should be readable)

### "Permission denied"
- Check service account has necessary IAM roles in GCP Console
- Verify project ID in `.env` is correct

### "File would be committed to git"
- Run: `git check-ignore -v credentials/gcp-service-account.json`
- Should show: `.gitignore:2:*.json`
- If not, ensure `.gitignore` has `*.json` pattern

## Python Usage Example

```python
from google.cloud import bigquery
from dotenv import load_dotenv
import os

# Load environment
load_dotenv()

# Create client (automatically uses GOOGLE_APPLICATION_CREDENTIALS)
client = bigquery.Client(project=os.getenv('GCP_PROJECT_ID'))

# Run query
results = client.query("SELECT 1 as test").result()
for row in results:
    print(row.test)
```

## Security Reminders

✅ **DO:**
- Use password managers
- Keep credentials local
- Verify .gitignore works
- Rotate keys regularly

❌ **DON'T:**
- Commit credentials
- Share via Slack/email
- Use overly broad permissions
- Leave keys in cloud storage

## Need Help?

- Detailed setup: [CREDENTIALS_SETUP.md](./CREDENTIALS_SETUP.md)
- Security checklist: [SECURITY_CHECKLIST.md](./SECURITY_CHECKLIST.md)
- GCP Docs: https://cloud.google.com/docs/authentication
