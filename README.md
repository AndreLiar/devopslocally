# 🚀 Multi-Environment DevOps Template - Complete Infrastructure Ready

Welcome! This is a **production-grade DevOps infrastructure template** with everything pre-configured. 

**Your job:** Just provide your project details, and your multi-environment setup is ready. Focus on development, not infrastructure.

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

## ⚡ Quick Start (5 Minutes to GitOps)

### What You Need to Provide

1. **Your Git Repository** (GitHub)
   - 3 branches: `dev`, `staging`, `main`
   - Your application code
   - Your Helm charts

2. **Your Project Details**
   - Project name
   - Service name(s)
   - Port numbers
   - Container image registry

3. **Your GitHub Token**
   - For ArgoCD to access your repo

---

## 📋 Step-by-Step Configuration (15 Minutes)

### **Step 1: Prepare Your Git Repository**

Your GitHub repo should have this structure:

```
your-project-repo/
├── .github/workflows/          # CI/CD pipelines
│   └── deploy.yml
├── helm/                       # Helm charts for deployment
│   └── my-service/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           └── ingress.yaml
├── src/                        # Your application code
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
└── README.md
```

**The 3 Git Branches You Need:**
```
main branch     → production environment
staging branch  → staging environment
dev branch      → development environment
```

Each push to a branch automatically triggers deployment to the matching environment.

---

### **Step 2: Create GitHub Personal Access Token**

ArgoCD needs permission to pull from your repository:

1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"** (Classic)
3. Name it: `argocd-deployment-token`
4. Set expiration: 1 year (or 90 days)
5. Select **scopes**:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `read:org` (Read organization)
   - ✅ `admin:repo_hook` (Repository hooks)
6. Click **"Generate token"**
7. **SAVE THIS TOKEN** - you'll need it in Step 3

Example token: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

---

### **Step 3: Connect Your Repository to ArgoCD**

The cluster already has ArgoCD installed. You just need to connect your repo:

#### 3a. Access ArgoCD Dashboard

```bash
# Get the ArgoCD admin password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

# Port forward to access dashboard
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Open: https://localhost:8080
# Login: admin / [password from above]
```

#### 3b. Add Your Repository

In ArgoCD Dashboard:

1. Click **Settings** (⚙️ icon, left sidebar)
2. Click **Repositories**
3. Click **"+ Connect a repo using HTTPS"**
4. Fill in:
   ```
   Repository URL: https://github.com/YOUR-USERNAME/your-project
   Username: YOUR-GITHUB-USERNAME
   Password: [YOUR-GITHUB-TOKEN-FROM-STEP-2]
   ```
5. Click **Connect**
6. Expected: ✅ Connection successful

---

### **Step 4: Create ArgoCD Applications (for each environment)**

Now link your branches to environments:

#### 4a. Create Dev Environment Application

In ArgoCD Dashboard, click **+ NEW APP**:

```
GENERAL:
  Application Name: my-service-dev
  Project Name: default
  Sync Policy: Automatic ✅ (auto-sync on Git push)

SOURCE:
  Repository URL: https://github.com/YOUR-USERNAME/your-project
  Revision: dev (the dev branch)
  Path: helm/my-service

DESTINATION:
  Cluster URL: https://kubernetes.default.svc
  Namespace: dev
```

Click **Create** ✅

#### 4b. Create Staging Environment Application

Click **+ NEW APP** again:

```
GENERAL:
  Application Name: my-service-staging
  Project Name: default
  Sync Policy: Automatic ✅

SOURCE:
  Repository URL: https://github.com/YOUR-USERNAME/your-project
  Revision: staging (the staging branch)
  Path: helm/my-service

DESTINATION:
  Cluster URL: https://kubernetes.default.svc
  Namespace: staging
```

Click **Create** ✅

#### 4c. Create Production Environment Application

Click **+ NEW APP** one more time:

```
GENERAL:
  Application Name: my-service-prod
  Project Name: default
  Sync Policy: Automatic ✅

SOURCE:
  Repository URL: https://github.com/YOUR-USERNAME/your-project
  Revision: main (the main branch)
  Path: helm/my-service

DESTINATION:
  Cluster URL: https://kubernetes.default.svc
  Namespace: production
```

