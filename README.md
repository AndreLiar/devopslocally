# 🚀 DevOps Lab - Production-Ready Kubernetes Template

A **complete, automated DevOps infrastructure template** for deploying microservices to Kubernetes with GitOps, monitoring, and logging—all with a single command.

**Get started in 5 minutes:** `./scripts/setup.sh`

---

## 📊 What You Get

```
┌─────────────────────────────────────────────────────────┐
│           Your Kubernetes DevOps Infrastructure         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  🎯 Orchestration                                       │
│  ├─ Kubernetes cluster (local or cloud)               │
│  ├─ Helm package manager                              │
│  └─ ArgoCD for GitOps-driven deployments             │
│                                                         │
│  📊 Observability                                       │
│  ├─ Prometheus (metrics collection)                   │
│  ├─ Grafana (dashboards, 28 available)                │
│  ├─ Loki (log aggregation)                            │
│  └─ Alertmanager (alert routing)                      │
│                                                         │
│  🔧 Development                                         │
│  ├─ Docker registry (localhost:5001)                  │
│  ├─ GitHub Actions (CI/CD)                            │
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

### 1. Prerequisites

Make sure you have:
- **Kubernetes**: Docker Desktop, Minikube, or any K8s cluster
- **Helm 3**: `helm version`
- **kubectl**: `kubectl cluster-info`
- **Docker**: `docker version`
- **Git**: `git --version`

### 2. One-Click Setup

```bash
# Clone and navigate
git clone https://github.com/AndreLiar/devopslocally.git
cd devopslocally

# Run one-click setup
./scripts/setup.sh

# Output: Infrastructure ready in ~10 minutes! ✅
```

### 3. Access Services

```bash
# Port forward to access Grafana
make port-forward

# Open browser
open http://localhost:3000  # Grafana (admin/admin123)

# View services
make status
```

---

## 🎯 Project Status

### Phase Completion
- **Phase 1 (60%)**: One-click setup, basic deployment ✅
- **Phase 2 (70%)**: Advanced features, CI/CD, databases ✅
- **Phase 3 (80%)**: Security hardening, testing framework ✅

### Phase 3 Features (NEW!)
- ✅ Security hardening (RBAC, Pod Security Policies, TLS)
- ✅ Sealed Secrets encryption setup
- ✅ Advanced testing framework (Jest, integration tests)
- ✅ Database backup/restore automation
- ✅ Security audit script
- ✅ Comprehensive documentation (Security, Architecture, Troubleshooting)

### Phase 2 Features
- ✅ Enhanced CI/CD pipeline (test, scan, deploy)
- ✅ Service templates (Node.js, Python, Go)
- ✅ Advanced Helm (ConfigMaps, Secrets, HPA, Network Policies)
- ✅ Database integration (PostgreSQL, Redis)
- ✅ Git hooks (ESLint, Prettier, Commitlint)
- ✅ Production-grade auto-scaling

**[👉 Read Phase 3 Guide →](docs/PHASE3_GUIDE.md)** | **[Phase 2 Guide →](docs/PHASE2_GUIDE.md)**

---

## 📚 Key Commands

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
helm install postgres postgres-chart/          # Deploy PostgreSQL
kubectl port-forward svc/postgresql 5432:5432  # Access database
```

---

## 🏗️ Project Structure

```
devopslocally/
├── 🎯 Root Level (YOU START HERE)
│   ├── README.md                    ← This file
│   ├── Makefile                     ← All commands
│   ├── .env.example                 ← Environment template
│   └── START_HERE.md                ← First-time orientation
│
├── 📜 Scripts (Automation)
│   ├── scripts/setup.sh             ← One-click infrastructure
│   ├── scripts/configure-env.sh     ← Configuration wizard
│   └── scripts/create-service.sh    ← Service generator
│
├── 🔧 Infrastructure (Helm)
│   ├── auth-service/                ← Example microservice
│   │   ├── server.js               ← Node.js app
│   │   ├── package.json            ← Dependencies
│   │   └── Dockerfile              ← Container image
│   │
│   └── auth-chart/                  ← Helm chart for deployment
│       ├── Chart.yaml
│       ├── values.yaml              ← Configuration
│       └── templates/               ← K8s manifests
│           ├── deployment.yaml
│           ├── service.yaml
│           └── ...
│
├── 🔄 CI/CD
│   └── .github/workflows/
│       ├── deploy.yml               ← Auto-deploy on push
│       └── deploy-local.yml         ← Local testing
│
├── 📊 Monitoring
│   └── docs/
│       ├── GITOPS_PIPELINE.md       ← CI/CD flow explained
│       ├── HOW_TO_CHECK_DASHBOARDS.md  ← Grafana guide
│       └── ...
│
├── 🧪 Testing
│   └── tests/
│       ├── test-grafana-quick.sh    ← Health check
│       ├── test-grafana-integration.sh
│       └── README.md
│
└── 📋 Planning
    ├── PROJECT_COMPLETION_PLAN.md    ← Full roadmap
    ├── PROJECT_COMPLETION_CHECKLIST.md
    └── ANALYSIS_SUMMARY.txt
```

