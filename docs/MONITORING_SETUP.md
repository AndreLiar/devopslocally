# 📦 Phase 3 — Monitoring & Logs Guide

## Overview

Your local Kubernetes cluster now has a **production-grade observability stack**:

| Component | Namespace | Role | Status |
| --- | --- | --- | --- |
| **Prometheus** | `monitoring` | Metrics collection | ✅ Running |
| **Grafana** | `monitoring` | Dashboards & visualization | ✅ Running |
| **Alertmanager** | `monitoring` | Alert routing | ✅ Running |
| **Loki** | `monitoring` | Centralized log storage | ✅ Running |
| **Promtail** | `monitoring` | Pod log shipping → Loki | ✅ Running |

---

## 🚀 Quick Start

### 0. Access Your DevOps Stack

#### 🔵 ArgoCD Dashboard
**URL:** https://localhost:8080

**Credentials:**
```
Username: admin
Password: [Get with command below]
```

To retrieve ArgoCD password:
```bash
/usr/local/bin/kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**In ArgoCD you can:**
- View auth-service application status (Synced/OutOfSync)
- See deployment history and Git sync logs
- Monitor GitOps pipeline in real-time
- Manually trigger syncs

If port-forward is not running, start it:
```bash
/usr/local/bin/kubectl port-forward svc/argocd-server -n argocd 8080:443
```

---

### 1. Access Grafana Dashboard

**URL:** http://localhost:3000

**Credentials:**
```
Username: admin
Password: UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX
```

If port-forward is not running, start it:
```bash
/usr/local/bin/kubectl port-forward svc/kube-prometheus-grafana -n monitoring 3000:80
```

**In Grafana you can:**
- View real-time cluster metrics (CPU, memory, network)
- Query pod logs from Loki
- Create custom dashboards
- Set up alerts

### 2. Verify Prometheus Data Source

In Grafana:
1. Click ⚙️ (gear icon, bottom left) → **Data Sources**
2. You should see `Prometheus` already configured
3. Click it → **Save & Test** → Should show "Data source is working"

### 3. Verify Loki Data Source

In Grafana:
1. Go to **Data Sources** again
2. Check if `Loki` exists; if not:
   - Click **Add data source** → Select **Loki**
   - Set URL to: `http://loki:3100`
   - Click **Save & Test**

---

## 🎯 Your DevOps Stack Summary

Both **ArgoCD** (GitOps) and **Grafana** (Observability) are now running:

| Component | URL | Username | Password | Purpose |
| --- | --- | --- | --- | --- |
| **ArgoCD** | https://localhost:8080 | admin | [Get with kubectl cmd] | GitOps pipeline & deployments |
| **Grafana** | http://localhost:3000 | admin | UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX | Metrics & logs visualization |

### Port-Forward Commands (if needed)
```bash
# ArgoCD
/usr/local/bin/kubectl port-forward svc/argocd-server -n argocd 8080:443

# Grafana
/usr/local/bin/kubectl port-forward svc/kube-prometheus-grafana -n monitoring 3000:80
```

### Full DevOps Workflow
```
1. Developer Push
   ↓
2. GitHub Actions (Build & Push Image)
   ↓
3. Update Helm Chart (new image tag)
   ↓
4. ArgoCD Detects Change
   ↓
5. ArgoCD Syncs to Cluster (via Git)
   ↓
6. Pod Deployed with New Image
   ↓
7. Prometheus Scrapes Metrics
   ↓
8. Promtail Collects Logs
   ↓
9. Grafana Visualizes Everything
```

---

## 📊 Explore Metrics (Prometheus)

### Option 1: Use Pre-built Dashboards

In Grafana:
1. Click **Dashboards** (left sidebar)
2. Click **New** → **Import**
3. Enter dashboard ID and click **Load**

**Recommended Dashboards:**

| Name | ID | Description |
| --- | --- | --- |
| Kubernetes / Cluster Monitoring | 315 | Overall cluster health |
| Kubernetes / Compute Resources / Cluster | 8588 | Pod CPU/memory usage |
| Kubernetes / Nodes | 9114 | Node metrics |
| Prometheus / Node Exporter Full | 1860 | Detailed node metrics |
| Loki / Logs Overview | 15104 | Log volume & queries |

**Import steps:**
```
Dashboards → + Import → Paste ID → Load → Select Data Source (Prometheus/Loki) → Import
```

### Option 2: Create Custom Queries

In Grafana → **Explore → Prometheus**, run PromQL queries:

#### CPU Usage by Pod
```promql
sum(rate(container_cpu_usage_seconds_total{namespace="default",pod!=""}[2m])) by (pod)
```

#### Memory Usage by Pod
```promql
sum(container_memory_usage_bytes{namespace="default",pod!=""}) by (pod) / 1024 / 1024
```

#### HTTP Requests Rate (if your app exports metrics)
```promql
rate(http_requests_total{namespace="default"}[5m])
```

#### Pod Restart Count
```promql
kube_pod_container_status_restarts_total{namespace="default"}
```

