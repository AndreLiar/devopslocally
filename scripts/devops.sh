#!/usr/bin/env bash
#
# DevOps Central Command Tool
# Unified interface for all devopslocally operations
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Version
VERSION="1.0.0"

show_help() {
  cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║           DevOps Lab Central Command Tool v1.0.0            ║
║                   All-in-One DevOps Operations              ║
╚══════════════════════════════════════════════════════════════╝

USAGE:
  devops <command> [options]

INFRASTRUCTURE COMMANDS:
  setup                 One-click cluster setup
  teardown              Remove all deployed services
  status                Show cluster and service status
  port-forward          Port forward to services
  
DEPLOYMENT COMMANDS:
  create-service        Generate new microservice
  deploy                Deploy or update services
  rollback              Rollback to previous deployment
  scale                 Scale services up/down
  
DATABASE COMMANDS:
  backup-db             Create database backup
  restore-db            Restore from database backup
  db-shell              Connect to database shell
  
SECURITY COMMANDS:
  audit                 Run security audit
  setup-secrets         Initialize Sealed Secrets
  rotate-secrets        Rotate encrypted secrets
  check-rbac            Verify RBAC configuration
  
MONITORING COMMANDS:
  logs                  View application logs
  metrics               Display metrics dashboard
  alerts                Show active alerts
  health                Health check services
  
TESTING COMMANDS:
  test                  Run test suite
  test-phase2           Run Phase 2 tests
  test-phase3           Run Phase 3 tests
  lint                  Run code linting
  
UTILITY COMMANDS:
  docs                  Open documentation
  version               Show version
  help                  Show this help message

EXAMPLES:
  devops setup                          # Initialize cluster
  devops create-service myapp nodejs    # Create Node.js service
  devops backup-db                      # Backup database
  devops audit default                  # Security audit
  devops test                           # Run tests
  devops logs auth-service              # View logs

For more help:
  devops <command> --help

EOF
}

# Commands

cmd_setup() {
  echo -e "${BLUE}Running one-click setup...${NC}"
  cd "$PROJECT_ROOT"
  ./scripts/setup.sh "$@"
}

cmd_teardown() {
  echo -e "${YELLOW}Tearing down services...${NC}"
  kubectl delete all --all -n default 2>/dev/null || true
  kubectl delete pvc --all -n default 2>/dev/null || true
  echo -e "${GREEN}✓ Teardown complete${NC}"
}

cmd_status() {
  echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║      Cluster & Service Status          ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
  echo
  
  echo -e "${CYAN}Cluster Info:${NC}"
  kubectl cluster-info | grep -i "server\|dns"
  echo
  
  echo -e "${CYAN}Nodes:${NC}"
  kubectl get nodes -o wide
  echo
  
  echo -e "${CYAN}Pods:${NC}"
  kubectl get pods -A -o wide
  echo
  
  echo -e "${CYAN}Services:${NC}"
  kubectl get svc -A -o wide
}

cmd_port_forward() {
  local service="${1:-auth-service}"
  local namespace="${2:-default}"
  local port="${3:-3000}"
  
  echo -e "${GREEN}Port forwarding: $service → localhost:$port${NC}"
  kubectl port-forward -n "$namespace" "svc/$service" "$port:$port"
}

cmd_create_service() {
  local name="${1:-}"
  local language="${2:-}"
  
  if [ -z "$name" ] || [ -z "$language" ]; then
    echo -e "${RED}Usage: devops create-service <name> <language>${NC}"
    echo "Languages: nodejs, python, go"
    exit 1
  fi
  
  cd "$PROJECT_ROOT"
  ./scripts/create-service.sh "$name" "$language"
}

cmd_deploy() {
  echo -e "${BLUE}Deploying services...${NC}"
  cd "$PROJECT_ROOT"
  helm upgrade --install auth auth-chart/ -n default --wait
  echo -e "${GREEN}✓ Deployment complete${NC}"
}

cmd_backup_db() {
  cd "$PROJECT_ROOT"
  ./scripts/backup-database.sh
}

cmd_restore_db() {
  local backup="${1:-}"
  if [ -z "$backup" ]; then
    echo -e "${RED}Usage: devops restore-db <backup-file>${NC}"
    ls -la .backups/ 2>/dev/null || echo "No backups found"
    exit 1
  fi
  
  cd "$PROJECT_ROOT"
  ./scripts/restore-database.sh "$backup"
}

