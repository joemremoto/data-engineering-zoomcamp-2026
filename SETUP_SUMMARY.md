# Setup Summary - Data Engineering Zoomcamp 2026

## What Has Been Created

### 📋 Documentation Files (13 files)

1. **README.md** (updated)
   - Complete setup instructions with automated and manual options
   - Uses `uv` for virtual environment management
   - Links to all documentation

2. **SETUP_VIRTUAL_ENV.md** (new)
   - Comprehensive guide to virtual environments
   - Why use virtual environments (best practices)
   - Complete `uv` installation and usage guide
   - Troubleshooting and IDE integration

3. **CREDENTIALS_SETUP.md** (new)
   - Detailed GCP credentials setup
   - Multiple secure transfer methods
   - Application Default Credentials (ADC) option
   - Troubleshooting guide

4. **QUICK_REFERENCE.md** (updated)
   - TL;DR commands
   - Quick troubleshooting
   - Common issues and solutions

5. **WORKFLOW_GUIDE.md** (new)
   - Visual ASCII workflow diagrams
   - Step-by-step for both machines
   - Security verification commands

6. **SECURITY_CHECKLIST.md** (new)
   - Complete security checklist
   - What to do if credentials are compromised
   - Best practices (DO's and DON'Ts)

### 🛠️ Scripts & Tools (5 files)

7. **setup.ps1** (new)
   - Automated setup script for Windows
   - Installs uv, creates venv, installs dependencies
   - Creates directory structure

8. **setup.sh** (new)
   - Automated setup script for Mac/Linux
   - Same functionality as setup.ps1

9. **verify_credentials.py** (new)
   - Python verification script
   - Tests all setup components
   - Attempts GCP connection

10. **verify_credentials.ps1** (new)
    - PowerShell verification script
    - Tests gitignore, files, environment

11. **example_gcp_usage.py** (new)
    - Working code examples
    - BigQuery, Cloud Storage examples
    - Multiple authentication methods

### ⚙️ Configuration (2 files)

12. **.env.example** (new)
    - Template for environment variables
    - Safe to commit to git
    - Documents all required variables

13. **requirements-gcp.txt** (new)
    - GCP SDK dependencies
    - Common data engineering tools
    - Version-pinned for reproducibility

## Best Practices Implemented

### ✅ Virtual Environment with uv

**Why:**
- Industry standard for Python development
- Prevents dependency conflicts
- Makes project portable
- `uv` is 10-100x faster than pip

**How:**
```bash
uv venv                           # Create virtual environment
.venv\Scripts\Activate.ps1        # Activate (Windows)
uv pip install -r requirements-gcp.txt  # Install dependencies
```

### ✅ Credentials Security

**Protected:**
- `credentials/*.json` - gitignored via `*.json`
- `.env` - gitignored
- `.venv/` - gitignored

**Secure Transfer Methods:**
1. Password Manager (recommended)
2. Encrypted file (GPG/7-Zip)
3. Private cloud (temporarily)
4. Encrypted USB

### ✅ Cross-Machine Consistency

**Same structure on both machines:**
```
├── .venv/                    # Virtual environment
├── credentials/              # GCP credentials
│   └── gcp-service-account.json
├── .env                      # Environment config
└── requirements-gcp.txt      # Dependencies
```

## Quick Start Commands

### First Time Setup (Work PC)

**Automated:**
```powershell
# Windows
.\setup.ps1

# Mac/Linux
chmod +x setup.sh && ./setup.sh
```

**Then:**
```bash
# 1. Download GCP service account JSON
#    Save as: credentials/gcp-service-account.json

# 2. Edit .env with your GCP project ID
notepad .env  # Windows
nano .env     # Mac/Linux

# 3. Verify setup
python verify_credentials.py

# 4. Test GCP connection
python example_gcp_usage.py
```

### Second Machine Setup (Personal PC)

```bash
# 1. Pull repo
git pull

# 2. Run setup script
.\setup.ps1      # Windows
./setup.sh       # Mac/Linux

# 3. Transfer credentials securely (use password manager)
#    Save as: credentials/gcp-service-account.json

# 4. Edit .env
notepad .env  # Windows
nano .env     # Mac/Linux

# 5. Verify
python verify_credentials.py
```

## Why These Choices?

### Why `uv` instead of `pip`?

| Feature | pip | uv |
|---------|-----|-----|
| Speed | 1x | 10-100x faster |
| Installation | Slow | Very fast |
| Resolution | Sometimes slow | Extremely fast |
| Written in | Python | Rust |
| Compatibility | 100% | Drop-in replacement |

**Verdict:** `uv` is objectively better with zero downsides.

### Why `.venv` instead of `venv`?

- `.venv` is the modern Python convention
- Hidden by default (starts with `.`)
- Consistent with other dot-directories (`.git`, `.env`)
- Already in your `.gitignore`

### Why Not Commit Virtual Environment?

**File count in typical `.venv/`:**
```
.venv/
├── ~500-2000+ files
├── ~50-200 MB size
└── Platform-specific binaries
```

