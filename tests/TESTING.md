# Grafana Integration Tests

## Overview

This directory contains comprehensive integration tests to verify that Grafana can:
- ✅ Connect to all datasources (Prometheus, Loki, Alertmanager)
- ✅ Retrieve logs from Loki
- ✅ Query metrics from Prometheus
- ✅ Access all dashboards
- ✅ Retrieve cluster information
- ✅ Get namespace and pod-level metrics

## Test Files

### 1. `test-grafana-integration.sh` (Bash Script)

**Purpose**: Shell-based integration tests using `curl` and `jq`

**Features**:
- 10 comprehensive test suites
- Color-coded output for easy reading
- Detailed logging and error handling
- Tests 100+ different queries and endpoints

**Test Suites**:
1. **Grafana Availability** - Health check, authentication
2. **Datasource Connectivity** - Prometheus, Loki, Alertmanager health
3. **Prometheus Metrics** - PromQL query execution
4. **Loki Log Retrieval** - LogQL query execution
5. **Dashboard Availability** - Dashboard listing and access
6. **Dashboard Data Access** - Panel and data verification
7. **Cluster Information** - Nodes, namespaces, deployments, pods
8. **Namespace-Specific Logs** - Per-namespace log retrieval
9. **Pod-Level Metrics** - Pod count, CPU usage, memory
10. **Alert Rules** - Alert group and rule retrieval

**Usage**:
```bash
# Make executable
chmod +x tests/test-grafana-integration.sh

# Run all tests
./tests/test-grafana-integration.sh

# Expected output shows:
# [✓ PASS] - Green checkmark for passed tests
# [✗ FAIL] - Red X for failed tests
# [⚠ WARN] - Yellow warning for optional/expected issues
```

### 2. `test-grafana-integration.js` (Jest/Node.js)

**Purpose**: JavaScript-based integration tests using Jest framework

**Features**:
- Automatic test discovery and execution
- Detailed assertion messages
- Organized test suites using `describe` blocks
- Async/await for clean async handling

**Test Suites**:
1. **Grafana Availability** - Health, auth, user info
2. **Datasources** - Existence, configuration, health checks
3. **Prometheus Metrics Queries** - Multiple PromQL queries
4. **Loki Log Retrieval** - Multiple LogQL queries with time ranges
5. **Dashboards** - Listing, access, panel counts
6. **Cluster Information** - Resource counts and totals
7. **Namespace and Pod Metrics** - Per-namespace and pod metrics
8. **Alert Rules** - Alert groups and rules
9. **Error Handling** - Graceful error responses

**Prerequisites**:
```bash
# Install dependencies (in auth-service/ or project root)
npm install axios jest --save-dev
```

**Usage**:
```bash
# Run with Jest
npm test -- tests/test-grafana-integration.js

# Run with detailed output
npm test -- tests/test-grafana-integration.js --verbose

# Run specific test suite
npm test -- tests/test-grafana-integration.js -t "Datasources"
```

## Pre-requisites

### 1. Grafana Must Be Running

Start port-forward:
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &
```

Verify Grafana is accessible:
```bash
curl -s http://localhost:3000/api/health | jq .
```

### 2. Datasources Must Be Configured

Verify datasources exist:
```bash
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/datasources | jq '.[] | {name: .name, type: .type}'
```

Expected output:
```json
{
  "name": "Prometheus",
  "type": "prometheus"
}
{
  "name": "Loki",
  "type": "loki"
}
{
  "name": "Alertmanager",
  "type": "alertmanager"
}
```

### 3. Credentials

The tests use these default credentials:
- **Username**: `admin`
- **Password**: `UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX`

To override, edit the test files:
- **Bash**: Lines 20-21 in `test-grafana-integration.sh`
- **Node.js**: Lines 9-10 in `test-grafana-integration.js`

### 4. Required Tools

**For Bash Tests**:
```bash
# macOS (using Homebrew)
brew install curl jq

# Linux (Ubuntu/Debian)
apt-get install curl jq

