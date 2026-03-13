# Quick Setup Script for Data Engineering Zoomcamp
# This script sets up your virtual environment and credentials structure

Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 59) -ForegroundColor Cyan
Write-Host "Data Engineering Zoomcamp 2026 - Quick Setup" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# Check if uv is installed
Write-Host "Checking for uv installation..." -ForegroundColor Yellow
try {
    $uvVersion = uv --version 2>$null
    Write-Host "✓ uv is installed: $uvVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ uv is not installed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installing uv..." -ForegroundColor Yellow
    try {
        powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
        Write-Host "✓ uv installed successfully" -ForegroundColor Green
        Write-Host "  Please restart your terminal and run this script again" -ForegroundColor Gray
        exit 0
    } catch {
        Write-Host "✗ Failed to install uv" -ForegroundColor Red
        Write-Host "  Please install manually: https://github.com/astral-sh/uv" -ForegroundColor Gray
        exit 1
    }
}
Write-Host ""

# Create virtual environment
Write-Host "Setting up virtual environment..." -ForegroundColor Yellow
if (Test-Path ".venv") {
    Write-Host "✓ Virtual environment already exists at .venv" -ForegroundColor Green
} else {
    try {
        uv venv
        Write-Host "✓ Created virtual environment at .venv" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to create virtual environment" -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# Activate virtual environment
Write-Host "Activating virtual environment..." -ForegroundColor Yellow
try {
    & .\.venv\Scripts\Activate.ps1
    Write-Host "✓ Virtual environment activated" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not activate automatically" -ForegroundColor Yellow
    Write-Host "  Run manually: .\.venv\Scripts\Activate.ps1" -ForegroundColor Gray
}
Write-Host ""

# Install dependencies
Write-Host "Installing dependencies from requirements-gcp.txt..." -ForegroundColor Yellow
if (Test-Path "requirements-gcp.txt") {
    try {
        uv pip install -r requirements-gcp.txt
        Write-Host "✓ Dependencies installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to install dependencies" -ForegroundColor Red
        Write-Host "  Try manually: uv pip install -r requirements-gcp.txt" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠ requirements-gcp.txt not found" -ForegroundColor Yellow
}
Write-Host ""

# Create credentials directory
Write-Host "Setting up credentials directory..." -ForegroundColor Yellow
if (Test-Path "credentials") {
    Write-Host "✓ credentials/ directory already exists" -ForegroundColor Green
} else {
    try {
        New-Item -ItemType Directory -Path "credentials" | Out-Null
        Write-Host "✓ Created credentials/ directory" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to create credentials directory" -ForegroundColor Red
    }
}
Write-Host ""

# Setup .env file
Write-Host "Setting up environment configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✓ .env file already exists" -ForegroundColor Green
} else {
    if (Test-Path ".env.example") {
        try {
            Copy-Item ".env.example" ".env"
            Write-Host "✓ Created .env from .env.example" -ForegroundColor Green
            Write-Host "  Remember to edit .env with your GCP project ID!" -ForegroundColor Gray
        } catch {
            Write-Host "⚠ Could not copy .env.example to .env" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠ .env.example not found" -ForegroundColor Yellow
    }
}
Write-Host ""

# Summary
Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 59) -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Download your GCP service account JSON key" -ForegroundColor White
Write-Host "   Save it as: credentials/gcp-service-account.json" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Edit .env file with your GCP project details" -ForegroundColor White
Write-Host "   Run: notepad .env" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Verify your setup" -ForegroundColor White
Write-Host "   Run: python verify_credentials.py" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Test GCP connection" -ForegroundColor White
Write-Host "   Run: python example_gcp_usage.py" -ForegroundColor Gray
Write-Host ""

Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "  - Quick Reference:    QUICK_REFERENCE.md" -ForegroundColor Gray
Write-Host "  - Virtual Env Setup:  SETUP_VIRTUAL_ENV.md" -ForegroundColor Gray
Write-Host "  - Credentials Guide:  CREDENTIALS_SETUP.md" -ForegroundColor Gray
Write-Host "  - Security Checklist: SECURITY_CHECKLIST.md" -ForegroundColor Gray
Write-Host ""

# Check if credentials exist
if (-not (Test-Path "credentials/gcp-service-account.json")) {
    Write-Host "⚠ WARNING: GCP credentials not found" -ForegroundColor Yellow
    Write-Host "  Please download your service account JSON and save it as:" -ForegroundColor Gray
    Write-Host "  credentials/gcp-service-account.json" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Happy coding! 🚀" -ForegroundColor Green
