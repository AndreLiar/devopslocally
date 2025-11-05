# 🎯 Developer Guide: Build & Deploy Your Services

> **You don't need to know Kubernetes.** This template handles all infrastructure automation. Focus on building your services—deployment is automatic.

---

## 📝 The Developer Workflow

### Your Responsibility:
1. ✅ **Build your service** (write code)
2. ✅ **Create a Docker image** (one Dockerfile)
3. ✅ **Add Helm chart** (copy + modify template)
4. ✅ **Push to Git** (one git push command)

### What We Handle (Automatically):
- ✅ Kubernetes cluster setup
- ✅ Multi-environment infrastructure (dev/staging/prod)
- ✅ GitOps continuous deployment (via ArgoCD)
- ✅ Health checks and monitoring
- ✅ Auto-scaling and resource management
- ✅ Rollbacks and disaster recovery

---

## 🚀 Quick Start: Deploy Your First Service (30 minutes)

### Step 1: One-Time Infrastructure Setup (20 minutes)

Run this **ONCE**. Everything else is automatic:

```bash
# Navigate to project
cd devopslocally

# Install Kubernetes cluster and all tools
./scripts/setup-cluster.sh

# Create development, staging, production namespaces
./scripts/multi-env-manager.sh setup

# Setup GitOps (ArgoCD)
./scripts/setup-argocd.sh install
./scripts/setup-argocd.sh configure
./scripts/setup-argocd.sh access
```

**That's it!** Your complete infrastructure is ready. No more manual setup needed.

---

### Step 2: Add Your Service (5 minutes per service)

#### Option A: Add to Existing Service

If you're adding to the existing `auth-service`:

```bash
# 1. Edit your code
vim auth-service/server.js

# 2. Update version (automatic Dockerfile rebuild)
# Edit: auth-service/package.json -> version: "1.1.0"

# 3. Commit and push
git add -A
git commit -m "feat: add new feature"
git push origin dev          # Auto-deploys to development
# or
git push origin staging      # Auto-deploys to staging
# or
git push origin main         # Auto-deploys to production
```

**DONE!** Your service is automatically deployed with health checks.

---

#### Option B: Create a NEW Service

Follow this template structure:

```bash
# Create service directory
mkdir my-service

# Copy existing service structure
cp -r auth-service/* my-service/
cd my-service

# Modify for your service
# 1. Edit package.json (name, dependencies)
# 2. Edit server.js (your app logic)
# 3. Edit Dockerfile (if needed)

# Create Helm chart (copy existing template)
mkdir -p ../helm/my-service
cp -r ../helm/auth-service/* ../helm/my-service/

# Modify Helm chart values
# Edit: helm/my-service/values.yaml
# Edit: helm/my-service/values-dev.yaml
# Edit: helm/my-service/values-staging.yaml
# Edit: helm/my-service/values-prod.yaml

# Add to ArgoCD (update applications.yaml)
# Copy auth-service applications and update names

# Commit and push
git add -A
git commit -m "feat: add my-service"
git push origin dev
```

**DONE!** Your new service is automatically deployed.

---

### Step 3: Push to Deploy (literally just git push)

```bash
# Develop in dev branch
git push origin dev        # Instantly deploys to development namespace

# Test in staging
git push origin staging    # Instantly deploys to staging namespace

# Deploy to production
git push origin main       # Instantly deploys to production namespace
```

**That's literally it.** No kubectl commands. No manual deployment steps.

---

## 📋 Service Template Structure

When creating a new service, follow this structure:

```
my-service/
├── package.json              # Service dependencies
├── server.js                 # Main application
├── Dockerfile                # Container definition (usually unchanged)
├── .dockerignore              # Docker build optimization
└── tests/
    ├── unit/
    └── integration/

helm/my-service/
├── Chart.yaml                # Helm chart metadata
├── values.yaml               # Default values
├── values-dev.yaml           # Development overrides
├── values-staging.yaml       # Staging overrides
├── values-prod.yaml          # Production overrides
├── templates/
│   ├── deployment.yaml       # Kubernetes deployment
│   ├── service.yaml          # Kubernetes service
│   ├── hpa.yaml             # Auto-scaling rules
│   ├── ingress.yaml         # Load balancer configuration
│   └── ...
```

---

## 🔧 Common Developer Tasks

### Task 1: Update Your Service in Development

