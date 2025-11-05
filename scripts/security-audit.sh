#!/usr/bin/env bash
#
# Security Audit Script
# Performs comprehensive security checks on Kubernetes deployment
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NAMESPACE="${1:-default}"
ISSUES_FOUND=0

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Security Audit for Kubernetes Deployment                ║${NC}"
echo -e "${BLUE}║     Namespace: $NAMESPACE${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

# Function to check and report
check() {
  local category=$1
  local description=$2
  local result=$3
  
  if [ "$result" = "true" ]; then
    echo -e "${GREEN}✓${NC} $category: $description"
  else
    echo -e "${RED}✗${NC} $category: $description"
    ((ISSUES_FOUND++))
  fi
}

# Check 1: ServiceAccounts
echo -e "${YELLOW}[1/10] Checking ServiceAccounts...${NC}"
SVCACCTS=$(kubectl get serviceaccounts -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
if [ -n "$SVCACCTS" ]; then
  echo "  Found ServiceAccounts: $SVCACCTS"
  for svc in $SVCACCTS; do
    AUTO_MOUNT=$(kubectl get serviceaccount "$svc" -n "$NAMESPACE" -o jsonpath='{.automountServiceAccountToken}')
    if [ "$AUTO_MOUNT" != "false" ]; then
      check "ServiceAccount" "$svc: automountServiceAccountToken should be false" "false"
    else
      check "ServiceAccount" "$svc: automountServiceAccountToken correctly disabled" "true"
    fi
  done
fi
echo

# Check 2: RBAC
echo -e "${YELLOW}[2/10] Checking RBAC Policies...${NC}"
ROLES=$(kubectl get roles -n "$NAMESPACE" -o name 2>/dev/null | wc -l)
check "RBAC" "Roles configured ($ROLES found)" "$([ $ROLES -gt 0 ] && echo true || echo false)"

ROLEBINDINGS=$(kubectl get rolebindings -n "$NAMESPACE" -o name 2>/dev/null | wc -l)
check "RBAC" "RoleBindings configured ($ROLEBINDINGS found)" "$([ $ROLEBINDINGS -gt 0 ] && echo true || echo false)"
echo

# Check 3: Security Context
echo -e "${YELLOW}[3/10] Checking Pod Security Context...${NC}"
PODS=$(kubectl get pods -n "$NAMESPACE" -o name 2>/dev/null)
PRIVILEGED_COUNT=0
READONLYFS_COUNT=0

for pod in $PODS; do
  POD_NAME=$(basename "$pod")
  PRIVILEGED=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].securityContext.privileged}' 2>/dev/null || echo "false")
  READONLYFS=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null || echo "false")
  
  [ "$PRIVILEGED" = "true" ] && ((PRIVILEGED_COUNT++))
  [ "$READONLYFS" != "true" ] && ((READONLYFS_COUNT++))
done

check "Security" "No privileged containers" "$([ $PRIVILEGED_COUNT -eq 0 ] && echo true || echo false)"
check "Security" "Read-only root filesystem" "$([ $READONLYFS_COUNT -eq 0 ] && echo true || echo false)"
echo

# Check 4: Network Policies
echo -e "${YELLOW}[4/10] Checking Network Policies...${NC}"
NETPOLICIES=$(kubectl get networkpolicies -n "$NAMESPACE" -o name 2>/dev/null | wc -l)
check "Network" "NetworkPolicies configured ($NETPOLICIES found)" "$([ $NETPOLICIES -gt 0 ] && echo true || echo false)"
echo

# Check 5: Pod Security Policies
echo -e "${YELLOW}[5/10] Checking Pod Security Policies...${NC}"
PSPS=$(kubectl get psp -o name 2>/dev/null | wc -l)
check "Security" "Pod Security Policies exist ($PSPS found)" "$([ $PSPS -gt 0 ] && echo true || echo false)"
echo

# Check 6: Resource Limits
echo -e "${YELLOW}[6/10] Checking Resource Limits...${NC}"
RESOURCE_LIMITED=0
for pod in $PODS; do
  POD_NAME=$(basename "$pod")
  LIMITS=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.limits}' 2>/dev/null)
  [ -n "$LIMITS" ] && ((RESOURCE_LIMITED++))
done

check "Resources" "Pods have resource limits ($RESOURCE_LIMITED/$((${#PODS[@]}))" "$([ $RESOURCE_LIMITED -gt 0 ] && echo true || echo false)"
echo

# Check 7: Secrets Management
echo -e "${YELLOW}[7/10] Checking Secrets Management...${NC}"
SEALED_SECRETS=$(kubectl get sealedsecrets -n "$NAMESPACE" -o name 2>/dev/null | wc -l || echo "0")
REGULAR_SECRETS=$(kubectl get secrets -n "$NAMESPACE" --field-selector type!=kubernetes.io/service-account-token -o name 2>/dev/null | wc -l)

check "Secrets" "Using Sealed Secrets" "$([ $SEALED_SECRETS -gt 0 ] && echo true || echo false)"
echo

# Check 8: TLS Configuration
echo -e "${YELLOW}[8/10] Checking TLS Configuration...${NC}"
TLS_SECRETS=$(kubectl get secrets -n "$NAMESPACE" --field-selector type=kubernetes.io/tls -o name 2>/dev/null | wc -l)
check "TLS" "TLS certificates configured ($TLS_SECRETS found)" "$([ $TLS_SECRETS -gt 0 ] && echo true || echo false)"
echo

# Check 9: Pod Disruption Budgets
echo -e "${YELLOW}[9/10] Checking Pod Disruption Budgets...${NC}"
PDBS=$(kubectl get pdb -n "$NAMESPACE" -o name 2>/dev/null | wc -l)
check "Reliability" "Pod Disruption Budgets configured ($PDBS found)" "$([ $PDBS -gt 0 ] && echo true || echo false)"
echo

# Check 10: Audit Logging
echo -e "${YELLOW}[10/10] Checking Audit Logging...${NC}"
EVENTS=$(kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' 2>/dev/null | wc -l)
check "Audit" "Events are being logged ($EVENTS events)" "$([ $EVENTS -gt 0 ] && echo true || echo false)"
echo

# Summary
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
if [ $ISSUES_FOUND -eq 0 ]; then
  echo -e "${GREEN}║     Security Audit Complete - No Critical Issues Found! ✓   ║${NC}"
else
  echo -e "${YELLOW}║     Security Audit Complete - $ISSUES_FOUND Issues Found        ║${NC}"
fi
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

echo -e "${BLUE}Recommendations:${NC}"
echo "  1. Enable Pod Security Standards (PSS) in your cluster"
echo "  2. Implement least privilege RBAC policies"
echo "  3. Use Sealed Secrets for sensitive data"
echo "  4. Configure NetworkPolicies for pod-to-pod communication"
echo "  5. Set resource requests and limits on all containers"
echo "  6. Enable Pod Disruption Budgets for critical workloads"
echo "  7. Use non-root containers whenever possible"
echo "  8. Regularly audit and rotate secrets"
echo

exit $ISSUES_FOUND
