# ArgoCD Automated Setup & GitOps Integration Guide

## Overview

This guide covers the **automated setup of ArgoCD** for GitOps-based deployments in your multi-environment DevOps infrastructure.

ArgoCD automatically syncs your Git repository state with your Kubernetes cluster - enabling true GitOps workflows where:
- ✅ Deployments are declarative (defined in Git)
- ✅ Changes are automatically applied
- ✅ Git is the source of truth
- ✅ Multi-environment synchronization is automatic

---

## What Is ArgoCD?

**ArgoCD** is a declarative, GitOps continuous deployment tool for Kubernetes.

### Key Benefits
- **Declarative**: Define state in Git, ArgoCD ensures cluster matches it
- **Automated**: Changes in Git automatically deploy to cluster
- **Secure**: RBAC, auditing, no secrets in code
- **Multi-environment**: Manage dev, staging, production from one Git repo
- **Self-healing**: Automatically fixes drift between Git and cluster
- **Rollback**: Instant rollback to any previous Git commit

### Architecture
```
Git Repository (Source of Truth)
    ↓
    ├─ helm/auth-service/values-dev.yaml
    ├─ helm/auth-service/values-staging.yaml
    ├─ helm/auth-service/values-prod.yaml
    └─ helm/postgres/values-*.yaml
    
    ↓
    
ArgoCD (in Kubernetes)
    ├─ Watches Git repo
    ├─ Detects changes
    ├─ Compares with cluster state
    ├─ Syncs if drift detected
    └─ Reports status
    
    ↓
    
Kubernetes Cluster
    ├─ development namespace  (auto-synced)
    ├─ staging namespace      (auto-synced)
    └─ production namespace   (auto-synced)
```

---

## Quick Start (10 minutes)

### Step 1: Install ArgoCD
```bash
./scripts/setup-argocd.sh install
```

**What happens:**
- Creates ArgoCD namespace
- Installs ArgoCD via Helm
- Configures server and components
- Sets up initial admin password

**Expected output:**
```
✅ Namespace created
✅ Helm repository added
✅ ArgoCD installed
✅ ArgoCD installation completed
```

### Step 2: Configure Git Repository
```bash
./scripts/setup-argocd.sh configure \
  --repo https://github.com/AndreLiar/devopslocally.git \
  --branch main
```

**What happens:**
- Registers your Git repository
- Creates applications for each environment
- Sets up automatic syncing

**Expected output:**
```
✅ Repository configured
✅ Application created for development
✅ Application created for staging
✅ Application created for production
```

### Step 3: Setup Access
```bash
./scripts/setup-argocd.sh access
```

**Output includes:**
```
ArgoCD Access Information:
  URL: https://argocd.local
  Username: admin
  Password: [auto-generated password]
```

### Step 4: Check Status
```bash
./scripts/setup-argocd.sh status
```

**Expected output:**
```
✅ Deployments: argocd-server, argocd-application-controller, etc.
✅ Pods: All running
✅ Services: argocd-server, argocd-metrics, etc.
✅ Applications: app-development, app-staging, app-production
```

---

## Complete Setup Workflow

### Architecture After Setup

```
Your Git Repository
    │
    ├─ helm/
    │   ├─ auth-service/
    │   │   ├─ Chart.yaml
    │   │   ├─ values.yaml           (base)
    │   │   ├─ values-dev.yaml       (dev overrides)
    │   │   ├─ values-staging.yaml   (staging overrides)
    │   │   └─ values-prod.yaml      (prod overrides)
    │   └─ postgres/
    │       ├─ Chart.yaml
    │       ├─ values-dev.yaml
    │       ├─ values-staging.yaml
    │       └─ values-prod.yaml
    │
    └─ argocd-apps.yaml  ← ArgoCD Applications definition
    
                    ↓
    
    ArgoCD (in Kubernetes cluster)
    │
    ├─ Watches Git repo for changes
    ├─ Compares desired state (Git) with current state (cluster)
    ├─ Automatically syncs if different
    └─ Reports sync status & health
    
                    ↓
    
    Kubernetes Cluster
    │
    ├─ development namespace
    │   └─ auth-service pod (1 replica)
    │
    ├─ staging namespace
    │   └─ auth-service pod (2 replicas)
    │
    └─ production namespace
        └─ auth-service pod (3 replicas)
```

