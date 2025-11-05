#!/bin/bash

################################################################################
# Multi-Environment Management Script
# Manages dev, staging, and production environments
# 
# Usage: ./scripts/multi-env-manager.sh [command] [options]
# Commands:
#   setup       - Initialize all environments
#   deploy      - Deploy to specific environment
#   status      - Show status of all environments
#   rollback    - Rollback specific environment
#   clean       - Clean up environments
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
ENVIRONMENTS=("development" "staging" "production")
NAMESPACES=("development" "staging" "production")
HELM_CHART="helm/auth-service"
POSTGRES_CHART="helm/postgres"

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

# Get environment from branch or argument
get_environment() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"
    
    case "$branch" in
        main)
            echo "production"
            ;;
        staging)
            echo "staging"
            ;;
        dev)
            echo "development"
            ;;
        *)
            log_error "Unknown branch: $branch"
            echo "development"
            ;;
    esac
}

# Get namespace from environment
get_namespace() {
    local env="$1"
    case "$env" in
        production) echo "production" ;;
        staging) echo "staging" ;;
        development) echo "development" ;;
        *) echo "development" ;;
    esac
}

# Get values files for environment
get_values_files() {
    local env="$1"
    case "$env" in
        production)
            echo "helm/auth-service/values.yaml,helm/auth-service/values-prod.yaml"
            ;;
        staging)
            echo "helm/auth-service/values.yaml,helm/auth-service/values-staging.yaml"
            ;;
        development)
            echo "helm/auth-service/values.yaml,helm/auth-service/values-dev.yaml"
            ;;
        *)
            echo "helm/auth-service/values.yaml,helm/auth-service/values-dev.yaml"
            ;;
    esac
}

# Get replicas for environment
get_replicas() {
    local env="$1"
    case "$env" in
        production) echo "3" ;;
        staging) echo "2" ;;
        development) echo "1" ;;
        *) echo "1" ;;
    esac
}

# Setup all environments
setup_environments() {
    log_section "Setting up all environments"

    for namespace in "${NAMESPACES[@]}"; do
        log_info "Creating namespace: $namespace"
        kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
        
        # Set resource quotas
        kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: env-quota
  namespace: $namespace
spec:
  hard:
    requests.cpu: "10"
    requests.memory: "20Gi"
    limits.cpu: "20"
    limits.memory: "40Gi"
    pods: "100"
EOF
        
        log_success "Namespace $namespace configured"
    done
}

# Deploy to specific environment
deploy_to_env() {
    local env="$1"
    local namespace=$(get_namespace "$env")
    local values_files=$(get_values_files "$env")
    local replicas=$(get_replicas "$env")
    
    log_section "Deploying to $env environment"
    log_info "Namespace: $namespace"
    log_info "Replicas: $replicas"
    log_info "Values: $values_files"
    
    # Create namespace if needed
    kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
    
    # Convert comma-separated values to individual -f flags
    local helm_flags=""
    IFS=',' read -ra VALUES_ARRAY <<< "$values_files"
    for file in "${VALUES_ARRAY[@]}"; do
        helm_flags="$helm_flags -f $file"
    done
    
    # Deploy auth-service
    log_info "Deploying auth-service..."
    # shellcheck disable=SC2086
    helm upgrade --install auth-service "$HELM_CHART" \
        --namespace "$namespace" \
        $helm_flags \
        --set replicaCount="$replicas" \
        --set environment="$env" \
        --wait \
        --timeout 5m
    
    log_success "auth-service deployed to $env"
    
    # Deploy PostgreSQL for staging and production
    if [[ "$env" != "development" ]]; then
        log_info "Deploying PostgreSQL..."
        helm upgrade --install postgres "$POSTGRES_CHART" \
            --namespace "$namespace" \
            -f "helm/postgres/values.yaml" \
            -f "helm/postgres/values-${env}.yaml" \
            --wait \
            --timeout 5m
        log_success "PostgreSQL deployed to $env"
    fi
    
    # Wait for rollout
    log_info "Waiting for rollout..."
    kubectl rollout status deployment/auth-service -n "$namespace" --timeout=5m
    log_success "Deployment ready in $env"
}

# Show status of all environments
show_status() {
    log_section "Environment Status Overview"
    
    for namespace in "${NAMESPACES[@]}"; do
        log_info "=== $namespace ==="
        
        if kubectl get namespace "$namespace" &>/dev/null; then
            log_success "Namespace exists"
            
            # Show deployments
            echo -e "${CYAN}Deployments:${NC}"
            kubectl get deployments -n "$namespace" || log_warning "No deployments found"
            
            # Show pods
            echo -e "${CYAN}Pods:${NC}"
            kubectl get pods -n "$namespace" -o wide || log_warning "No pods found"
            
            # Show services
            echo -e "${CYAN}Services:${NC}"
            kubectl get services -n "$namespace" || log_warning "No services found"
            
            # Show ConfigMaps
            echo -e "${CYAN}ConfigMaps:${NC}"
            kubectl get configmaps -n "$namespace" || log_warning "No ConfigMaps found"
            
            # Show Secrets
            echo -e "${CYAN}Secrets:${NC}"
            kubectl get secrets -n "$namespace" || log_warning "No secrets found"
        else
            log_warning "Namespace does not exist"
        fi
        
        echo ""
    done
}

