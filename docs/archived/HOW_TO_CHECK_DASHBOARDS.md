# How to Check & Access 28 Dashboards in Grafana

## 🎯 Quick Overview

You have **28 total dashboards** available in Grafana:
- **18 Kubernetes-specific dashboards** (CPU, memory, networking, pods, nodes)
- **10 System component dashboards** (Alertmanager, etcd, CoreDNS, Grafana, etc.)

All are **fully accessible and working** ✅

---

## 📊 Method 1: Access via Grafana Web UI (Easiest)

### Step 1: Open Grafana
```
URL: http://localhost:3000
Username: admin
Password: UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX
```

### Step 2: Navigate to Dashboards
1. Click **"Dashboards"** in the left sidebar
2. Click **"Browse"** or **"Search"**
3. You'll see all 28 dashboards listed

### Step 3: View Dashboard Details
Each dashboard shows:
- **Title** - Dashboard name
- **Tags** - Category (e.g., "kubernetes-mixin", "alertmanager-mixin")
- **Preview** - Quick look at panels

---

## 🔍 Method 2: List Dashboards via CLI

### Option A: Using the Quick Test Script

```bash
./tests/test-grafana-quick.sh
```

**Output will show:**
```
Test 6: Dashboards
✓ PASS - Found 28 dashboards (18 Kubernetes)
```

### Option B: Using curl Command

```bash
# Get all dashboards
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | jq '.[] | {title: .title, tags: .tags}'
```

**Sample Output:**
```json
{
  "title": "Kubernetes / Compute Resources / Cluster",
  "tags": ["kubernetes-mixin"]
}
{
  "title": "Kubernetes / Compute Resources / Namespace (Pods)",
  "tags": ["kubernetes-mixin"]
}
{
  "title": "Alertmanager / Overview",
  "tags": ["alertmanager-mixin"]
}
...
```

### Option C: Count Total Dashboards

```bash
# Count exact number of dashboards
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | jq 'length'
```

**Output:** `28`

### Option D: Count Kubernetes Dashboards

```bash
# Count only Kubernetes dashboards
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | jq '[.[] | select(.title | contains("Kubernetes"))] | length'
```

**Output:** `18`

---

## 📋 Method 3: View Complete List of All 28 Dashboards

### Kubernetes Dashboards (18 total)

```bash
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | jq '.[] | select(.title | contains("Kubernetes")) | .title'
```

**Output - All 18 Kubernetes Dashboards:**
```
1. Kubernetes / API server
2. Kubernetes / Compute Resources / Cluster
3. Kubernetes / Compute Resources / Multi-Cluster
4. Kubernetes / Compute Resources / Namespace (Pods)
5. Kubernetes / Compute Resources / Namespace (Workloads)
6. Kubernetes / Compute Resources / Node (Pods)
7. Kubernetes / Compute Resources / Pod
8. Kubernetes / Compute Resources / Workload
9. Kubernetes / Controller Manager
10. Kubernetes / Kubelet
11. Kubernetes / Networking / Cluster
12. Kubernetes / Networking / Namespace (Pods)
13. Kubernetes / Networking / Namespace (Workload)
14. Kubernetes / Networking / Pod
15. Kubernetes / Networking / Workload
16. Kubernetes / Persistent Volumes
17. Kubernetes / Scheduler
18. Kubernetes / StatefulSet / Statefulsets
```

### System Dashboards (10 total)

```bash
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | jq '.[] | select(.title | contains("Kubernetes") | not) | .title'
```

**Output - All 10 System Dashboards:**
```
1. Alertmanager / Overview
2. CoreDNS
3. etcd
4. Grafana Overview
5. Kubelet Node Exporter Full
6. Kube-Apiserver Cluster
7. Kube-Controller-Manager
8. Node Exporter for Prometheus
9. Prometheus
10. Prometheus Server
```

---

## 🎯 Method 4: Access Specific Dashboards

### View a Specific Dashboard

#### Option A: Via Web UI
1. Go to http://localhost:3000
2. Click **Dashboards** → **Browse**
3. Search for dashboard name (e.g., "Kubernetes / Compute Resources / Cluster")
4. Click to open

