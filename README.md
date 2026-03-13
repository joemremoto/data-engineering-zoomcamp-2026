# data-engineering-zoomcamp-2026
This is my personal repo for anything related to the data engineering zoomcamp 2026 cohort.

> **📚 Documentation:** [Quick Reference](./QUICK_REFERENCE.md) | [Virtual Env Setup](./SETUP_VIRTUAL_ENV.md) | [Credentials Setup](./CREDENTIALS_SETUP.md) | [Security Checklist](./SECURITY_CHECKLIST.md)

## Quick Setup

### Option A: Automated Setup (Recommended)

Run the setup script that does everything for you:

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

**Mac/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

The script will:
- Install `uv` if not present
- Create virtual environment
- Install dependencies
- Create `credentials/` directory
- Copy `.env.example` to `.env`

### Option B: Manual Setup

### 1. Python Environment (using uv)

**Install uv** (if not already installed):
```bash
# Windows (PowerShell):
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Mac/Linux:
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Setup virtual environment and install dependencies:**
```bash
# Create virtual environment with uv (much faster than venv)
uv venv

# Activate virtual environment
# On Windows (PowerShell):
.venv\Scripts\Activate.ps1
# On Windows (CMD):
.venv\Scripts\activate.bat
# On Mac/Linux:
source .venv/bin/activate

# Install GCP dependencies with uv (10-100x faster than pip)
uv pip install -r requirements-gcp.txt

# Or in one command (create venv + install):
uv pip install -r requirements-gcp.txt
```

<details>
<summary>Alternative: Using standard Python venv (slower)</summary>

```bash
# Create virtual environment
python -m venv .venv

# Activate
.venv\Scripts\Activate.ps1  # Windows
source .venv/bin/activate     # Mac/Linux

# Install dependencies
pip install -r requirements-gcp.txt
```
</details>

### 2. GCP Credentials Setup
See [CREDENTIALS_SETUP.md](./CREDENTIALS_SETUP.md) for detailed instructions on setting up your GCP credentials securely across multiple machines.

**Quick Start:**
```bash
# Step 1: Create credentials directory
mkdir credentials

# Step 2: Download your GCP service account JSON key from GCP Console
# Save it as: credentials/gcp-service-account.json

# Step 3: Copy environment template and fill in your values
cp .env.example .env
# Edit .env with your actual GCP project ID and settings

# Step 4: Verify your setup
python verify_credentials.py
# Or on Windows PowerShell:
.\verify_credentials.ps1
```

**Important:** Credentials are already gitignored - safe from accidental commits!

### 3. Test Your Setup
```bash
# Run example script to test GCP connectivity
python example_gcp_usage.py
```

## Working Across Multiple Machines

This setup is designed to work seamlessly between your work PC and personal PC:

1. **Same credential location** on both machines: `credentials/gcp-service-account.json`
2. **Use a password manager** (recommended) to securely sync your GCP JSON key
3. **Gitignored by default** - credentials never accidentally committed
4. **Environment variables** via `.env` file for easy configuration

See [CREDENTIALS_SETUP.md](./CREDENTIALS_SETUP.md) for secure credential transfer methods.

## Project Structure

```
.
├── .venv/                    # Virtual environment (gitignored)
├── credentials/              # GCP service account keys (gitignored)
│   └── gcp-service-account.json
├── .env                      # Environment variables (gitignored)
├── .env.example              # Template for environment variables
├── CREDENTIALS_SETUP.md      # Detailed credential setup guide
├── QUICK_REFERENCE.md        # Quick reference guide
├── SECURITY_CHECKLIST.md     # Security best practices
├── WORKFLOW_GUIDE.md         # Visual workflow guide
├── verify_credentials.py     # Python verification script
├── verify_credentials.ps1    # PowerShell verification script
├── example_gcp_usage.py      # Example GCP usage code
└── requirements-gcp.txt      # GCP dependencies
```

## Additional Resources

- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Quick commands and troubleshooting
- [SETUP_VIRTUAL_ENV.md](./SETUP_VIRTUAL_ENV.md) - Virtual environment best practices with uv
- [CREDENTIALS_SETUP.md](./CREDENTIALS_SETUP.md) - Comprehensive credentials setup guide
- [WORKFLOW_GUIDE.md](./WORKFLOW_GUIDE.md) - Visual workflow between machines
- [SECURITY_CHECKLIST.md](./SECURITY_CHECKLIST.md) - Security best practices and checklist
