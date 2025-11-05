# ArgoCD Quick Reference & Command Guide

## 🚀 Quick Start (3 Commands)

```bash
# 1. Install ArgoCD (5 minutes)
./scripts/setup-argocd.sh install

# 2. Configure applications (1 minute)
./scripts/setup-argocd.sh configure

# 3. Access and monitor
./scripts/setup-argocd.sh access
```

---

## 📋 Complete Command Reference

### Installation & Setup

| Command | Purpose | Time |
|---------|---------|------|
| `./scripts/setup-argocd.sh install` | Install ArgoCD | 5 min |
| `./scripts/setup-argocd.sh install --version v2.8.0` | Install specific version | 5 min |
| `./scripts/setup-argocd.sh configure` | Setup applications | 1 min |
| `./scripts/setup-argocd.sh access` | Setup access & ingress | 2 min |
| `./scripts/setup-argocd.sh status` | Check status | 1 min |
| `./scripts/setup-argocd.sh cleanup` | Remove ArgoCD | 2 min |

### Access & Authentication

```bash
# Get admin password
kubectl get secret argocd-initial-admin-secret \
  -n argocd -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Change admin password
argocd account update-password --account admin

# Create service account
kubectl create serviceaccount myapp -n argocd

# Get API token
kubectl describe secret $(kubectl get secret -n argocd | grep myapp | awk '{print $1}') -n argocd
```

### Application Management

```bash
# List all applications
kubectl get applications -n argocd

# Get application status
kubectl get application app-production -n argocd -o wide

# Describe application
kubectl describe application app-production -n argocd

# View application details (full YAML)
kubectl get application app-production -n argocd -o yaml

# Watch application status in real-time
kubectl get applications -n argocd -w

# Check sync status only
kubectl get applications -n argocd -o custom-columns=\
NAME:.metadata.name,\
SYNC:.status.sync.status,\
HEALTH:.status.health.status
```

### Synchronization

```bash
# Manual sync application
kubectl patch application app-production -n argocd \
  -p '{"metadata": {"labels": {"refresh": "'"$(date +%s)"'"}}}' --type merge

# Force sync (discard local changes)
kubectl patch application app-production -n argocd \
  -p '{"spec": {"syncPolicy": {"syncOptions": ["RespectIgnoreDifferences=true"]}}}' --type merge

# Disable auto-sync
kubectl patch application app-production -n argocd \
  -p '{"spec": {"syncPolicy": {"automated": null}}}' --type merge

# Enable auto-sync
kubectl patch application app-production -n argocd \
  -p '{"spec": {"syncPolicy": {"automated": {"prune": true, "selfHeal": true}}}}' --type merge

# Sync all applications
kubectl patch applications --all -n argocd \
  -p '{"metadata": {"labels": {"refresh": "'"$(date +%s)"'"}}}' --type merge
```

### Monitoring & Logs

```bash
# ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Application controller logs
kubectl logs -n argocd deployment/argocd-application-controller

# Repository server logs
kubectl logs -n argocd deployment/argocd-repo-server

# API server logs
kubectl logs -n argocd deployment/argocd-server

# Watch all logs
kubectl logs -n argocd -f --all-containers=true -l app.kubernetes.io/name=argocd

# Stream logs from specific pod
kubectl logs -n argocd -f pod/argocd-server-xxx

# Get all events
kubectl get events -n argocd --sort-by='.lastTimestamp'

# Watch events
kubectl get events -n argocd -w
```

### Repositories

```bash
# List repositories
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository

# View repository details
kubectl describe secret github-repo -n argocd

# Add new repository (via kubectl)
kubectl create secret generic my-repo \
  -n argocd \
  --from-literal=type=git \
  --from-literal=url=https://github.com/yourorg/yourrepo.git \
  --from-literal=username=your-username \
  --from-literal=password=your-token \
  -o yaml | kubectl apply -f - \
  -l argocd.argoproj.io/secret-type=repository
```

### Troubleshooting

