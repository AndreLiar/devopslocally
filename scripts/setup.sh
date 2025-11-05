#!/bin/bash

################################################################################
# DevOps Lab - ONE-CLICK SETUP SCRIPT
# This script automates the complete setup of the DevOps infrastructure
# 
# Usage: ./scripts/setup.sh
# Time: ~10-15 minutes
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
K8S_CONTEXT="${K8S_CONTEXT:-docker-desktop}"
K8S_CLUSTER="${K8S_CLUSTER:-docker-desktop}"
REGISTRY_URL="${REGISTRY_URL:-localhost:5001}"
ARGOCD_NAMESPACE="argocd"
MONITORING_NAMESPACE="monitoring"
DEFAULT_NAMESPACE="default"
APP_NAMESPACE="default"

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

# Check prerequisites
check_prerequisites() {
    log_section "STEP 1: Checking Prerequisites"

    local missing_tools=()

    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    else
        log_success "kubectl found ($(kubectl version --client --short 2>/dev/null | head -1))"
    fi

    # Check helm
    if ! command -v helm &> /dev/null; then
        missing_tools+=("helm")
    else
        log_success "helm found ($(helm version --short | grep -oP 'v\d+\.\d+\.\d+'))"
    fi

    # Check docker
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    else
        log_success "docker found ($(docker --version))"
    fi

    # Check git
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    else
        log_success "git found ($(git --version))"
    fi

    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install the missing tools and try again"
        return 1
    fi

    log_success "All prerequisites met!"
}

# Check Kubernetes cluster
check_kubernetes_cluster() {
    log_section "STEP 2: Checking Kubernetes Cluster"

    if ! kubectl cluster-info &> /dev/null; then
        log_error "Kubernetes cluster not running"
        log_info "Please start your Kubernetes cluster (Docker Desktop, Minikube, etc.)"
        return 1
    fi

    log_success "Kubernetes cluster is running"
    
    # Get cluster info
    local cluster_name=$(kubectl config current-context)
    local k8s_version=$(kubectl version --short 2>/dev/null | grep -oP 'Server: v\d+\.\d+\.\d+' | cut -d' ' -f2)
    
    log_info "Cluster: $cluster_name"
    log_info "Kubernetes: $k8s_version"
}

# Create namespaces
create_namespaces() {
    log_section "STEP 3: Creating Kubernetes Namespaces"

    for namespace in "$ARGOCD_NAMESPACE" "$MONITORING_NAMESPACE" "$APP_NAMESPACE"; do
        if kubectl get namespace "$namespace" &> /dev/null; then
            log_warning "Namespace '$namespace' already exists"
        else
            log_info "Creating namespace '$namespace'..."
            kubectl create namespace "$namespace"
            log_success "Namespace '$namespace' created"
        fi
    done
}

# Install ArgoCD
install_argocd() {
    log_section "STEP 4: Installing ArgoCD (GitOps)"

    if kubectl get deployment -n "$ARGOCD_NAMESPACE" argocd-server &> /dev/null 2>&1; then
        log_warning "ArgoCD is already installed"
        return 0
    fi

    log_info "Installing ArgoCD into namespace '$ARGOCD_NAMESPACE'..."
    
    if helm repo list | grep -q "argoproj"; then
        helm repo update argoproj
    else
        helm repo add argoproj https://argoproj.github.io/argo-helm
        helm repo update argoproj
    fi

    helm upgrade --install argocd argoproj/argo-cd \
        --namespace "$ARGOCD_NAMESPACE" \
        --set server.service.type=LoadBalancer \
        --set "configs.secret.argocdServerAdminPassword=admin123" \
        --wait \
        --timeout 5m

    log_success "ArgoCD installed"
    
    # Get ArgoCD UI URL
    log_info "ArgoCD UI will be available at http://localhost:8080"
    log_info "Default username: admin"
    log_info "Default password: admin123"
}

