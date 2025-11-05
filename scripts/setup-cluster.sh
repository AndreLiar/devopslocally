#!/bin/bash

################################################################################
# Automated Cluster Setup Script
# Sets up all prerequisites for multi-environment deployment
#
# Prerequisites checked/installed:
#   - Kubernetes cluster (minikube for local, or detect existing)
#   - kubectl
#   - Helm
#   - git
#
# Usage: ./scripts/setup-cluster.sh [options]
# Options:
#   --cluster-type [minikube|docker|existing]  (default: auto-detect)
#   --skip-checks                              (skip all prerequisite checks)
#   --minikube-cpus [number]                   (default: 4)
#   --minikube-memory [MB]                     (default: 8192)
#   --minikube-disk [GB]                       (default: 50)
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
CLUSTER_TYPE="auto"
SKIP_CHECKS=false
MINIKUBE_CPUS=4
MINIKUBE_MEMORY=8192
MINIKUBE_DISK=50

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
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$*${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cluster-type)
                CLUSTER_TYPE="$2"
                shift 2
                ;;
            --skip-checks)
                SKIP_CHECKS=true
                shift
                ;;
            --minikube-cpus)
                MINIKUBE_CPUS="$2"
                shift 2
                ;;
            --minikube-memory)
                MINIKUBE_MEMORY="$2"
                shift 2
                ;;
            --minikube-disk)
                MINIKUBE_DISK="$2"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

show_usage() {
    cat << EOF
Usage: ./scripts/setup-cluster.sh [options]

Options:
    --cluster-type [minikube|docker|existing]  Cluster type (default: auto-detect)
    --skip-checks                              Skip prerequisite checks
    --minikube-cpus [number]                   CPU cores for minikube (default: 4)
    --minikube-memory [MB]                     Memory for minikube (default: 8192)
    --minikube-disk [GB]                       Disk for minikube (default: 50)

Examples:
    ./scripts/setup-cluster.sh                          # Auto-detect and setup
    ./scripts/setup-cluster.sh --cluster-type minikube  # Force minikube setup
    ./scripts/setup-cluster.sh --cluster-type existing  # Use existing cluster
    ./scripts/setup-cluster.sh --minikube-cpus 8 --minikube-memory 16384
EOF
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

# Get package manager for OS
get_package_manager() {
    local os="$1"
    case "$os" in
        linux)
            if command_exists apt-get; then
                echo "apt"
            elif command_exists yum; then
                echo "yum"
            elif command_exists pacman; then
                echo "pacman"
            fi
            ;;
        macos)
            echo "brew"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Install command using package manager
install_with_package_manager() {
    local package="$1"
    local pm="$2"
    local os="$3"

    log_info "Installing $package via $pm..."

    case "$pm" in
        apt)
            sudo apt-get update
            sudo apt-get install -y "$package"
            ;;
        yum)
            sudo yum install -y "$package"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$package"
            ;;
        brew)
            brew install "$package"
            ;;
        *)
            log_error "Unable to install $package. Package manager not supported: $pm"
            return 1
            ;;
    esac

    log_success "$package installed"
}

# Check and install kubectl
check_and_install_kubectl() {
    log_section "Checking kubectl"

    if command_exists kubectl; then
        local version=$(kubectl version --client -o json 2>/dev/null | grep -o '"gitVersion":"[^"]*"' | cut -d'"' -f4)
        log_success "kubectl is already installed: $version"
        return 0
    fi

    log_warning "kubectl not found. Installing..."

    local os=$(detect_os)
    local pm=$(get_package_manager "$os")

    if [[ "$os" == "macos" ]]; then
        install_with_package_manager "kubectl" "$pm" "$os"
    elif [[ "$os" == "linux" ]]; then
        # Try snap first on Linux
        if command_exists snap; then
            log_info "Installing kubectl via snap..."
            sudo snap install kubectl --classic
            log_success "kubectl installed via snap"
        else
            install_with_package_manager "kubectl" "$pm" "$os"
        fi
    else
        log_error "Unsupported OS: $os"
        return 1
    fi
}

