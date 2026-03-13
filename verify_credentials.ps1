# GCP Credentials Setup Verification Script for Windows
# Run this to verify your GCP credentials are properly configured

Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 59) -ForegroundColor Cyan
Write-Host "GCP Credentials Setup Verification" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

$checksPassedCount = 0
$totalChecks = 0

# Check 1: Credentials directory
Write-Host "1. Checking credentials directory..." -ForegroundColor Yellow
if (Test-Path "credentials") {
    Write-Host "✓ credentials/ directory exists" -ForegroundColor Green
    $checksPassedCount++
} else {
    Write-Host "✗ credentials/ directory NOT found" -ForegroundColor Red
    Write-Host "  Create it with: mkdir credentials" -ForegroundColor Gray
}
$totalChecks++
Write-Host ""

# Check 2: Credentials file
Write-Host "2. Checking GCP credentials file..." -ForegroundColor Yellow
if (Test-Path "credentials/gcp-service-account.json") {
    Write-Host "✓ GCP service account JSON found at: credentials/gcp-service-account.json" -ForegroundColor Green
    $checksPassedCount++
} else {
    Write-Host "✗ GCP service account JSON NOT found at: credentials/gcp-service-account.json" -ForegroundColor Red
    Write-Host "  Download your service account key from GCP Console" -ForegroundColor Gray
}
$totalChecks++
Write-Host ""

# Check 3: .env file
Write-Host "3. Checking .env file..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✓ .env configuration file found at: .env" -ForegroundColor Green
    $checksPassedCount++
} else {
    Write-Host "✗ .env configuration file NOT found at: .env" -ForegroundColor Red
    Write-Host "  Hint: Copy .env.example to .env and fill in your values" -ForegroundColor Gray
    Write-Host "  Run: cp .env.example .env" -ForegroundColor Gray
}
$totalChecks++
Write-Host ""

# Check 4: Environment variables
Write-Host "4. Checking environment variables..." -ForegroundColor Yellow
$gcpCredsEnv = $env:GOOGLE_APPLICATION_CREDENTIALS
if ($gcpCredsEnv) {
    Write-Host "✓ Environment variable GOOGLE_APPLICATION_CREDENTIALS is set to: $gcpCredsEnv" -ForegroundColor Green
    $checksPassedCount++
} else {
    Write-Host "✗ Environment variable GOOGLE_APPLICATION_CREDENTIALS is NOT set" -ForegroundColor Red
    Write-Host "  This is OK if you're using .env file with python-dotenv" -ForegroundColor Gray
}
$totalChecks++
Write-Host ""

# Check 5: Gitignore
Write-Host "5. Checking .gitignore configuration..." -ForegroundColor Yellow
if (Test-Path ".gitignore") {
    $gitignoreContent = Get-Content ".gitignore" -Raw
    $jsonIgnored = $gitignoreContent -match '\*\.json'
    $envIgnored = $gitignoreContent -match '\.env\b'
    
    if ($jsonIgnored) {
        Write-Host "✓ JSON files (includes credentials) is in .gitignore" -ForegroundColor Green
    } else {
        Write-Host "✗ JSON files pattern is NOT in .gitignore" -ForegroundColor Red
    }
    
    if ($envIgnored) {
        Write-Host "✓ .env file is in .gitignore" -ForegroundColor Green
    } else {
        Write-Host "✗ .env file is NOT in .gitignore" -ForegroundColor Red
    }
    
    if ($jsonIgnored -and $envIgnored) {
        $checksPassedCount++
    }
} else {
    Write-Host "✗ .gitignore file not found" -ForegroundColor Red
}
$totalChecks++
Write-Host ""

# Check 6: Test if files would be committed
Write-Host "6. Verifying files are gitignored..." -ForegroundColor Yellow
try {
    $gitCheckResult = git check-ignore credentials/gcp-service-account.json .env 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Credentials and .env are properly gitignored" -ForegroundColor Green
        $checksPassedCount++
    } else {
        Write-Host "⚠ Could not verify git ignore status" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ Git not available or not in a git repository" -ForegroundColor Yellow
}
$totalChecks++
Write-Host ""

# Summary
Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 59) -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan

if ($checksPassedCount -eq $totalChecks) {
    Write-Host "✓ All checks passed ($checksPassedCount/$totalChecks)" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎉 Your GCP credentials are properly configured!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠ $checksPassedCount/$totalChecks checks passed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please review the issues above and follow CREDENTIALS_SETUP.md" -ForegroundColor Gray
    exit 1
}
