# 🚀 Local DevOps Lab - Docker Desktop / Minikube / Kind

Welcome! This is a **complete local Kubernetes development environment** with everything pre-configured.

**Your job:** Focus on building and testing. Infrastructure is already built and automated.

## ⚡ Quick Start (One Command - 5-10 Minutes)

Deploy your entire local infrastructure:

```bash
bash scripts/setup-infrastructure.sh
```

**That's it!** Everything else is automated. Your infrastructure is ready.

---

## 🎯 What You Get (Already Built)

This template includes a **complete, production-ready infrastructure** pre-configured and ready to use:

| Component | Purpose | Environments | Status |
|-----------|---------|--------------|--------|
| **Kubernetes Cluster** | Runs your applications | Dev, Staging, Prod | ✅ Pre-configured |
| **ArgoCD** | Auto-deploys from GitHub | 3 branches → 3 environments | ✅ Pre-configured |
| **Prometheus** | Collects metrics | All environments | ✅ Pre-configured |
| **Grafana** | Dashboards & alerts | All environments | ✅ Pre-configured |
| **Loki** | Log aggregation | All environments | ✅ Pre-configured |
| **Namespaces** | Environment isolation | dev, staging, production | ✅ Pre-configured |
| **GitHub Integration** | GitOps pipeline | 3 branches (dev/staging/main) | ✅ Ready to connect |

**You don't set these up. They're already done. You just configure them with YOUR project.**

---

## � Prerequisites (One-Time Setup)

Before running the automation script, ensure you have a local Kubernetes cluster and basic tools installed.

### Option A: Docker Desktop (Mac/Windows - Recommended)

1. **Install Docker Desktop**: https://www.docker.com/products/docker-desktop
2. **Enable Kubernetes**:
   - Open Docker Desktop → Preferences/Settings
   - Go to **Kubernetes** tab
   - Check **Enable Kubernetes**
   - Wait ~2 minutes for it to start
3. **Verify**:
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

### Option B: Minikube (Linux/Mac/Windows)

1. **Install Minikube**: https://minikube.sigs.k8s.io/
2. **Start cluster**:
   ```bash
   minikube start --cpus=4 --memory=8192 --disk-size=50g
   minikube addons enable ingress
   ```
3. **Verify**:
   ```bash
   minikube status
   kubectl get nodes
   ```

### Option C: Kind (Lightweight - Linux/Mac/Windows)

1. **Install Kind**: https://kind.sigs.k8s.io/
2. **Create cluster**:
   ```bash
   kind create cluster --name devops-lab
   ```
3. **Verify**:
   ```bash
   kind get clusters
   kubectl get nodes
   ```

---

## 🛠️ Infrastructure Deployment (Automated)

The setup script handles everything automatically:

```bash
bash scripts/setup-infrastructure.sh
```

**What gets deployed (automatically):**
- ✅ 5 Kubernetes namespaces (dev, staging, production, argocd, monitoring)
- ✅ ArgoCD (GitOps automation)
- ✅ Prometheus (metrics collection)
- ✅ Grafana (dashboards)
- ✅ Loki + Promtail (log aggregation)
- ✅ Network policies (namespace isolation)

**Time:** 5-10 minutes
**What you do:** Just run the script. Everything else is automated.

---

## 📋 After Deployment: Configuration (5 Minutes)

Your infrastructure is ready. Now connect it to your Git repository and applications.

### Step 2: Create GitHub Personal Access Token

ArgoCD needs permission to access your repository:

1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"** (Classic)
3. Fill in:
   - Name: `argocd-token`
   - Expiration: 1 year
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `read:org`
   - ✅ `admin:repo_hook`
5. Click **"Generate token"** and **save it** - you'll need it next

---

### Step 3: Connect Your Repository to ArgoCD

Access ArgoCD and connect your repo:

```bash
# 1. Get ArgoCD admin password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

# 2. Port forward to ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# 3. Open browser: https://localhost:8080
# Login: admin / [password from step 1]
```

In ArgoCD Dashboard:
1. Click **Settings** (⚙️) → **Repositories**
2. Click **"+ Connect a repo using HTTPS"**
3. Enter:
   - Repository URL: `https://github.com/YOUR-USERNAME/your-project`
   - Username: `YOUR-GITHUB-USERNAME`
   - Password: `[YOUR-GITHUB-TOKEN]`
4. Click **Connect** ✅

---

### Step 4: Create ArgoCD Applications (One for Each Environment)

Create 3 applications to link your Git branches to Kubernetes namespaces.

**Create App 1: Dev Environment**

In ArgoCD, click **+ NEW APP** and fill in:

```
Application Name:     my-service-dev
Repository URL:       https://github.com/YOUR-USERNAME/your-project
Revision:             dev
Path:                 helm/my-service
Cluster URL:          https://kubernetes.default.svc
Namespace:            dev
Sync Policy:          Automatic ✅
```

Click **Create** ✅

**Create App 2: Staging Environment**

Click **+ NEW APP** again:

```
Application Name:     my-service-staging
Repository URL:       https://github.com/YOUR-USERNAME/your-project
Revision:             staging
Path:                 helm/my-service
Cluster URL:          https://kubernetes.default.svc
Namespace:            staging
Sync Policy:          Automatic ✅
```

Click **Create** ✅

**Create App 3: Production Environment**

