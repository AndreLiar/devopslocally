#!/bin/bash

################################################################################
# ArgoCD Automated Setup & Management Script
# Installs, configures, and manages ArgoCD for GitOps deployments
#
# Features:
#   - Automated ArgoCD installation
#   - Repository configuration
#   - Application deployment
#   - Ingress setup
#   - Access management
#
# Usage: ./scripts/setup-argocd.sh [command] [options]
# Commands:
#   install     - Install ArgoCD
#   configure   - Configure repositories and applications
#   access      - Setup access and ingress
#   status      - Check ArgoCD status
#   cleanup     - Remove ArgoCD
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
ARGOCD_NAMESPACE="argocd"
ARGOCD_VERSION="latest"
GITHUB_REPO="${GITHUB_REPO:-https://github.com/AndreLiar/devopslocally.git}"
GITHUB_BRANCH="${GITHUB_BRANCH:-main}"
ARGOCD_SERVER_PASSWORD="${ARGOCD_SERVER_PASSWORD:-}"

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
    COMMAND="${1:-install}"
    shift || true
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --version)
                ARGOCD_VERSION="$2"
                shift 2
                ;;
            --repo)
                GITHUB_REPO="$2"
                shift 2
                ;;
            --branch)
                GITHUB_BRANCH="$2"
                shift 2
                ;;
            --password)
                ARGOCD_SERVER_PASSWORD="$2"
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
Usage: ./scripts/setup-argocd.sh [command] [options]

Commands:
    install      Install ArgoCD
    configure    Configure repositories and applications
    access       Setup access and ingress
    status       Check ArgoCD status
    cleanup      Remove ArgoCD

Options:
    --version [version]     ArgoCD version (default: latest)
    --repo [url]           Git repository URL
    --branch [branch]      Git branch (default: main)
    --password [password]  Admin password

Examples:
    ./scripts/setup-argocd.sh install
    ./scripts/setup-argocd.sh configure --repo https://github.com/yourorg/repo.git
    ./scripts/setup-argocd.sh access
    ./scripts/setup-argocd.sh status
EOF
}

# Check prerequisites
check_prerequisites() {
    log_section "Checking Prerequisites"

    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl not found. Please install kubectl first"
        exit 1
    fi
    log_success "kubectl found"

    if ! command -v helm &> /dev/null; then
        log_error "helm not found. Please install helm first"
        exit 1
    fi
    log_success "helm found"

    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    log_success "Kubernetes cluster connected"
}

# Install ArgoCD
install_argocd() {
    log_section "Installing ArgoCD"

    log_info "Creating ArgoCD namespace..."
    kubectl create namespace "$ARGOCD_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    log_success "Namespace created"

    log_info "Adding ArgoCD Helm repository..."
    helm repo add argocd https://argoproj.github.io/argo-helm 2>/dev/null || true
    helm repo update
    log_success "Helm repository added"

    log_info "Installing ArgoCD..."
    helm upgrade --install argocd argocd/argo-cd \
        --namespace "$ARGOCD_NAMESPACE" \
        --set server.service.type=LoadBalancer \
        --set server.ingress.enabled=true \
        --set server.ingress.ingressClassName=nginx \
        --set server.ingress.hosts[0]=argocd.local \
        --set configs.secret.argocdServerAdminPassword="$(openssl rand -base64 15)" \
        --wait

    log_success "ArgoCD installed"

    # Wait for deployment
    log_info "Waiting for ArgoCD server to be ready..."
    kubectl wait --for=condition=available --timeout=300s \
        deployment/argocd-server \
        -n "$ARGOCD_NAMESPACE" || true

    log_success "ArgoCD installation completed"
}

# Configure repositories
configure_repositories() {
    log_section "Configuring Git Repositories"

    log_info "Creating repository secret for GitHub..."
    
    # Create repository credential for GitHub
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: github-repo
  namespace: $ARGOCD_NAMESPACE
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: $GITHUB_REPO
  password: $GITHUB_PAT
  username: not-used
EOF

    log_success "Repository configured"
}

# Create applications
create_applications() {
    log_section "Creating ArgoCD Applications"

    for env in development staging production; do
        log_info "Creating application for $env environment..."
        
        kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-$env
  namespace: $ARGOCD_NAMESPACE
spec:
  project: default
  source:
    repoURL: $GITHUB_REPO
    targetRevision: $GITHUB_BRANCH
    path: helm/auth-service
    helm:
      releaseName: auth-service
      values: |
        environment: $env
        replicaCount: $(get_replicas_for_env "$env")
  destination:
    server: https://kubernetes.default.svc
    namespace: $env
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

        log_success "Application created for $env"
    done
}

# Get replicas for environment
get_replicas_for_env() {
    local env="$1"
    case "$env" in
        production) echo "3" ;;
        staging) echo "2" ;;
        development) echo "1" ;;
        *) echo "1" ;;
    esac
}

# Setup ingress and access
setup_access() {
    log_section "Setting Up Access & Ingress"

    log_info "Creating ingress for ArgoCD..."
    kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: $ARGOCD_NAMESPACE
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/ssl-protocols: "TLSv1.2 TLSv1.3"
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80
EOF

    log_success "Ingress created"

    log_info "Getting ArgoCD admin password..."
    local password=$(kubectl get secret argocd-initial-admin-secret \
        -n "$ARGOCD_NAMESPACE" \
        -o jsonpath="{.data.password}" | base64 -d)
    
    log_success "ArgoCD Access Information:"
    echo ""
    echo "  URL: https://argocd.local"
    echo "  Username: admin"
    echo "  Password: $password"
    echo ""
    echo "  Port forward: kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443"
    echo ""
}

# Check status
check_status() {
    log_section "ArgoCD Status"

    if ! kubectl get namespace "$ARGOCD_NAMESPACE" &> /dev/null; then
        log_warning "ArgoCD namespace not found"
        return 1
    fi

    log_info "Deployments:"
    kubectl get deployments -n "$ARGOCD_NAMESPACE"

    log_info "Pods:"
    kubectl get pods -n "$ARGOCD_NAMESPACE"

    log_info "Services:"
    kubectl get services -n "$ARGOCD_NAMESPACE"

    log_info "Applications:"
    kubectl get applications -n "$ARGOCD_NAMESPACE" || log_warning "No applications found"

    log_success "Status check completed"
}

# Cleanup ArgoCD
cleanup_argocd() {
    log_section "Removing ArgoCD"

    read -p "Are you sure you want to remove ArgoCD? (y/N): " -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Removing ArgoCD helm release..."
        helm uninstall argocd -n "$ARGOCD_NAMESPACE" || true

        log_info "Removing ArgoCD namespace..."
        kubectl delete namespace "$ARGOCD_NAMESPACE" || true

        log_success "ArgoCD removed"
    else
        log_warning "Cleanup cancelled"
    fi
}

# Main function
main() {
    log_section "🚀 ArgoCD Automated Setup & Management"

    parse_arguments "$@"

    check_prerequisites

    case "$COMMAND" in
        install)
            install_argocd
            ;;
        configure)
            configure_repositories
            create_applications
            ;;
        access)
            setup_access
            ;;
        status)
            check_status
            ;;
        cleanup)
            cleanup_argocd
            ;;
        *)
            log_error "Unknown command: $COMMAND"
            show_usage
            exit 1
            ;;
    esac

    log_success "Command completed successfully!"
}

main "$@"