```bash
# Edit code
nano auth-service/server.js

# Push to git
git add auth-service/server.js
git commit -m "fix: update endpoint"
git push origin dev

# ✅ AUTOMATIC:
# • Docker image rebuilds (GitHub Actions)
# • Kubernetes deployment updates (ArgoCD)
# • Health checks verify it works
# • Instant feedback on errors
```

**Check deployment status:**
```bash
./scripts/multi-env-manager.sh status
```

---

### Task 2: Update Configuration (No code change)

```bash
# Edit Helm values (dev environment)
nano helm/auth-service/values-dev.yaml

# Change: replicas, memory, CPU, database host, etc.

# Push to git
git add helm/auth-service/values-dev.yaml
git commit -m "config: increase replicas in dev"
git push origin dev

# ✅ AUTOMATIC:
# • Kubernetes updates with new configuration
# • Pods restart with new settings
# • Health checks verify it works
```

---

### Task 3: Environment-Specific Configuration

Each environment has its own values file:

**Development (1 replica, 256MB RAM):**
```bash
vim helm/my-service/values-dev.yaml
```

**Staging (2 replicas, 512MB RAM):**
```bash
vim helm/my-service/values-staging.yaml
```

**Production (3 replicas, 1GB RAM, load balancer):**
```bash
vim helm/my-service/values-prod.yaml
```

**Push once, all environments update automatically:**
```bash
git push origin dev
git push origin staging
git push origin main
```

---

### Task 4: Add a New Service Dependency

```bash
# Add to package.json
npm install express-cors

# Update package.json in git
git add auth-service/package.json auth-service/package-lock.json
git commit -m "feat: add cors support"
git push origin dev

# ✅ AUTOMATIC:
# • npm install runs in Docker build
# • New image is built and pushed
# • Kubernetes deployment updates
# • Service restarts with new dependencies
```

---

### Task 5: Scale Your Service

```bash
# Change replicas in Helm values
nano helm/my-service/values-prod.yaml
# Change: replicas: 3 → replicas: 5

# Push to git
git add helm/my-service/values-prod.yaml
git commit -m "ops: scale production to 5 replicas"
git push origin main

# ✅ AUTOMATIC:
# • Kubernetes spins up 2 new pods
# • Load balancer distributes traffic
# • Health checks monitor all pods
```

---

### Task 6: Rollback a Bad Deployment

```bash
# If something went wrong, revert the git commit
git revert HEAD
git push origin dev

# ✅ AUTOMATIC:
# • ArgoCD detects the revert
# • Kubernetes rolls back to previous version
# • Service is restored within 1-2 minutes
# • No manual intervention needed
```

---

## 📊 What Happens Automatically

### When You Push Code:

```
Developer Push (git push origin main)
        ↓
GitHub Actions Triggered
        ↓
Build Docker Image
        ↓
Push to Registry
        ↓
Update Helm Values
        ↓
Commit to Git
        ↓
ArgoCD Detects Change
        ↓
Kubernetes Updates Deployment
        ↓
Pods Restart with New Image
        ↓
Health Checks Verify
        ↓
✅ Service Live & Healthy
```

**Time: 3-8 minutes, Zero Manual Steps**

---

### When You Update Configuration:

```
Developer Push (git push origin dev)
        ↓
ArgoCD Detects Change
        ↓
Helm Reconciles New Values
        ↓
Kubernetes Updates Configuration
        ↓
✅ Service Updated
```

**Time: 30 seconds - 1 minute, Zero Manual Steps**

---

## 🎯 Development Environments

### Development (dev branch)
- **Purpose:** Active development, testing new features
- **Replicas:** 1 (minimal resources)
- **Update Speed:** Instant (push and see results immediately)
- **Access:** Via port-forward or local ingress
- **Data:** Ephemeral (resets with pod restart)

```bash
git push origin dev
# Deploys to: development namespace
```

---

### Staging (staging branch)
- **Purpose:** Pre-production testing, integration tests
- **Replicas:** 2 (load balancing)
- **Update Speed:** Fast (2-3 minutes)
- **Access:** Via staging.example.com (ingress)
- **Data:** Persistent (survives pod restarts)

```bash
git push origin staging
# Deploys to: staging namespace
```

---

### Production (main branch)
- **Purpose:** Live service, user traffic
- **Replicas:** 3+ (high availability)
- **Update Speed:** Controlled (3-8 minutes)
- **Access:** Via example.com (load balancer)
- **Data:** Persistent + backups (guaranteed safety)

```bash
git push origin main
# Deploys to: production namespace
```

---