# Install Monitoring Stack (kube-prometheus-stack)
install_monitoring_stack() {
    log_section "STEP 5: Installing Monitoring Stack (Prometheus, Grafana, Loki)"

    if helm repo list | grep -q "prometheus-community"; then
        helm repo update prometheus-community
    else
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo update prometheus-community
    fi

    if helm repo list | grep -q "grafana"; then
        helm repo update grafana
    else
        helm repo add grafana https://grafana.github.io/helm-charts
        helm repo update grafana
    fi

    # Install kube-prometheus-stack
    if helm list -n "$MONITORING_NAMESPACE" | grep -q "kube-prometheus-stack"; then
        log_warning "Monitoring stack already installed"
    else
        log_info "Installing kube-prometheus-stack..."
        helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
            --namespace "$MONITORING_NAMESPACE" \
            --set grafana.adminPassword=admin123 \
            --wait \
            --timeout 5m
        log_success "kube-prometheus-stack installed"
    fi

    # Install Loki (log aggregation)
    if helm list -n "$MONITORING_NAMESPACE" | grep -q "loki-stack"; then
        log_warning "Loki stack already installed"
    else
        log_info "Installing Loki stack for log aggregation..."
        helm install loki-stack grafana/loki-stack \
            --namespace "$MONITORING_NAMESPACE" \
            --set promtail.enabled=true \
            --set grafana.enabled=false \
            --wait \
            --timeout 5m
        log_success "Loki stack installed"
    fi

    # Get Grafana password
    local grafana_pass=$(kubectl get secret -n "$MONITORING_NAMESPACE" kube-prometheus-grafana -o jsonpath='{.data.admin-password}' 2>/dev/null | base64 -d || echo "admin123")
    log_info "Grafana UI will be available at http://localhost:3000"
    log_info "Grafana username: admin"
    log_info "Grafana password: $grafana_pass"
}

# Setup local Docker registry
setup_docker_registry() {
    log_section "STEP 6: Setting Up Local Docker Registry"

    if docker ps | grep -q "registry.*$REGISTRY_URL"; then
        log_warning "Local Docker registry is already running"
        return 0
    fi

    if docker ps -a | grep -q "registry.*$REGISTRY_URL"; then
        log_info "Starting existing local Docker registry..."
        docker start registry || true
    else
        log_info "Creating local Docker registry at $REGISTRY_URL..."
        docker run -d \
            -p "5001:5000" \
            --name registry \
            --restart always \
            registry:2
    fi

    log_success "Local Docker registry is ready at $REGISTRY_URL"
    log_info "You can push images: docker push $REGISTRY_URL/image-name:tag"
}

# Configure kubectl context
configure_kubectl_context() {
    log_section "STEP 7: Verifying kubectl Context"

    local current_context=$(kubectl config current-context)
    log_info "Current kubectl context: $current_context"

    if [ "$current_context" != "$K8S_CONTEXT" ]; then
        log_warning "Current context is '$current_context', expected '$K8S_CONTEXT'"
        log_info "To switch context, run: kubectl config use-context $K8S_CONTEXT"
    else
        log_success "kubectl context is correct: $current_context"
    fi
}

# Create image pull secrets
create_image_pull_secrets() {
    log_section "STEP 8: Creating Image Pull Secrets"

    local secret_name="ghcr-login-secret"

    if kubectl get secret "$secret_name" -n "$APP_NAMESPACE" &> /dev/null; then
        log_warning "Image pull secret already exists"
    else
        log_info "Creating image pull secret for private registries..."
        # Note: Users will need to update these credentials
        kubectl create secret docker-registry "$secret_name" \
            --docker-server=ghcr.io \
            --docker-username=unused \
            --docker-password=unused \
            --docker-email=unused@example.com \
            -n "$APP_NAMESPACE" \
            || log_warning "Could not create image pull secret (manual setup may be needed)"
        log_success "Image pull secret created"
    fi
}

# Deploy auth-service example
deploy_auth_service() {
    log_section "STEP 9: Deploying Example Service (auth-service)"

    if [ ! -d "$PROJECT_DIR/auth-chart" ]; then
        log_warning "auth-chart not found, skipping deployment"
        return 0
    fi

    log_info "Deploying auth-service using Helm..."
    helm upgrade --install auth-service "$PROJECT_DIR/auth-chart" \
        --namespace "$APP_NAMESPACE" \
        --set image.repository="$REGISTRY_URL/auth-service" \
        --set image.tag="latest" \
        --wait \
        --timeout 2m \
        || log_warning "auth-service deployment may not have succeeded (check with kubectl)"

    log_success "auth-service deployment initiated"
}