---

## 🎯 Common Workflows

### Create New Microservice

```bash
# Generate service scaffolding
make create-service NAME=payment LANGUAGE=nodejs

# Start coding
cd payment-service/
npm install
npm start

# Deploy to Kubernetes
git push  # Triggers CI/CD pipeline automatically
```

### Monitor Your Services

```bash
# Start port forwarding
make port-forward

# Open Grafana
open http://localhost:3000

# Browse dashboards
# → Kubernetes cluster metrics
# → Service-specific metrics
# → System health
```

### View Logs

```bash
# See all pods
kubectl get pods

# Stream logs from service
make logs SERVICE=auth-service

# Or use kubectl directly
kubectl logs -f deployment/auth-service
```

### Troubleshoot Issues

```bash
# Health check
make check

# Pod status
make status

# Open shell in pod
make shell

# Execute command in pod
make exec POD=auth-service CMD="ls -la"

# View pod details
kubectl describe pod <pod-name>

# Check pod events
kubectl get events --sort-by='.lastTimestamp'
```

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

### Credentials

**Default Credentials** (change in production!):

| Service | User | Password | URL |
|---------|------|----------|-----|
| Grafana | admin | admin123 | http://localhost:3000 |
| ArgoCD | admin | admin123 | http://localhost:8080 |
| Prometheus | - | - | http://localhost:9090 |

---

## 📊 Monitoring & Observability

### Available Dashboards (28 Total)

**Kubernetes Dashboards (18):**
- Compute Resources (CPU, Memory, Storage)
- Networking (Pod communication, traffic)
- System Components (API server, kubelet, etc.)
- Persistent Volumes

**System Dashboards (10):**
- Node Exporter (Hardware metrics)
- Prometheus & Alertmanager
- etcd, CoreDNS monitoring
- Grafana Overview

### Prometheus Queries

```bash
# CPU usage
sum(rate(container_cpu_usage_seconds_total[5m])) by (pod_name)

# Memory usage
sum(container_memory_usage_bytes) by (pod_name)

# Pod count
count(kube_pod_info)
```

### Loki Log Queries

```bash
# All logs from auth-service
{job="auth-service"}

# Error logs
{job="auth-service"} | level="error"

# Last 100 entries
{job="auth-service"} | tail 100
```

---

## 🚀 Deployment Strategies

### Local Development

```bash
# Start services locally
cd auth-service
npm install
npm start

# Test locally
curl http://localhost:3000

# Deploy to K8s when ready
make deploy
```

### Docker Image Build

```bash
# Build Docker image
make build

# Test image locally
docker run -p 3000:3000 localhost:5001/auth-service:latest

# Push to registry
make push

# Kubernetes auto-deploys (GitOps)
```

### GitOps Workflow

```
Code change → Git push → GitHub Actions
         ↓
    Build & push image → Update Helm values.yaml
         ↓
    Commit values.yaml back to repo
         ↓
    ArgoCD detects change → Syncs to cluster
         ↓
    New pods roll out automatically ✅
```

---

## 🐛 Troubleshooting

### Can't Connect to Kubernetes

```bash
# Check if cluster is running
kubectl cluster-info

# Switch context if multiple clusters
kubectl config get-contexts
kubectl config use-context docker-desktop

# Verify kubectl config
cat ~/.kube/config | grep current-context
```

### Grafana Not Accessible

```bash
# Start port forwarding
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80

# Check pod status
kubectl get pods -n monitoring

# View logs
kubectl logs -n monitoring deployment/kube-prometheus-grafana
```

### Service Not Deploying

```bash
# Check deployment status
kubectl describe deployment auth-service

# View pod events
kubectl get events --sort-by='.lastTimestamp'

# Check image pull
kubectl describe pod <pod-name> | grep Image

# Verify registry connection
docker pull localhost:5001/auth-service:latest
```