## 🔍 Monitoring Your Service

### Quick Status Check

```bash
# See all services and their status
./scripts/multi-env-manager.sh status

# Output example:
# ✅ DEVELOPMENT
#    Service: auth-service (1/1 ready)
#    URL: http://localhost:3000
#    Last Update: 2 minutes ago
#
# ✅ STAGING
#    Service: auth-service (2/2 ready)
#    URL: http://staging.example.com
#    Last Update: 30 seconds ago
#
# ✅ PRODUCTION
#    Service: auth-service (3/3 ready)
#    URL: http://example.com
#    Last Update: 10 minutes ago
```

---

### Detailed Environment Info

```bash
./scripts/multi-env-manager.sh details prod

# Shows:
# • Pod status and health
# • Resource usage (CPU, memory)
# • Recent events
# • Rollout history
# • Database connections
```

---

### View Logs

```bash
# Watch logs in real-time
kubectl logs -f deployment/auth-service -n development

# View logs from specific pod
kubectl logs pod-name -n development

# View all pods logs
kubectl logs -l app=auth-service -n development
```

---

## 🐛 Troubleshooting

### Service Won't Start

```bash
# Check status
./scripts/multi-env-manager.sh status

# Check logs
kubectl logs deployment/auth-service -n development

# Common issues:
# • Port already in use → Change in values.yaml
# • Database connection error → Update DB host in values
# • Image not found → Check Docker build in GitHub Actions
# • Insufficient resources → Increase memory in values.yaml
```

---

### Need to Revert a Change

```bash
# See git history
git log --oneline

# Revert to previous version
git revert <commit-hash>

# Push to trigger rollback
git push origin dev

# ✅ Service automatically rolls back
```

---

### Emergency: Need Immediate Rollback

```bash
# Kill current deployment
./scripts/multi-env-manager.sh rollback dev

# This reverts to previous image while we debug
# Then update your code and push again
```

---

## 📦 What You Don't Need to Know

You don't need to understand:

- ❌ Kubernetes YAML syntax
- ❌ kubectl commands (unless you want to)
- ❌ Docker networking
- ❌ Container registries
- ❌ Load balancer configuration
- ❌ Pod scheduling
- ❌ Network policies
- ❌ Storage classes
- ❌ Service discovery
- ❌ Health check configuration
- ❌ Resource quotas
- ❌ RBAC and security policies

**We handle ALL of that automatically.**

---

## 💡 Pro Tips

### Tip 1: Local Testing Before Push

```bash
# Test your service locally
cd auth-service
npm install
npm start

# Test endpoints
curl http://localhost:3000/health

# Once happy, commit and push
git push origin dev
```

---

### Tip 2: Different Configurations Per Environment

```bash
# Development: Enable debug logging
helm/auth-service/values-dev.yaml:
  debug: true
  logLevel: DEBUG

# Production: Disable debug, high performance
helm/auth-service/values-prod.yaml:
  debug: false
  logLevel: WARN
```

**Same code, different behavior per environment automatically.**

---

### Tip 3: Zero-Downtime Deployments

ArgoCD handles this automatically:

```yaml
# In deployment.yaml:
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1

# Result: New pods start before old ones stop
# Zero downtime, no user impact
```

---

### Tip 4: Instant Rollback If Needed

```bash
# Deployment going bad?
git revert HEAD
git push origin main

# Automatic rollback in 1-2 minutes
# Better than stopping to debug!
```

---

## 🎓 Learning Path