```bash
# Check all ArgoCD components
kubectl get all -n argocd

# Check pod status
kubectl get pods -n argocd

# Check pod logs
kubectl logs -n argocd pod/argocd-server-xxx

# Describe failing pod
kubectl describe pod -n argocd pod/argocd-application-controller-xxx

# Check resource usage
kubectl top nodes
kubectl top pods -n argocd

# Debug application sync
kubectl describe application app-production -n argocd

# Check cluster connectivity
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=cluster

# Verify Git repository access
kubectl exec -it pod/argocd-repo-server-xxx -n argocd -- \
  git ls-remote https://github.com/yourorg/yourrepo.git
```

### Deletion & Cleanup

```bash
# Delete single application
kubectl delete application app-development -n argocd

# Delete all applications
kubectl delete applications --all -n argocd

# Delete ArgoCD namespace (removes everything)
kubectl delete namespace argocd

# Full cleanup script
./scripts/setup-argocd.sh cleanup
```

---

## 🔄 GitOps Workflow Examples

### Example 1: Update Application Replica Count

**Step 1: Modify Git**
```bash
cd ~/devopslocally
vim helm/auth-service/values-prod.yaml
# Change replicaCount: 3 to replicaCount: 5
git add helm/auth-service/values-prod.yaml
git commit -m "chore: scale production to 5 replicas"
git push origin main
```

**Step 2: ArgoCD Auto-Syncs (within 3 minutes)**
```bash
# Monitor sync status
kubectl get application app-production -n argocd -w

# Expected output after sync:
# NAME               SYNC STATUS   HEALTH STATUS
# app-production     Synced        Healthy
```

**Step 3: Verify Changes**
```bash
./scripts/multi-env-manager.sh status
# Should show production: 5/5 replicas running
```

### Example 2: Rollback Deployment

**Via Git (Recommended - Automatic with ArgoCD):**
```bash
# Revert the previous commit
git revert HEAD
git push origin main

# ArgoCD automatically syncs back
# Application rolled back instantly!
```

**Via kubectl (Manual):**
```bash
# Get previous revision
argocd app get app-production

# Rollback to previous revision
argocd app rollback app-production 1

# Or manually redeploy from previous commit
git checkout HEAD~1 helm/auth-service/values-prod.yaml
git push origin main
```

### Example 3: Update Database Configuration

**Step 1: Modify database values**
```bash
vim helm/postgres/values-staging.yaml
# Update backup schedule, storage size, etc.
git add helm/postgres/values-staging.yaml
git commit -m "chore: update staging database configuration"
git push origin staging
```

**Step 2: Monitor ArgoCD sync**
```bash
kubectl get application postgres-staging -n argocd -w
```

**Step 3: Verify**
```bash
kubectl describe statefulset postgres -n staging
```

### Example 4: Emergency Hotfix

**Critical bug in production:**

```bash
# 1. Fix code
vim auth-service/server.js
# Fix critical bug

# 2. Commit to main branch
git add auth-service/server.js
git commit -m "fix: critical security issue"
git push origin main

# 3. Docker image built automatically
# GitHub Actions builds and pushes image

# 4. Update Helm values with new image tag
vim helm/auth-service/values-prod.yaml
# Update image.tag to new version
git add helm/auth-service/values-prod.yaml
git commit -m "chore: deploy fixed image to production"
git push origin main

# 5. ArgoCD automatically deploys
# Check status:
kubectl get application app-production -n argocd -o wide

# Deployment complete within 3-5 minutes!
```

---

## 🎯 Common Scenarios

### Scenario 1: Canary Deployment

```bash
# Gradually roll out to production
# 1. Deploy to development
git push origin dev

# 2. Wait for testing, then staging
git push origin staging

# 3. Only after validation, push to main
git push origin main
```

### Scenario 2: Blue-Green Deployment

```bash
# Create new deployment variant
cp helm/auth-service/values-prod.yaml helm/auth-service/values-prod-green.yaml

# Deploy green version
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-production-green
  namespace: argocd
spec:
  source:
    path: helm/auth-service
    helm:
      valuesObject:
        deployment: green
EOF

# When ready, switch traffic
# Remove old deployment, keep new one
kubectl delete application app-production -n argocd
kubectl patch application app-production-green -n argocd \
  --type merge \
  -p '{"metadata":{"name":"app-production"}}'
```

### Scenario 3: Feature Branch Workflow

