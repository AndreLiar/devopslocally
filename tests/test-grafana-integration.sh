#!/bin/bash

################################################################################
# Grafana Integration Tests
# 
# This script tests:
# 1. Datasource connectivity (Prometheus, Loki, Alertmanager)
# 2. Log retrieval from Loki
# 3. Dashboard availability and access
# 4. Cluster metrics queries
# 5. Kubernetes namespace logs
# 6. Pod-level metrics
################################################################################

set -e

# Configuration
GRAFANA_URL="http://localhost:3000"
GRAFANA_USER="admin"
GRAFANA_PASSWORD="UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX"
PROMETHEUS_PORT="9090"
LOKI_PORT="3100"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $1"
}

log_test_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

get_auth_token() {
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"user\":\"${GRAFANA_USER}\",\"password\":\"${GRAFANA_PASSWORD}\"}" \
        "${GRAFANA_URL}/api/auth/login" | jq -r '.token' 2>/dev/null || echo ""
}

################################################################################
# Test Suite 1: Grafana Availability
################################################################################

test_grafana_health() {
    log_test_header "Test Suite 1: Grafana Availability"
    
    log_info "Checking Grafana health endpoint..."
    local response=$(curl -s -w "\n%{http_code}" "${GRAFANA_URL}/api/health")
    local http_code=$(echo "$response" | tail -1)
    local body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" == "200" ]; then
        local version=$(echo "$body" | jq -r '.version' 2>/dev/null)
        log_success "Grafana is healthy (version: $version)"
    else
        log_error "Grafana health check failed (HTTP $http_code)"
        return 1
    fi
}

test_grafana_authentication() {
    log_info "Testing Grafana authentication..."
    
    local token=$(get_auth_token)
    if [ -z "$token" ] || [ "$token" == "null" ]; then
        log_error "Failed to authenticate with Grafana"
        return 1
    fi
    
    if [[ "$token" =~ ^[a-zA-Z0-9]+ ]]; then
        log_success "Successfully authenticated to Grafana"
        echo "$token"
    else
        log_error "Invalid token format received"
        return 1
    fi
}

################################################################################
# Test Suite 2: Datasource Tests
################################################################################

test_datasources() {
    log_test_header "Test Suite 2: Datasource Connectivity"
    
    local token=$(get_auth_token)
    if [ -z "$token" ]; then
        log_error "Cannot test datasources without valid token"
        return 1
    fi
    
    local response=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/datasources")
    
    local ds_count=$(echo "$response" | jq 'length')
    log_info "Found $ds_count datasources"
    
    # Test each datasource
    local ds_names=("Prometheus" "Loki" "Alertmanager")
    
    for ds_name in "${ds_names[@]}"; do
        local ds_info=$(echo "$response" | jq ".[] | select(.name==\"$ds_name\")")
        
        if [ -z "$ds_info" ]; then
            log_error "Datasource '$ds_name' not found"
            continue
        fi
        
        local ds_type=$(echo "$ds_info" | jq -r '.type')
        local ds_url=$(echo "$ds_info" | jq -r '.url')
        local ds_health=$(echo "$ds_info" | jq -r '.health // "unknown"')
        
        log_info "Testing datasource: $ds_name"
        
        # Test datasource health
        local health_response=$(curl -s -H "Authorization: Bearer $token" \
            "${GRAFANA_URL}/api/datasources/name/${ds_name}/health" 2>/dev/null)
        
        if echo "$health_response" | jq -e '.status' &>/dev/null; then
            local status=$(echo "$health_response" | jq -r '.status')
            if [ "$status" == "ok" ]; then
                log_success "Datasource '$ds_name' is healthy (Type: $ds_type, URL: $ds_url)"
            else
                log_warning "Datasource '$ds_name' status: $status"
            fi
        else
            log_warning "Could not verify health for '$ds_name', but it exists"
        fi
    done
}

################################################################################
# Test Suite 3: Prometheus Metrics Tests
################################################################################