### Deployment Flow

```
Step 1: Developer Makes Change
  └─ Edits helm/auth-service/values-prod.yaml
  
Step 2: Developer Commits & Pushes
  └─ git push origin main
  
Step 3: Change is in Git (Source of Truth)
  └─ Immediately visible in repository
  
Step 4: ArgoCD Detects Change (within 3 minutes)
  └─ Periodic sync: Every 3 minutes by default
  └─ Webhook sync: Instant (if configured)
  
Step 5: ArgoCD Compares States
  └─ Desired state (Git): prod values updated
  └─ Current state (cluster): old values deployed
  └─ Difference detected → sync needed
  
Step 6: ArgoCD Syncs Changes
  └─ Updates deployment
  └─ Runs helm upgrade
  └─ Updates pods
  
Step 7: Cluster State Matches Git
  └─ Sync status: ✅ Synced
  └─ Health status: ✅ Healthy
```

---

## ArgoCD Commands Reference

### Installation & Setup
```bash
# Install ArgoCD
./scripts/setup-argocd.sh install

# Configure with GitHub repository
./scripts/setup-argocd.sh configure \
  --repo https://github.com/your-org/your-repo.git \
  --branch main

# Setup access and ingress
./scripts/setup-argocd.sh access

# Check current status
./scripts/setup-argocd.sh status
```

### Operations
```bash
# Port forward to access UI locally
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl get secret argocd-initial-admin-secret \
  -n argocd -o jsonpath="{.data.password}" | base64 -d

# View applications
kubectl get applications -n argocd

# View application details
kubectl describe application app-production -n argocd

# Manually sync application
kubectl patch application app-production \
  -n argocd --type json \
  -p='[{"op": "replace", "path": "/spec/syncPolicy/automated", "value": null}]'

# View ArgoCD events
kubectl get events -n argocd --sort-by='.lastTimestamp'

# Check sync status
kubectl get applications -n argocd -o custom-columns=\
NAME:.metadata.name,\
SYNC:.status.sync.status,\
HEALTH:.status.health.status
```

### Cleanup
```bash
# Remove ArgoCD (with confirmation)
./scripts/setup-argocd.sh cleanup
```

---

## Integration with Multi-Environment Setup

### How It Works Together

**Your infrastructure now has 3 layers:**

```
Layer 1: Git Repository (Source of Truth)
  └─ All configurations in YAML/Helm
  └─ Branch-based environment mapping
  
Layer 2: ArgoCD (GitOps Operator)
  └─ Watches Git for changes
  └─ Automatically deploys changes
  └─ Maintains state synchronization
  
Layer 3: Kubernetes Cluster (Runtime)
  └─ Actual running applications
  └─ dev, staging, production namespaces
```

### Complete Workflow

```
1. Developer Code Change
   └─ Update application code

2. Commit & Push to Branch
   └─ git push origin main

3. GitHub Actions Triggered (optional)
   └─ Runs tests
   └─ Builds container image
   └─ Pushes to registry

4. ArgoCD Detects Changes
   └─ Polls Git repo (every 3 min)
   └─ OR receives webhook (instant)

5. ArgoCD Compares States
   └─ Desired: values in Git
   └─ Current: running in cluster
   └─ Difference? → Sync needed

6. ArgoCD Applies Changes
   └─ helm upgrade
   └─ kubectl apply
   └─ Waits for rollout

7. Deployment Complete
   └─ New version running
   └─ All previous versions rolled back
   └─ Instant rollback available (git revert)
```

---

## Monitoring ArgoCD

### ArgoCD UI

