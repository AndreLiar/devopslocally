# 🚀 Quick Start - Monitoring & Logging

## TL;DR - Get Started in 30 Seconds

### 1. Access Grafana
```bash
open http://localhost:3000
```
**Login**: `admin` / `UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX`

### 2. View Metrics (Prometheus)
1. Click **Explore** 
2. Select **Prometheus** datasource
3. Type query: `up{job="prometheus"}`
4. Click **Run**

### 3. View Logs (Loki)
1. Click **Explore**
2. Select **Loki** datasource  
3. Type query: `{job="kube-system/kubelet"}`
4. Click **Run**

### 4. View Dashboards
- Click **Dashboards** → Find "RKE2" or "Kubernetes Cluster"
- Pre-built panels show both metrics and logs

---

## 🔧 Common Tasks

### View Auth Service Logs
```logql
{namespace="default", app="auth-chart"}
```

### View CPU Usage
```promql
sum(rate(container_cpu_usage_seconds_total[5m])) by (pod)
```

### View Memory Usage
```promql
sum(container_memory_working_set_bytes) by (pod)
```

### View Request Rate
```promql
rate(http_requests_total[1m])
```

---

## 📊 Data Sources

All three datasources are **automatically configured and running**:

1. **Prometheus** - Metrics (scrape interval: 30s)
2. **Alertmanager** - Alert routing
3. **Loki** - Logs (retention: 14 days)

---

## 🛠️ Port Forwards (Already Active)

```bash
# Grafana on localhost:3000
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80

# Prometheus on localhost:9090
kubectl port-forward -n monitoring svc/kube-prometheus-kube-prome-prometheus 9090:9090
```

---

## ✅ Verification

All components running:
```bash
kubectl get pods -n monitoring
```

Expected: 8 pods all `Running`

---

## 📚 Learn More

- `LOKI_DATASOURCE_FIX.md` - Technical details
- `MONITORING_SETUP.md` - Full setup guide
- `PROJECT_SUMMARY.md` - Architecture overview
