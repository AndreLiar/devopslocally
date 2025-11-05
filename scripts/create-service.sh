#!/bin/bash

################################################################################
# Service Generator Script
# Creates a new microservice with scaffolding, Helm chart, and CI/CD pipeline
#
# Usage: ./scripts/create-service.sh <service-name> <language>
# Example: ./scripts/create-service.sh payment nodejs
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $*${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

log_error() {
    echo -e "${RED}❌ $*${NC}"
}

log_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$*${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Validate input
if [ $# -lt 2 ]; then
    log_error "Missing required arguments"
    echo ""
    echo "Usage: ./scripts/create-service.sh <service-name> <language>"
    echo ""
    echo "Supported languages:"
    echo "  • nodejs"
    echo "  • python"
    echo "  • go"
    echo ""
    echo "Examples:"
    echo "  ./scripts/create-service.sh payment nodejs"
    echo "  ./scripts/create-service.sh inventory python"
    echo "  ./scripts/create-service.sh user-service go"
    exit 1
fi

SERVICE_NAME="$1"
LANGUAGE="$2"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_DIR="$PROJECT_DIR/${SERVICE_NAME}-service"
CHART_DIR="$PROJECT_DIR/${SERVICE_NAME}-chart"

# Validate language
case "$LANGUAGE" in
    nodejs|node)
        LANGUAGE="nodejs"
        PORT=3000
        ;;
    python|py)
        LANGUAGE="python"
        PORT=5000
        ;;
    go)
        LANGUAGE="go"
        PORT=8080
        ;;
    *)
        log_error "Unsupported language: $LANGUAGE"
        echo "Supported: nodejs, python, go"
        exit 1
        ;;
esac

log_section "🎉 Creating New Service: $SERVICE_NAME ($LANGUAGE)"

# Check if service already exists
if [ -d "$SERVICE_DIR" ]; then
    log_error "Service directory already exists: $SERVICE_DIR"
    exit 1
fi

if [ -d "$CHART_DIR" ]; then
    log_error "Helm chart directory already exists: $CHART_DIR"
    exit 1
fi

# Create service directory
log_info "Creating service directory..."
mkdir -p "$SERVICE_DIR"
log_success "Service directory created"

# Create service based on language
log_section "Setting up $LANGUAGE service"

case "$LANGUAGE" in
    nodejs)
        create_nodejs_service
        ;;
    python)
        create_python_service
        ;;
    go)
        create_go_service
        ;;
esac

# Create Helm chart
create_helm_chart

# Create CI/CD workflow
create_workflow

# Print summary
print_summary