Click **Create** ✅

---

### **Step 5: Verify Multi-Environment Setup**

In ArgoCD Dashboard, you should now see 3 applications:

```
✅ my-service-dev       → Synced (from dev branch)
✅ my-service-staging   → Synced (from staging branch)  
✅ my-service-prod      → Synced (from main branch)
```

Each one monitors its branch and auto-deploys on changes!

---

## 🔄 GitOps Workflow (How It Works Now)

### Your Development Workflow

```
1. Make code changes on dev branch
   ↓
2. Push to GitHub: git push origin dev
   ↓
3. ArgoCD detects change immediately
   ↓
4. Automatically deploys to dev namespace ✅
   (within seconds)

5. Test and verify in dev environment
   ↓
6. Create Pull Request: dev → staging
   ↓
7. Merge PR to staging branch
   ↓
8. ArgoCD auto-deploys to staging namespace ✅
   
9. Final verification in staging
   ↓
10. Create Pull Request: staging → main
   ↓
11. Merge PR to main branch
   ↓
12. ArgoCD auto-deploys to production namespace ✅
```

**No manual deployments needed!** Every push → automatic deployment. That's GitOps.

---

## 📊 Monitor Your Applications

### Access Grafana Dashboard

```bash
# Port forward Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &

# Open: http://localhost:3000
# Login: admin / prom-operator
```

### View Your Application Metrics

In Grafana:
1. Click a dashboard (e.g., "Kubernetes / Cluster Monitoring")
2. You'll see:
   - CPU usage
   - Memory consumption
   - Request rates
   - Error rates
   - Network traffic

### View Application Logs

In Grafana:
1. Click **Explore** (left sidebar)
2. Select **Loki** (log viewer)
3. Run query:
   ```
   {namespace="dev"}
   ```
   or
   ```
   {namespace="staging"}
   ```
   or
   ```
   {namespace="production"}
   ```

You'll see all logs from that environment in real-time!

---

## 🔍 Multi-Environment Overview

### Environment Isolation

Each environment is completely isolated:

```
Dev Environment (dev branch → dev namespace)
├─ Your dev application instance
├─ Dev database (if needed)
├─ Dev configuration
└─ Dev logs & monitoring

Staging Environment (staging branch → staging namespace)
├─ Your staging application instance
├─ Staging database (if needed)
├─ Staging configuration
└─ Staging logs & monitoring

Production Environment (main branch → production namespace)
├─ Your production application instance
├─ Production database (if needed)
├─ Production configuration
└─ Production logs & monitoring
```

### Check What's Running in Each Environment

```bash
# Dev environment
kubectl get pods -n dev

# Staging environment
kubectl get pods -n staging

# Production environment
kubectl get pods -n production

# All environments at once
kubectl get pods -A
```

---

## 🔑 Important Configuration Files

### Your Helm Chart Structure

Each environment reads from the same Helm chart but with different values:

```
helm/my-service/
├── Chart.yaml                    # Chart metadata
├── values.yaml                   # Default values
├── values-dev.yaml               # Dev overrides
├── values-staging.yaml           # Staging overrides
├── values-prod.yaml              # Production overrides
└── templates/
    ├── deployment.yaml           # Kubernetes deployment
    ├── service.yaml              # Service definition
    ├── ingress.yaml              # Ingress rules
    └── configmap.yaml            # Environment config
```

### Environment-Specific Configuration

```yaml
# values-dev.yaml
replicaCount: 1
image:
  tag: dev-latest
resources:
  limits:
    memory: "256Mi"
    cpu: "250m"

# values-staging.yaml
replicaCount: 2
image:
  tag: staging-latest
resources:
  limits:
    memory: "512Mi"
    cpu: "500m"

# values-prod.yaml
replicaCount: 3
image:
  tag: latest
resources:
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

---

## 🚀 Deployment Flow

### Push to Dev Branch

```bash
# Make changes
nano src/server.js

