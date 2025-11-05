# Environment Configuration Quick Reference

## Branch Deployment Mapping

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GIT BRANCH → ENVIRONMENT                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  main        →  PRODUCTION      →  production namespace            │
│  staging     →  STAGING         →  staging namespace              │
│  dev         →  DEVELOPMENT     →  development namespace          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Quick Setup

```bash
# 1. Initialize all environments
./scripts/multi-env-manager.sh setup

# 2. Deploy to development (from dev branch)
git checkout dev
./scripts/multi-env-manager.sh deploy development

# 3. Deploy to staging (from staging branch)
git checkout staging
./scripts/multi-env-manager.sh deploy staging

# 4. Deploy to production (from main branch)
git checkout main
./scripts/multi-env-manager.sh deploy production

# 5. Check all environments
./scripts/multi-env-manager.sh status
```

## Environment Specifications

### 🔵 DEVELOPMENT

**Branch:** `dev`
**Namespace:** `development`
**Purpose:** Developer testing and experimentation

**Configuration:**
```yaml
Replicas:              1
CPU Request:           250m
CPU Limit:             500m
Memory Request:        128Mi
Memory Limit:          256Mi
Auto-scaling:          Disabled
Pod Disruption Budget: Disabled
Ingress:               Disabled
```

**Usage:**
```bash
# Access via port-forward
kubectl port-forward -n development svc/auth-service 3000:3000

# View logs
kubectl logs -n development -l app=auth-service -f

# Debug pod
kubectl exec -it -n development deployment/auth-service -- /bin/sh
```

**Features:**
- Always pull latest image
- Debug logging (verbose)
- Relaxed health checks
- No resource constraints
- Fast iteration

---

### 🟡 STAGING

**Branch:** `staging`
**Namespace:** `staging`
**Purpose:** Pre-production testing and validation

**Configuration:**
```yaml
Replicas:              2
CPU Request:           500m
CPU Limit:             1000m
Memory Request:        256Mi
Memory Limit:          512Mi
Auto-scaling:          Enabled (1-5 replicas)
Pod Disruption Budget: Enabled (1 available)
Ingress:               Enabled (staging domain)
```

**Usage:**
```bash
# Access staging application
curl https://staging-auth.example.com

# Check pod distribution
kubectl get pods -n staging -o wide

# View resource usage
kubectl top pods -n staging

# Deploy manual update
kubectl rollout restart deployment/auth-service -n staging
```

**Features:**
- HA testing (2 replicas)
- Production-like resources
- Standard monitoring
- TLS enabled
- End-to-end tests

---

### 🔴 PRODUCTION

**Branch:** `main`
**Namespace:** `production`
**Purpose:** Live customer-facing environment

**Configuration:**
```yaml
Replicas:              3
CPU Request:           1000m
CPU Limit:             2000m
Memory Request:        512Mi
Memory Limit:          1Gi
Auto-scaling:          Enabled (2-10 replicas)
Pod Disruption Budget: Enabled (1 available)
Ingress:               Enabled (production domain)
```

**Usage:**
```bash
# Access production application
curl https://auth.example.com

# Monitor deployment
kubectl top nodes -n production
kubectl top pods -n production

# Check alerts
kubectl get prometheusrules -n production

# Review audit logs
kubectl logs -n production deployment/auth-service --tail=1000
```

**Features:**
- High availability (3+ replicas)
- Aggressive autoscaling
- Strict health checks
- Production alerting
- Point-in-time recovery
- Canary deployments

---

## Helm Values Override Precedence

For each environment, values are applied in this order (later overrides earlier):

```
1. helm/auth-service/values.yaml
2. helm/auth-service/values-{env}.yaml
3. --set flags from CI/CD
4. Environment variables (if configured)
```

**Example - Production deployment command:**
```bash
helm upgrade --install auth-service helm/auth-service/ \
  -f helm/auth-service/values.yaml \              # Base config
  -f helm/auth-service/values-prod.yaml \         # Prod overrides
  --set environment=production \                   # CI/CD override
  --set image.tag=latest \                        # Latest image
  -n production
```

---

## Database Configuration

### Development Database
```yaml
Replicas:           1
Storage:            5Gi
Backups:            Disabled
Replication:        Disabled
Auto-restart:       Yes
```

### Staging Database
```yaml
Replicas:           2 (with replicas)
Storage:            20Gi
Backups:            Daily (2 AM)
Replication:        Yes (synchronous)
Auto-restart:       Yes
```