test_prometheus_queries() {
    log_test_header "Test Suite 3: Prometheus Metrics"
    
    local token=$(get_auth_token)
    if [ -z "$token" ]; then
        log_error "Cannot test Prometheus without valid token"
        return 1
    fi
    
    # Get Prometheus datasource ID
    local prom_uid=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/datasources/name/Prometheus" | jq -r '.uid' 2>/dev/null)
    
    if [ -z "$prom_uid" ] || [ "$prom_uid" == "null" ]; then
        log_error "Could not find Prometheus datasource UID"
        return 1
    fi
    
    log_info "Prometheus UID: $prom_uid"
    
    # Test queries
    local queries=(
        'count(kube_pod_info)|Pod Count'
        'count(kube_node_info)|Node Count'
        'count(kube_namespace_info)|Namespace Count'
        'up{job="kubernetes-pods"}|Pod Metrics Available'
        'container_memory_usage_bytes|Memory Usage Available'
    )
    
    for query_info in "${queries[@]}"; do
        local query="${query_info%%|*}"
        local label="${query_info##*|}"
        
        log_info "Testing query: $label"
        
        # Query via Grafana API
        local response=$(curl -s -H "Authorization: Bearer $token" \
            "${GRAFANA_URL}/api/datasources/proxy/uid/${prom_uid}/api/v1/query?query=$(urlencode "$query")" 2>/dev/null)
        
        if echo "$response" | jq -e '.data' &>/dev/null; then
            local result_count=$(echo "$response" | jq '.data.result | length')
            if [ "$result_count" -gt 0 ]; then
                log_success "Query '$label' returned $result_count results"
            else
                log_warning "Query '$label' executed but returned no results (expected for some queries)"
            fi
        else
            log_warning "Could not verify query '$label' - check if metrics are being collected"
        fi
    done
}

# Helper function to URL encode
urlencode() {
    local string="$1"
    echo -n "$string" | jq -sRr @uri
}

################################################################################
# Test Suite 4: Loki Log Retrieval Tests
################################################################################

test_loki_logs() {
    log_test_header "Test Suite 4: Loki Log Retrieval"
    
    local token=$(get_auth_token)
    if [ -z "$token" ]; then
        log_error "Cannot test Loki without valid token"
        return 1
    fi
    
    # Get Loki datasource ID
    local loki_uid=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/datasources/name/Loki" | jq -r '.uid' 2>/dev/null)
    
    if [ -z "$loki_uid" ] || [ "$loki_uid" == "null" ]; then
        log_error "Could not find Loki datasource UID"
        return 1
    fi
    
    log_info "Loki UID: $loki_uid"
    
    # Test log queries
    local log_queries=(
        '{job="kubelet"}|Kubelet Logs'
        '{namespace="kube-system"}|Kube-system Logs'
        '{namespace="monitoring"}|Monitoring Logs'
        '{job="kubernetes-pods"}|Kubernetes Pod Logs'
    )
    
    for query_info in "${log_queries[@]}"; do
        local query="${query_info%%|*}"
        local label="${query_info##*|}"
        
        log_info "Testing log query: $label"
        
        # Query via Grafana API with time range (last 1 hour)
        local end_time=$(date +%s)000000000
        local start_time=$((end_time - 3600000000000))
        
        local response=$(curl -s -H "Authorization: Bearer $token" \
            "${GRAFANA_URL}/api/datasources/proxy/uid/${loki_uid}/loki/api/v1/query_range?query=$(urlencode "$query")&start=${start_time}&end=${end_time}" 2>/dev/null)
        
        if echo "$response" | jq -e '.data.result' &>/dev/null; then
            local stream_count=$(echo "$response" | jq '.data.result | length')
            if [ "$stream_count" -gt 0 ]; then
                local log_count=$(echo "$response" | jq '[.data.result[].values | length] | add')
                log_success "Log query '$label' found $stream_count streams with $log_count entries"
            else
                log_warning "Log query '$label' executed but found no logs (this may be expected if no logs exist)"
            fi
        else
            log_warning "Could not verify log query '$label'"
        fi
    done
}

################################################################################
# Test Suite 5: Dashboard Tests
################################################################################

test_dashboards() {
    log_test_header "Test Suite 5: Dashboard Availability"
    
    local token=$(get_auth_token)
    if [ -z "$token" ]; then
        log_error "Cannot test dashboards without valid token"
        return 1
    fi
    
    log_info "Fetching all available dashboards..."
    
    local dashboards=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/search?type=dash-db")
    
    local total_dashboards=$(echo "$dashboards" | jq 'length')
    log_info "Found $total_dashboards dashboards"
    
    # Test specific dashboard categories
    local dashboard_patterns=(
        "Kubernetes"
        "Alertmanager"
        "etcd"
        "CoreDNS"
    )
    
    for pattern in "${dashboard_patterns[@]}"; do
        local matching=$(echo "$dashboards" | jq "[.[] | select(.title | contains(\"$pattern\"))] | length")
        if [ "$matching" -gt 0 ]; then
            log_success "Found $matching dashboards matching '$pattern'"
            
            # List them
            echo "$dashboards" | jq -r ".[] | select(.title | contains(\"$pattern\")) | \"  • \(.title)\"" | head -5
        else
            log_warning "No dashboards found matching '$pattern'"
        fi
    done
}

