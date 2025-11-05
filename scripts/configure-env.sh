#!/bin/bash

################################################################################
# Environment Configuration Setup Script
# This script creates .env.local with custom configuration
################################################################################

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$PROJECT_DIR/.env.local"
ENV_EXAMPLE="$PROJECT_DIR/.env.example"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  DevOps Lab - Environment Configuration Setup             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if .env.local already exists
if [ -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}⚠️  .env.local already exists${NC}"
    read -p "Do you want to reconfigure? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing .env.local"
        exit 0
    fi
fi

# Check if .env.example exists
if [ ! -f "$ENV_EXAMPLE" ]; then
    echo -e "${RED}❌ .env.example not found!${NC}"
    exit 1
fi

# Copy .env.example to .env.local
cp "$ENV_EXAMPLE" "$ENV_FILE"
echo -e "${GREEN}✅ Created .env.local${NC}"

echo ""
echo -e "${BLUE}Configure your environment:${NC}"
echo ""

# Function to prompt for value
prompt_value() {
    local var_name=$1
    local description=$2
    local default_value=$3
    
    echo -n "Enter $description [$default_value]: "
    read -r value
    
    if [ -z "$value" ]; then
        value=$default_value
    fi
    
    # Update .env.local
    if [ -z "$default_value" ]; then
        # For variables without defaults
        sed -i.bak "s|^$var_name=.*|$var_name=$value|" "$ENV_FILE"
    else
        sed -i.bak "s|^$var_name=.*|$var_name=$value|" "$ENV_FILE"
    fi
    
    echo -e "${GREEN}✓${NC} $var_name set"
}

# Kubernetes Configuration
echo -e "${BLUE}━━━ Kubernetes Configuration ━━━${NC}"
prompt_value "K8S_CONTEXT" "Kubernetes context" "docker-desktop"
prompt_value "K8S_CLUSTER" "Kubernetes cluster" "docker-desktop"
prompt_value "MONITORING_NAMESPACE" "Monitoring namespace" "monitoring"
echo ""

# Docker Registry
echo -e "${BLUE}━━━ Docker Registry Configuration ━━━${NC}"
prompt_value "REGISTRY_URL" "Registry URL" "localhost:5001"
prompt_value "REGISTRY_USERNAME" "Registry username" ""
prompt_value "REGISTRY_PASSWORD" "Registry password" ""
echo ""

# GitHub Configuration
echo -e "${BLUE}━━━ GitHub Configuration ━━━${NC}"
prompt_value "GITHUB_USERNAME" "GitHub username" "AndreLiar"
prompt_value "GITHUB_TOKEN" "GitHub personal access token" ""
prompt_value "ARGOCD_REPO_URL" "ArgoCD repo URL" "https://github.com/AndreLiar/devopslocally"
echo ""

# Application Configuration
echo -e "${BLUE}━━━ Application Configuration ━━━${NC}"
prompt_value "APP_ENVIRONMENT" "Environment (local/staging/production)" "local"
prompt_value "APP_LOG_LEVEL" "Log level (debug/info/warn/error)" "debug"
echo ""

# Database Configuration (Optional)
echo -e "${BLUE}━━━ Database Configuration (Optional) ━━━${NC}"
prompt_value "DB_HOST" "Database host" "postgres-service"
prompt_value "DB_NAME" "Database name" "devopsdb"
echo ""

# Clean up backup files
rm -f "$ENV_FILE.bak"

echo ""
echo -e "${GREEN}✅ Configuration complete!${NC}"
echo ""
echo "📝 Configuration saved to: .env.local"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review .env.local and adjust values if needed"
echo "  2. Run: ./scripts/setup.sh"
echo "  3. Start using: make deploy"
echo ""
