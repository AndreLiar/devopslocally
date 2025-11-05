# 🚀 DevOps Lab - Production-Ready Kubernetes Template

A **complete, automated DevOps infrastructure template** for deploying microservices to Kubernetes with GitOps, monitoring, and logging—all with a single command.

**⏱️ Get started in 5 minutes:** `./scripts/setup.sh`

---

## � Table of Contents

1. [What You Get](#-what-you-get)
2. [Quick Start](#-quick-start-5-minutes)
3. [Project Structure](#-project-structure)
4. [Common Workflows](#-common-workflows)
5. [Key Commands](#-key-commands)
6. [Monitoring & Observability](#-monitoring--observability)
7. [Architecture & Git Flow](#-architecture--git-flow)
8. [Security & Configuration](#-security--configuration)
9. [Troubleshooting](#-troubleshooting)
10. [Learn More](#-learn-more)

---

## �📊 What You Get

```
┌─────────────────────────────────────────────────────────┐
│           Your Kubernetes DevOps Infrastructure         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  🎯 Orchestration                                       │
│  ├─ Kubernetes cluster (local or cloud)               │
│  ├─ Helm package manager (v3+)                        │
│  └─ ArgoCD for GitOps-driven deployments             │
│                                                         │
│  📊 Observability                                       │
│  ├─ Prometheus (metrics collection)                   │
│  ├─ Grafana (dashboards, 28 available)                │
│  ├─ Loki (log aggregation)                            │
│  └─ Alertmanager (alert routing)                      │
│                                                         │
│  🔧 Development & CI/CD                                │
│  ├─ Docker registry (localhost:5001)                  │
│  ├─ GitHub Actions (CI/CD pipelines)                  │
│  ├─ Service templates (Node.js, Python, Go)           │
│  └─ One-click service generator                       │
│                                                         │
│  📚 Documentation                                       │
│  ├─ Complete setup guides                             │
│  ├─ Troubleshooting runbooks                          │
│  └─ Architecture documentation                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## ⚡ Quick Start (5 Minutes)

### Step 1: Prerequisites Check

**Option A: Automated Check (Recommended)**

Run the comprehensive prerequisite checker:

```bash
./scripts/check-prerequisites.sh
```

This script automatically verifies:
- ✅ kubectl (Kubernetes CLI) installation & cluster connectivity
- ✅ Helm 3+ (Package manager) installation
- ✅ Docker installation & daemon status
- ✅ Git installation & configuration
- ✅ System information & requirements

**Option B: Manual Check**

If you prefer manual verification:

```bash
# Kubernetes: Check your cluster
kubectl cluster-info
kubectl get nodes

# Helm: Package manager for Kubernetes
helm version

# Docker: Container runtime
docker version

# Git: Version control
git --version
```

**✅ Supported Kubernetes Distributions:**
- Docker Desktop (recommended for Mac/Windows)
- Minikube (lightweight local K8s)
- Kind (Kubernetes in Docker)
- Cloud K8s (EKS, GKE, AKS, etc.)

### Step 2: Clone & Setup

```bash
# Clone the repository
git clone https://github.com/AndreLiar/devopslocally.git
cd devopslocally

# Run one-click setup
./scripts/setup.sh

# ✅ Output: Infrastructure ready in ~10 minutes!
```

**What happens during setup:**
- ✅ Creates Kubernetes namespaces (default, monitoring, argocd, etc.)
- ✅ Deploys Prometheus, Grafana, Loki, Alertmanager
- ✅ Configures ArgoCD for GitOps
- ✅ Sets up local Docker registry
- ✅ Applies Helm charts
- ✅ Initializes sample auth-service

### Step 3: Access Your Services

```bash
# Start port forwarding to all services
make port-forward

# Access Grafana dashboards
open http://localhost:3000
# Login: admin / admin123

# Access ArgoCD
open http://localhost:8080
# Login: admin / admin123

# Access Prometheus
open http://localhost:9090

# View cluster status
make status
```

---

---

## �️ Project Structure

```
devopslocally/
│
├── 📖 Documentation (START HERE!)
│   ├── README.md                    ← This file
│   ├── START_HERE.md                ← First-time guide
│   ├── DOCUMENTATION_INDEX.md       ← All docs index
│   └── docs/
│       ├── WORKFLOWS_EXPLAINED.md   ← GitHub Actions
│       ├── GIT_FLOW.md              ← 3-branch strategy (dev, staging, main)
│       ├── GITOPS_PIPELINE.md       ← CI/CD pipeline
│       ├── KUBERNETES_GUIDE.md      ← K8s basics
│       ├── MONITORING_GUIDE.md      ← Grafana & Prometheus
│       └── TROUBLESHOOTING.md       ← Common issues
│
├── 🚀 Setup & Configuration
│   ├── Makefile                     ← All make commands
│   ├── .env.example                 ← Environment template
│   └── scripts/
│       ├── setup.sh                 ← One-click infrastructure setup
│       ├── configure-env.sh         ← Configuration wizard
│       └── create-service.sh        ← Service generator
│
├── 🔧 Microservices (Your Applications)
│   ├── auth-service/                ← Example Node.js service
│   │   ├── server.js               ← Application code
│   │   ├── package.json            ← Dependencies
│   │   ├── Dockerfile              ← Container image
│   │   └── tests/                  ← Tests
│   │
│   └── (Add your services here!)
│
├── 📦 Helm Charts (Kubernetes Deployment)
│   ├── helm/
│   │   ├── auth-service/            ← Auth service chart
│   │   │   ├── Chart.yaml          ← Chart metadata
│   │   │   ├── values.yaml         ← Default values
│   │   │   ├── values-dev.yaml     ← Dev environment overrides
│   │   │   ├── values-staging.yaml ← Staging environment overrides
│   │   │   ├── values-prod.yaml    ← Production environment overrides
│   │   │   └── templates/          ← K8s manifests (deployment, service, etc.)
│   │   │
│   │   └── postgres/                ← PostgreSQL database chart
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       ├── values-dev.yaml
│   │       └── templates/
│   │
│   └── README.md                    ← Helm documentation
│
├── 🔄 CI/CD Pipelines
│   └── .github/workflows/
│       ├── deploy.yml               ← Auto-deploy on push
│       ├── test-and-scan.yml        ← PR tests & security scans
│       ├── multi-env-deploy.yml     ← Deploy to dev/staging/main
│       └── deploy-local.yml         ← Local testing
│
├── 🧪 Testing
│   └── tests/
│       ├── test-grafana-quick.sh    ← Quick health check
│       ├── test-grafana-integration.sh ← Full integration tests
│       └── README.md                ← Testing guide
│
└── 📋 Planning & Status
    ├── PROJECT_COMPLETION_PLAN.md
    ├── ANALYSIS_SUMMARY.txt
    └── version.txt
```

---

## 📚 Essential Commands

```bash
# Setup & Configuration
make setup                          # One-click infrastructure setup
make configure-env                 # Interactive environment setup
make check                          # Health check all components

# Service Management (Phase 2)
make create-service NAME=my-api LANGUAGE=nodejs    # Generate new service (NEW!)
make deploy                         # Deploy all services
make build                          # Build Docker image
make push                           # Push to registry

# Monitoring & Logs
make port-forward                   # Start port forwarding
make logs SERVICE=auth-service      # Stream pod logs
make status                         # Show cluster status

# Troubleshooting
make shell                          # Open shell in pod
make exec POD=auth-service CMD="cmd"   # Execute command
make restart                        # Restart deployment
make test                           # Run health tests

# Cleanup
make clean                          # Clean local files
make destroy                        # Delete all Kubernetes resources

# Phase 2 Testing (NEW!)
./tests/test-phase2-integration.sh  # Validate all Phase 2 features

# Database Operations (NEW!)
helm install postgres helm/postgres/                                    # Deploy PostgreSQL (dev)
helm install postgres helm/postgres/ -f helm/postgres/values-prod.yaml # Deploy PostgreSQL (prod)
kubectl port-forward svc/postgresql 5432:5432                           # Access database
```

## 📚 Essential Commands

### 🎯 Setup & Configuration Commands

```bash
# ⭐ CHECK PREREQUISITES FIRST (Automated)
./scripts/check-prerequisites.sh

# One-click infrastructure setup (do this first!)
make setup

# Interactive configuration wizard
make configure-env

# Health check all components
make check

# View cluster status and all services
make status
```

### 🐳 Service Management

```bash
# Generate new microservice scaffold
make create-service NAME=my-api LANGUAGE=nodejs

# Build Docker image for your service
make build

# Push image to local registry
make push

# Deploy/update all services
make deploy

# Redeploy (useful if something crashed)
make restart
```

### 🔍 Monitoring & Logs

```bash
# Start port forwarding to all services
make port-forward

# View pod logs in real-time
make logs SERVICE=auth-service

# Get pod status and details
make status

# Open shell in a running pod
make shell

# Execute command in pod
make exec POD=auth-service CMD="ls -la"

# Watch pod events in real-time
kubectl get events --sort-by='.lastTimestamp' -w
```

### 🧪 Testing

```bash
# Run quick health checks
./tests/test-grafana-quick.sh

# Run full integration tests
./tests/test-grafana-integration.sh

# Run application tests
make test
```

### 💾 Database Operations

```bash
# Deploy PostgreSQL (development)
helm install postgres helm/postgres/

# Deploy PostgreSQL (production)
helm install postgres helm/postgres/ -f helm/postgres/values-prod.yaml

# Access database via port forward
kubectl port-forward svc/postgresql 5432:5432
psql -h localhost -U postgres  # Password in .env
```

### 🧹 Cleanup & Troubleshooting

```bash
# Clean local files and builds
make clean

# Delete all Kubernetes resources
make destroy

# Describe a pod (detailed info)
kubectl describe pod <pod-name>

# Get pod logs with timestamps
kubectl logs <pod-name> --timestamps=true

# Port forward to specific service
kubectl port-forward svc/auth-service 3000:3000
```

---

## 🔄 Common Workflows

### Workflow 1: Create & Deploy New Service

```bash
# Step 1: Generate service scaffolding
make create-service NAME=payment LANGUAGE=nodejs

# Step 2: Navigate to service
cd payment-service/

# Step 3: Install dependencies
npm install

# Step 4: Start coding your service
npm start

# Step 5: Create feature branch for changes
git checkout -b feature/payment-api
git add .
git commit -m "Add payment API"

# Step 6: Push and create Pull Request
git push origin feature/payment-api
# Create PR on GitHub (auto-tests via GitHub Actions)

# Step 7: Merge to dev when approved
# (Or use make commands to merge locally)

# ✅ Auto-deployed via CI/CD!
```

### Workflow 2: Monitor Your Services

```bash
# Step 1: Start port forwarding
make port-forward

# Step 2: Open Grafana dashboard
open http://localhost:3000
# Login: admin / admin123

# Step 3: Browse available dashboards:
# - Kubernetes / Compute Resources (CPU, Memory)
# - Kubernetes / Pod Count
# - Your Service Dashboards
# - System Health

# Step 4: Create custom alerts in Grafana
# - Define conditions
# - Add notification channels
# - Test alerts
```

### Workflow 3: Debug a Failing Service

```bash
# Step 1: Check pod status
kubectl get pods

# Step 2: View recent logs
make logs SERVICE=auth-service

# Step 3: Get pod details and events
kubectl describe pod <pod-name>

# Step 4: Open shell in pod for debugging
make shell

# Step 5: Check health endpoints
curl http://localhost:3000/health

# Step 6: Check Prometheus metrics
open http://localhost:9090
# Query: up{job="auth-service"}

# Step 7: If needed, restart the pod
make restart
```

### Workflow 4: Deploy Code Changes

```bash
# Step 1: Make code changes
nano auth-service/server.js

# Step 2: Commit and push
git add auth-service/
git commit -m "Fix: improve error handling"
git push origin feature/fix-error-handling

# Step 3: Create Pull Request on GitHub
# - GitHub Actions runs tests automatically
# - PR shows test results (pass/fail)

# Step 4: Get approval and merge
# - Reviewer approves PR
# - Merge to dev branch
# - GitHub Actions builds Docker image
# - ArgoCD auto-deploys to Kubernetes

# ✅ Done! Your changes are live!
# ⏱️ Total time: ~5-10 minutes
```

---

## 🌳 Git Flow: 3-Branch Strategy

Your repository uses **3 production branches** for smooth deployments:

### Branch Overview

| Branch | Purpose | Users | Env |
|--------|---------|-------|-----|
| **dev** | Development & testing | Developers | dev namespace |
| **staging** | Pre-production tests | QA/Testers | staging namespace |
| **main** | Production (LIVE!) | Users | production namespace |

### Typical Release Flow

```
Your Feature Branch
        ↓
    (PR to dev)
        ↓
    DEV ENV (test)
        ↓
    (merge dev → staging)
        ↓
  STAGING ENV (QA tests)
        ↓
    (merge staging → main)
        ↓
 PRODUCTION ENV (LIVE!) 🎉
```

### Git Commands for This Flow

```bash
# Create feature branch from dev
git checkout -b feature/my-feature origin/dev

# Work on your feature
git add .
git commit -m "Add my feature"
git push origin feature/my-feature

# Create PR to dev on GitHub
# Once approved, it's auto-deployed to dev

# Later, promote to staging
git checkout staging
git merge dev --no-ff
git push origin staging

# Finally, release to production
git checkout main
git merge staging --no-ff
git tag -a v1.2.3
git push origin main
git push origin v1.2.3
```

**[👉 Detailed Git Flow Guide →](docs/GIT_FLOW.md)**

---

## 📊 Monitoring & Observability

### Available Dashboards (28 Total)

**Kubernetes Dashboards (18):**
- ✅ Compute Resources (CPU, Memory, Storage)
- ✅ Networking (Pod communication, traffic)
- ✅ System Components (API server, kubelet)
- ✅ Persistent Volumes

**System Dashboards (10):**
- ✅ Node Exporter (Hardware metrics)
- ✅ Prometheus (metrics system health)
- ✅ Alertmanager (alerts)
- ✅ etcd, CoreDNS
- ✅ Grafana overview

### Prometheus Queries (Examples)

```bash
# CPU usage per pod
sum(rate(container_cpu_usage_seconds_total[5m])) by (pod_name)

# Memory usage per pod
sum(container_memory_usage_bytes) by (pod_name)

# Pod restart count
increase(kube_pod_container_status_restarts_total[1h])

# Service availability
up{job="auth-service"}
```

### Loki Log Queries (Examples)

```bash
# All logs from auth-service
{job="auth-service"}

# Error logs only
{job="auth-service"} | level="error"

# Last 100 log entries
{job="auth-service"} | tail 100

# Logs containing specific text
{job="auth-service"} | "database connection failed"
```

**[👉 Complete Monitoring Guide →](docs/MONITORING_GUIDE.md)**

---

## 🔐 Security & Configuration

### Environment Configuration

```bash
# Create custom configuration
make configure-env

# This creates .env.local with:
# ✓ Kubernetes context
# ✓ Registry credentials
# ✓ GitHub token
# ✓ Database settings
# ✓ Application secrets
```

### Secrets Management

Secrets are kept **external** from Git:

```bash
# Create secret manually
kubectl create secret generic my-secret \
  --from-literal=key=value \
  -n default

# Or use environment variables
export DB_PASSWORD=secure-password
# Reference in deployment as: ${DB_PASSWORD}
```

### Default Credentials

**⚠️ Change these in production!**

| Service | User | Password | URL |
|---------|------|----------|-----|
| Grafana | admin | admin123 | http://localhost:3000 |
| ArgoCD | admin | admin123 | http://localhost:8080 |
| Prometheus | - | - | http://localhost:9090 |

**[� Security Best Practices →](docs/SECURITY.md)**

---

## 🚀 Deployment Strategies

### Local Development Flow

```bash
# 1. Clone and setup
git clone https://github.com/AndreLiar/devopslocally.git
cd devopslocally
./scripts/setup.sh

# 2. Create your service
make create-service NAME=my-service LANGUAGE=nodejs

# 3. Develop locally
cd my-service
npm start

# 4. Create feature branch
git checkout -b feature/my-feature

# 5. Make changes and commit
git add .
git commit -m "Add feature"

# 6. Push and create PR
git push origin feature/my-feature
# → Open PR on GitHub
```

### GitOps Deployment Flow

```
Your Code Change
       ↓
   Git Push
       ↓
GitHub Actions (CI)
├─ Run tests
├─ Build image
├─ Push to registry
└─ Update Helm values
       ↓
  Commit to Git
       ↓
 ArgoCD Watches Git
├─ Detects change
├─ Generates K8s YAML
└─ Applies to cluster
       ↓
 Kubernetes Rolling Update
├─ Create new pods
├─ Health checks
├─ Switch traffic
└─ Cleanup old pods
       ↓
   ✅ LIVE! (Zero downtime)
```

---

## 🐛 Troubleshooting

### Pod Won't Start

```bash
# Check pod status
kubectl describe pod <pod-name>

# View recent logs
kubectl logs <pod-name> --tail=50

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check resource limits
kubectl top pods
```

### Can't Access Services

```bash
# Start port forwarding
make port-forward

# Or manually:
kubectl port-forward svc/auth-service 3000:3000

# Test locally
curl http://localhost:3000/health
```

### Helm Deployment Failed

```bash
# Check Helm release status
helm status auth-service

# See Helm release history
helm history auth-service

# Rollback to previous version
helm rollback auth-service
```

### ArgoCD Not Syncing

```bash
# Check ArgoCD app status
kubectl get application -n argocd

# Refresh ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:443
open http://localhost:8080

# Manually sync
argocd app sync auth-service
```

---

## 📚 Learn More

### Key Documentation Files

| Document | Purpose |
|----------|---------|
| [START_HERE.md](START_HERE.md) | First-time setup guide |
| [docs/GIT_FLOW.md](docs/GIT_FLOW.md) | 3-branch Git strategy |
| [docs/KUBERNETES_GUIDE.md](docs/KUBERNETES_GUIDE.md) | K8s concepts |
| [docs/MONITORING_GUIDE.md](docs/MONITORING_GUIDE.md) | Prometheus & Grafana |
| [docs/GITOPS_PIPELINE.md](docs/GITOPS_PIPELINE.md) | CI/CD pipeline |
| [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) | Complete index |

### External Resources

- 🔗 [Kubernetes Official Docs](https://kubernetes.io/docs/)
- 🔗 [Helm Documentation](https://helm.sh/docs/)
- 🔗 [ArgoCD User Guide](https://argo-cd.readthedocs.io/)
- 🔗 [Prometheus Querying](https://prometheus.io/docs/prometheus/latest/querying/)
- 🔗 [Grafana Dashboards](https://grafana.com/grafana/dashboards/)

---

## ✅ Quick Health Check

After setup, verify everything is working:

```bash
# Check cluster
kubectl cluster-info

# Check all pods
kubectl get pods --all-namespaces

# Check services
make status

# Run tests
./tests/test-grafana-quick.sh

# Health check
make check
```

---

## 🎯 Next Steps

### 1️⃣ First Time?
Start with [START_HERE.md](START_HERE.md)

### 2️⃣ Want to Deploy?
Follow [docs/GITOPS_PIPELINE.md](docs/GITOPS_PIPELINE.md)

### 3️⃣ Need to Debug?
Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

### 4️⃣ Learning Git Flow?
Read [docs/GIT_FLOW.md](docs/GIT_FLOW.md)

---

## 📊 Project Status

✅ **Phase 1** - One-click setup & basic deployment  
✅ **Phase 2** - Advanced CI/CD & service templates  
✅ **Phase 3** - Security hardening & monitoring  

**Current:** All phases complete! Production-ready! 🎉

---

## 💡 Pro Tips

```bash
# Alias for frequent commands
alias k=kubectl
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"
alias kdel="kubectl delete"

# Watch pod status in real-time
kubectl get pods -w

# Stream logs with timestamps
kubectl logs -f <pod-name> --timestamps=true

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash

# Port forward multiple services
make port-forward  # Forwards all at once

# Get pod IP addresses
kubectl get pods -o wide

# Export pod logs
kubectl logs <pod-name> > pod.log
```

---

## 🆘 Quick Help

```bash
# Show all available commands
make help

# Run health check
make check

# View cluster status
make status

# Get help on specific command
make deploy --help
```

---

## 📞 Support

- ❓ Questions? Check the docs folder
- 🐛 Found a bug? Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- 📚 Want to learn more? See [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)
- 💬 Need help? Check the test outputs: `./tests/test-grafana-quick.sh`

---

## 📝 License

This project is provided for **educational and development purposes**.

---

## 🚀 You're Ready!

```bash
# Everything set? Let's go! 🎉

# 1. Start here
./scripts/setup.sh

# 2. Access Grafana
make port-forward
open http://localhost:3000

# 3. Create service
make create-service NAME=my-api LANGUAGE=nodejs

# 4. Deploy
make deploy

# 5. Monitor
open http://localhost:3000/dashboards

# ✅ Success!
```

---

**Made with ❤️ for DevOps Engineers**  
*Last Updated: November 5, 2025*

