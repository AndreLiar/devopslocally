# 🚀 Automated Infrastructure Setup Guide

This directory contains automation scripts to deploy and manage your complete DevOps infrastructure.

## Quick Start (5 minutes)

```bash
# 1. Make scripts executable
chmod +x scripts/setup-infrastructure.sh
chmod +x scripts/teardown-infrastructure.sh

# 2. Run the setup (automatic deployment of all 8 phases)
bash scripts/setup-infrastructure.sh

# 3. Wait ~5-10 minutes for everything to deploy
# 4. Follow the access instructions shown at the end
```

That's it! Your complete infrastructure is now deployed. ✅

---

## What Gets Deployed

### Phase 1: Kubernetes Namespaces ✅
```
dev              (development environment)
staging          (staging environment)
production       (production environment)
argocd           (GitOps platform)
monitoring       (metrics & logging)
```

### Phase 2: Helm Repositories ✅
```
stable                    (official Kubernetes charts)
prometheus-community      (Prometheus charts)
grafana                   (Grafana charts)
argocd                    (ArgoCD charts)
loki                      (Loki charts)
```

### Phase 3: ArgoCD ✅
```
GitOps deployment engine
Watches your Git repository
Auto-syncs changes to Kubernetes
Credentials saved to: .credentials
```

### Phase 4: Prometheus & Grafana ✅
```
Prometheus: Metrics collection from cluster
Grafana: Beautiful dashboards & visualization
Admin credentials: admin / admin123
```

### Phase 5: Loki & Promtail ✅
```
Loki: Centralized log storage
Promtail: Agent that collects logs from pods
Full observability for all environments
```

### Phase 6: Network Policies ✅
```
Optional isolation between namespaces
Prevents accidental cross-environment traffic
```

---

## Common Commands

### ✅ Setup (Full Automation)
```bash
# Complete automated deployment
bash scripts/setup-infrastructure.sh

# Skip verification step (for faster setup)
bash scripts/setup-infrastructure.sh --skip-verification
```

### 📊 Access Dashboards

**Grafana (Dashboards & Visualization)**
```bash
# Terminal 1: Start port-forward
kubectl port-forward svc/kube-prometheus-grafana -n monitoring 3000:80 &

# Browser: Open
http://localhost:3000

# Login: admin / admin123
```

**Prometheus (Metrics Explorer)**
```bash
# Terminal 1: Start port-forward
kubectl port-forward svc/kube-prometheus-prometheus -n monitoring 9090:9090 &

# Browser: Open
http://localhost:9090
```

**ArgoCD (Deployment Dashboard)**
```bash
# Terminal 1: Start port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Browser: Open
https://localhost:8080

# Login: admin / [password from .credentials file]
```

### 🧹 Check Status

```bash
# List all namespaces
kubectl get namespaces

# Check ArgoCD
kubectl get pods -n argocd
kubectl get svc -n argocd

# Check monitoring (Prometheus, Grafana, Loki)
kubectl get pods -n monitoring
kubectl get svc -n monitoring

# Check dev/staging/production namespaces
kubectl get pods -n dev
kubectl get pods -n staging
kubectl get pods -n production
```

### 📋 View Logs

```bash
# ArgoCD logs
kubectl logs -n argocd -f deployment/argocd-server

# Prometheus logs
kubectl logs -n monitoring -f deployment/kube-prometheus-operator

# Grafana logs
kubectl logs -n monitoring -f deployment/kube-prometheus-grafana

# Loki logs
kubectl logs -n monitoring -f deployment/loki
```

### 🧹 Teardown (Remove Everything)

```bash
# Interactive teardown (asks for confirmation)
bash scripts/teardown-infrastructure.sh

# Force teardown (no confirmation)
bash scripts/teardown-infrastructure.sh --force
```

---

## How It Works

### Automated Deployment Flow

