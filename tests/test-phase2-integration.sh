#!/bin/bash

################################################################################
# Phase 2 Integration Tests
# Validates all Phase 2 features are working correctly
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0
TOTAL=0

# Test functions
log_test() {
    echo -e "${BLUE}Testing: $1${NC}"
}

log_pass() {
    echo -e "${GREEN}✅ PASS: $1${NC}"
    ((PASSED++))
}

log_fail() {
    echo -e "${RED}❌ FAIL: $1${NC}"
    ((FAILED++))
}

# Test 1: Service template generation
test_service_templates() {
    TOTAL=$((TOTAL + 3))
    
    log_test "Service template generation"
    
    # Test Node.js template
    if [ -f "./scripts/create-service.sh" ]; then
        log_pass "create-service.sh exists"
    else
        log_fail "create-service.sh not found"
    fi
    
    # Test service scaffolding
    if grep -q "create_nodejs_service" "./scripts/create-service.sh"; then
        log_pass "Node.js service function defined"
    else
        log_fail "Node.js service function not found"
    fi
    
    # Test Python template
    if grep -q "create_python_service" "./scripts/create-service.sh"; then
        log_pass "Python service function defined"
    else
        log_fail "Python service function not found"
    fi
}

# Test 2: Helm template validation
test_helm_templates() {
    TOTAL=$((TOTAL + 4))
    
    log_test "Helm templates validation"
    
    # Test ConfigMap template
    if [ -f "auth-chart/templates/configmap.yaml" ]; then
        log_pass "ConfigMap template exists"
    else
        log_fail "ConfigMap template not found"
    fi
    
    # Test Secrets template
    if [ -f "auth-chart/templates/secrets.yaml" ]; then
        log_pass "Secrets template exists"
    else
        log_fail "Secrets template not found"
    fi
    
    # Test HPA template
    if [ -f "auth-chart/templates/hpa.yaml" ]; then
        log_pass "HPA template exists"
    else
        log_fail "HPA template not found"
    fi
    
    # Test Network Policy template
    if [ -f "auth-chart/templates/networkpolicy.yaml" ]; then
        log_pass "Network Policy template exists"
    else
        log_fail "Network Policy template not found"
    fi
}

# Test 3: CI/CD Pipeline validation
test_cicd_pipelines() {
    TOTAL=$((TOTAL + 2))
    
    log_test "CI/CD Pipeline validation"
    
    # Test test-and-scan workflow
    if [ -f ".github/workflows/test-and-scan.yml" ]; then
        log_pass "test-and-scan workflow exists"
    else
        log_fail "test-and-scan workflow not found"
    fi
    
    # Test deploy workflow
    if [ -f ".github/workflows/deploy.yml" ]; then
        log_pass "deploy workflow exists"
    else
        log_fail "deploy workflow not found"
    fi
}

# Test 4: Git hooks validation
test_git_hooks() {
    TOTAL=$((TOTAL + 3))
    
    log_test "Git hooks validation"
    
    # Test commitlint config
    if [ -f "commitlint.config.js" ]; then
        log_pass "commitlint config exists"
    else
        log_fail "commitlint config not found"
    fi
    
    # Test eslint config
    if [ -f ".eslintrc" ]; then
        log_pass "ESLint config exists"
    else
        log_fail "ESLint config not found"
    fi
    
    # Test prettier config
    if [ -f ".prettierrc" ]; then
        log_pass "Prettier config exists"
    else
        log_fail "Prettier config not found"
    fi
}

# Test 5: PostgreSQL chart validation
test_postgres_chart() {
    TOTAL=$((TOTAL + 2))
    
    log_test "PostgreSQL Helm chart validation"
    
    # Test postgres chart exists
    if [ -d "postgres-chart" ]; then
        log_pass "PostgreSQL chart directory exists"
    else
        log_fail "PostgreSQL chart directory not found"
    fi
    
    # Test postgres values
    if [ -f "postgres-chart/values.yaml" ]; then
        log_pass "PostgreSQL values.yaml exists"
    else
        log_fail "PostgreSQL values.yaml not found"
    fi
}

# Test 6: Helm chart rendering
test_helm_rendering() {
    TOTAL=$((TOTAL + 2))
    
    log_test "Helm chart rendering"
    
    # Test auth-chart rendering
    if helm template auth-chart auth-chart/ > /dev/null 2>&1; then
        log_pass "auth-chart renders successfully"
    else
        log_fail "auth-chart rendering failed"
    fi
    
    # Test postgres-chart rendering
    if helm template postgres postgres-chart/ > /dev/null 2>&1; then
        log_pass "postgres-chart renders successfully"
    else
        log_fail "postgres-chart rendering failed"
    fi
}

# Test 7: Makefile commands
test_makefile() {
    TOTAL=$((TOTAL + 2))
    
    log_test "Makefile commands"
    
    # Test if Makefile exists
    if [ -f "Makefile" ]; then
        log_pass "Makefile exists"
    else
        log_fail "Makefile not found"
    fi
    
    # Test if make help works
    if make help > /dev/null 2>&1; then
        log_pass "make help command works"
    else
        log_fail "make help command failed"
    fi
}

# Test 8: Documentation
test_documentation() {
    TOTAL=$((TOTAL + 2))
    
    log_test "Documentation"
    
    # Test README exists
    if [ -f "README.md" ]; then
        log_pass "README.md exists"
    else
        log_fail "README.md not found"
    fi
    
    # Test if README mentions Phase 2
    if grep -q "Phase 2" "README.md"; then
        log_pass "README.md documents Phase 2"
    else
        log_fail "README.md missing Phase 2 documentation"
    fi
}

# Main execution
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Phase 2 Implementation Tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Navigate to project root
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT" || exit 1

test_service_templates
echo ""

test_helm_templates
echo ""

test_cicd_pipelines
echo ""

test_git_hooks
echo ""

test_postgres_chart
echo ""

test_helm_rendering
echo ""

test_makefile
echo ""

test_documentation

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Test Results${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Total:  $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed!${NC}"
    exit 1
fi