#### Option B: Direct URL
```bash
# Get dashboard UID
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search?query=Cluster | jq '.[0].uid'
```

Then open:
```
http://localhost:3000/d/UID/kubernetes-compute-resources-cluster
```

#### Option C: Via curl to get dashboard data
```bash
# Get Kubernetes Cluster dashboard data
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search?query=Cluster | jq '.[0]'
```

---

## 📊 Method 5: Categorized Dashboard List

### By Category

**CPU & Memory Dashboards:**
```bash
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | jq '.[] | select(.title | contains("Compute Resources")) | .title'
```

**Networking Dashboards:**
```bash
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | jq '.[] | select(.title | contains("Networking")) | .title'
```

**System Component Dashboards:**
```bash
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | jq '.[] | select(.tags | contains(["alertmanager-mixin"])) | .title'
```

---

## 🧪 Method 6: Verify via Test Script

### Run Quick Test
```bash
./tests/test-grafana-quick.sh
```

**Look for:**
```
Test 6: Dashboards
✓ PASS - Found 28 dashboards (18 Kubernetes)
```

### Run Full Test
```bash
./tests/test-grafana-integration.sh
```

**Look for section:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Suite 5: Dashboard Availability
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[INFO] Found 28 dashboards
[✓ PASS] Found 18 dashboards matching 'Kubernetes'
[✓ PASS] Found 1 dashboards matching 'Alertmanager'
...
```

---

## 💡 Top 5 Most Useful Dashboards

### 1. Kubernetes / Compute Resources / Cluster
**What it shows:**
- CPU usage across entire cluster
- Memory usage across all nodes
- Network I/O
- Pod creation rate

**Access:** http://localhost:3000 → Dashboards → Search "Cluster"

### 2. Kubernetes / Compute Resources / Pod
**What it shows:**
- Individual pod CPU usage
- Individual pod memory usage
- Network per pod
- Pod restart count

**Access:** http://localhost:3000 → Dashboards → Search "Pod"

### 3. Kubernetes / Networking / Cluster
**What it shows:**
- Network bandwidth per pod
- Network errors
- Network latency
- DNS lookups

**Access:** http://localhost:3000 → Dashboards → Search "Networking"

### 4. Alertmanager / Overview
**What it shows:**
- Active alerts
- Alert status
- Alert routes
- Notification status

**Access:** http://localhost:3000 → Dashboards → Search "Alertmanager"

### 5. etcd
**What it shows:**
- etcd cluster health
- Key operations
- Commit latency
- Store size

**Access:** http://localhost:3000 → Dashboards → Search "etcd"

---

## 🔍 Advanced: Detailed Dashboard Information

### Get Full Dashboard List with Details

```bash
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | jq '.[] | {
    title: .title,
    uid: .uid,
    tags: .tags,
    type: .type,
    url: .url
  }' | head -50
```

**Output example:**
```json
{
  "title": "Kubernetes / Compute Resources / Cluster",
  "uid": "efa86fd1d0c121a26444b636a3f509a8",
  "tags": ["kubernetes-mixin"],
  "type": "dash-db",
  "url": "/d/efa86fd1d0c121a26444b636a3f509a8/kubernetes-compute-resources-cluster"
}
```

### Get Dashboard Panel Count

```bash
# Get panels for a specific dashboard
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/dashboards/uid/efa86fd1d0c121a26444b636a3f509a8 | jq '.dashboard.panels | length'
```

---

## 📱 Quick Reference: Commands to Check Dashboards

```bash
# Count total dashboards
curl -s -u admin:PASSWORD http://localhost:3000/api/search | jq 'length'
# Expected: 28

# List all dashboard titles
curl -s -u admin:PASSWORD http://localhost:3000/api/search | jq '.[] | .title'

# Count Kubernetes dashboards
curl -s -u admin:PASSWORD http://localhost:3000/api/search | jq '[.[] | select(.title | contains("Kubernetes"))] | length'
# Expected: 18

