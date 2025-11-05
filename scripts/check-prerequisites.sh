#!/bin/bash

################################################################################
# DevOps Lab - PREREQUISITES CHECKER
# Comprehensive script to verify all required tools are installed and working
# 
# Usage: ./scripts/check-prerequisites.sh
# 
# This script checks:
# ✅ kubectl (Kubernetes command-line tool)
# ✅ helm (Package manager for Kubernetes)
# ✅ docker (Container runtime)
# ✅ git (Version control)
# ✅ Kubernetes cluster connectivity
# ✅ Helm 3+ (not 2.x)
# ✅ Docker daemon running
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Symbols
CHECK="✅"
CROSS="❌"
ARROW="→"
DIVIDER="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# Logging functions
print_header() {
    echo ""
    echo -e "${BLUE}${DIVIDER}${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}${DIVIDER}${NC}"
    echo ""
}

log_success() {
    echo -e "${GREEN}${CHECK}${NC} $1"
    ((CHECKS_PASSED++))
}

log_fail() {
    echo -e "${RED}${CROSS}${NC} $1"
    ((CHECKS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}⚠️ ${NC} $1"
    ((CHECKS_WARNING++))
}

log_info() {
    echo -e "${CYAN}${ARROW}${NC} $1"
}

log_section() {
    echo -e "${BLUE}■${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Get version info
get_version() {
    "$1" --version 2>/dev/null || "$1" -v 2>/dev/null || echo "unknown"
}

################################################################################
# PREREQUISITE CHECKS
################################################################################

print_header "DevOps Lab - Prerequisites Check"

# ============================================================================
# 1. Check kubectl
# ============================================================================
print_header "1️⃣  Checking kubectl (Kubernetes CLI)"

if command_exists kubectl; then
    KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null | head -1 || echo "unknown")
    log_success "kubectl is installed"
    log_info "Version: $KUBECTL_VERSION"
    
    # Try to connect to cluster
    if kubectl cluster-info &> /dev/null; then
        CLUSTER_INFO=$(kubectl cluster-info 2>/dev/null | head -1)
        log_success "Kubernetes cluster is accessible"
        log_info "Info: $CLUSTER_INFO"
        
        # Get current context
        CURRENT_CONTEXT=$(kubectl config current-context)
        log_info "Current context: $CURRENT_CONTEXT"
        
        # Get K8s server version
        SERVER_VERSION=$(kubectl version --short 2>/dev/null | grep -oP 'Server: v\d+\.\d+\.\d+' | cut -d' ' -f2 || echo "unknown")
        log_info "Kubernetes Server Version: $SERVER_VERSION"
        
        # Get node count
        NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
        log_info "Nodes available: $NODE_COUNT"
        
    else
        log_fail "Cannot connect to Kubernetes cluster"
        log_warning "Please start your Kubernetes cluster (Docker Desktop, Minikube, Kind, etc.)"
        log_info "For Docker Desktop: Check if Kubernetes is enabled in preferences"
        log_info "For Minikube: Run 'minikube start'"
    fi
else
    log_fail "kubectl is NOT installed"
    log_info "Install: https://kubernetes.io/docs/tasks/tools/"
    log_info "macOS: brew install kubectl"
    log_info "Linux: curl -LO https://dl.k8s.io/release/stable.txt && kubectl install"
    log_info "Windows (WSL2): sudo apt-get install kubectl"
fi

# ============================================================================
# 2. Check Helm
# ============================================================================
print_header "2️⃣  Checking Helm (Kubernetes Package Manager)"

if command_exists helm; then
    HELM_VERSION=$(helm version --short 2>/dev/null || echo "unknown")
    log_success "Helm is installed"
    log_info "Version: $HELM_VERSION"
    
    # Check if Helm 3
    if echo "$HELM_VERSION" | grep -q "v3"; then
        log_success "Helm 3+ detected (compatible)"
    else
        log_warning "Helm version may not be v3+ (v3+ is required)"
    fi
    
    # Check Helm repos
    REPO_COUNT=$(helm repo list 2>/dev/null | tail -n +2 | wc -l)
    log_info "Helm repositories configured: $REPO_COUNT"
    
else
    log_fail "Helm is NOT installed"
    log_info "Install: https://helm.sh/docs/intro/install/"
    log_info "macOS: brew install helm"
    log_info "Linux: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
    log_info "Windows (WSL2): sudo apt-get install helm"
fi

# ============================================================================
# 3. Check Docker
# ============================================================================
print_header "3️⃣  Checking Docker (Container Runtime)"

if command_exists docker; then
    DOCKER_VERSION=$(docker --version 2>/dev/null)
    log_success "Docker is installed"
    log_info "Version: $DOCKER_VERSION"
    
    # Check if Docker daemon is running
    if docker ps &> /dev/null; then
        log_success "Docker daemon is running"
        
        # Get Docker info
        DOCKER_INFO=$(docker info 2>/dev/null | grep "Storage Driver" | cut -d' ' -f3-)
        log_info "Storage Driver: $DOCKER_INFO"
        
        # Check local registry
        if docker ps 2>/dev/null | grep -q "localhost:5001"; then
            log_success "Local Docker registry (localhost:5001) is running"
        else
            log_warning "Local Docker registry (localhost:5001) is NOT running"
            log_info "It will be created during setup if needed"
        fi
        
    else
        log_fail "Docker daemon is NOT running"
        log_info "Please start Docker Desktop or Docker daemon"
        log_info "macOS: Start Docker Desktop application"
        log_info "Linux: sudo systemctl start docker"
        log_info "Windows: Start Docker Desktop from Start menu"
    fi
else
    log_fail "Docker is NOT installed"
    log_info "Install: https://docs.docker.com/get-docker/"
    log_info "macOS: brew install --cask docker"
    log_info "Linux: curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
fi

# ============================================================================
# 4. Check Git
# ============================================================================
print_header "4️⃣  Checking Git (Version Control)"

if command_exists git; then
    GIT_VERSION=$(git --version)
    log_success "Git is installed"
    log_info "Version: $GIT_VERSION"
    
    # Check Git config
    if git config --get user.name &> /dev/null; then
        GIT_USER=$(git config --get user.name)
        GIT_EMAIL=$(git config --get user.email)
        log_success "Git user configured"
        log_info "User: $GIT_USER <$GIT_EMAIL>"
    else
        log_warning "Git user not configured"
        log_info "Configure: git config --global user.name 'Your Name'"
        log_info "Configure: git config --global user.email 'your.email@example.com'"
    fi
else
    log_fail "Git is NOT installed"
    log_info "Install: https://git-scm.com/downloads"
    log_info "macOS: brew install git"
    log_info "Linux: sudo apt-get install git"
fi

# ============================================================================
# 5. Additional checks
# ============================================================================
print_header "5️⃣  Additional Checks"

# Check Make
if command_exists make; then
    MAKE_VERSION=$(make --version 2>/dev/null | head -1)
    log_success "Make is installed ($MAKE_VERSION)"
else
    log_warning "Make is NOT installed (optional, for convenience)"
    log_info "Install: macOS: brew install make, Linux: sudo apt-get install make"
fi

# Check jq (JSON processor)
if command_exists jq; then
    JQ_VERSION=$(jq --version 2>/dev/null)
    log_success "jq is installed ($JQ_VERSION)"
else
    log_warning "jq is NOT installed (optional, for JSON processing)"
fi

# ============================================================================
# 6. System information
# ============================================================================
print_header "6️⃣  System Information"

OS_NAME=$(uname -s)
OS_VERSION=$(uname -r)
log_info "OS: $OS_NAME $OS_VERSION"

ARCH=$(uname -m)
log_info "Architecture: $ARCH"

RAM=$(free -h 2>/dev/null | grep Mem | awk '{print $2}' || vm_stat | grep "Pages free" | awk '{print $3}')
log_info "Available Memory: ${RAM}B (minimum 4GB recommended)"

# ============================================================================
# SUMMARY REPORT
# ============================================================================
print_header "📊 Summary Report"

echo ""
echo -e "${GREEN}Passed:${NC} ${CHECKS_PASSED}"
echo -e "${RED}Failed:${NC} ${CHECKS_FAILED}"
echo -e "${YELLOW}Warnings:${NC} ${CHECKS_WARNING}"
echo ""

# ============================================================================
# FINAL STATUS
# ============================================================================

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}${DIVIDER}${NC}"
    echo -e "${GREEN}✅ ALL PREREQUISITES MET! You're ready to proceed!${NC}"
    echo -e "${GREEN}${DIVIDER}${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. Run: ${CYAN}./scripts/setup.sh${NC}"
    echo -e "  2. Or run: ${CYAN}make setup${NC}"
    echo ""
    exit 0
    
else
    echo -e "${RED}${DIVIDER}${NC}"
    echo -e "${RED}❌ Some prerequisites are missing!${NC}"
    echo -e "${RED}${DIVIDER}${NC}"
    echo ""
    echo -e "${YELLOW}Please install the missing tools above, then run this check again.${NC}"
    echo ""
    
    if [ $CHECKS_WARNING -gt 0 ]; then
        echo -e "${CYAN}ℹ️  Warnings can usually be ignored, but fix them for best experience.${NC}"
        echo ""
    fi
    
    exit 1
fi
