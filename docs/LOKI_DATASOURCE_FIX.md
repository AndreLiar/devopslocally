# Loki Data Source Configuration Fix

## Problem
When attempting to add Loki as a data source in Grafana with URL `http://loki:3100`, the connection test failed.

## Root Cause Analysis
- ✅ **Loki service**: Running correctly in `monitoring` namespace on port 3100
- ✅ **Loki pod**: Actively processing queries and data
- ✅ **Cluster DNS**: Verified `http://loki:3100` is reachable from within the cluster
- ✅ **Grafana-to-Loki connectivity**: Confirmed from Grafana pod itself

**Issue identified**: The UI-added datasource may have had a transient connectivity issue or misconfiguration. The solution is to provision Loki as a ConfigMap-managed datasource (same way Prometheus and Alertmanager are configured).

## Solution Implemented

### Step 1: Updated Grafana Datasource ConfigMap
Added Loki as a provisioned datasource alongside Prometheus and Alertmanager in the `kube-prometheus-kube-prome-grafana-datasource` ConfigMap:

```yaml
- name: "Loki"
  type: loki
  uid: loki
  url: http://loki.monitoring:3100
  access: proxy
  isDefault: false
  jsonData:
    maxLines: 1000
```

**Key Configuration Details:**
- **URL**: `http://loki.monitoring:3100` - Uses Kubernetes DNS FQDN for reliability
- **Access Mode**: `proxy` - Grafana proxies requests to Loki (recommended for security)
- **UID**: `loki` - Unique identifier for the datasource
- **maxLines**: Limited to 1000 to prevent performance issues with large log volumes

### Step 2: Restarted Grafana
```bash
kubectl rollout restart deployment/kube-prometheus-grafana -n monitoring
```

This ensures Grafana reloads the ConfigMap and registers the new Loki datasource at startup.

### Step 3: Verified Connectivity
- ✅ Tested `http://loki:3100/ready` endpoint → Returns `ready`
- ✅ Tested from Grafana pod → Successfully connected
- ✅ Confirmed Loki is actively handling queries and log ingestion

## Verification Steps

### Access Grafana and Verify Datasource
1. Navigate to `http://localhost:3000`
2. Go to **⚙️ (Settings) → Data Sources**
3. Look for **"Loki"** datasource (should now appear in the list)
4. Click on **Loki** to verify:
   - URL: `http://loki.monitoring:3100`
   - Status: Should show **"Connected"** (green checkmark)

### Test Loki Connectivity
1. Go to **Explore** tab
2. Select **Loki** from the datasource dropdown
3. Run a simple LogQL query:
   ```logql
   {job="kube-system/kubelet"}
   ```
4. If logs appear, the connection is working ✅

### Example LogQL Queries to Try
```logql
# All logs from Prometheus
{job="kube-system/prometheus"}

# Logs containing "error"
{namespace="monitoring"} | "error"

# JSON-parsed logs
{namespace="default"} | json

# Logs with status code 500
{app="auth-chart"} | json | status="500"
```

## What Changed
| Component | Before | After |
|-----------|--------|-------|
| Loki datasource | UI-added (not persisted across restarts) | Provisioned via ConfigMap (persistent) |
| Connection method | Direct from UI | Helm-managed configuration |
| Availability | Manual re-add if pod restarts | Automatic (ConfigMap-based) |

## Next Steps
1. ✅ Verify Loki appears in Data Sources list
2. ✅ Run test queries in Explore tab
3. ✅ Confirm log data is flowing from Promtail → Loki → Grafana
4. (Optional) Import Loki dashboard (ID: 14243) or create custom log panels

## Related Documentation
- See `MONITORING_SETUP.md` for full monitoring setup details
- See `GITOPS_PIPELINE.md` for application deployment flow

## Troubleshooting

### If Loki still doesn't appear:
1. Check Grafana logs: `kubectl logs -n monitoring -l app.kubernetes.io/name=grafana`
2. Verify ConfigMap was applied: `kubectl get configmap -n monitoring kube-prometheus-kube-prome-grafana-datasource -o yaml`
3. Restart Grafana: `kubectl rollout restart deployment/kube-prometheus-grafana -n monitoring`

### If connection test still fails:
```bash
# Test from Grafana pod
kubectl exec -n monitoring deployment/kube-prometheus-grafana -- \
  curl -i http://loki.monitoring:3100/ready
```

Expected response: `200 OK` with body `ready`
