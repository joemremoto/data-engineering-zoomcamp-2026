# Python Virtual Environment Setup with uv

## Why Use a Virtual Environment?

✅ **Best Practices:**
- Isolates project dependencies from system Python
- Prevents version conflicts between projects
- Makes dependencies reproducible
- Easier to manage and clean up
- Required for professional Python development

✅ **Why uv?**
- **10-100x faster** than pip for package installation
- Written in Rust (extremely fast)
- Drop-in replacement for pip
- Modern Python package manager
- Officially recommended by many Python projects

## Installation

### Install uv

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**Mac:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Linux:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Alternative (using pip):**
```bash
pip install uv
```

Verify installation:
```bash
uv --version
```

## Creating Virtual Environment

### Using uv (Recommended)

```bash
# Create virtual environment in .venv directory
uv venv

# uv automatically creates .venv by default
# This is the standard Python virtual environment location
```

### Activate Virtual Environment

**Windows (PowerShell):**
```powershell
.venv\Scripts\Activate.ps1
```

**Windows (CMD):**
```cmd
.venv\Scripts\activate.bat
```

**Mac/Linux:**
```bash
source .venv/bin/activate
```

You should see `(.venv)` prefix in your terminal prompt.

### Deactivate Virtual Environment

```bash
deactivate
```

## Installing Dependencies

### With uv (Fast - Recommended)

```bash
# Make sure virtual environment is activated
uv pip install -r requirements-gcp.txt

# Or install specific packages
uv pip install google-cloud-bigquery google-cloud-storage

# Sync exact versions (creates lockfile-like behavior)
uv pip sync requirements-gcp.txt
```

### With pip (Slower - Traditional)

```bash
pip install -r requirements-gcp.txt
```

## Complete Setup Workflow

### First Time Setup

```bash
# 1. Install uv (one-time)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"  # Windows
# curl -LsSf https://astral.sh/uv/install.sh | sh            # Mac/Linux

# 2. Create virtual environment
cd data-engineering-zoomcamp-2026
uv venv

# 3. Activate virtual environment
.venv\Scripts\Activate.ps1  # Windows PowerShell
# source .venv/bin/activate  # Mac/Linux

# 4. Install dependencies
uv pip install -r requirements-gcp.txt

# 5. Verify Python is using virtual environment
which python  # Mac/Linux
# where python  # Windows
# Should show path in .venv directory

# 6. Setup credentials (see CREDENTIALS_SETUP.md)
mkdir credentials
cp .env.example .env
# Edit .env and add credentials

# 7. Verify setup
python verify_credentials.py
```

### Daily Workflow

```bash
# 1. Navigate to project
cd data-engineering-zoomcamp-2026

# 2. Activate virtual environment
.venv\Scripts\Activate.ps1  # Windows
# source .venv/bin/activate  # Mac/Linux

# 3. Work on your code
python your_script.py

# 4. Deactivate when done
deactivate
```

## Virtual Environment Benefits for This Project

### Isolation
```
System Python (Don't touch!)
├── python 3.12
└── system packages

Project .venv (Your sandbox!)
├── python 3.12
├── google-cloud-bigquery==3.11.0
├── google-cloud-storage==2.10.0
└── pandas==2.0.0
```

### Reproducibility
- Same dependencies on work PC and personal PC
- `requirements-gcp.txt` locks versions
- Easy to recreate environment if corrupted

### Performance with uv

**Installation Speed Comparison:**
```
pip install -r requirements-gcp.txt:     ~60 seconds
uv pip install -r requirements-gcp.txt:  ~5 seconds  (12x faster!)
```

## Troubleshooting

### Problem: Command 'uv' not found

**Solution:** Add uv to PATH

Windows (PowerShell):
```powershell
$env:Path += ";$env:USERPROFILE\.cargo\bin"
# Or restart terminal after installation
```

Mac/Linux:
```bash
export PATH="$HOME/.cargo/bin:$PATH"
# Add to ~/.bashrc or ~/.zshrc for persistence
```

### Problem: Virtual environment not activating

**Solution:** Check PowerShell execution policy (Windows)

```powershell
# Check current policy
Get-ExecutionPolicy

# If restricted, allow scripts for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problem: Wrong Python version in virtual environment

**Solution:** Specify Python version

```bash
# Use specific Python version
uv venv --python 3.11
uv venv --python 3.12

# Or use system Python
uv venv --python python3
```

### Problem: Package conflicts

**Solution:** Recreate virtual environment

```bash
# Deactivate if active
deactivate

# Remove old virtual environment
rm -rf .venv  # Mac/Linux
# Remove-Item -Recurse -Force .venv  # Windows

# Create fresh virtual environment
uv venv
.venv\Scripts\Activate.ps1
uv pip install -r requirements-gcp.txt
```

## Best Practices

### ✅ DO:
- Use `uv venv` for fast virtual environment creation
- Activate virtual environment before working
- Use `.venv` as virtual environment name (standard)
- Keep `requirements-gcp.txt` updated
- Use `uv pip install` for faster installs
- Create separate virtual environments for each project

### ❌ DON'T:
- Install packages globally (without virtual environment)
- Commit `.venv/` directory to git (already gitignored)
- Mix pip and uv in same environment (stick to one)
- Share virtual environments between projects
- Run `pip install` outside virtual environment

## uv Quick Reference

```bash
# Create virtual environment
uv venv

# Install from requirements file
uv pip install -r requirements-gcp.txt

# Install specific package
uv pip install package-name

# Install with version
uv pip install package-name==1.2.3

# List installed packages
uv pip list

# Show package info
uv pip show package-name

# Freeze current packages to file
uv pip freeze > requirements.txt

# Uninstall package
uv pip uninstall package-name

# Upgrade package
uv pip install --upgrade package-name

# Sync to exact requirements (removes extra packages)
uv pip sync requirements-gcp.txt
```

## IDE Integration

### VS Code

Add to `.vscode/settings.json`:
```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "python.terminal.activateEnvironment": true
}
```

VS Code will automatically detect and activate `.venv`.

### PyCharm

1. File → Settings → Project → Python Interpreter
2. Click gear icon → Add
3. Select "Existing environment"
4. Browse to `.venv/Scripts/python.exe` (Windows) or `.venv/bin/python` (Mac/Linux)

### Cursor (this IDE)

Cursor automatically detects `.venv` and offers to use it.

## Additional Resources

- [uv Documentation](https://github.com/astral-sh/uv)
- [Python Virtual Environments Guide](https://docs.python.org/3/tutorial/venv.html)
- [Why Use Virtual Environments?](https://realpython.com/python-virtual-environments-a-primer/)

## Summary

**For this project:**

1. Install `uv` (one-time setup)
2. Run `uv venv` in project root
3. Activate: `.venv\Scripts\Activate.ps1` (Windows) or `source .venv/bin/activate` (Mac/Linux)
4. Install: `uv pip install -r requirements-gcp.txt`
5. Work normally, deactivate when done

**Why it matters:**
- Professional Python development standard
- Prevents dependency conflicts
- Makes project portable between work and personal PC
- Much faster with `uv`