---

## 🪵 Explore Logs (Loki)

### Query Pod Logs

In Grafana → **Explore → Loki**, run LogQL queries:

#### View Auth-Service Logs
```logql
{app="auth-chart"}
```

#### View Logs with Errors
```logql
{namespace="default"} |= "error" or "Error" or "ERROR"
```

#### View Logs from Specific Pod
```logql
{pod_name="auth-service-auth-chart-xxxxx"}
```

#### Stream Logs in Real-time
```logql
{job="kubernetes/pods"}
```

**Note:** Logs are captured by Promtail from container stdout/stderr. Make sure your app logs to console (e.g., `console.log()` in Node.js).

---

## 🧩 Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                     Your Kubernetes Cluster                  │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐        ┌─────────────┐    ┌────────────┐  │
│  │ auth-service│ ──────▶│  Prometheus │    │ Alertmanager │  │
│  │ (your app)  │        │  Scrapes    │    │  Routes    │  │
│  └─────────────┘        │  Metrics    │    │  Alerts    │  │
│       │                 └─────────────┘    └────────────┘  │
│       │                        │                    │        │
│  console.log()                 ▼                    │        │
│       │                   ┌──────────┐             │        │
│       └──────────────────▶│ Promtail │             │        │
│                           │ Collects │             │        │
│                           │  Logs    │             │        │
│                           └──────────┘             │        │
│                                │                   │        │
│                                ▼                   │        │
│                           ┌────────┐               │        │
│                           │  Loki  │               │        │
│                           │ Stores │               │        │
│                           │  Logs  │               │        │
│                           └────────┘               │        │
│                                │                   │        │
│                                ▼                   ▼        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              GRAFANA                                   │ │
│  │  ┌──────────────┐        ┌──────────────┐             │ │
│  │  │  Dashboards  │        │   Explore    │             │ │
│  │  │ (Metrics)    │        │ (Metrics/Logs)│            │ │
│  │  └──────────────┘        └──────────────┘             │ │
│  │  ┌──────────────────────────────────────┐             │ │
│  │  │     Alerts & Notifications           │             │ │
│  │  └──────────────────────────────────────┘             │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└──────────────────────────────────────────────────────────────┘
                            ▲
                            │
                    localhost:3000
                   (Your Machine)
```

---

## 🔧 Installed Components

### Prometheus
- **Role:** Collects metrics from cluster (CPU, memory, network, custom metrics)
- **Storage:** In-memory + local disk (~15 days retention by default)
- **Scrape Interval:** 30 seconds (default)

### Grafana
- **Role:** Visualize metrics & logs, create dashboards, manage alerts
- **Data Sources:** Prometheus, Loki, AlertManager
- **Default Dashboard:** Shows cluster overview

### Alertmanager
- **Role:** Deduplicates, groups, and routes alerts
- **Configuration:** Can be customized via Helm values

### Loki
- **Role:** Central log storage (like Elasticsearch but simpler)
- **Retention:** Configurable (default: 336 hours = 2 weeks)
- **Format:** Labels-based indexing (efficient, fast queries)

### Promtail
- **Role:** Agent running on every node
- **Collects:** Pod logs from `/var/log/pods/`
- **Ships to:** Loki via HTTP

---

## 📈 Create a Custom Dashboard for auth-service

### Manual Steps in Grafana

1. Click **Dashboards** → **Create** → **New Dashboard**
2. Click **Add Panel**
3. In the query editor:

#### Panel 1: Auth-Service Pod Count
```promql
count(kube_pod_labels{label_app_kubernetes_io_name="auth-chart"})
```

#### Panel 2: CPU Usage
```promql
sum(rate(container_cpu_usage_seconds_total{pod=~"auth-service.*"}[2m]))
```

#### Panel 3: Memory Usage
```promql
sum(container_memory_usage_bytes{pod=~"auth-service.*"}) / 1024 / 1024 / 1024
```

#### Panel 4: Recent Logs
Switch to **Loki** data source and query:
```logql
{app="auth-chart"}
```

Save the dashboard with a name like "Auth-Service Monitoring".

---

## 🔍 Troubleshooting

### Grafana Won't Connect to Prometheus
```bash
# Check Prometheus pod status
/usr/local/bin/kubectl get pods -n monitoring | grep prometheus

# Check Prometheus service
/usr/local/bin/kubectl get svc -n monitoring | grep prometheus

# Port-forward to test directly
/usr/local/bin/kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090
# Visit http://localhost:9090 to verify Prometheus UI
```

### Logs Not Showing in Loki
```bash
# Check Promtail pods
/usr/local/bin/kubectl get pods -n monitoring | grep promtail

# Check Promtail logs
/usr/local/bin/kubectl logs -n monitoring -l app=promtail --tail=50

# Verify Loki is receiving logs
/usr/local/bin/kubectl logs -n monitoring -l app=loki --tail=50