# Verify installation
curl --version
jq --version
```

**For Jest Tests**:
```bash
npm install axios jest
```

## Running the Tests

### Quick Start

**Option 1: Run Bash Tests (Recommended for quick verification)**
```bash
chmod +x tests/test-grafana-integration.sh
./tests/test-grafana-integration.sh
```

**Option 2: Run Jest Tests**
```bash
npm test -- tests/test-grafana-integration.js --verbose
```

### Example Output - Bash Tests

```
╔════════════════════════════════════════════════════════════════╗
║         GRAFANA INTEGRATION TEST SUITE                        ║
║                                                                ║
║  Testing: Datasources, Logs, Dashboards, Metrics & Cluster   ║
╚════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Suite 1: Grafana Availability
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[INFO] Checking Grafana health endpoint...
[✓ PASS] Grafana is healthy (version: 12.2.1)
[INFO] Testing Grafana authentication...
[✓ PASS] Successfully authenticated to Grafana

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Suite 2: Datasource Connectivity
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[INFO] Found 3 datasources
[INFO] Testing datasource: Prometheus
[✓ PASS] Datasource 'Prometheus' is healthy (Type: prometheus, URL: http://...)
[INFO] Testing datasource: Loki
[✓ PASS] Datasource 'Loki' is healthy (Type: loki, URL: http://...)
[INFO] Testing datasource: Alertmanager
[✓ PASS] Datasource 'Alertmanager' is healthy (Type: alertmanager, URL: http://...)

[... more test suites ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Passed: 87
Failed: 0
✓ All tests passed!
```

### Example Output - Jest Tests

```
PASS  tests/test-grafana-integration.js
  Grafana Integration Tests
    Grafana Availability
      ✓ Grafana health endpoint should return 200 (15ms)
      ✓ Should authenticate successfully (12ms)
      ✓ Should get Grafana user info (18ms)
    Datasources (40ms)
      ✓ Should have at least 3 datasources (8ms)
      ✓ Should have Prometheus datasource (6ms)
      ✓ Should have Loki datasource (5ms)
      ✓ Should have Alertmanager datasource (4ms)
      ✓ Should verify Prometheus datasource health (45ms)
      ✓ Should verify Loki datasource health (32ms)
    Prometheus Metrics Queries (85ms)
      ✓ Should execute Prometheus query: Pod Count (15ms)
      ✓ Should execute Prometheus query: Node Count (18ms)
      ...
    Loki Log Retrieval (120ms)
      ✓ Should retrieve logs: Kubelet Logs (25ms)
      ✓ Should retrieve logs: Kube-system Logs (30ms)
      ...

Test Suites: 1 passed, 1 total
Tests:       45 passed, 45 total
Snapshots:   0 total
Time:        3.847s
```

## Test Coverage

### Datasource Tests
- ✅ Prometheus datasource exists and is healthy
- ✅ Loki datasource exists and is healthy
- ✅ Alertmanager datasource exists and is healthy
- ✅ Prometheus is marked as default

### Metrics Tests
- ✅ Pod count query
- ✅ Node count query
- ✅ Namespace count query
- ✅ Target status query
- ✅ CPU usage metrics
- ✅ Memory usage metrics

### Log Tests
- ✅ Kubelet logs retrieval
- ✅ Kube-system logs retrieval
- ✅ Monitoring namespace logs
- ✅ Pod-level logs
- ✅ Namespace-specific logs

### Dashboard Tests
- ✅ Dashboard listing
- ✅ Kubernetes dashboard access
- ✅ System component dashboards (Alertmanager, etcd, CoreDNS)
- ✅ Panel count verification
- ✅ Dashboard data retrieval

### Cluster Information Tests
- ✅ Total nodes count
- ✅ Total namespaces count
- ✅ Total deployments count
- ✅ Total pods count
- ✅ CPU and memory information

### Alert Rules Tests
- ✅ Alert groups retrieval
- ✅ Alert rules listing
- ✅ Alert rule details

## Troubleshooting

### Issue: "Grafana is not accessible at http://localhost:3000"

**Solution**: Start port-forward
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &
sleep 2
```

### Issue: "Failed to authenticate with Grafana"

**Possible Causes**:
1. Wrong password
2. Grafana not initialized yet

**Solution**: Check credentials and get current password
```bash
kubectl get secret -n monitoring kube-prometheus-grafana \
  -o jsonpath='{.data.admin-password}' | base64 -d && echo ""
```

### Issue: "No data available" warnings

**Expected Behavior**: Some queries return no data if:
- Metrics haven't been collected yet
- Logs haven't arrived yet
- The time range is too far in the past

**Solution**: Wait a few minutes for metrics collection, then re-run tests

### Issue: "Failed to execute LogQL query"

**Possible Causes**:
1. Promtail not collecting logs
2. Loki not storing logs

**Solution**: Check Promtail status
```bash
kubectl logs -n monitoring -l app=promtail | head -20
```

### Issue: "No Kubernetes dashboards found"

**Solution**: Dashboards are pre-built by kube-prometheus-stack. If missing:
1. Verify helm chart deployment: `helm list -n monitoring`
2. Check if dashboards ConfigMap exists:
   ```bash
   kubectl get configmap -n monitoring | grep dashboard
   ```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Grafana Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Set up Kubernetes
        run: |
          # Setup minikube or kind
          # Deploy monitoring stack
      
      - name: Run Grafana Tests
        run: |
          chmod +x tests/test-grafana-integration.sh
          ./tests/test-grafana-integration.sh
```

### Local Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-push

echo "Running Grafana tests..."
chmod +x tests/test-grafana-integration.sh
./tests/test-grafana-integration.sh

if [ $? -ne 0 ]; then
  echo "Tests failed. Push aborted."
  exit 1
fi
```

## Performance Considerations

### Timeout Settings
- **Bash**: 10 seconds per curl request (adjustable in `test-grafana-integration.sh` line 207)
- **Jest**: 10 seconds per request (adjustable in `test-grafana-integration.js` line 15)

### Query Performance
- Metrics queries: ~50-100ms
- Log queries: ~100-200ms
- Dashboard queries: ~200-500ms

## Advanced Usage

### Running Specific Test Suites

**Bash**:
```bash
# Edit test file to comment out unwanted test_* function calls
./tests/test-grafana-integration.sh
```

**Jest**:
```bash
# Run only datasource tests
npm test -- tests/test-grafana-integration.js -t "Datasources"

# Run only Prometheus tests
npm test -- tests/test-grafana-integration.js -t "Prometheus"

# Run only Loki tests
npm test -- tests/test-grafana-integration.js -t "Loki"
```

### Custom Queries

**Bash**: Add to `test_prometheus_queries()` function:
```bash
local queries=(
    'your_custom_query|Your Label'
)
```

**Jest**: Add to test suite:
```javascript
test('Should query custom metric', async () => {
  const query = 'your_custom_query';
  // ... rest of test
});
```

## Documentation

For more information on:
- **Prometheus**: See `docs/QUICK_START.md`
- **Loki**: See `docs/LOKI_DATASOURCE_FIX.md`
- **Dashboards**: See `docs/GRAFANA_SETUP_COMPLETE.md`

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review test output for specific errors
3. Check Grafana logs: `kubectl logs -n monitoring -l app.kubernetes.io/name=grafana`
4. Check Prometheus logs: `kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus`