test_dashboard_access() {
    log_test_header "Test Suite 6: Dashboard Data Access"
    
    local token=$(get_auth_token)
    if [ -z "$token" ]; then
        log_error "Cannot test dashboard data without valid token"
        return 1
    fi
    
    log_info "Testing access to Kubernetes dashboards..."
    
    # Find a Kubernetes dashboard
    local dashboards=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/search?type=dash-db")
    
    local k8s_dashboard=$(echo "$dashboards" | jq -r '.[] | select(.title | contains("Kubernetes")) | .uid' | head -1)
    
    if [ -z "$k8s_dashboard" ] || [ "$k8s_dashboard" == "null" ]; then
        log_warning "No Kubernetes dashboard found to test"
        return 0
    fi
    
    log_info "Testing dashboard: $k8s_dashboard"
    
    # Get dashboard data
    local dashboard_data=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/dashboards/uid/${k8s_dashboard}")
    
    if echo "$dashboard_data" | jq -e '.dashboard' &>/dev/null; then
        local panel_count=$(echo "$dashboard_data" | jq '.dashboard.panels | length')
        local title=$(echo "$dashboard_data" | jq -r '.dashboard.title')
        
        log_success "Accessed dashboard '$title' with $panel_count panels"
    else
        log_error "Could not access dashboard data"
    fi
}

################################################################################
# Test Suite 7: Cluster Information Tests
################################################################################

test_cluster_info() {
    log_test_header "Test Suite 7: Cluster Information"
    
    local token=$(get_auth_token)
    if [ -z "$token" ]; then
        log_error "Cannot test cluster info without valid token"
        return 1
    fi
    
    local prom_uid=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/datasources/name/Prometheus" | jq -r '.uid' 2>/dev/null)
    
    if [ -z "$prom_uid" ]; then
        log_error "Could not find Prometheus datasource"
        return 1
    fi
    
    # Test cluster queries
    local cluster_queries=(
        'count(kube_node_info)|Total Nodes'
        'sum(machine_cpu_cores)|Total CPU Cores'
        'sum(machine_memory_bytes)|Total Memory'
        'count(kube_namespace_info)|Total Namespaces'
        'count(kube_deployment_info)|Total Deployments'
        'count(kube_pod_info)|Total Pods'
    )
    
    for query_info in "${cluster_queries[@]}"; do
        local query="${query_info%%|*}"
        local label="${query_info##*|}"
        
        log_info "Fetching: $label"
        
        local response=$(curl -s -H "Authorization: Bearer $token" \
            "${GRAFANA_URL}/api/datasources/proxy/uid/${prom_uid}/api/v1/query?query=$(urlencode "$query")" 2>/dev/null)
        
        if echo "$response" | jq -e '.data.result' &>/dev/null; then
            local results=$(echo "$response" | jq '.data.result')
            if [ "$results" != "[]" ]; then
                local value=$(echo "$response" | jq -r '.data.result[0].value[1]' 2>/dev/null)
                log_success "$label: $value"
            else
                log_warning "$label: No data available (metrics may not be collected yet)"
            fi
        fi
    done
}

################################################################################
# Test Suite 8: Namespace-Specific Tests
################################################################################

test_namespace_logs() {
    log_test_header "Test Suite 8: Namespace-Specific Logs"
    
    local token=$(get_auth_token)
    if [ -z "$token" ]; then
        log_error "Cannot test namespace logs without valid token"
        return 1
    fi
    
    local loki_uid=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/datasources/name/Loki" | jq -r '.uid' 2>/dev/null)
    
    if [ -z "$loki_uid" ]; then
        log_error "Could not find Loki datasource"
        return 1
    fi
    
    # Get namespaces from Prometheus
    local namespaces=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/datasources/proxy/uid/prometheus/api/v1/label/namespace/values" 2>/dev/null | jq -r '.data[]?' 2>/dev/null)
    
    if [ -z "$namespaces" ]; then
        log_warning "Could not fetch namespaces from Prometheus"
        return 0
    fi
    
    log_info "Testing logs for each namespace..."
    
    local namespace_count=0
    while IFS= read -r namespace; do
        if [ -z "$namespace" ]; then
            continue
        fi
        
        ((namespace_count++))
        
        log_info "Namespace: $namespace"
        
        # Query logs for this namespace
        local query="{namespace=\"$namespace\"}"
        local end_time=$(date +%s)000000000
        local start_time=$((end_time - 3600000000000))
        
        local response=$(curl -s -H "Authorization: Bearer $token" \
            "${GRAFANA_URL}/api/datasources/proxy/uid/${loki_uid}/loki/api/v1/query_range?query=$(urlencode "$query")&start=${start_time}&end=${end_time}" 2>/dev/null)
        
        if echo "$response" | jq -e '.data.result' &>/dev/null; then
            local stream_count=$(echo "$response" | jq '.data.result | length')
            log_success "Namespace '$namespace': $stream_count log streams"
        fi
    done <<< "$namespaces"
    
    log_info "Tested $namespace_count namespaces"
}