# Show detailed status for specific environment
show_env_details() {
    local env="$1"
    local namespace=$(get_namespace "$env")
    
    log_section "Detailed Status for $env"
    
    log_info "Pods:"
    kubectl get pods -n "$namespace" -o wide
    
    log_info "Pod Logs:"
    kubectl logs -n "$namespace" -l app=auth-service --tail=50 || log_warning "No logs found"
    
    log_info "Events:"
    kubectl get events -n "$namespace" --sort-by='.lastTimestamp' | tail -20
    
    log_info "Resource Usage:"
    kubectl top pods -n "$namespace" --selector=app=auth-service 2>/dev/null || log_warning "Metrics not available"
}

# Rollback specific environment
rollback_env() {
    local env="$1"
    local namespace=$(get_namespace "$env")
    
    log_section "Rolling back $env environment"
    log_warning "This will revert auth-service to the previous Helm release"
    
    read -p "Are you sure? (yes/no): " -r
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        helm rollback auth-service -n "$namespace"
        log_success "Rollback completed for $env"
        
        kubectl rollout status deployment/auth-service -n "$namespace" --timeout=5m
        log_success "Deployment stabilized"
    else
        log_warning "Rollback cancelled"
    fi
}

# Clean up environments
cleanup_environments() {
    log_section "Cleanup Environments"
    log_warning "This will delete all deployments in the specified environment"
    
    local env="${1:-all}"
    
    if [[ "$env" == "all" ]]; then
        read -p "Delete ALL environments? This cannot be undone. (yes/no): " -r
        if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            for namespace in "${NAMESPACES[@]}"; do
                log_info "Deleting namespace: $namespace"
                kubectl delete namespace "$namespace" --ignore-not-found
            done
            log_success "All environments cleaned up"
        else
            log_warning "Cleanup cancelled"
        fi
    else
        local namespace=$(get_namespace "$env")
        read -p "Delete environment: $env? (yes/no): " -r
        if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            log_info "Deleting namespace: $namespace"
            kubectl delete namespace "$namespace" --ignore-not-found
            log_success "Environment $env cleaned up"
        else
            log_warning "Cleanup cancelled"
        fi
    fi
}

# Compare environments
compare_environments() {
    log_section "Comparing Environments"
    
    echo -e "${CYAN}Development:${NC}"
    kubectl get deployment auth-service -n development -o yaml | grep -E "replicas|image:" || log_warning "Not found"
    
    echo ""
    echo -e "${CYAN}Staging:${NC}"
    kubectl get deployment auth-service -n staging -o yaml | grep -E "replicas|image:" || log_warning "Not found"
    
    echo ""
    echo -e "${CYAN}Production:${NC}"
    kubectl get deployment auth-service -n production -o yaml | grep -E "replicas|image:" || log_warning "Not found"
}

# Show usage
show_usage() {
    cat << EOF
Multi-Environment Management Script

Usage: $0 [command] [options]

Commands:
  setup               Initialize all environments
  deploy [env]        Deploy to specific environment (dev/staging/prod)
  status              Show status of all environments
  details [env]       Show detailed status for environment
  rollback [env]      Rollback specific environment
  cleanup [env|all]   Clean up environment(s)
  compare             Compare environments
  help                Show this help message

Examples:
  $0 setup
  $0 deploy development
  $0 deploy staging
  $0 deploy production
  $0 status
  $0 details staging
  $0 rollback production
  $0 cleanup staging
  $0 cleanup all
  $0 compare

Environment Mapping:
  - development  (dev branch)
  - staging      (staging branch)
  - production   (main branch)
EOF
}

# Main script
main() {
    local command="${1:-status}"
    
    case "$command" in
        setup)
            setup_environments
            ;;
        deploy)
            local env="${2:-$(get_environment)}"
            # Convert short names to full names
            case "$env" in
                dev) env="development" ;;
                prod) env="production" ;;
            esac
            deploy_to_env "$env"
            ;;
        status)
            show_status
            ;;
        details)
            local env="${2:-$(get_environment)}"
            case "$env" in
                dev) env="development" ;;
                prod) env="production" ;;
            esac
            show_env_details "$env"
            ;;
        rollback)
            local env="${2:-$(get_environment)}"
            case "$env" in
                dev) env="development" ;;
                prod) env="production" ;;
            esac
            rollback_env "$env"
            ;;
        cleanup)
            local env="${2:-}"
            cleanup_environments "$env"
            ;;
        compare)
            compare_environments
            ;;
        help)
            show_usage
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