Click **+ NEW APP** one more time:

```
Application Name:     my-service-prod
Repository URL:       https://github.com/YOUR-USERNAME/your-project
Revision:             main
Path:                 helm/my-service
Cluster URL:          https://kubernetes.default.svc
Namespace:            production
Sync Policy:          Automatic ✅
```

Click **Create** ✅

---

### ✅ Verification

You should now see in ArgoCD:

```
✅ my-service-dev       → Synced
✅ my-service-staging   → Synced
✅ my-service-prod      → Synced
```

**Perfect!** Your infrastructure is now connected to your Git repository.

---

## ⚡ Quick Start (5 Minutes to GitOps)

---

## 🔄 Development Workflow

Once everything is connected, your workflow is simple:

### Dev → Staging → Production

```
1. Make code changes on dev branch
   ↓
2. git push origin dev
   ↓
3. ArgoCD auto-deploys to dev namespace ✅
   (within seconds)
   ↓
4. Test and verify
   ↓
5. git merge dev → staging branch
   ↓
6. ArgoCD auto-deploys to staging namespace ✅
   ↓
7. Final verification
   ↓
8. git merge staging → main branch
   ↓
9. ArgoCD auto-deploys to production namespace ✅
```

**That's it!** No manual deployments. Every push = automatic deployment. That's GitOps.

---

## 📊 Monitoring Your Applications

### Access Grafana

```bash
# Port forward Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &

# Open: http://localhost:3000
# Login: admin / prom-operator
```

### View Metrics by Environment

In Grafana, query metrics for each namespace:

```
# Dev metrics
{namespace="dev"}

# Staging metrics
{namespace="staging"}

# Production metrics
{namespace="production"}
```

### View Logs by Environment

In Grafana (Explore → Loki):

```
# Dev logs
{namespace="dev"}

# Staging logs
{namespace="staging"}

# Production logs
{namespace="production"}
```

---

## 🔍 Multi-Environment Overview

Your infrastructure creates 3 isolated environments:

```
Dev (dev branch)
├─ Namespace: dev
├─ Auto-deploy on push
└─ Fast iteration

Staging (staging branch)
├─ Namespace: staging
├─ Test before production
└─ Mirror production

Production (main branch)
├─ Namespace: production
├─ Stable, monitored
└─ Ready for users
```

---

## 🛠️ Useful kubectl Commands

### Check All Environments

```bash
# View all pods in all environments
kubectl get pods -A

# Check specific environment
kubectl get pods -n dev
kubectl get pods -n staging
kubectl get pods -n production

# View services
kubectl get svc -n dev
kubectl get svc -n staging
kubectl get svc -n production
```

### Access Your Services

```bash
# Port forward to dev service
kubectl port-forward -n dev svc/my-service 3000:3000

# Port forward to staging service
kubectl port-forward -n staging svc/my-service 3000:3000

# Port forward to production service
kubectl port-forward -n production svc/my-service 3000:3000
```

### View Logs

```bash
# Dev logs
kubectl logs -n dev -f deployment/my-service

# Staging logs
kubectl logs -n staging -f deployment/my-service

# Production logs
kubectl logs -n production -f deployment/my-service
```

---

## ⚠️ Troubleshooting

### "Application shows OutOfSync"

```bash
# Manual sync (usually auto-syncs automatically)
# In ArgoCD Dashboard: Click app → SYNC button
```

### "Application not deploying"

**Check:**

1. Is your GitHub token still valid? → Re-connect repository in ArgoCD
2. Is the Helm chart path correct? → Verify in ArgoCD app settings
3. Are the values files correct? → Test locally: `helm template my-service ./helm/my-service`
4. Check ArgoCD logs:
   ```bash
   kubectl logs -n argocd deployment/argocd-application-controller | tail -20
   ```

### "Can't access my service"

```bash
# Verify service exists
kubectl get svc -n dev  # (or staging/production)

# Port forward to access
kubectl port-forward -n dev svc/my-service 3000:3000
```

---

## 📋 Verification Checklist

After setup, verify:

- [ ] 3 Git branches created (dev, staging, main)
- [ ] GitHub Personal Access Token saved
- [ ] ArgoCD repository connected
- [ ] 3 ArgoCD applications created (dev, staging, prod)
- [ ] All applications showing "Synced"
- [ ] Can access ArgoCD: https://localhost:8080
- [ ] Can access Grafana: http://localhost:3000
- [ ] Can see all namespaces: `kubectl get namespaces`
- [ ] Pods running: `kubectl get pods -A`
- [ ] Can view logs in Grafana for each environment

---

## 🎯 Summary

**Your infrastructure includes:**

✅ **Local Kubernetes** - Docker Desktop, Minikube, or Kind  
✅ **ArgoCD** - GitOps automation  
✅ **Prometheus & Grafana** - Metrics & dashboards  
✅ **Loki & Promtail** - Centralized logs  
✅ **3 Environments** - Dev, staging, production  
✅ **Multi-environment support** - Isolated namespaces  

**Your workflow:**

1. Push code → ArgoCD detects change → Auto-deploy ✅
2. Monitor in Grafana → View logs in Loki ✅
3. Promote through Git branches → Automatic progression ✅

**Ready to start?** Create your GitHub repository with 3 branches and Helm charts, then follow Step 2 above! 🚀
