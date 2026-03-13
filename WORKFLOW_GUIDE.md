# GCP Credentials Workflow: Work PC ↔️ Personal PC

## Visual Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         GCP Console                                  │
│  https://console.cloud.google.com/iam-admin/serviceaccounts        │
│                                                                      │
│  1. Create/Select Service Account                                   │
│  2. Keys → Add Key → Create new key → JSON                         │
│  3. Download: my-project-xxxxx.json                                 │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
                    Download JSON Key
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    Secure Transfer Method                            │
│                     (Choose ONE)                                     │
│                                                                      │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐  │
│  │ Password Manager │  │ Encrypted File   │  │ Private Cloud   │  │
│  │  (Recommended)   │  │  (GPG/7-Zip)     │  │   (Temporary)   │  │
│  │                  │  │                  │  │                 │  │
│  │ • 1Password      │  │ • GPG encrypt    │  │ • Google Drive  │  │
│  │ • Bitwarden      │  │ • 7-Zip AES256   │  │ • OneDrive      │  │
│  │ • LastPass       │  │ • Decrypt on     │  │ • Delete after  │  │
│  │                  │  │   other machine  │  │   setup         │  │
│  └──────────────────┘  └──────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
         ┌────────────────────┴────────────────────┐
         ↓                                          ↓
┌──────────────────────┐                  ┌──────────────────────┐
│     Work PC          │                  │    Personal PC       │
│  (work email)        │                  │  (personal email)    │
│                      │                  │                      │
│  📁 Project Root     │                  │  📁 Project Root     │
│  ├── credentials/    │                  │  ├── credentials/    │
│  │   └── gcp-*.json │ ← Same path →    │  │   └── gcp-*.json │
│  ├── .env           │                  │  ├── .env           │
│  ├── .env.example   │                  │  ├── .env.example   │
│  └── .gitignore     │                  │  └── .gitignore     │
│                      │                  │                      │
│  ✅ gitignored       │                  │  ✅ gitignored       │
│  ✅ local only       │                  │  ✅ local only       │
└──────────────────────┘                  └──────────────────────┘
         │                                          │
         └────────────────┬─────────────────────────┘
                          ↓
                ┌──────────────────────┐
                │   Git Repository     │
                │                      │
                │  ❌ NO credentials   │
                │  ❌ NO .env file     │
                │  ✅ .env.example     │
                │  ✅ Documentation    │
                │  ✅ Verification     │
                │      scripts         │
                └──────────────────────┘
```

## Step-by-Step Setup

### First Machine (e.g., Work PC)

```bash
# 1. Clone/navigate to repo
cd data-engineering-zoomcamp-2026

# 2. Install uv (if not already installed)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"  # Windows
# curl -LsSf https://astral.sh/uv/install.sh | sh           # Mac/Linux

# 3. Create virtual environment
uv venv

# 4. Activate virtual environment
.venv\Scripts\Activate.ps1  # Windows PowerShell
# source .venv/bin/activate  # Mac/Linux

# 5. Install dependencies
uv pip install -r requirements-gcp.txt

# 6. Create credentials directory
mkdir credentials

# 7. Download GCP service account JSON from console
# Save as: credentials/gcp-service-account.json

# 8. Setup environment
cp .env.example .env
# Edit .env: set GCP_PROJECT_ID=your-project-id

# 9. Verify setup
python verify_credentials.py

# 10. Test GCP connection
python example_gcp_usage.py

# 11. Commit documentation (NOT credentials)
git add README.md CREDENTIALS_SETUP.md .env.example
git commit -m "Add GCP credentials setup documentation"
git push
```

### Second Machine (e.g., Personal PC)

```bash
# 1. Pull latest changes
cd data-engineering-zoomcamp-2026
git pull

# 2. Install uv (if not already installed)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"  # Windows
# curl -LsSf https://astral.sh/uv/install.sh | sh           # Mac/Linux

# 3. Create virtual environment
uv venv

# 4. Activate virtual environment
.venv\Scripts\Activate.ps1  # Windows PowerShell
# source .venv/bin/activate  # Mac/Linux

# 5. Install dependencies
uv pip install -r requirements-gcp.txt

# 6. Create credentials directory
mkdir credentials

# 7. Transfer credentials from first machine
#    Use password manager, encrypted file, or private cloud
#    Copy JSON to: credentials/gcp-service-account.json

# 8. Setup environment
cp .env.example .env
# Edit .env: set GCP_PROJECT_ID=your-project-id

# 9. Verify setup
python verify_credentials.py

# 10. Test GCP connection
python example_gcp_usage.py

# 11. Start working!
```

## File Management

### ✅ Commit to Git (Safe)
```
├── .env.example              ← Template
├── .gitignore               ← Already has *.json and .env
├── README.md
├── CREDENTIALS_SETUP.md
├── QUICK_REFERENCE.md
├── SECURITY_CHECKLIST.md
├── verify_credentials.py
├── verify_credentials.ps1
├── example_gcp_usage.py
└── requirements-gcp.txt
```

### ❌ Never Commit (Gitignored)
```
├── credentials/
│   └── gcp-service-account.json  ← SECRET
└── .env                           ← SECRET
```

## Security Verification

### Before Every Commit
```bash
# Check what you're about to commit
git status

# Verify credentials are ignored
git check-ignore credentials/gcp-service-account.json .env

# Should output:
# .gitignore:2:*.json    credentials/gcp-service-account.json
# .gitignore:195:.env    .env
```

### Quick Security Test
```bash
# These should return NOTHING (empty):
git ls-files | grep "gcp-service-account"
git ls-files | grep "^\.env$"

# This should show them as ignored:
git status --ignored | grep -E "(credentials|\.env)"
```

## Troubleshooting

### Problem: Credentials not found
**Solution:** Check file path
```bash
ls credentials/gcp-service-account.json
# Should exist and be readable
```

### Problem: Permission denied
**Solution:** Check GCP IAM roles
1. Go to GCP Console → IAM & Admin → IAM
2. Find your service account
3. Ensure it has necessary roles (e.g., BigQuery Admin, Storage Admin)

### Problem: About to commit credentials
**Solution:** Undo and verify gitignore
```bash
# If accidentally staged:
git reset credentials/gcp-service-account.json
git reset .env

# Verify gitignore:
git check-ignore -v credentials/gcp-service-account.json
```

## Best Practices Summary

1. **Use same file structure** on both machines
2. **Never commit** credentials or `.env`
3. **Always verify** with `git status` before committing
4. **Use password manager** for secure syncing
5. **Rotate keys** every 90 days
6. **Minimal permissions** on service accounts
7. **Test regularly** with verification scripts

## Quick Commands Reference

```bash
# Install uv (one-time)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"  # Windows
# curl -LsSf https://astral.sh/uv/install.sh | sh           # Mac/Linux

# Setup virtual environment
uv venv
.venv\Scripts\Activate.ps1              # Windows
# source .venv/bin/activate              # Mac/Linux
uv pip install -r requirements-gcp.txt

# Setup credentials
mkdir credentials
cp .env.example .env

# Verify
python verify_credentials.py          # or .\verify_credentials.ps1
python example_gcp_usage.py

# Security check
git check-ignore credentials/gcp-service-account.json .env
git status

# Transfer (GPG method)
gpg --symmetric --cipher-algo AES256 credentials/gcp-service-account.json
# Transfer .gpg file, then:
gpg --decrypt credentials/gcp-service-account.json.gpg > credentials/gcp-service-account.json
```

---

**Remember:** The credentials file exists ONLY on your local machines, NEVER in git!