```bash
# Developer creates feature branch
git checkout -b feature/new-feature

# Develop and test locally
# ...code changes...

# Create temporary ArgoCD application for feature testing
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-feature-test
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/yourorg/yourrepo.git
    targetRevision: feature/new-feature
    path: helm/auth-service
  destination:
    namespace: feature-test
EOF

# Test in dedicated namespace
kubectl get application app-feature-test -n argocd -w

# When ready, merge to main
git checkout main
git merge feature/new-feature
git push origin main

# Delete test application
kubectl delete application app-feature-test -n argocd
```

---

## 📊 Monitoring Dashboard Commands

```bash
# One-line monitoring
watch -n 5 'kubectl get applications -n argocd -o custom-columns=\
NAME:.metadata.name,\
SYNC:.status.sync.status,\
HEALTH:.status.health.status,\
LASTSYNC:.status.operationState.finishedAt'

# Full status with resources
watch -n 5 'kubectl get application app-production -n argocd -o jsonpath=\
"{.status.sync.status} | {.status.health.status} | {.spec.source.repoURL} | {.spec.source.targetRevision}"'

# Pod status in all environments
watch -n 5 'for ns in development staging production; do 
  echo "=== $ns ==="; 
  kubectl get pods -n $ns -o custom-columns=\
NAME:.metadata.name,\
STATUS:.status.phase,\
READY:.status.conditions[?(@.type=="Ready")].status; 
done'
```

---

## ⚡ Performance Optimization

```bash
# Increase sync frequency
kubectl patch configmap argocd-cmd-params-cm -n argocd \
  -p '{"data":{"application.instanceLabelKey":"argocd.argoproj.io/instance","server.timeout.reconciliation":"30s"}}'

# Enable webhook for instant sync
# See ARGOCD_SETUP_GUIDE.md for webhook setup

# Increase retry limits
kubectl patch application app-production -n argocd \
  --type merge \
  -p '{"spec":{"syncPolicy":{"retry":{"limit":10,"backoff":{"duration":"10s","factor":2,"maxDuration":"5m"}}}}}'
```

---

## 🔐 Security Commands

```bash
# Restrict RBAC
kubectl create rolebinding argocd-server \
  --clusterrole=view \
  --serviceaccount=argocd:argocd-server

# Enable network policies
kubectl apply -f - <<'EOF'
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
    - podSelector: {}
    ports:
    - protocol: TCP
      port: 443
EOF

# Audit logging
kubectl logs -n argocd deployment/argocd-server \
  | grep -i "audit\|admin\|sync"
```

---

## 📚 Integration with Other Tools

### With GitLab
```bash
# Add GitLab repository
./scripts/setup-argocd.sh configure \
  --repo https://gitlab.com/yourgroup/yourproject.git \
  --branch main
```

### With Bitbucket
```bash
# Add Bitbucket repository
./scripts/setup-argocd.sh configure \
  --repo https://bitbucket.org/yourteam/yourrepo.git \
  --branch main
```

### With GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main, staging, dev]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Trigger ArgoCD sync
        run: |
          # ArgoCD detects Git change automatically
          # No manual trigger needed!
          echo "Changes pushed, ArgoCD will sync within 3 minutes"
```

---

## 💡 Best Practices

✅ **Do:**
- Use Git as source of truth
- Keep all configs in Git
- Use branch-based environments
- Enable auto-sync for dev/staging
- Disable auto-prune for production
- Monitor sync status regularly
- Use namespace labels for organization
- Document deployment procedures

❌ **Don't:**
- Manually kubectl apply to production
- Store passwords in Git
- Disable health checks
- Use manual sync for prod
- Skip testing before merge
- Delete applications without backup
- Mix manual and GitOps deployments

---

## 🚀 Next Steps

1. **Install ArgoCD:**
   ```bash
   ./scripts/setup-argocd.sh install
   ```

2. **Configure Applications:**
   ```bash
   ./scripts/setup-argocd.sh configure
   ```

3. **Start Using GitOps:**
   ```bash
   git push origin main
   # Automatic deployment!
   ```

4. **Monitor and Manage:**
   ```bash
   ./scripts/setup-argocd.sh status
   ```

---

## 📞 Getting Help

- Official Docs: https://argo-cd.readthedocs.io/
- GitHub Issues: https://github.com/argoproj/argo-cd/issues
- Community Chat: https://argoproj.github.io/community/get-involved/
- Local Setup Guide: `docs/ARGOCD_SETUP_GUIDE.md`