Access the web interface:
```bash
# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Then open: https://localhost:8080
# Username: admin
# Password: [from setup-argocd.sh output]
```

### Dashboard Features
- ✅ Application sync status
- ✅ Resource health
- ✅ Deployment history
- ✅ Logs and events
- ✅ Resource tree visualization
- ✅ Manual sync/refresh

### CLI Status Checks
```bash
# View all applications
kubectl get applications -n argocd

# Detailed application info
kubectl describe application app-production -n argocd

# Watch sync in real-time
kubectl get applications -n argocd -w

# Export application status
kubectl get applications -n argocd -o yaml
```

---

## Configuration Examples

### Example: Update Production Replica Count

**Step 1: Edit Git**
```bash
# In your local repository
vim helm/auth-service/values-prod.yaml
```

Change:
```yaml
replicaCount: 3
```

To:
```yaml
replicaCount: 5
```

**Step 2: Commit and Push**
```bash
git add helm/auth-service/values-prod.yaml
git commit -m "chore: increase production replicas to 5"
git push origin main
```

**Step 3: ArgoCD Auto-Syncs**
```bash
# Within 3 minutes (or instant with webhook):
./scripts/multi-env-manager.sh status

# You'll see:
# ✅ production replicas: 5
```

### Example: Rollback Production

**Using Git (Recommended - Automatic with ArgoCD):**
```bash
# Revert the commit
git revert HEAD
git push origin main

# ArgoCD automatically syncs back to previous state
# Production rolled back instantly!
```

**Or Manually:**
```bash
# Via ArgoCD UI: Click "Sync" to desired revision
# Or via CLI:
kubectl rollout undo deployment/auth-service -n production
```

---

## Security Best Practices

### 1. Change Default Password
```bash
# Get current password
kubectl get secret argocd-initial-admin-secret \
  -n argocd -o jsonpath="{.data.password}" | base64 -d

# Login to UI, then change password in settings
# Or via CLI:
# kubectl port-forward svc/argocd-server -n argocd 8080:443
# argocd account update-password
```

### 2. Enable RBAC
```bash
# Create service account for deployments
kubectl create serviceaccount argocd-deployer -n argocd

# Grant permissions
kubectl create clusterrolebinding argocd-deployer \
  --clusterrole=edit \
  --serviceaccount=argocd:argocd-deployer
```

### 3. Restrict Git Access
- Use deploy keys or tokens with minimal permissions
- Restrict to specific repositories
- Use read-only access where possible

### 4. Enable Audit Logging
```bash
# View ArgoCD audit logs
kubectl logs -n argocd deployment/argocd-server | grep "audit"
```

### 5. Network Policies
```bash
# Restrict traffic to ArgoCD
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: argocd-network-policy
  namespace: argocd
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: argocd
  egress:
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443  # For Git HTTPS
EOF
```

---

## Troubleshooting

### Issue: ArgoCD Applications Not Syncing

**Symptoms:**
```
Sync Status: ❌ OutOfSync
Health: ⚠️ Degraded
```

**Solutions:**
```bash
# 1. Check application status
kubectl describe application app-production -n argocd

# 2. Check ArgoCD controller logs
kubectl logs -n argocd deployment/argocd-application-controller

# 3. Check ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# 4. Manual sync
kubectl patch application app-production -n argocd \
  -p '{"spec": {"syncPolicy": {}}}' --type merge

# 5. Force refresh
kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-server
```

### Issue: Repository Not Accessible

**Check:**
```bash
# Verify repository secret
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository

# Check repository credentials
kubectl describe secret github-repo -n argocd

# Check network connectivity
kubectl run -it --rm debug --image=alpine --restart=Never -- sh
# Inside pod: wget https://github.com/your-repo
```

### Issue: Helm Values Not Being Used

**Solutions:**
```bash
# 1. Verify Helm parameters in application
kubectl get application app-production -n argocd -o yaml | grep -A 10 "helm:"

# 2. Check for syntax errors in values files
helm template --values helm/auth-service/values-prod.yaml helm/auth-service

# 3. Manually refresh ArgoCD
kubectl rollout restart deployment/argocd-repo-server -n argocd
```

