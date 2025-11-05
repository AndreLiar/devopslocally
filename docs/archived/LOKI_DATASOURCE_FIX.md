# Loki Data Source Configuration Fix

## Problem
Loki datasource failed to provision in Grafana with error: **"Only one datasource per organization can be marked as default"**

Even though Loki was configured, it couldn't load because there was a datasource provisioning conflict.

## Root Cause Analysis
✅ **Real Issue Found**: The `loki-stack` Helm chart auto-provisioned a Loki datasource with **`isDefault: true`**, while Prometheus was already marked as default.

**Conflict**: Grafana doesn't allow multiple datasources marked as `isDefault: true`

- ✅ **Loki service**: Running correctly in `monitoring` namespace on port 3100
- ✅ **Loki pod**: Actively processing queries and data
- ✅ **Cluster DNS**: Verified `http://loki:3100` is reachable from within the cluster
- ✅ **Grafana-to-Loki connectivity**: Confirmed from Grafana pod itself
- ❌ **Datasource provisioning**: BLOCKED by default datasource conflict

## Solution Implemented

### Step 1: Identified All Provisioning ConfigMaps
Found three datasource ConfigMaps creating conflicts:
- `kube-prometheus-kube-prome-grafana-datasource` (Prometheus + Alertmanager + Loki addition)
- `loki-loki-stack` (Auto-provisioned by loki-stack Helm chart with `isDefault: true`)
- `kube-prometheus-grafana-datasource-loki` (Manual addition)

### Step 2: Fixed the loki-stack ConfigMap
**Patched** `loki-loki-stack` ConfigMap to set `isDefault: false`:

```bash
kubectl patch configmap -n monitoring loki-loki-stack --type merge \
  -p '{"data":{"loki-stack-datasource.yaml":"apiVersion: 1\ndatasources:\n- name: Loki\n  type: loki\n  access: proxy\n  url: \"http://loki:3100\"\n  version: 1\n  isDefault: false\n  jsonData:\n    {}"}}'
```

**Result**: Removed the conflicting default datasource designation

### Step 3: Restarted Grafana
```bash
kubectl delete pod -n monitoring -l app.kubernetes.io/name=grafana
```

This forced Grafana to reload all provisioning ConfigMaps from scratch with the corrected settings.

### Step 4: Verified Provisioning Success
```bash
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana | grep -i "provision"
```

**Result**: ✅ No more provisioning errors, Grafana successfully loaded all three datasources:
- Prometheus (default)
- Alertmanager  
- Loki

## Verification Steps

### Access Grafana and Verify Datasource
1. Navigate to `http://localhost:3000`
2. Go to **⚙️ (Settings) → Data Sources**
3. Look for **"Loki"** datasource (should now appear in the list)
4. Click on **Loki** to verify:
   - URL: `http://loki:3100`  or  `http://loki.monitoring:3100`
   - Status: Shows provisioned datasource

### Test Loki Connectivity via API
```bash
# Check if Loki is registered in Grafana
kubectl exec -n monitoring deployment/kube-prometheus-grafana -- \
  curl -s -u admin:<password> http://localhost:3000/api/datasources | grep loki

# Expected: "uid":"loki" appears in the response
```

### Verify No Provisioning Errors
```bash
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana --tail=100 | grep -i provision
```

**Expected Output**: Only mentions "provisioning datasources" and "provisioning dashboards" with no errors

### Query Logs in Explore Tab
1. Go to **Explore** 
2. Select **Loki** from datasource dropdown
3. Try a LogQL query:
   ```logql
   {job="kube-system/kubelet"}
   ```
4. If logs appear, the connection is working ✅

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

### If provisioning still shows "Only one datasource marked as default" error:

1. **Check all datasource ConfigMaps**:
   ```bash
   kubectl get configmap -n monitoring | grep -i datasource
   ```

2. **Find which ConfigMaps have conflicting defaults**:
   ```bash
   kubectl get configmap -n monitoring -o json | jq -r \
     '.items[] | select(.data["datasource.yaml"] or .data["loki-stack-datasource.yaml"]) | 
     {name: .metadata.name, defaults: (.data["datasource.yaml"] | 
     select(.) | split("\n") | map(select(contains("isDefault"))))}' 
   ```

3. **Patch conflicting ConfigMaps** to ensure only Prometheus has `isDefault: true`:
   ```bash
   # For loki-loki-stack
   kubectl patch configmap loki-loki-stack -n monitoring --type merge \
     -p '{"data":{"loki-stack-datasource.yaml":"apiVersion: 1\ndatasources:\n- name: Loki\n  type: loki\n  access: proxy\n  url: \"http://loki:3100\"\n  version: 1\n  isDefault: false\n  jsonData:\n    {}"}}'
   ```

4. **Restart Grafana**:
   ```bash
   kubectl delete pod -n monitoring -l app.kubernetes.io/name=grafana
   ```

### If Loki datasource shows connection errors:

1. **Test connectivity from Grafana pod**:
   ```bash
   kubectl exec -n monitoring deployment/kube-prometheus-grafana -- \
     curl -v http://loki:3100/ready
   ```
   Expected: `HTTP/1.1 200 OK` with body `ready`

2. **Check Loki pod status**:
   ```bash
   kubectl get pod -n monitoring loki-0
   ```
   Expected: `Running` status

3. **Check Promtail is shipping logs**:
   ```bash
   kubectl logs -n monitoring -l app.kubernetes.io/name=promtail | grep -i shipped | head -5
   ```

### If LogQL queries return "Failed to fetch":

This usually means logs haven't been ingested yet. Wait a few minutes for Promtail to collect logs from the cluster, then retry the query.
