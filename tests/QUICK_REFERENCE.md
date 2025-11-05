# Test Command Quick Reference

## Run Tests

### Quick Tests (Recommended) ⚡
```bash
./tests/test-grafana-quick.sh
```
**Time**: ~30 seconds  
**Coverage**: 7 critical tests  
**Perfect for**: CI/CD, quick verification

### Full Bash Tests 🔧
```bash
./tests/test-grafana-integration.sh
```
**Time**: ~5+ minutes  
**Coverage**: 10 test suites, 100+ tests  
**Perfect for**: Comprehensive verification

### Jest Tests 📊
```bash
npm test -- tests/test-grafana-integration.js --verbose
```
**Time**: ~3-5 seconds  
**Coverage**: 9 test suites  
**Perfect for**: Programmatic testing

## Run Specific Tests

### Only Datasource Tests
```bash
npm test -- tests/test-grafana-integration.js -t "Datasources"
```

### Only Prometheus Tests
```bash
npm test -- tests/test-grafana-integration.js -t "Prometheus"
```

### Only Loki Tests
```bash
npm test -- tests/test-grafana-integration.js -t "Loki"
```

### Only Dashboard Tests
```bash
npm test -- tests/test-grafana-integration.js -t "Dashboards"
```

## Setup

### Start Grafana
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &
```

### Check Grafana Status
```bash
curl -s http://localhost:3000/api/health | jq .
```

### Verify Credentials
```bash
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/user | jq '.login'
```

## Common Queries

### Get Pod Count
```bash
# Via curl
curl -s -u admin:PASSWORD \
  'http://localhost:3000/api/datasources/proxy/uid/prometheus/api/v1/query?query=count(kube_pod_info)' | jq '.data.result[0].value'
```

### Get Logs from Namespace
```bash
# Via curl
curl -s -u admin:PASSWORD \
  'http://localhost:3000/api/datasources/proxy/uid/loki/loki/api/v1/query_range?query={namespace="monitoring"}&start=STARTIME&end=ENDTIME' | jq '.data.result'
```

### List All Dashboards
```bash
curl -s -u admin:PASSWORD \
  http://localhost:3000/api/search | jq '.[] | {title: .title, uid: .uid}'
```

### List All Datasources
```bash
curl -s -u admin:PASSWORD \
  http://localhost:3000/api/datasources | jq '.[] | {name: .name, type: .type, url: .url}'
```

## Documentation Files

| File | Purpose |
|------|---------|
| `tests/TESTING.md` | Comprehensive testing guide |
| `tests/TESTS_COMPLETE.md` | Test results summary |
| `tests/test-grafana-quick.sh` | Quick 7-test suite |
| `tests/test-grafana-integration.sh` | Full 10-suite tests |
| `tests/test-grafana-integration.js` | Jest tests |
| `docs/GRAFANA_SETUP_COMPLETE.md` | Setup guide |
| `docs/QUICK_START.md` | Quick reference |
| `docs/LOKI_DATASOURCE_FIX.md` | Troubleshooting |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Grafana not accessible" | `kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80` |
| "Auth failed" | Verify: `curl -u admin:PASSWORD http://localhost:3000/api/user` |
| "No logs found" | Wait 5 mins, logs take time to accumulate |
| "No dashboards" | Verify: `kubectl get configmap -n monitoring \| grep dashboard` |
| "No metrics" | Check Prometheus: `http://localhost:9090/targets` |

## Test Breakdown

| Component | Tests |
|-----------|-------|
| Datasources | 5 tests |
| Prometheus | 4 tests |
| Loki | 3 tests |
| Dashboards | 3 tests |
| Cluster Info | 6 tests |
| Pod Metrics | 3 tests |
| Alert Rules | 1 test |

## Expected Results

```
✓ PASS - Grafana is healthy (v12.2.1)
✓ PASS - Successfully authenticated
✓ PASS - All 3 datasources configured
✓ PASS - Prometheus query executed (1 results)
✓ PASS - Loki query executed (0+ log streams)
✓ PASS - Found 28 dashboards (18 Kubernetes)
✓ PASS - Cluster info retrieved (Nodes: 1)

Passed: 7
Failed: 0
✓ All critical tests passed!
```

## Credentials

- **URL**: http://localhost:3000
- **User**: admin
- **Password**: UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX

## Dashboard Examples

- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Pod
- Kubernetes / Networking / Cluster
- Alertmanager / Overview
- etcd
- CoreDNS

## Query Examples

**PromQL**:
```
count(kube_pod_info)
count(kube_node_info)
sum(rate(container_cpu_usage_seconds_total[5m])) by (pod_name)
```

**LogQL**:
```
{namespace="monitoring"}
{job="kubelet"}
{pod_name="my-pod"}
```