# Check and install Helm
check_and_install_helm() {
    log_section "Checking Helm"

    if command_exists helm; then
        local version=$(helm version --short 2>/dev/null | grep -o 'v[0-9.]*')
        log_success "Helm is already installed: $version"
        return 0
    fi

    log_warning "Helm not found. Installing..."

    local os=$(detect_os)
    local pm=$(get_package_manager "$os")

    if [[ "$os" == "macos" ]]; then
        install_with_package_manager "helm" "$pm" "$os"
    elif [[ "$os" == "linux" ]]; then
        if command_exists snap; then
            log_info "Installing helm via snap..."
            sudo snap install helm --classic
            log_success "helm installed via snap"
        else
            # Use curl to install helm
            log_info "Installing helm via curl..."
            curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
            log_success "helm installed"
        fi
    else
        log_error "Unsupported OS: $os"
        return 1
    fi
}

# Check and install git
check_and_install_git() {
    log_section "Checking git"

    if command_exists git; then
        local version=$(git --version)
        log_success "git is already installed: $version"
        return 0
    fi

    log_warning "git not found. Installing..."

    local os=$(detect_os)
    local pm=$(get_package_manager "$os")

    if [[ "$os" == "macos" ]]; then
        install_with_package_manager "git" "$pm" "$os"
    elif [[ "$os" == "linux" ]]; then
        install_with_package_manager "git" "$pm" "$os"
    else
        log_error "Unsupported OS: $os"
        return 1
    fi
}

# Check and install minikube
check_and_install_minikube() {
    log_section "Checking Minikube"

    if command_exists minikube; then
        local version=$(minikube version)
        log_success "Minikube is already installed: $version"
        return 0
    fi

    log_warning "Minikube not found. Installing..."

    local os=$(detect_os)
    local pm=$(get_package_manager "$os")

    if [[ "$os" == "macos" ]]; then
        install_with_package_manager "minikube" "$pm" "$os"
    elif [[ "$os" == "linux" ]]; then
        if command_exists snap; then
            log_info "Installing minikube via snap..."
            sudo snap install minikube --classic
            log_success "minikube installed via snap"
        else
            # Use curl to install minikube
            log_info "Installing minikube via curl..."
            curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
            sudo install minikube-linux-amd64 /usr/local/bin/minikube
            rm minikube-linux-amd64
            log_success "minikube installed"
        fi
    else
        log_error "Unsupported OS: $os"
        return 1
    fi
}

# Detect existing cluster
detect_existing_cluster() {
    log_section "Detecting Kubernetes Cluster"

    # Check if kubectl can connect to a cluster
    if ! command_exists kubectl; then
        return 1
    fi

    if kubectl cluster-info &> /dev/null; then
        local cluster_info=$(kubectl cluster-info 2>/dev/null | head -1)
        log_success "Found existing cluster: $cluster_info"
        return 0
    fi

    return 1
}

# Start minikube
start_minikube() {
    log_section "Starting Minikube Cluster"

    log_info "Starting minikube with:"
    log_info "  CPUs: $MINIKUBE_CPUS"
    log_info "  Memory: ${MINIKUBE_MEMORY}MB"
    log_info "  Disk: ${MINIKUBE_DISK}GB"

    if minikube status | grep -q "Running"; then
        log_success "Minikube is already running"
        return 0
    fi

    # Start minikube with specified resources
    minikube start \
        --cpus="$MINIKUBE_CPUS" \
        --memory="$MINIKUBE_MEMORY" \
        --disk-size="${MINIKUBE_DISK}gb" \
        --driver=auto \
        --container-runtime=docker \
        --addons=ingress,dashboard,metrics-server

    # Wait for cluster to be ready
    log_info "Waiting for cluster to be ready..."
    kubectl wait --for=condition=ready node --all --timeout=300s

    log_success "Minikube cluster is running"

    # Display cluster info
    log_info "Cluster Info:"
    kubectl cluster-info
}