cmd_audit() {
  local namespace="${1:-default}"
  cd "$PROJECT_ROOT"
  ./scripts/security-audit.sh "$namespace"
}

cmd_setup_secrets() {
  cd "$PROJECT_ROOT"
  ./scripts/setup-sealed-secrets.sh "${1:-0.18.0}"
}

cmd_test() {
  local test_type="${1:-all}"
  
  case $test_type in
    all)
      echo -e "${BLUE}Running all tests...${NC}"
      cd "$PROJECT_ROOT/auth-service" && npm test
      ;;
    phase2)
      echo -e "${BLUE}Running Phase 2 tests...${NC}"
      cd "$PROJECT_ROOT" && ./tests/test-phase2-integration.sh
      ;;
    phase3)
      echo -e "${BLUE}Running Phase 3 tests...${NC}"
      cd "$PROJECT_ROOT" && ./tests/test-phase3-integration.sh
      ;;
    *)
      echo -e "${RED}Unknown test type: $test_type${NC}"
      exit 1
      ;;
  esac
}

cmd_logs() {
  local service="${1:-}"
  local namespace="${2:-default}"
  
  if [ -z "$service" ]; then
    echo -e "${CYAN}Recent pod logs:${NC}"
    kubectl logs -n "$namespace" -l app="$service" --tail=50 -f 2>/dev/null || \
      kubectl logs -n "$namespace" --tail=50 -f 2>/dev/null
  else
    kubectl logs -n "$namespace" -l app="$service" --tail=100 -f
  fi
}

cmd_health() {
  echo -e "${BLUE}Health Check:${NC}"
  
  # Check API server
  if kubectl cluster-info &> /dev/null; then
    echo -e "${GREEN}✓${NC} Kubernetes cluster accessible"
  else
    echo -e "${RED}✗${NC} Kubernetes cluster not accessible"
    return 1
  fi
  
  # Check auth service
  if kubectl get svc auth-service &> /dev/null; then
    READY=$(kubectl get deployment auth-service -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    DESIRED=$(kubectl get deployment auth-service -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
    echo -e "${GREEN}✓${NC} Auth service: $READY/$DESIRED replicas ready"
  fi
  
  # Check PostgreSQL
  if kubectl get statefulset postgres &> /dev/null; then
    READY=$(kubectl get statefulset postgres -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    DESIRED=$(kubectl get statefulset postgres -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
    echo -e "${GREEN}✓${NC} PostgreSQL: $READY/$DESIRED replicas ready"
  fi
}

cmd_docs() {
  echo -e "${BLUE}Opening documentation...${NC}"
  
  if command -v open &> /dev/null; then
    open "$PROJECT_ROOT/docs/PHASE3_GUIDE.md"
  elif command -v xdg-open &> /dev/null; then
    xdg-open "$PROJECT_ROOT/docs/PHASE3_GUIDE.md"
  else
    echo "Documentation at: $PROJECT_ROOT/docs/"
    ls -la "$PROJECT_ROOT/docs/"
  fi
}

cmd_version() {
  echo "DevOps Lab v$VERSION"
  kubectl version --client --short 2>/dev/null || echo "kubectl not found"
  helm version --short 2>/dev/null || echo "helm not found"
}

# Main dispatcher
main() {
  local command="${1:-help}"
  
  case $command in
    setup) cmd_setup "${@:2}" ;;
    teardown) cmd_teardown ;;
    status) cmd_status ;;
    port-forward) cmd_port_forward "${@:2}" ;;
    create-service) cmd_create_service "${@:2}" ;;
    deploy) cmd_deploy ;;
    backup-db) cmd_backup_db ;;
    restore-db) cmd_restore_db "${@:2}" ;;
    audit) cmd_audit "${@:2}" ;;
    setup-secrets) cmd_setup_secrets "${@:2}" ;;
    test) cmd_test "${@:2}" ;;
    logs) cmd_logs "${@:2}" ;;
    health) cmd_health ;;
    docs) cmd_docs ;;
    version) cmd_version ;;
    -v|--version) cmd_version ;;
    -h|--help|help) show_help ;;
    *)
      echo -e "${RED}Unknown command: $command${NC}"
      echo
      show_help
      exit 1
      ;;
  esac
}

main "$@"