### Week 1: Get Familiar
1. Read this guide (you're reading it!)
2. Run setup scripts once
3. Deploy to development
4. Update a simple config value
5. Push and watch automatic deployment

### Week 2: Build Confidence
1. Add a new endpoint to your service
2. Deploy to development
3. Test it
4. Promote to staging
5. Test in staging
6. Promote to production

### Week 3: Add New Services
1. Create a new service (follow template)
2. Add Helm chart (copy existing)
3. Deploy to development
4. Full development → staging → production cycle

### Week 4: Advanced (Optional)
1. Customize Helm values per environment
2. Setup monitoring alerts
3. Configure database backups
4. Setup SSL certificates

---

## ❓ FAQ

### Q: Do I need to learn Kubernetes?

**A:** No! You just need to know:
- `git push` to deploy
- `git revert` to rollback
- That's it!

Optional: Understand basic Kubernetes concepts (pods, services, deployments) for curiosity, but not required.

---

### Q: What if the cluster crashes?

**A:** Automatic:
1. Pods restart on different nodes
2. Services maintain availability
3. Data persists (saved separately)
4. You're notified automatically
5. Everything recovers without manual intervention

---

### Q: Can I test locally first?

**A:** Yes! Before pushing:

```bash
# Run locally
cd auth-service
npm install
npm start

# Test thoroughly
curl http://localhost:3000/health

# Push when ready
git push origin dev
```

---

### Q: How do I check if my deployment worked?

**A:** Multiple ways:

```bash
# Quick check
./scripts/multi-env-manager.sh status

# Detailed info
./scripts/multi-env-manager.sh details dev

# Watch logs live
kubectl logs -f deployment/auth-service -n development

# Check pods
kubectl get pods -n development -w

# Test endpoint
curl http://localhost:3000/health
```

---

### Q: What if I need to change environment-specific config?

**A:** Super easy:

```bash
# Edit dev values
nano helm/auth-service/values-dev.yaml
# Change replicas, memory, environment variables, etc.

# Edit staging values
nano helm/auth-service/values-staging.yaml

# Edit prod values  
nano helm/auth-service/values-prod.yaml

# Push once, all environments update automatically
git push origin dev
git push origin staging
git push origin main
```

---

### Q: Can I rollback quickly if something breaks?

**A:** Yes, in 30 seconds:

```bash
# Option 1: Git-based rollback (recommended)
git revert HEAD
git push origin main
# Automatic rollback in 1-2 minutes

# Option 2: Immediate manual rollback
./scripts/multi-env-manager.sh rollback prod
# Instant but needs manual re-push to sync Git
```

---

### Q: Do I need to write Kubernetes YAML?

**A:** No! We pre-configured everything:
- ✅ Deployment specs
- ✅ Service configuration
- ✅ Ingress setup
- ✅ Health checks
- ✅ Resource limits
- ✅ Scaling policies

Just use Helm values to customize.

---

### Q: What if multiple developers push at same time?

**A:** Automatic handling:
1. Each push creates a new deployment
2. All changes are queued
3. Latest change wins
4. No conflicts, no merge needed
5. All tracked in Git history

---

## 🎯 Next Steps

### 1. Run One-Time Setup
```bash
./scripts/setup-cluster.sh
./scripts/multi-env-manager.sh setup
./scripts/setup-argocd.sh install
```

### 2. Make a Change
```bash
echo "// New comment" >> auth-service/server.js
git push origin dev
```

### 3. Watch It Deploy
```bash
./scripts/multi-env-manager.sh status
# Service updates automatically!
```

### 4. Promote to Staging
```bash
git push origin staging
# ArgoCD automatically deploys to staging namespace
```

### 5. Promote to Production
```bash
git push origin main
# ArgoCD automatically deploys to production namespace
```

**That's it! You're now a DevOps master without learning DevOps.** 🎉

---

## 📚 Related Docs

- **AUTOMATION_INDEX.md** - Complete index of all automation
- **QUICK_START.sh** - Visual quick start guide
- **docs/ARGOCD_SETUP_GUIDE.md** - ArgoCD details (if curious)
- **docs/MULTI_ENV_IMPLEMENTATION.md** - Technical details (if interested)

---

## 💬 Support

Something unclear? Common issues:

**"Deployment stuck"**
```bash
./scripts/multi-env-manager.sh status
kubectl describe pod <pod-name> -n development
```

**"Need to debug"**
```bash
kubectl logs deployment/auth-service -n development
```

**"Want to rollback"**
```bash
git revert HEAD && git push origin dev
```

**"Want to scale"**
```bash
nano helm/auth-service/values-prod.yaml  # Change replicas
git push origin main
```

**Everything else?** Check **AUTOMATION_INDEX.md** for documentation links!

---

## ✨ Summary

### Your Workflow:

```
1. Write code
2. Commit: git add . && git commit -m "feat: ..."
3. Push: git push origin dev/staging/main
4. Wait 3-8 minutes
5. ✅ Live on Kubernetes!
```

### Everything Automated:

```
✅ Docker builds & pushes
✅ Kubernetes deployments
✅ Multi-environment scaling
✅ Health checks
✅ Monitoring & alerting
✅ Rollbacks
✅ Load balancing
✅ Auto-scaling
```

### No Kubernetes Knowledge Needed:

```
❌ Learn kubectl
❌ Learn YAML
❌ Learn networking
❌ Learn storage

✅ Just git push and relax!
```

**Happy building! 🚀**