**Problems:**
- Massive git repo size
- Platform-specific (Windows binaries won't work on Mac)
- Slow git operations
- Unnecessary - can recreate with `uv pip install -r requirements-gcp.txt`

### Why Separate `requirements-gcp.txt`?

- Focused on GCP dependencies only
- Doesn't conflict with module-specific requirements
- Easy to maintain
- Clear purpose

## File Organization

```
data-engineering-zoomcamp-2026/
│
├── .venv/                          # Virtual env (gitignored)
├── credentials/                    # Secrets (gitignored)
│   └── gcp-service-account.json
│
├── .env                            # Config (gitignored)
├── .env.example                    # Template (committed)
│
├── Documentation/
│   ├── README.md                   # Main entry point
│   ├── SETUP_VIRTUAL_ENV.md        # Virtual env guide
│   ├── CREDENTIALS_SETUP.md        # Credentials guide
│   ├── QUICK_REFERENCE.md          # Quick commands
│   ├── WORKFLOW_GUIDE.md           # Visual workflow
│   └── SECURITY_CHECKLIST.md       # Security guide
│
├── Scripts/
│   ├── setup.ps1                   # Windows setup
│   ├── setup.sh                    # Mac/Linux setup
│   ├── verify_credentials.py       # Python verify
│   ├── verify_credentials.ps1      # PowerShell verify
│   └── example_gcp_usage.py        # Usage examples
│
└── Config/
    ├── requirements-gcp.txt        # GCP dependencies
    └── .gitignore                  # Already configured
```

## Verification Checklist

Before starting work on either machine:

```bash
# 1. Virtual environment exists and activated
ls .venv/                        # Should exist
echo $env:VIRTUAL_ENV            # Should show .venv path (Windows)
# echo $VIRTUAL_ENV              # Mac/Linux

# 2. Dependencies installed
python -c "import google.cloud.bigquery; print('OK')"

# 3. Credentials exist
ls credentials/gcp-service-account.json

# 4. Environment configured
cat .env                         # Should have your project ID

# 5. Not in git
git check-ignore .venv credentials/gcp-service-account.json .env
# All should be ignored

# 6. Run verifier
python verify_credentials.py
```

## Daily Workflow

### Starting Work

```bash
# Navigate to project
cd data-engineering-zoomcamp-2026

# Activate virtual environment
.venv\Scripts\Activate.ps1        # Windows
# source .venv/bin/activate       # Mac/Linux

# Verify prompt shows (.venv)
# Work on your code...
```

### Ending Work

```bash
# Deactivate virtual environment
deactivate

# If committing code
git status                        # Check no secrets
git add your_files.py
git commit -m "Your message"
git push
```

## Troubleshooting

### "Command 'uv' not found"

**Solution:**
```bash
# Install uv
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"  # Windows
# curl -LsSf https://astral.sh/uv/install.sh | sh          # Mac/Linux

# Restart terminal
```

### "Virtual environment not activating"

**Solution:**
```powershell
# Windows: Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then try again
.venv\Scripts\Activate.ps1
```

### "Dependencies install failed"

**Solution:**
```bash
# Remove and recreate virtual environment
deactivate
rm -rf .venv  # Mac/Linux
# Remove-Item -Recurse -Force .venv  # Windows

# Recreate
uv venv
.venv\Scripts\Activate.ps1
uv pip install -r requirements-gcp.txt
```

### "Credentials not found"

**Solution:**
```bash
# Check file exists
ls credentials/gcp-service-account.json

# Check it's not empty
cat credentials/gcp-service-account.json | head

# Verify .env is configured
cat .env
```

### "About to commit secrets"

**Solution:**
```bash
# STOP! Don't commit
git reset

# Verify gitignore
git check-ignore credentials/gcp-service-account.json .env

# Should show they're ignored
```

## What You Get

### Speed Improvements

**Virtual Environment Creation:**
- Old: `python -m venv .venv` → ~10-30 seconds
- New: `uv venv` → ~1-2 seconds

**Dependency Installation:**
- Old: `pip install -r requirements-gcp.txt` → ~60 seconds
- New: `uv pip install -r requirements-gcp.txt` → ~5 seconds

**Total Time Saved:** ~55 seconds per setup

### Security Improvements

- ✅ Credentials never in git
- ✅ Multiple secure transfer options
- ✅ Verification scripts
- ✅ Security checklist
- ✅ Automated checks

### Productivity Improvements

- ✅ Automated setup scripts
- ✅ One command setup
- ✅ Consistent environment across machines
- ✅ Comprehensive documentation
- ✅ Troubleshooting guides

## Resources Created

| Type | Count | Purpose |
|------|-------|---------|
| Documentation | 6 files | Complete guides |
| Scripts | 5 files | Automation & verification |
| Config | 2 files | Environment & dependencies |
| **Total** | **13 files** | **Complete professional setup** |

## Next Steps

1. **Work PC:** Run `.\setup.ps1`
2. **Download GCP credentials**
3. **Edit .env**
4. **Verify:** `python verify_credentials.py`
5. **Test:** `python example_gcp_usage.py`
6. **Commit documentation:** `git add . && git commit -m "Add setup documentation"`
7. **Personal PC:** `git pull` and repeat steps 1-5

## Support

If you encounter issues:

1. Check [SETUP_VIRTUAL_ENV.md](./SETUP_VIRTUAL_ENV.md) for virtual environment issues
2. Check [CREDENTIALS_SETUP.md](./CREDENTIALS_SETUP.md) for credential issues
3. Check [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) for quick solutions
4. Run verification script: `python verify_credentials.py`

---

**You now have a production-grade setup for your Data Engineering Zoomcamp 2026!** 🎉