# Commit and push to dev branch
git add src/
git commit -m "feat: add new endpoint"
git push origin dev
```

**What happens automatically:**
1. GitHub Actions builds Docker image
2. Pushes to registry
3. Updates `values-dev.yaml` with new image tag
4. ArgoCD detects change in 5 seconds
5. Deploys to `dev` namespace
6. You can access at: `http://my-service-dev:3000` (or your service port)

### Promote to Staging

```bash
# Create PR from dev to staging
git checkout staging
git pull origin staging
git merge dev
git push origin staging
```

**What happens automatically:**
1. Same GitHub Actions pipeline runs
2. Updates `values-staging.yaml`
3. ArgoCD auto-deploys to `staging` namespace
4. You can verify in staging
5. Access at: `http://my-service-staging:3000`

### Release to Production

```bash
# Create PR from staging to main
git checkout main
git pull origin main
git merge staging
git tag v1.0.0        # (optional) tag releases
git push origin main --tags
```

**What happens automatically:**
1. GitHub Actions runs
2. Updates `values-prod.yaml`
3. ArgoCD auto-deploys to `production` namespace
4. Your production app is live!
5. Access at: `http://my-service-prod:3000`

---

## 📊 Monitoring Multi-Environment

### View Metrics by Environment

In Grafana, create queries for each environment:

```
# Dev environment metrics
sum(rate(http_requests_total{namespace="dev"}[5m])) by (pod)

# Staging environment metrics
sum(rate(http_requests_total{namespace="staging"}[5m])) by (pod)

# Production environment metrics
sum(rate(http_requests_total{namespace="production"}[5m])) by (pod)
```

### View Logs by Environment

In Grafana Loki:

```
# Dev logs
{namespace="dev", app="my-service"}

# Staging logs
{namespace="staging", app="my-service"}

# Production logs
{namespace="production", app="my-service"}
```

---

## 🆘 Troubleshooting

### Problem: "ArgoCD Shows OutOfSync"

**Solution:** ArgoCD detected a change that isn't deployed yet.

```bash
# Manual sync (usually not needed - auto-sync should handle it)
# In ArgoCD Dashboard, click app → SYNC button
# Or use CLI:
argocd app sync my-service-dev
```

### Problem: "Application Not Deploying"

**Check these:**

1. Is your GitHub token still valid?
   ```bash
   # Re-connect repository in ArgoCD
   ```

2. Does your Helm chart have the correct path?
   ```bash
   # Verify in ArgoCD: Path should match your helm/ folder
   ```

3. Are your values files correct?
   ```bash
   # Test locally:
   helm template my-service ./helm/my-service -f ./helm/my-service/values-dev.yaml
   ```

4. Check ArgoCD logs:
   ```bash
   kubectl logs -n argocd deployment/argocd-application-controller | tail -20
   ```

### Problem: "Can't Access My Service"

**Get the service endpoint:**

```bash
# For dev
kubectl get svc -n dev
kubectl port-forward -n dev svc/my-service 3000:3000

# For staging
kubectl get svc -n staging
kubectl port-forward -n staging svc/my-service 3000:3000

# For production
kubectl get svc -n production
kubectl port-forward -n production svc/my-service 3000:3000
```

---

## ✅ Verification Checklist

After configuration, verify everything works:

- [ ] GitHub repository has 3 branches (dev, staging, main)
- [ ] GitHub Personal Access Token created and saved
- [ ] ArgoCD repository connected successfully
- [ ] 3 ArgoCD applications created (dev, staging, prod)
- [ ] All 3 applications showing "Synced" status
- [ ] Can access ArgoCD dashboard: https://localhost:8080
- [ ] Can access Grafana: http://localhost:3000
- [ ] Can see all 3 namespaces: `kubectl get namespaces`
  - [ ] dev
  - [ ] staging
  - [ ] production
- [ ] Pods running in each namespace:
  - [ ] `kubectl get pods -n dev`
  - [ ] `kubectl get pods -n staging`
  - [ ] `kubectl get pods -n production`
