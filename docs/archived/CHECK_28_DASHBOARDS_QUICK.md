# Quick Guide: Checking 28 Dashboards in Grafana

## TL;DR - Fastest Ways

### 🌐 **Easiest (Visual - 1 minute)**
```
1. Go to: http://localhost:3000
2. Login: admin / UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX
3. Click: "Dashboards" → "Browse"
4. See all 28 dashboards!
```

### ⚡ **Quick (Terminal - 30 seconds)**
```bash
./tests/test-grafana-quick.sh
# Look for: ✓ PASS - Found 28 dashboards (18 Kubernetes)
```

### 📋 **Detailed (Commands)**
```bash
# Count total dashboards
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | jq 'length'
# Result: 28

# Count Kubernetes only
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | \
  jq '[.[] | select(.title | contains("Kubernetes"))] | length'
# Result: 18
```

---

## 📊 What You'll See

### **18 Kubernetes Dashboards** 🟦

**Compute Resources (6):**
- Cluster (CPU, Memory, Network overview)
- Pod (Individual pod metrics)
- Node (Per-node metrics)
- Namespace Pods & Workloads

**Networking (5):**
- Cluster (Network I/O, errors)
- Pod & Namespace (Network details)
- Workload (Workload networking)

**System Components (5):**
- API Server
- Controller Manager
- Kubelet
- Proxy
- Scheduler

**Specialized (2):**
- Multi-Cluster
- Persistent Volumes

### **10 System Dashboards** 🟫

- Alertmanager / Overview
- CoreDNS
- etcd
- Grafana Overview
- Node Exporter (5 variants)
- Prometheus / Overview

---

## ✅ Verification

### Test to Confirm All 28 Are There
```bash
./tests/test-grafana-quick.sh
```

### Manual Count
```bash
# Should return 28
curl -s -u admin:UEBVMdWvjDNVolfXNNEKhJyBSmhOqQRzC3fZcboX \
  http://localhost:3000/api/search | jq 'length'
```

---

## 🎯 Top 5 Most Important Dashboards

1. **Kubernetes / Compute Resources / Cluster** - CPU, Memory, Network overview
2. **Kubernetes / Compute Resources / Pod** - Individual pod metrics
3. **Kubernetes / Networking / Cluster** - Network performance
4. **Alertmanager / Overview** - Active alerts
5. **etcd** - Database cluster health

---

## 📁 Related Files

- `docs/HOW_TO_CHECK_DASHBOARDS.md` - Complete detailed guide
- `tests/test-grafana-quick.sh` - Automated verification
- `tests/QUICK_REFERENCE.md` - Command reference
