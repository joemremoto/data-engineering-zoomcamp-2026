#!/bin/bash
# Quick Setup Script for Data Engineering Zoomcamp (Mac/Linux)
# This script sets up your virtual environment and credentials structure

set -e

echo "============================================================"
echo "Data Engineering Zoomcamp 2026 - Quick Setup"
echo "============================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Check if uv is installed
echo -e "${YELLOW}Checking for uv installation...${NC}"
if command -v uv &> /dev/null; then
    UV_VERSION=$(uv --version)
    echo -e "${GREEN}✓ uv is installed: $UV_VERSION${NC}"
else
    echo -e "${RED}✗ uv is not installed${NC}"
    echo ""
    echo -e "${YELLOW}Installing uv...${NC}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo -e "${GREEN}✓ uv installed successfully${NC}"
    echo -e "${GRAY}  Please restart your terminal or run: source ~/.bashrc${NC}"
    echo -e "${GRAY}  Then run this script again${NC}"
    exit 0
fi
echo ""

# Create virtual environment
echo -e "${YELLOW}Setting up virtual environment...${NC}"
if [ -d ".venv" ]; then
    echo -e "${GREEN}✓ Virtual environment already exists at .venv${NC}"
else
    uv venv
    echo -e "${GREEN}✓ Created virtual environment at .venv${NC}"
fi
echo ""

# Activate virtual environment
echo -e "${YELLOW}Activating virtual environment...${NC}"
source .venv/bin/activate
echo -e "${GREEN}✓ Virtual environment activated${NC}"
echo ""

# Install dependencies
echo -e "${YELLOW}Installing dependencies from requirements-gcp.txt...${NC}"
if [ -f "requirements-gcp.txt" ]; then
    uv pip install -r requirements-gcp.txt
    echo -e "${GREEN}✓ Dependencies installed successfully${NC}"
else
    echo -e "${YELLOW}⚠ requirements-gcp.txt not found${NC}"
fi
echo ""

# Create credentials directory
echo -e "${YELLOW}Setting up credentials directory...${NC}"
if [ -d "credentials" ]; then
    echo -e "${GREEN}✓ credentials/ directory already exists${NC}"
else
    mkdir credentials
    echo -e "${GREEN}✓ Created credentials/ directory${NC}"
fi
echo ""

# Setup .env file
echo -e "${YELLOW}Setting up environment configuration...${NC}"
if [ -f ".env" ]; then
    echo -e "${GREEN}✓ .env file already exists${NC}"
else
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✓ Created .env from .env.example${NC}"
        echo -e "${GRAY}  Remember to edit .env with your GCP project ID!${NC}"
    else
        echo -e "${YELLOW}⚠ .env.example not found${NC}"
    fi
fi
echo ""

# Summary
echo "============================================================"
echo -e "${CYAN}Setup Complete!${NC}"
echo "============================================================"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo -e "${NC}1. Download your GCP service account JSON key${NC}"
echo -e "${GRAY}   Save it as: credentials/gcp-service-account.json${NC}"
echo ""
echo -e "${NC}2. Edit .env file with your GCP project details${NC}"
echo -e "${GRAY}   Run: nano .env  (or vim .env)${NC}"
echo ""
echo -e "${NC}3. Verify your setup${NC}"
echo -e "${GRAY}   Run: python verify_credentials.py${NC}"
echo ""
echo -e "${NC}4. Test GCP connection${NC}"
echo -e "${GRAY}   Run: python example_gcp_usage.py${NC}"
echo ""

echo -e "${YELLOW}Documentation:${NC}"
echo -e "${GRAY}  - Quick Reference:    QUICK_REFERENCE.md${NC}"
echo -e "${GRAY}  - Virtual Env Setup:  SETUP_VIRTUAL_ENV.md${NC}"
echo -e "${GRAY}  - Credentials Guide:  CREDENTIALS_SETUP.md${NC}"
echo -e "${GRAY}  - Security Checklist: SECURITY_CHECKLIST.md${NC}"
echo ""

# Check if credentials exist
if [ ! -f "credentials/gcp-service-account.json" ]; then
    echo -e "${YELLOW}⚠ WARNING: GCP credentials not found${NC}"
    echo -e "${GRAY}  Please download your service account JSON and save it as:${NC}"
    echo -e "${GRAY}  credentials/gcp-service-account.json${NC}"
    echo ""
fi

echo -e "${GREEN}Happy coding! 🚀${NC}"