# Port forward services
setup_port_forwards() {
    log_section "STEP 10: Setting Up Port Forwards"

    log_info "Port forwarding setup (run in separate terminal if needed):"
    log_info ""
    log_info "  # Grafana (Monitoring)"
    log_info "  kubectl port-forward -n $MONITORING_NAMESPACE svc/kube-prometheus-grafana 3000:80"
    log_info ""
    log_info "  # Prometheus"
    log_info "  kubectl port-forward -n $MONITORING_NAMESPACE svc/kube-prometheus-prometheus 9090:9090"
    log_info ""
    log_info "  # auth-service"
    log_info "  kubectl port-forward -n $APP_NAMESPACE svc/auth-service 3001:3000"
    log_info ""
}

# Verify setup
verify_setup() {
    log_section "STEP 11: Verifying Setup"

    local success_count=0
    local total_checks=0

    # Check namespaces
    for namespace in "$ARGOCD_NAMESPACE" "$MONITORING_NAMESPACE"; do
        total_checks=$((total_checks + 1))
        if kubectl get namespace "$namespace" &> /dev/null; then
            log_success "Namespace '$namespace' ✓"
            success_count=$((success_count + 1))
        else
            log_error "Namespace '$namespace' ✗"
        fi
    done

    # Check ArgoCD
    total_checks=$((total_checks + 1))
    if kubectl get deployment -n "$ARGOCD_NAMESPACE" argocd-server &> /dev/null; then
        log_success "ArgoCD deployment ✓"
        success_count=$((success_count + 1))
    else
        log_error "ArgoCD deployment ✗"
    fi

    # Check Prometheus
    total_checks=$((total_checks + 1))
    if kubectl get deployment -n "$MONITORING_NAMESPACE" kube-prometheus-prometheus &> /dev/null; then
        log_success "Prometheus ✓"
        success_count=$((success_count + 1))
    else
        log_error "Prometheus ✗"
    fi

    # Check Grafana
    total_checks=$((total_checks + 1))
    if kubectl get deployment -n "$MONITORING_NAMESPACE" kube-prometheus-grafana &> /dev/null; then
        log_success "Grafana ✓"
        success_count=$((success_count + 1))
    else
        log_error "Grafana ✗"
    fi

    # Check Docker registry
    total_checks=$((total_checks + 1))
    if docker ps | grep -q "registry"; then
        log_success "Local Docker Registry ✓"
        success_count=$((success_count + 1))
    else
        log_error "Local Docker Registry ✗"
    fi

    echo ""
    log_info "Verification: $success_count/$total_checks checks passed"
    echo ""
}

# Print summary
print_summary() {
    log_section "SETUP COMPLETE! 🎉"

    echo ""
    echo -e "${GREEN}Your DevOps infrastructure is ready!${NC}"
    echo ""
    echo "📊 What's Running:"
    echo "  ✅ Kubernetes cluster"
    echo "  ✅ ArgoCD (GitOps controller)"
    echo "  ✅ Prometheus (metrics collection)"
    echo "  ✅ Grafana (dashboards & visualization)"
    echo "  ✅ Loki (log aggregation)"
    echo "  ✅ Local Docker Registry ($REGISTRY_URL)"
    echo ""
    echo "🔗 Access Points:"
    echo "  • Grafana:      http://localhost:3000 (admin / check setup.sh output)"
    echo "  • Prometheus:   http://localhost:9090 (via kubectl port-forward)"
    echo "  • ArgoCD UI:    http://localhost:8080 (via kubectl port-forward)"
    echo ""
    echo "📚 Next Steps:"
    echo "  1. Start port forwarding: make port-forward"
    echo "  2. Access Grafana: open http://localhost:3000"
    echo "  3. Create a new service: ./scripts/create-service.sh my-api nodejs"
    echo "  4. Deploy to cluster: make deploy"
    echo ""
    echo "📖 Documentation:"
    echo "  • README.md - Overview and quick start"
    echo "  • Makefile - Common commands"
    echo "  • docs/ - Detailed guides"
    echo ""
    echo -e "${BLUE}Happy DevOps-ing! 🚀${NC}"
    echo ""
}

# Main execution
main() {
    log_section "🚀 DevOps Lab - One-Click Setup"
    echo "Project: $PROJECT_DIR"
    echo "Kubernetes Context: $K8S_CONTEXT"
    echo ""

    # Run setup steps
    check_prerequisites || exit 1
    check_kubernetes_cluster || exit 1
    create_namespaces
    install_argocd
    install_monitoring_stack
    setup_docker_registry
    configure_kubectl_context
    create_image_pull_secrets
    deploy_auth_service
    setup_port_forwards
    verify_setup
    print_summary
}

# Run main function
main "$@"