### Production Database
```yaml
Replicas:           2 (with replicas)
Storage:            100Gi (or more)
Backups:            Hourly + PITR
Replication:        Yes (synchronous)
Auto-restart:       Yes
Read replicas:      2+
```

---

## ConfigMaps & Secrets per Environment

### Development
```bash
# ConfigMap
kubectl get configmap -n development auth-config-dev

# Secret
kubectl get secret -n development auth-secrets-dev
```

### Staging
```bash
# ConfigMap
kubectl get configmap -n staging auth-config-staging

# Secret
kubectl get secret -n staging auth-secrets-staging
```

### Production
```bash
# ConfigMap
kubectl get configmap -n production auth-config-prod

# Secret
kubectl get secret -n production auth-secrets-prod
```

---

## Deployment Workflow

### Code Promotion

```
Your Code
    ↓
    Push to dev branch
    ↓
    GitHub Actions → Deploy to development namespace
    ↓
    Manual Testing in dev
    ↓
    Push to staging branch (PR)
    ↓
    GitHub Actions → Deploy to staging namespace
    ↓
    User Acceptance Testing (UAT)
    ↓
    Merge to main branch
    ↓
    GitHub Actions → Deploy to production namespace
    ↓
    Live ✅
```

### Automatic Deployments

**On push to dev:**
```bash
$ git push origin dev
→ Triggers GitHub Actions
→ Runs tests
→ Deploys to development namespace
→ Runs smoke tests
→ Complete in ~3 minutes
```

**On push to staging:**
```bash
$ git push origin staging
→ Triggers GitHub Actions
→ Runs full test suite
→ Deploys to staging namespace
→ Runs e2e tests
→ Complete in ~5 minutes
```

**On push to main:**
```bash
$ git push origin main
→ Triggers GitHub Actions
→ Runs full security scan
→ Requires approval (auto-approves if tests pass)
→ Deploys to production namespace
→ Runs smoke tests
→ Complete in ~8 minutes
```

---

## Common Operations

### Deploy Specific Environment

```bash
# Deploy to development
./scripts/multi-env-manager.sh deploy development

# Deploy to staging
./scripts/multi-env-manager.sh deploy staging

# Deploy to production
./scripts/multi-env-manager.sh deploy production
```

### Check Status

```bash
# All environments
./scripts/multi-env-manager.sh status

# Specific environment details
./scripts/multi-env-manager.sh details production
```

### Rollback

```bash
# Rollback production
./scripts/multi-env-manager.sh rollback production

# Rollback staging
./scripts/multi-env-manager.sh rollback staging

# Rollback development
./scripts/multi-env-manager.sh rollback development
```

### Compare Configurations

```bash
# Compare all environments
./scripts/multi-env-manager.sh compare

# Manual check
kubectl get deployment auth-service \
  -n development -o jsonpath='{.spec.replicas}'
kubectl get deployment auth-service \
  -n staging -o jsonpath='{.spec.replicas}'
kubectl get deployment auth-service \
  -n production -o jsonpath='{.spec.replicas}'
```

---

## Troubleshooting

### Deployment stuck in development?
```bash
kubectl describe pod -n development -l app=auth-service
kubectl logs -n development -l app=auth-service
```

### Staging database not syncing?
```bash
kubectl exec -it -n staging postgres-0 -- pg_isready
kubectl logs -n staging statefulset/postgres
```

### Production rollout issues?
```bash
kubectl rollout status deployment/auth-service -n production
kubectl rollout history deployment/auth-service -n production
kubectl rollout undo deployment/auth-service -n production
```

---

## Environment-Specific Features

### Development Only
```
- Debug logging
- Hot reload enabled
- Single replica
- No resource limits
- Direct port-forward access
```

### Staging Only
```
- UAT endpoints
- Performance testing
- Replica testing
- TLS with staging certificates
- Daily backups
```

### Production Only
```
- Auto-scaling (2-10 replicas)
- Rate limiting
- DDoS protection
- Encrypted secrets
- Hourly backups
- Real-time monitoring
- Incident alerts
```

---

## Next Steps

1. ✅ Set up all environments: `./scripts/multi-env-manager.sh setup`
2. ✅ Deploy to dev: `git push origin dev`
3. ✅ Test in development namespace
4. ✅ Deploy to staging: `git push origin staging`
5. ✅ Run UAT tests
6. ✅ Deploy to production: `git push origin main`
7. ✅ Monitor production

**Done!** Your multi-environment setup is complete. 🚀