- [ ] Can view logs in Grafana Loki for each environment

---

## 📚 Quick Command Reference

### ArgoCD Commands

```bash
# Get admin password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

# Port forward to dashboard
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# List all applications
kubectl get applications -n argocd

# Check application status
kubectl describe app my-service-dev -n argocd

# Manual sync (if needed)
argocd app sync my-service-dev --auth-token $(argocd account generate-token)
```

### Grafana Commands

```bash
# Port forward
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &

# Get admin credentials
# Username: admin
# Password: prom-operator (change this!)
```

### Kubernetes Commands

```bash
# Check all namespaces
kubectl get namespaces

# Check pods in specific namespace
kubectl get pods -n dev
kubectl get pods -n staging
kubectl get pods -n production

# View logs
kubectl logs -n dev -f deployment/my-service
kubectl logs -n staging -f deployment/my-service
kubectl logs -n production -f deployment/my-service

# Check services
kubectl get svc -n dev
kubectl get svc -n staging
kubectl get svc -n production

# Port forward to service
kubectl port-forward -n dev svc/my-service 3000:3000
kubectl port-forward -n staging svc/my-service 3000:3000
kubectl port-forward -n production svc/my-service 3000:3000
```

---

## 🎯 What's Ready for You

### ✅ Already Configured (You Don't Need to Do These)

- ✅ Kubernetes cluster running
- ✅ 3 namespaces (dev, staging, production)
- ✅ ArgoCD installed and ready
- ✅ Prometheus collecting metrics
- ✅ Grafana with dashboards
- ✅ Loki collecting logs from all environments
- ✅ Ingress controller configured
- ✅ Network policies for multi-environment isolation

### ⚠️ You Need to Provide

- ⚠️ Your GitHub repository (with 3 branches)
- ⚠️ Your Helm charts in `helm/` folder
- ⚠️ Your application code in `src/` folder
- ⚠️ Your Dockerfile for containerization
- ⚠️ GitHub Personal Access Token

---

## 🚀 Next Steps

1. **Prepare your GitHub repository** with the 3 branches and Helm charts
2. **Generate GitHub Personal Access Token** (Step 2 above)
3. **Connect your repository to ArgoCD** (Step 3 above)
4. **Create 3 ArgoCD applications** (Step 4 above)
5. **Push code to dev branch** and watch it auto-deploy
6. **Promote through staging to production** using Git

**That's it!** Your complete multi-environment DevOps infrastructure is now ready. Focus on developing your service. The infrastructure handles everything else.

---

## 💡 Development Tips

1. **Always start with dev branch**
   - Make changes
   - Test in dev environment
   - Push and watch auto-deploy

2. **Use Grafana to monitor**
   - Check metrics for your service
   - Set up alerts for production
   - View logs for debugging

3. **Use GitOps workflow**
   - Every change goes through Git
   - Every branch gets its own environment
   - Full audit trail of all deployments

4. **Keep 3 environments separate**
   - Test in dev without affecting staging
   - Verify in staging before production
   - Production is stable for users

---

## 📞 Support

For detailed guides on specific components:

- **ArgoCD Setup**: See `docs/ARGOCD_SETUP_GUIDE.md`
- **Monitoring**: See `docs/MONITORING_SETUP.md`
- **Multi-Environment**: See `docs/MULTI_ENVIRONMENT_SETUP.md`
- **Troubleshooting**: See `docs/TROUBLESHOOTING.md`
- **Git Workflow**: See `docs/GITOPS_PIPELINE.md`

---

## 🎉 Summary

This template provides:

✅ **Complete infrastructure** - Kubernetes, monitoring, GitOps  
✅ **Multi-environment setup** - dev, staging, production  
✅ **Automatic deployments** - Push to Git, watch it deploy  
✅ **Full observability** - Metrics, dashboards, logs  
✅ **Production-ready** - Used by real applications  

**Your job:** Develop your service. **Our job:** Manage infrastructure.

---

**Ready to deploy?** Start with **Step 1: Prepare Your Git Repository** above! 🚀