### High Resource Usage

```bash
# Check resource requests
kubectl describe node

# See pod resource usage
kubectl top pods

# Scale deployment down
kubectl scale deployment auth-service --replicas=1

# Check HPA status
kubectl get hpa
```

---

## 📈 Performance Tuning

### Resource Limits

Edit `auth-chart/values.yaml`:

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Horizontal Pod Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### Database Caching

Use Redis for session/cache:

```bash
# Deploy Redis
helm install redis redis/redis -n default

# Connect from app
REDIS_URL=redis://redis:6379
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

**Triggered on:** Push to `main` branch in `auth-service/` directory

**Steps:**
1. ✅ Checkout code
2. ✅ Build Docker image (tag: run number)
3. ✅ Push to GitHub Container Registry (ghcr.io)
4. ✅ Update Helm `values.yaml` with new tag
5. ✅ Commit & push values.yaml
6. ✅ ArgoCD detects change
7. ✅ Kubernetes auto-syncs new version

**Manual trigger:**
```bash
git push origin main
# Or use GitHub Actions UI for manual trigger
```

---

## 📖 Additional Resources

### Documentation Files
- **START_HERE.md** - First-time orientation
- **PROJECT_COMPLETION_PLAN.md** - Full implementation roadmap
- **GITOPS_PIPELINE.md** - CI/CD pipeline details
- **HOW_TO_CHECK_DASHBOARDS.md** - Grafana guide

### External Links
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Helm Docs](https://helm.sh/docs/)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [Prometheus Queries](https://prometheus.io/docs/prometheus/latest/querying/basics/)

---

## 🤝 Contributing

### Code Style
- JavaScript: Follow `.eslintrc.json`
- Bash: shellcheck compatible
- YAML: 2-space indentation
- Markdown: Conventional format

### Commit Messages
```bash
# Feature
git commit -m "feat: add new dashboard"

# Fix
git commit -m "fix: correct deployment template"

# Docs
git commit -m "docs: update setup guide"

# Chore
git commit -m "chore: update dependencies"
```

### Creating Pull Requests
1. Fork repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Make changes
4. Run tests: `make test`
5. Commit: `git commit -m "feat: ..."`
6. Push: `git push origin feature/my-feature`
7. Open PR with description

---

## ✅ Success Checklist

After setup, you should have:

- [ ] Kubernetes cluster running (`kubectl cluster-info`)
- [ ] ArgoCD deployed (`kubectl get pods -n argocd`)
- [ ] Prometheus collecting metrics (`make status`)
- [ ] Grafana with 28 dashboards (`http://localhost:3000`)
- [ ] Loki aggregating logs (`kubectl get pods -n monitoring`)
- [ ] Local Docker registry (`docker ps | grep registry`)
- [ ] Example auth-service deployed (`kubectl get pods`)
- [ ] CI/CD pipeline configured (`.github/workflows/`)

**All checks pass?** You're ready to deploy! 🎉

---

## 🆘 Getting Help

### Quick Help
```bash
# Show all commands
make help

# Test setup
make test

# Health check
make check

# View status
make status
```

### Common Issues & Solutions

**Issue:** `kubectl: command not found`
- **Solution:** Install kubectl or add to PATH

**Issue:** Cluster not running
- **Solution:** Start Docker Desktop or Minikube

**Issue:** Port 3000 already in use
- **Solution:** Kill process or use different port: `make port-forward-grafana 8000:80`

**Issue:** Image pull failed
- **Solution:** Check registry: `docker push localhost:5001/test:latest`

### Additional Support
- Check `docs/` folder for detailed guides
- Review test outputs: `./tests/test-grafana-quick.sh`
- Check logs: `kubectl logs -f deployment/auth-service`

---

## 📝 License

This project is provided as-is for educational and development purposes.

---

## 🎉 Next Steps

```bash
# 1. One-click setup
./scripts/setup.sh

# 2. Configure environment
make configure-env

# 3. Start port forwarding
make port-forward

# 4. Open Grafana
open http://localhost:3000

# 5. Create your first service
make create-service NAME=my-api LANGUAGE=nodejs

# 6. Deploy
make deploy

# 7. Monitor
open http://localhost:3000/dashboards

# 8. View logs
make logs SERVICE=my-api

# 🚀 You're up and running!
```

---

**Made with ❤️ for DevOps Engineers**

*Last Updated: November 5, 2025*
