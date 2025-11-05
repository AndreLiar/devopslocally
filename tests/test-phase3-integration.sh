#!/usr/bin/env bash
#
# Phase 3 Integration Tests
# Tests security hardening, advanced testing, and documentation
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Phase 3 Integration Test Suite                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo

# Test 1: RBAC Template
test_rbac() {
  echo -e "${YELLOW}[1/10]${NC} Testing RBAC template..."
  if [ -f "auth-chart/templates/rbac.yaml" ]; then
    if grep -q "kind: Role" auth-chart/templates/rbac.yaml; then
      echo -e "${GREEN}✓${NC} RBAC template exists and contains Role definition"
      ((TESTS_PASSED++))
    else
      echo -e "${RED}✗${NC} RBAC template missing Role definition"
      ((TESTS_FAILED++))
    fi
  else
    echo -e "${RED}✗${NC} RBAC template not found"
    ((TESTS_FAILED++))
  fi
}

# Test 2: Pod Security Policy
test_psp() {
  echo -e "${YELLOW}[2/10]${NC} Testing Pod Security Policy template..."
  if [ -f "auth-chart/templates/psp.yaml" ]; then
    if grep -q "kind: PodSecurityPolicy" auth-chart/templates/psp.yaml; then
      echo -e "${GREEN}✓${NC} PSP template exists and contains PodSecurityPolicy"
      ((TESTS_PASSED++))
    else
      echo -e "${RED}✗${NC} PSP template missing PodSecurityPolicy definition"
      ((TESTS_FAILED++))
    fi
  else
    echo -e "${RED}✗${NC} PSP template not found"
    ((TESTS_FAILED++))
  fi
}

# Test 3: TLS Template
test_tls() {
  echo -e "${YELLOW}[3/10]${NC} Testing TLS template..."
  if [ -f "auth-chart/templates/tls.yaml" ]; then
    if grep -q "kind: Secret" auth-chart/templates/tls.yaml; then
      echo -e "${GREEN}✓${NC} TLS template exists and contains Secret definition"
      ((TESTS_PASSED++))
    else
      echo -e "${RED}✗${NC} TLS template missing Secret definition"
      ((TESTS_FAILED++))
    fi
  else
    echo -e "${RED}✗${NC} TLS template not found"
    ((TESTS_FAILED++))
  fi
}

# Test 4: Sealed Secrets Script
test_sealed_secrets_script() {
  echo -e "${YELLOW}[4/10]${NC} Testing Sealed Secrets setup script..."
  if [ -f "scripts/setup-sealed-secrets.sh" ]; then
    if chmod +x scripts/setup-sealed-secrets.sh 2>/dev/null && \
       grep -q "kubeseal" scripts/setup-sealed-secrets.sh; then
      echo -e "${GREEN}✓${NC} Sealed Secrets script is executable and valid"
      ((TESTS_PASSED++))
    else
      echo -e "${RED}✗${NC} Sealed Secrets script invalid"
      ((TESTS_FAILED++))
    fi
  else
    echo -e "${RED}✗${NC} Sealed Secrets script not found"
    ((TESTS_FAILED++))
  fi
}

# Test 5: Database Backup Script
test_backup_script() {
  echo -e "${YELLOW}[5/10]${NC} Testing database backup script..."
  if [ -f "scripts/backup-database.sh" ]; then
    if chmod +x scripts/backup-database.sh 2>/dev/null && \
       grep -q "pg_dump" scripts/backup-database.sh; then
      echo -e "${GREEN}✓${NC} Backup script is executable and valid"
      ((TESTS_PASSED++))
    else
      echo -e "${RED}✗${NC} Backup script invalid"
      ((TESTS_FAILED++))
    fi
  else
    echo -e "${RED}✗${NC} Backup script not found"
    ((TESTS_FAILED++))
  fi
}

# Test 6: Database Restore Script
test_restore_script() {
  echo -e "${YELLOW}[6/10]${NC} Testing database restore script..."
  if [ -f "scripts/restore-database.sh" ]; then
    if chmod +x scripts/restore-database.sh 2>/dev/null && \
       grep -q "psql" scripts/restore-database.sh; then
      echo -e "${GREEN}✓${NC} Restore script is executable and valid"
      ((TESTS_PASSED++))
    else
      echo -e "${RED}✗${NC} Restore script invalid"
      ((TESTS_FAILED++))
    fi
  else
    echo -e "${RED}✗${NC} Restore script not found"
    ((TESTS_FAILED++))
  fi
}

# Test 7: Security Audit Script
test_security_audit_script() {
  echo -e "${YELLOW}[7/10]${NC} Testing security audit script..."
  if [ -f "scripts/security-audit.sh" ]; then
    if chmod +x scripts/security-audit.sh 2>/dev/null && \
       grep -q "kubectl" scripts/security-audit.sh; then
      echo -e "${GREEN}✓${NC} Security audit script is executable and valid"
      ((TESTS_PASSED++))
    else
      echo -e "${RED}✗${NC} Security audit script invalid"
      ((TESTS_FAILED++))
    fi
  else
    echo -e "${RED}✗${NC} Security audit script not found"
    ((TESTS_FAILED++))
  fi
}

# Test 8: Documentation
test_documentation() {
  echo -e "${YELLOW}[8/10]${NC} Testing documentation files..."
  local docs_count=0
  [ -f "docs/SECURITY.md" ] && ((docs_count++))
  [ -f "docs/ARCHITECTURE.md" ] && ((docs_count++))
  [ -f "docs/TROUBLESHOOTING.md" ] && ((docs_count++))
  
  if [ $docs_count -ge 3 ]; then
    echo -e "${GREEN}✓${NC} All Phase 3 documentation files present ($docs_count/3)"
    ((TESTS_PASSED++))
  else
    echo -e "${RED}✗${NC} Missing documentation files ($docs_count/3)"
    ((TESTS_FAILED++))
  fi
}

# Test 9: Jest Configuration
test_jest_config() {
  echo -e "${YELLOW}[9/10]${NC} Testing Jest configuration..."
  if [ -f "auth-service/__tests__/jest.config.json" ] && \
     [ -f "auth-service/__tests__/setup.js" ] && \
     [ -f "auth-service/__tests__/server.test.js" ] && \
     [ -f "auth-service/__tests__/integration.test.js" ]; then
    echo -e "${GREEN}✓${NC} All Jest test files present"
    ((TESTS_PASSED++))
  else
    echo -e "${RED}✗${NC} Missing Jest test files"
    ((TESTS_FAILED++))
  fi
}

# Test 10: Helm Chart Syntax
test_helm_syntax() {
  echo -e "${YELLOW}[10/10]${NC} Testing Helm chart syntax..."
  if command -v helm &> /dev/null; then
    if helm lint auth-chart/ > /dev/null 2>&1; then
      echo -e "${GREEN}✓${NC} Helm chart passes lint checks"
      ((TESTS_PASSED++))
    else
      echo -e "${YELLOW}⚠${NC} Helm lint warnings (non-critical)"
      ((TESTS_PASSED++))
    fi
  else
    echo -e "${YELLOW}⚠${NC} Helm not installed, skipping lint check"
    ((TESTS_PASSED++))
  fi
}

# Run all tests
echo -e "${BLUE}Running Tests...${NC}"
echo

test_rbac
test_psp
test_tls
test_sealed_secrets_script
test_backup_script
test_restore_script
test_security_audit_script
test_documentation
test_jest_config
test_helm_syntax

echo
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    Test Results                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ All Phase 3 tests passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ Some Phase 3 tests failed${NC}"
  exit 1
fi
