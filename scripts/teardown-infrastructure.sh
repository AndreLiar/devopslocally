#!/bin/bash

################################################################################
# DevOps Infrastructure Teardown Script
#
# This script safely removes all infrastructure deployed by setup-infrastructure.sh
#
# Usage:
#   bash scripts/teardown-infrastructure.sh
#   bash scripts/teardown-infrastructure.sh --force
#
# Warning: This is DESTRUCTIVE and will remove:
#   - All Helm releases (ArgoCD, Prometheus, Grafana, Loki)
#   - All namespaces (dev, staging, production, argocd, monitoring)
#   - All resources in those namespaces
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

FORCE=false

log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC} $1"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

main() {
    # Parse arguments
    if [[ "$#" -gt 0 && "$1" == "--force" ]]; then
        FORCE=true
    fi
    
    print_header "🧹 DevOps Infrastructure Teardown"
    
    log_warning "This will DELETE all infrastructure!"
    log_warning "This includes:"
    echo "  • ArgoCD (and all applications)"
    echo "  • Prometheus & Grafana"
    echo "  • Loki & Promtail"
    echo "  • All namespaces: dev, staging, production, argocd, monitoring"
    echo "  • All resources in these namespaces"
    echo ""
    
    if [ "$FORCE" = false ]; then
        read -p "Are you absolutely sure? Type 'yes' to confirm: " -r
        if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            log_info "Teardown cancelled"
            exit 0
        fi
    fi
    
    echo ""
    log_info "Starting teardown..."
    
    # Uninstall Helm releases
    log_info "Removing Helm releases..."
    
    helm uninstall loki -n monitoring 2>/dev/null || log_warning "Loki not found"
    helm uninstall kube-prometheus -n monitoring 2>/dev/null || log_warning "Prometheus not found"
    helm uninstall argocd -n argocd 2>/dev/null || log_warning "ArgoCD not found"
    
    log_success "Helm releases removed"
    
    # Delete namespaces
    log_info "Deleting namespaces..."
    
    for ns in dev staging production argocd monitoring; do
        if kubectl get namespace "$ns" &>/dev/null; then
            log_info "Deleting namespace: $ns"
            kubectl delete namespace "$ns" --wait=true 2>/dev/null || log_warning "Failed to delete namespace $ns"
        fi
    done
    
    log_success "Namespaces deleted"
    
    # Clean up local files
    log_info "Cleaning up local files..."
    
    rm -f .credentials .setup-infrastructure.log
    
    log_success "Local files cleaned"
    
    echo ""
    print_header "✅ Teardown Complete"
    
    log_success "All infrastructure has been removed"
    log_info "To redeploy: bash scripts/setup-infrastructure.sh"
}

main "$@"