# Test query in Loki
/usr/local/bin/kubectl port-forward svc/loki -n monitoring 3100:3100
# Visit http://localhost:3100/loki/api/v1/label
```

### Pod Metrics Not Appearing
- Ensure pod is running for at least 1 minute
- Check if metrics endpoint is exposed (Prometheus scrape config)
- Run: `kubectl get --raw /metrics` to see node metrics

### Out of Memory / Disk Space
```bash
# Check monitoring namespace resource usage
/usr/local/bin/kubectl describe nodes

# See PVC usage
/usr/local/bin/kubectl get pvc -n monitoring
```

---

## 🛠️ Maintenance Commands

### View Helm Release Info
```bash
/usr/local/bin/helm list -n monitoring
/usr/local/bin/helm status kube-prometheus -n monitoring
/usr/local/bin/helm status loki -n monitoring
```

### Update Prometheus Retention
```bash
# Edit and re-deploy (e.g., increase to 30 days)
/usr/local/bin/helm upgrade kube-prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set prometheus.prometheusSpec.retention=30d
```

### View All Monitoring Resources
```bash
/usr/local/bin/kubectl get all -n monitoring
/usr/local/bin/kubectl get pvc -n monitoring
/usr/local/bin/kubectl get statefulsets -n monitoring
```

### Uninstall Monitoring Stack (if needed)
```bash
/usr/local/bin/helm uninstall kube-prometheus -n monitoring
/usr/local/bin/helm uninstall loki -n monitoring
/usr/local/bin/kubectl delete namespace monitoring
```

---

## 📊 Recommended Alerts

You can configure alerts in Alertmanager. Examples:

### Alert: High CPU Usage
```yaml
- alert: HighPodCPU
  expr: sum(rate(container_cpu_usage_seconds_total{namespace="default"}[5m])) > 0.5
  for: 5m
  annotations:
    summary: "High CPU usage in default namespace"
```

### Alert: Pod Restart Loop
```yaml
- alert: PodRestartingFrequently
  expr: rate(kube_pod_container_status_restarts_total{namespace="default"}[15m]) > 0
  for: 5m
  annotations:
    summary: "Pod is restarting frequently"
```

### Alert: Memory Pressure
```yaml
- alert: HighMemoryUsage
  expr: (sum(container_memory_usage_bytes{namespace="default"}) / 1024 / 1024) > 500
  for: 5m
  annotations:
    summary: "High memory usage detected"
```

---

## 🎯 Next Steps

1. **Explore Pre-built Dashboards** — Import dashboard IDs 315, 1860, 15104
2. **Create Custom Queries** — Use the Explore tab to experiment with PromQL & LogQL
3. **Set Alerts** — Configure Alertmanager rules in Alertmanager UI or Helm values
4. **Integrate with CI/CD** — Add Prometheus metrics endpoint to auth-service app
5. **Setup Notifications** — Configure email/Slack notifications for alerts

---

## 🚀 Integration with auth-service

To expose metrics from your Node.js auth-service:

### Option 1: Use Prometheus Client Library

```bash
cd auth-service
npm install prom-client
```

Update `server.js`:
```javascript
const express = require("express");
const prometheus = require("prom-client");

const app = express();

// Prometheus metrics
const httpRequestDuration = new prometheus.Histogram({
  name: "http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route", "status_code"]
});

app.get("/", (req, res) => {
  const start = Date.now();
  res.send("✅ Auth Service v2.1 with metrics!");
  const duration = (Date.now() - start) / 1000;
  httpRequestDuration.observe({
    method: "GET",
    route: "/",
    status_code: 200
  }, duration);
});

app.get("/metrics", (req, res) => {
  res.set("Content-Type", prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});

app.listen(3000, () => {
  console.log("Server listening on port 3000");
  console.log("Metrics available at http://localhost:3000/metrics");
});
```

### Option 2: Prometheus Will Auto-Discover

If your pod has annotations:
```yaml
prometheus.io/scrape: "true"
prometheus.io/port: "3000"
prometheus.io/path: "/metrics"
```

Prometheus will automatically scrape your metrics.

---

## 📚 References

- **Prometheus Docs:** https://prometheus.io/docs/
- **Grafana Docs:** https://grafana.com/docs/
- **Loki Docs:** https://grafana.com/docs/loki/latest/
- **PromQL Guide:** https://prometheus.io/docs/prometheus/latest/querying/basics/
- **LogQL Guide:** https://grafana.com/docs/loki/latest/logql/

---

## ✅ Completion Status

| Step | Status | Notes |
| --- | --- | --- |
| Prometheus Stack | ✅ Installed | Collecting metrics from cluster |
| Grafana | ✅ Running | Access at http://localhost:3000 |
| Loki + Promtail | ✅ Running | Collecting pod logs |
| Data Sources | ✅ Configured | Prometheus & Loki connected |
| Port-forward | ✅ Active | Grafana on localhost:3000 |

**Phase 3 — Monitoring & Logs is now complete! 🎉**

---

**Last Updated:** November 5, 2025  
**Maintained by:** DevOps Team