# List Kubernetes dashboards only
curl -s -u admin:PASSWORD http://localhost:3000/api/search | jq '.[] | select(.title | contains("Kubernetes")) | .title'

# Find dashboard by keyword
curl -s -u admin:PASSWORD http://localhost:3000/api/search?query=Pod | jq '.[] | .title'

# Get dashboard with detailed info
curl -s -u admin:PASSWORD http://localhost:3000/api/dashboards/uid/DASHBOARD_UID | jq '.dashboard | {title, panels: (.panels | length)}'
```

---

## 🎓 Step-by-Step: First Time Access

### Step 1: Ensure Grafana is Running
```bash
curl -s http://localhost:3000/api/health | jq '.version'
# Should show: "12.2.1"
```

### Step 2: Open Grafana in Browser
```
http://localhost:3000
```

### Step 3: Login
```
Username: admin
Password: UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX
```

### Step 4: Click "Dashboards" in Left Sidebar
You'll see a dropdown menu

### Step 5: Click "Browse"
All 28 dashboards appear

### Step 6: Find Kubernetes Dashboards
Look for dashboards with names starting with "Kubernetes /"

**Example Kubernetes Dashboards:**
- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Pod
- Kubernetes / Networking / Cluster
- Kubernetes / Kubelet
- etc.

### Step 7: Click Dashboard Title to Open
Watch the metrics update in real-time!

---

## ✅ Verification Checklist

Use this to verify all dashboards are accessible:

```bash
# Run the test
./tests/test-grafana-quick.sh

# Check for:
# ✓ PASS - Found 28 dashboards (18 Kubernetes)
```

Or manually:
```bash
# Verify count
curl -s -u admin:PASSWORD http://localhost:3000/api/search | jq 'length' # Should be 28
curl -s -u admin:PASSWORD http://localhost:3000/api/search | jq '[.[] | select(.title | contains("Kubernetes"))] | length' # Should be 18
```

---

## 🎯 Common Tasks

### Find Dashboard by Name
```bash
curl -s -u admin:PASSWORD http://localhost:3000/api/search?query=Pod | jq '.[] | .title'
```

### Open Dashboard in Browser
```bash
# Get UID first
UID=$(curl -s -u admin:PASSWORD http://localhost:3000/api/search?query=Cluster | jq -r '.[0].uid')

# Open in browser
open "http://localhost:3000/d/$UID/dashboard-name"
```

### List Dashboards by Tag
```bash
# Kubernetes dashboards
curl -s -u admin:PASSWORD http://localhost:3000/api/search | jq '.[] | select(.tags | contains(["kubernetes-mixin"])) | .title'

# Alertmanager dashboards
curl -s -u admin:PASSWORD http://localhost:3000/api/search | jq '.[] | select(.tags | contains(["alertmanager-mixin"])) | .title'
```

---

## 📞 Troubleshooting

### Issue: "Connection refused" when accessing http://localhost:3000

**Solution:**
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &
sleep 2
# Try again
```

### Issue: "Authentication failed"

**Solution:**
```bash
# Verify password is correct
curl -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX http://localhost:3000/api/user | jq '.login'
```

### Issue: "Dashboards not showing"

**Solution:**
```bash
# Restart Grafana pod
kubectl delete pod -n monitoring -l app.kubernetes.io/name=grafana

# Wait for pod to restart
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=60s
```

---

## 📚 Related Documentation

- **`tests/README.md`** - Test suite overview
- **`tests/QUICK_REFERENCE.md`** - CLI commands reference
- **`docs/GRAFANA_SETUP_COMPLETE.md`** - Setup guide with dashboard info

---

## ✨ Summary

You can check the 28 dashboards (18 Kubernetes) by:

1. **Web UI** (Easiest): http://localhost:3000 → Dashboards → Browse
2. **CLI** (Quick): `./tests/test-grafana-quick.sh`
3. **curl** (Detailed): `curl -u admin:PASSWORD http://localhost:3000/api/search`
4. **Test Script**: Full verification with `./tests/test-grafana-integration.sh`

**All 28 dashboards are working and accessible right now!** ✅