################################################################################
# Test Suite 9: Pod-Level Metrics
################################################################################

test_pod_metrics() {
    log_test_header "Test Suite 9: Pod-Level Metrics"
    
    local token=$(get_auth_token)
    if [ -z "$token" ]; then
        log_error "Cannot test pod metrics without valid token"
        return 1
    fi
    
    local prom_uid=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/datasources/name/Prometheus" | jq -r '.uid' 2>/dev/null)
    
    if [ -z "$prom_uid" ]; then
        log_error "Could not find Prometheus datasource"
        return 1
    fi
    
    log_info "Testing pod-level metrics..."
    
    # Get list of pods
    local pod_query="count by (pod_name) (kube_pod_info) > 0"
    
    local response=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/datasources/proxy/uid/${prom_uid}/api/v1/query?query=$(urlencode "$pod_query")" 2>/dev/null)
    
    local pod_count=$(echo "$response" | jq '.data.result | length' 2>/dev/null)
    
    if [ "$pod_count" -gt 0 ]; then
        log_success "Found metrics for $pod_count pods"
        
        # Get CPU metrics for top 5 pods
        log_info "Top pods by CPU usage:"
        
        local cpu_query="topk(5, sum by (pod_name) (rate(container_cpu_usage_seconds_total[5m])))"
        
        local cpu_response=$(curl -s -H "Authorization: Bearer $token" \
            "${GRAFANA_URL}/api/datasources/proxy/uid/${prom_uid}/api/v1/query?query=$(urlencode "$cpu_query")" 2>/dev/null)
        
        echo "$cpu_response" | jq -r '.data.result[] | "  • \(.metric.pod_name): \(.value[1]) cores"' 2>/dev/null
    else
        log_warning "No pod metrics found"
    fi
}

################################################################################
# Test Suite 10: Alert Rules
################################################################################

test_alert_rules() {
    log_test_header "Test Suite 10: Alert Rules"
    
    local token=$(get_auth_token)
    if [ -z "$token" ]; then
        log_error "Cannot test alert rules without valid token"
        return 1
    fi
    
    # Get Prometheus UID
    local prom_uid=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/datasources/name/Prometheus" | jq -r '.uid' 2>/dev/null)
    
    if [ -z "$prom_uid" ]; then
        log_error "Could not find Prometheus datasource"
        return 1
    fi
    
    log_info "Fetching alert rules from Prometheus..."
    
    local response=$(curl -s -H "Authorization: Bearer $token" \
        "${GRAFANA_URL}/api/datasources/proxy/uid/${prom_uid}/api/v1/rules" 2>/dev/null)
    
    if echo "$response" | jq -e '.data.groups' &>/dev/null; then
        local group_count=$(echo "$response" | jq '.data.groups | length')
        local rule_count=$(echo "$response" | jq '[.data.groups[].rules | length] | add')
        
        log_success "Found $group_count alert groups with $rule_count rules"
    else
        log_warning "Could not fetch alert rules"
    fi
}

################################################################################
# Main Test Execution
################################################################################

main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║         GRAFANA INTEGRATION TEST SUITE                        ║"
    echo "║                                                                ║"
    echo "║  Testing: Datasources, Logs, Dashboards, Metrics & Cluster   ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Check if Grafana is accessible
    if ! curl -s -f "${GRAFANA_URL}/api/health" > /dev/null 2>&1; then
        log_error "Grafana is not accessible at ${GRAFANA_URL}"
        echo "Make sure to run: kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80"
        exit 1
    fi
    
    # Run all tests
    test_grafana_health
    test_grafana_authentication
    test_datasources
    test_prometheus_queries
    test_loki_logs
    test_dashboards
    test_dashboard_access
    test_cluster_info
    test_namespace_logs
    test_pod_metrics
    test_alert_rules
    
    # Print summary
    echo ""
    log_test_header "TEST SUMMARY"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        exit 1
    fi
}

# Run main function
main "$@"