# Configure git
configure_git() {
    log_section "Configuring git"

    if ! command_exists git; then
        log_error "git is not installed"
        return 1
    fi

    # Check if git is configured
    local git_user=$(git config --global user.name 2>/dev/null || echo "")
    local git_email=$(git config --global user.email 2>/dev/null || echo "")

    if [[ -z "$git_user" ]] || [[ -z "$git_email" ]]; then
        log_warning "git is not configured globally"
        log_info "Please configure git with:"
        log_info "  git config --global user.name 'Your Name'"
        log_info "  git config --global user.email 'your.email@example.com'"
        return 1
    fi

    log_success "git is configured: $git_user <$git_email>"
    return 0
}

# Verify cluster connectivity
verify_cluster_connectivity() {
    log_section "Verifying Cluster Connectivity"

    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        return 1
    fi

    # Get cluster version
    local k8s_version=$(kubectl version --short 2>/dev/null | grep "Server Version" || echo "Unknown")
    log_success "Kubernetes cluster connected"
    log_info "$k8s_version"

    # Check nodes
    log_info "Cluster nodes:"
    kubectl get nodes -o wide

    return 0
}

# Test helm connectivity
test_helm_connectivity() {
    log_section "Testing Helm Connectivity"

    if ! helm version &> /dev/null; then
        log_error "Helm is not properly configured"
        return 1
    fi

    log_success "Helm is properly configured"
    helm version

    # Add common helm repos
    log_info "Adding Helm repositories..."
    helm repo add stable https://charts.helm.sh/stable 2>/dev/null || true
    helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
    helm repo update

    log_success "Helm repositories updated"
    return 0
}

# Main setup function
main() {
    log_section "🚀 Automated DevOps Cluster Setup"

    parse_arguments "$@"

    if [[ "$SKIP_CHECKS" == "true" ]]; then
        log_warning "Skipping all prerequisite checks"
        return 0
    fi

    # Step 1: Install tools
    log_section "Step 1: Installing Prerequisites"

    check_and_install_kubectl || true
    check_and_install_helm || true
    check_and_install_git || true

    # Step 2: Setup Kubernetes cluster
    log_section "Step 2: Setting Up Kubernetes Cluster"

    if [[ "$CLUSTER_TYPE" == "auto" ]]; then
        if detect_existing_cluster; then
            log_success "Using existing Kubernetes cluster"
        else
            log_info "No existing cluster found. Setting up Minikube..."
            check_and_install_minikube || true
            start_minikube
        fi
    elif [[ "$CLUSTER_TYPE" == "minikube" ]]; then
        check_and_install_minikube || true
        start_minikube
    elif [[ "$CLUSTER_TYPE" == "docker" ]]; then
        log_info "Using Docker Desktop Kubernetes"
        log_info "Please enable Kubernetes in Docker Desktop settings"
        verify_cluster_connectivity
    elif [[ "$CLUSTER_TYPE" == "existing" ]]; then
        log_info "Using existing Kubernetes cluster"
        verify_cluster_connectivity
    fi

    # Step 3: Configure git
    log_section "Step 3: Configuring git"

    configure_git || log_warning "git configuration incomplete"

    # Step 4: Verify all components
    log_section "Step 4: Verifying All Components"

    verify_cluster_connectivity || exit 1
    test_helm_connectivity || exit 1

    # Step 5: Summary
    log_section "✅ Cluster Setup Complete!"

    cat << EOF

All prerequisites are now installed and configured:
${GREEN}✅ kubectl${NC}        - Kubernetes CLI
${GREEN}✅ Helm${NC}            - Kubernetes package manager
${GREEN}✅ git${NC}            - Version control
${GREEN}✅ Kubernetes${NC}     - Container orchestration cluster

${CYAN}Next Steps:${NC}

1. Initialize multi-environment namespaces:
   ${YELLOW}./scripts/multi-env-manager.sh setup${NC}

2. Deploy to development environment:
   ${YELLOW}git push origin dev${NC}

3. Monitor deployment:
   ${YELLOW}./scripts/multi-env-manager.sh status${NC}

4. View documentation:
   ${YELLOW}cat docs/MULTI_ENVIRONMENT_SETUP.md${NC}

EOF
}

main "$@"