### Issue: Pod Pending After Sync

**Check:**
```bash
# Get pod status
kubectl get pods -n production

# Check pod events
kubectl describe pod <pod-name> -n production

# Check resource availability
kubectl describe nodes

# Check resource quotas
kubectl describe resourcequota -n production
```

---

## Advanced Configuration

### Webhook for Instant Sync

Instead of waiting 3 minutes, sync instantly on Git push:

```bash
# 1. Get ArgoCD webhook URL
echo "https://argocd.local/api/webhook"

# 2. Configure GitHub webhook
# Go to GitHub repo → Settings → Webhooks → Add webhook
# Payload URL: https://argocd.local/api/webhook
# Events: Just the push event
# Content type: application/json

# 3. Verify webhook works
kubectl logs -n argocd deployment/argocd-server | grep webhook
```

### Custom Health Assessments

```bash
# Add custom health rules to application
kubectl patch application app-production -n argocd \
  --type json \
  -p='[{"op": "add", "path": "/spec/ignoreDifferences", "value": [{"kind": "ConfigMap"}]}]'
```

### Multi-Repository Setup

```bash
# Add additional repository
./scripts/setup-argocd.sh configure \
  --repo https://github.com/yourorg/other-repo.git \
  --branch develop
```

---

## Integration with Your Current Setup

### Multi-Environment Manager + ArgoCD

```bash
# Traditional multi-environment deployment
./scripts/multi-env-manager.sh deploy development

# With ArgoCD (no manual deploy needed!)
# Just push to Git:
git push origin dev
# ArgoCD automatically deploys!
```

### GitHub Actions + ArgoCD

```
GitHub Actions:
  1. Builds container image
  2. Pushes to registry
  3. Updates Helm values in Git

    ↓

ArgoCD:
  1. Detects Git change
  2. Compares with cluster state
  3. Automatically syncs
  4. Updates running containers
```

---

## File Structure

```
devopslocally/
├── scripts/
│   ├── setup-cluster.sh          # Cluster setup
│   ├── setup-argocd.sh           # 🆕 ArgoCD setup
│   └── multi-env-manager.sh      # Environment management
├── helm/
│   ├── auth-service/
│   │   ├── values.yaml
│   │   ├── values-dev.yaml
│   │   ├── values-staging.yaml
│   │   └── values-prod.yaml
│   └── postgres/
│       └── values-*.yaml
├── argocd/
│   ├── applications.yaml         # 🆕 ArgoCD applications
│   ├── repositories.yaml         # 🆕 Git repositories config
│   └── kustomization.yaml        # 🆕 ArgoCD configuration
└── docs/
    └── ARGOCD_SETUP_GUIDE.md     # 🆕 This file
```

---

## Next Steps

1. **Install ArgoCD:**
   ```bash
   ./scripts/setup-argocd.sh install
   ```

2. **Configure Applications:**
   ```bash
   ./scripts/setup-argocd.sh configure
   ```

3. **Setup Access:**
   ```bash
   ./scripts/setup-argocd.sh access
   ```

4. **Verify Status:**
   ```bash
   ./scripts/setup-argocd.sh status
   ```

5. **Access Web UI:**
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   # Open: https://localhost:8080
   ```

---

## Summary

Your DevOps infrastructure now includes:

✅ **Complete automation stack:**
- Kubernetes cluster setup (automated)
- Multi-environment infrastructure (automated)
- ArgoCD GitOps deployment (automated)

✅ **True GitOps workflow:**
- Git as source of truth
- Automatic deployment on change
- Instant rollback capability
- Multi-environment synchronization

✅ **Production-ready:**
- High availability configurations
- Automatic self-healing
- Comprehensive monitoring
- Security best practices

**Everything is now fully automated - from infrastructure to deployments!** 🚀
