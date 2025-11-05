#!/bin/bash

################################################################################
# Quick Grafana Integration Tests
# 
# Faster version that tests core functionality
################################################################################

GRAFANA_URL="http://localhost:3000"
GRAFANA_USER="admin"
GRAFANA_PASSWORD="UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}  GRAFANA INTEGRATION TESTS (QUICK)${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}\n"

# Test 1: Grafana Health
echo "Test 1: Grafana Health"
if curl -s -f "${GRAFANA_URL}/api/health" > /dev/null 2>&1; then
  VERSION=$(curl -s "${GRAFANA_URL}/api/health" | jq -r '.version')
  echo -e "${GREEN}✓ PASS${NC} - Grafana is healthy (v${VERSION})\n"
  ((PASS++))
else
  echo -e "${RED}✗ FAIL${NC} - Grafana is not accessible\n"
  ((FAIL++))
  exit 1
fi

# Test 2: Authentication (using basic auth)
echo "Test 2: Authentication"
AUTH_TEST=$(curl -s -w "%{http_code}" -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  "${GRAFANA_URL}/api/user" -o /dev/null)

if [ "$AUTH_TEST" == "200" ]; then
  echo -e "${GREEN}✓ PASS${NC} - Successfully authenticated\n"
  ((PASS++))
else
  echo -e "${RED}✗ FAIL${NC} - Authentication failed (HTTP $AUTH_TEST)\n"
  ((FAIL++))
  exit 1
fi

# Test 3: Datasources
echo "Test 3: Datasources"
DATASOURCES=$(curl -s -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  "${GRAFANA_URL}/api/datasources")

DS_COUNT=$(echo "$DATASOURCES" | jq 'length')
PROM=$(echo "$DATASOURCES" | jq '.[] | select(.name=="Prometheus")')
LOKI=$(echo "$DATASOURCES" | jq '.[] | select(.name=="Loki")')
AM=$(echo "$DATASOURCES" | jq '.[] | select(.name=="Alertmanager")')

if [ -n "$PROM" ] && [ -n "$LOKI" ] && [ -n "$AM" ]; then
  echo -e "${GREEN}✓ PASS${NC} - All 3 datasources configured\n"
  ((PASS++))
else
  echo -e "${RED}✗ FAIL${NC} - Missing datasources\n"
  ((FAIL++))
fi

# Test 4: Prometheus Queries
echo "Test 4: Prometheus Metrics Query"
PROM_UID=$(echo "$DATASOURCES" | jq -r '.[] | select(.name=="Prometheus") | .uid')

PROM_RESPONSE=$(curl -s -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  "${GRAFANA_URL}/api/datasources/proxy/uid/${PROM_UID}/api/v1/query?query=$(echo 'count(kube_pod_info)' | jq -sRr @uri)")

if echo "$PROM_RESPONSE" | jq -e '.data.result' > /dev/null 2>&1; then
  RESULT_COUNT=$(echo "$PROM_RESPONSE" | jq '.data.result | length')
  echo -e "${GREEN}✓ PASS${NC} - Prometheus query executed ($RESULT_COUNT results)\n"
  ((PASS++))
else
  echo -e "${YELLOW}⚠ WARN${NC} - Prometheus query check failed\n"
fi

# Test 5: Loki Logs
echo "Test 5: Loki Log Query"
LOKI_UID=$(echo "$DATASOURCES" | jq -r '.[] | select(.name=="Loki") | .uid')

END_TIME=$(date +%s)000000000
START_TIME=$((END_TIME - 3600000000000))

LOKI_RESPONSE=$(curl -s -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  "${GRAFANA_URL}/api/datasources/proxy/uid/${LOKI_UID}/loki/api/v1/query_range?query=$(echo '{job="kubelet"}' | jq -sRr @uri)&start=${START_TIME}&end=${END_TIME}")

if echo "$LOKI_RESPONSE" | jq -e '.data.result' > /dev/null 2>&1; then
  STREAM_COUNT=$(echo "$LOKI_RESPONSE" | jq '.data.result | length')
  echo -e "${GREEN}✓ PASS${NC} - Loki query executed ($STREAM_COUNT log streams)\n"
  ((PASS++))
else
  echo -e "${YELLOW}⚠ WARN${NC} - Loki query check failed\n"
fi

# Test 6: Dashboards
echo "Test 6: Dashboards"
DASHBOARDS=$(curl -s -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  "${GRAFANA_URL}/api/search?type=dash-db")

DASHBOARD_COUNT=$(echo "$DASHBOARDS" | jq 'length')
K8S_DASHBOARDS=$(echo "$DASHBOARDS" | jq '[.[] | select(.title | contains("Kubernetes"))] | length')

if [ "$DASHBOARD_COUNT" -gt 0 ]; then
  echo -e "${GREEN}✓ PASS${NC} - Found $DASHBOARD_COUNT dashboards ($K8S_DASHBOARDS Kubernetes)\n"
  ((PASS++))
else
  echo -e "${RED}✗ FAIL${NC} - No dashboards found\n"
  ((FAIL++))
fi

# Test 7: Cluster Information
echo "Test 7: Cluster Information"
CLUSTER_INFO=$(curl -s -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  "${GRAFANA_URL}/api/datasources/proxy/uid/${PROM_UID}/api/v1/query?query=$(echo 'count(kube_node_info)' | jq -sRr @uri)")

if echo "$CLUSTER_INFO" | jq -e '.data.result[0]' > /dev/null 2>&1; then
  NODE_COUNT=$(echo "$CLUSTER_INFO" | jq -r '.data.result[0].value[1]')
  echo -e "${GREEN}✓ PASS${NC} - Cluster info retrieved (Nodes: $NODE_COUNT)\n"
  ((PASS++))
else
  echo -e "${YELLOW}⚠ WARN${NC} - Cluster info query returned no data\n"
fi

# Summary
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}  TEST SUMMARY${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}Passed:${NC} $PASS"
echo -e "${RED}Failed:${NC} $FAIL"

if [ $FAIL -eq 0 ]; then
  echo -e "\n${GREEN}✓ All critical tests passed!${NC}\n"
  exit 0
else
  echo -e "\n${RED}✗ Some tests failed${NC}\n"
  exit 1
fi