```
1. Check Prerequisites
   └─ kubectl, helm, git, docker installed?
   └─ Kubernetes cluster running?
   
2. Create Namespaces (1 minute)
   └─ dev, staging, production, argocd, monitoring
   
3. Add Helm Repos (1 minute)
   └─ All required Helm repositories
   
4. Deploy ArgoCD (3-5 minutes)
   └─ GitOps platform for automatic deployment
   
5. Deploy Prometheus & Grafana (3-5 minutes)
   └─ Metrics collection & visualization
   
6. Deploy Loki & Promtail (2 minutes)
   └─ Log aggregation from all pods
   
7. Create Network Policies (1 minute)
   └─ Isolate namespaces from each other
   
8. Verify Everything (1 minute)
   └─ Check all components are running
   
TOTAL: ~15-20 minutes (vs 30-45 minutes manual)
```

### Error Handling

The script includes:
- ✅ Prerequisites validation
- ✅ Progress indicators for each phase
- ✅ Error handling and recovery
- ✅ Detailed logging to `.setup-infrastructure.log`
- ✅ Credential management
- ✅ Verification checklist
- ✅ Easy rollback with teardown script

---

## Credentials & Access

### Saved Credentials
After deployment, credentials are saved to: `.credentials`

```bash
# View credentials
cat .credentials

# Contains:
# - ArgoCD admin password
# - Grafana admin password
# - Access URLs
```

### Port Forwarding

Access local services:
```bash
# Grafana (port 3000)
kubectl port-forward svc/kube-prometheus-grafana -n monitoring 3000:80 &

# Prometheus (port 9090)
kubectl port-forward svc/kube-prometheus-prometheus -n monitoring 9090:9090 &

# ArgoCD (port 8080)
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
```

---

## Troubleshooting

### Script won't run
```bash
# Make sure script is executable
chmod +x scripts/setup-infrastructure.sh

# Run with bash explicitly
bash scripts/setup-infrastructure.sh
```

### Kubernetes cluster not found
```bash
# Start Docker Desktop (or Minikube/Kind)
# Enable Kubernetes in Docker Desktop settings
# Then run setup again
```

### Pods not starting
```bash
# Wait a bit longer (deployments take 2-5 minutes)
kubectl get pods -n monitoring -w

# View pod status
kubectl describe pod <pod-name> -n monitoring

# Check events
kubectl get events -n monitoring
```

### Need to see full logs
```bash
# Check detailed setup logs
tail -f .setup-infrastructure.log

# Check pod logs
kubectl logs -n <namespace> <pod-name>
```

### Want to restart
```bash
# Teardown everything
bash scripts/teardown-infrastructure.sh

# Then redeploy
bash scripts/setup-infrastructure.sh
```

---

## Next Steps

After setup completes:

1. **Connect Your GitHub Repository**
   - Create GitHub personal access token
   - Add your repository to ArgoCD
   - Create 3 ArgoCD applications (dev, staging, production)
   - See: README.md for detailed steps

2. **Deploy Your Applications**
   - Push Helm charts to your repository
   - ArgoCD automatically deploys
   - See: README.md for configuration

3. **Monitor Your Applications**
   - View metrics in Grafana
   - View logs in Loki (via Grafana)
   - Set up alerts
   - See: docs/MONITORING_SETUP.md

4. **Enable GitOps Workflow**
   - Push code to dev branch
   - GitHub Actions builds image
   - ArgoCD auto-deploys to dev namespace
   - Promote to staging → production
   - See: docs/GITOPS_PIPELINE.md

---

## Features

- ✅ **One-command deployment**: `bash scripts/setup-infrastructure.sh`
- ✅ **Fast setup**: 5-10 minutes (vs 30-45 manual)
- ✅ **Error handling**: Validates prerequisites, checks each phase
- ✅ **Progress tracking**: Clear output showing what's happening
- ✅ **Credential management**: Saves credentials to `.credentials`
- ✅ **Verification**: Confirms all components are running
- ✅ **Easy rollback**: `bash scripts/teardown-infrastructure.sh`
- ✅ **Logging**: Detailed logs in `.setup-infrastructure.log`
- ✅ **Cross-platform**: Works on Linux, macOS, Windows (WSL2)

---

## Support

For detailed documentation, see:
- `README.md` - Complete infrastructure guide
- `docs/ARGOCD_SETUP_GUIDE.md` - ArgoCD configuration
- `docs/MONITORING_SETUP.md` - Monitoring setup
- `docs/GITOPS_PIPELINE.md` - GitOps workflow
- `docs/TROUBLESHOOTING.md` - Common issues

---

## License

MIT
