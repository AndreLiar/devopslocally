# Phase 2: Advanced Features Guide

> **Status:** ✅ Phase 2 Implementation Complete  
> **Project Completion:** 70%  
> **Last Updated:** November 5, 2025

## Table of Contents

1. [Overview](#overview)
2. [Enhanced CI/CD Pipeline](#enhanced-cicd-pipeline)
3. [Service Templates](#service-templates)
4. [Advanced Helm Features](#advanced-helm-features)
5. [Database Integration](#database-integration)
6. [Git Hooks & Code Quality](#git-hooks--code-quality)
7. [Production Deployment](#production-deployment)
8. [Troubleshooting](#troubleshooting)

---

## Overview

Phase 2 adds professional-grade features for production deployment:

- **🔄 Enhanced CI/CD:** Automated testing, security scanning, and image scanning
- **📦 Service Templates:** Scaffolding for Node.js, Python, and Go microservices
- **⚙️ Advanced Helm:** ConfigMaps, Secrets, HPA, Network Policies, Resource Quotas
- **🗄️ Databases:** PostgreSQL and Redis integration with backup/restore
- **🔍 Code Quality:** Git hooks, linting, formatting, and commit validation
- **🚀 Production Ready:** Load balancing, auto-scaling, and monitoring

### What's New

```
Phase 1 (60%):  One-click setup, basic deployment, monitoring
Phase 2 (70%):  Professional CI/CD, databases, code quality, advanced K8s
+ 10%:          Security scanning, auto-scaling, resource quotas
```

---

## Enhanced CI/CD Pipeline

### Workflows Included

#### 1. **test-and-scan.yml** - Testing & Security

Runs on every push and pull request:

```bash
# Runs:
- Node.js tests with coverage
- ESLint and Prettier checks
- npm audit for vulnerabilities
- Trivy filesystem scan
- Docker image vulnerability scan
- Helm chart validation
```

**Actions:**
- Tests pass/fail status
- Coverage reports to Codecov
- Security findings in GitHub Security tab
- Build status checks

**Example Output:**
```
✅ Unit Tests:     PASSED (18/18)
✅ Coverage:       85%
✅ Linting:        PASSED
✅ Dependency:     PASSED (no moderate vulnerabilities)
✅ Image Scan:     PASSED (0 critical)
✅ Helm Lint:      PASSED
```

#### 2. **deploy.yml** - Kubernetes Deployment

Auto-deploys after tests pass:

```bash
# Deploys to:
- Kubernetes cluster (via kubeconfig)
- Uses Helm for deployment
- Runs smoke tests
- Verifies rollout status
```

**Requirements:**
Set GitHub secrets:
```bash
KUBE_CONFIG: (base64-encoded kubeconfig)
```

**Usage:**
```bash
# Manual trigger
gh workflow run deploy.yml
# Or auto-triggers after test-and-scan passes
```

### How to Use

1. **Enable Actions** - Go to GitHub Settings → Actions → Allow all

2. **Add Secrets** (if deploying to real cluster):
   ```bash
   gh secret set KUBE_CONFIG --body "$(cat ~/.kube/config | base64)"
   ```

3. **Monitor Runs**:
   ```bash
   # View all workflow runs
   gh run list
   
   # View latest run details
   gh run view -w test-and-scan
   
   # View logs
   gh run view <run-id> --log
   ```

### Configuration Examples

**Run tests only on certain paths:**
```yaml
on:
  push:
    paths:
      - 'auth-service/**'
      - '.github/workflows/test-and-scan.yml'
```

**Run on schedule (daily):**
```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
```

---

## Service Templates

### Quick Start

Create a new microservice in 30 seconds:

```bash
# Create Node.js service
make create-service NAME=payment LANGUAGE=nodejs

# Create Python service
make create-service NAME=inventory LANGUAGE=python

# Create Go service
make create-service NAME=order-processor LANGUAGE=go
```

### What Gets Generated

Each service includes:

```
payment-service/
├── package.json (or requirements.txt / go.mod)
├── server.js (or server.py / main.go)
├── Dockerfile
├── .env.example
├── .gitignore
└── health-check.js

payment-chart/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml

.github/workflows/
└── payment-ci.yml
```

### Node.js Template Features

```javascript
// Auto-generated server.js includes:
- Express.js setup
- Pino HTTP logging
- Health check endpoints (/health, /ready)
- Error handling middleware
- Structured logging
- Environment configuration
```

**Generated Files:**
- `package.json` - Dependencies (Express, Pino, dotenv)
- `server.js` - Express server with health checks
- `Dockerfile` - Multi-stage, optimized for production
- `health-check.js` - Kubernetes health probe script
- `.env.example` - Configuration template

**Test It:**
```bash
cd payment-service
npm install
npm start
# Server runs on http://localhost:3000
curl http://localhost:3000/health
```

### Python Template Features

```python
# Auto-generated server.py includes:
- Flask app setup
- Environment configuration
- Health check endpoints
- Structured logging
- Error handling
```

**Generated Files:**
- `requirements.txt` - Flask, gunicorn, python-dotenv
- `server.py` - Flask app with health checks
- `Dockerfile` - Alpine-based, production-ready
- `.env.example` - Configuration template

**Test It:**
```bash
cd inventory-service
pip install -r requirements.txt
python server.py
# Server runs on http://localhost:5000
curl http://localhost:5000/health
```

### Go Template Features

```go
// Auto-generated main.go includes:
- Gin framework setup
- Environment configuration
- Health check endpoints
- Structured logging
```

**Generated Files:**
- `go.mod` - Module definition
- `main.go` - Gin server with health checks
- `Dockerfile` - Multi-stage build
- `.env.example` - Configuration template

**Test It:**
```bash
cd order-processor
go mod download
go run .
# Server runs on http://localhost:8080
curl http://localhost:8080/health
```

### Deploy Generated Service

```bash
# Deploy to Kubernetes
cd payment-chart
helm install payment . --namespace default

# Verify
kubectl get pods -l app=payment
kubectl logs deployment/payment
```

---

## Advanced Helm Features

### ConfigMaps

Manages application configuration:

```yaml
# Automatically created from values.yaml
data:
  LOG_LEVEL: "info"
  DATABASE_HOST: "postgresql"
  REDIS_HOST: "redis-master"
  PORT: "3000"
```

**Usage in Deployment:**
```yaml
envFrom:
  - configMapRef:
      name: auth-config
```

### Secrets Management

Stores sensitive data:

```yaml
# Encrypted in Kubernetes
data:
  JWT_SECRET: (base64 encoded)
  DATABASE_PASSWORD: (base64 encoded)
  API_KEY: (base64 encoded)
```

**Set Secrets:**
```bash
# Set via values
helm install auth-service auth-chart/ \
  --set secrets.jwtSecret="your-secret" \
  --set secrets.apiKey="your-api-key"

# Or use environment variables
export JWT_SECRET="your-secret"
helm install auth-service auth-chart/ \
  --set-string secrets.jwtSecret=$JWT_SECRET
```

### Horizontal Pod Autoscaling (HPA)

Auto-scales based on metrics:

```yaml
# Enabled in values.yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

**How It Works:**
- Starts with 2 replicas (min)
- Scales up to 10 replicas (max)
- Scales when CPU > 70% or Memory > 80%
- Scales down gradually (stabilization window)

**Monitor:**
```bash
# View HPA status
kubectl get hpa -w

# View detailed HPA info
kubectl describe hpa auth-service
```

### Network Policies

Controls pod-to-pod traffic:

```yaml
# Enabled via networkPolicy.enabled: true
# Default: Deny all ingress/egress
# Allowed: Same namespace, Ingress controller
# Database access: Only to PostgreSQL (5432)
# DNS: Always allowed (kube-system)
```

**Benefits:**
- ✅ Defense in depth
- ✅ Prevents lateral movement
- ✅ Reduces attack surface
- ✅ Compliance (PCI-DSS, SOC 2)

**Test Network Policy:**
```bash
# Try to ping another pod (should fail)
kubectl exec -it auth-pod -- ping redis-pod
# Connection refused

# Verify rules
kubectl get networkpolicies
kubectl describe networkpolicy auth-deny-all
```

### Resource Quotas

Limits resource consumption:

```yaml
resourceQuota:
  enabled: true
  requests:
    cpu: "10"
    memory: "20Gi"
  limits:
    cpu: "20"
    memory: "40Gi"
  pods: "100"
```

**Prevents:**
- ❌ Resource starvation
- ❌ Noisy neighbor problems
- ❌ Accidental overprovisioning

**Check Usage:**
```bash
kubectl describe resourcequota auth-quota
# Shows: Used / Requested / Limited
```

### Using Advanced Features

**Enable in Deployment:**
```bash
helm install auth-service auth-chart/ \
  --values auth-chart/values.yaml \
  --set autoscaling.enabled=true \
  --set networkPolicy.enabled=true \
  --set resourceQuota.enabled=true
```

**For Production (all features):**
```bash
helm install auth-service auth-chart/ \
  --values auth-chart/values.yaml \
  --set replicaCount=3 \
  --set autoscaling.enabled=true \
  --set networkPolicy.enabled=true \
  --set resourceQuota.enabled=true \
  --set postgresql.enabled=true \
  --set monitoring.enabled=true
```

---

## Database Integration

### PostgreSQL Setup

Deploy PostgreSQL with Helm:

```bash
# Deploy PostgreSQL
helm install postgres postgres-chart/ \
  --namespace default \
  --set auth.password="your-secure-password" \
  --set persistence.size="20Gi"

# Verify
kubectl get pods -l app=postgresql
kubectl describe pvc postgresql-data-postgresql-0
```

**Access Database:**
```bash
# Port forward
kubectl port-forward svc/postgresql 5432:5432

# Connect locally
psql -h localhost -U postgres -d appdb
# Enter password when prompted
```

**Backup & Restore:**
```bash
# Backup
kubectl exec postgresql-0 -- pg_dump -U postgres appdb > backup.sql

# Restore
kubectl exec -i postgresql-0 -- psql -U postgres appdb < backup.sql
```

### Redis Setup

Enable Redis in values:

```bash
helm install auth-service auth-chart/ \
  --set redis.enabled=true \
  --set redis.auth.password="redis-password"
```

**Access Redis:**
```bash
# Port forward
kubectl port-forward svc/redis-master 6379:6379

# Connect
redis-cli
> PING
PONG
```

### Connection from Services

**Configure in values.yaml:**
```yaml
postgresql:
  enabled: true
  auth:
    username: postgres
    password: "secure-password"
    database: appdb

redis:
  enabled: true
  auth:
    password: "redis-password"
```

**Use in Service Code:**

```javascript
// Node.js example
const pg = require('pg');
const redis = require('redis');

const pgClient = new pg.Client({
  host: process.env.DATABASE_HOST,
  port: process.env.DATABASE_PORT,
  user: process.env.DATABASE_USER,
  password: process.env.DATABASE_PASSWORD,
  database: process.env.DATABASE_NAME,
});

const redisClient = redis.createClient({
  host: process.env.REDIS_HOST,
  port: 6379,
  password: process.env.REDIS_PASSWORD,
});
```

---

## Git Hooks & Code Quality

### Pre-commit Hooks Setup

Auto-run checks before commit:

```bash
# Install dependencies
npm install --save-dev husky lint-staged commitlint

# Setup hooks
npx husky install

# Add pre-commit hook
npx husky add .husky/pre-commit "npx lint-staged"

# Add commit-msg hook
npx husky add .husky/commit-msg "npx commitlint --edit"
```

### What Gets Checked

**ESLint** - JavaScript syntax:
```bash
# Automatically fixed issues:
- Missing semicolons
- Unused variables
- Incorrect indentation
- Naming conventions
```

**Prettier** - Code formatting:
```bash
# Auto-formats:
- Line length (100 chars)
- Quotes (double quotes)
- Trailing commas
- Indentation (2 spaces)
```

**Commit Lint** - Commit messages:
```bash
# Valid formats:
✅ feat: add new feature
✅ fix: correct bug
✅ docs: update documentation
✅ test: add tests
✅ chore: update dependencies

# Invalid:
❌ Added feature
❌ FIX: bug
❌ updated code
```

### Usage Examples

**Good workflow:**
```bash
# Make changes
code auth-service/server.js

# Try to commit
git add auth-service/server.js
git commit -m "Add user endpoint"
# ✅ Commit-msg hook validates message
# ✅ Pre-commit hook runs eslint --fix
# ✅ Pre-commit hook runs prettier

# Commit succeeds
# ✅ Changes are formatted and linted
```

**Skip hooks (when needed):**
```bash
# Skip all hooks
git commit --no-verify

# Skip specific hook
git commit --no-verify
```

### Configuration Files

**commitlint.config.js** - Commit message rules
**eslintrc** - JavaScript linting rules
**.prettierrc** - Code formatting rules
**.lintstagedrc** - What to lint before commit

---

## Production Deployment

### Pre-Deployment Checklist

```bash
# ✅ Run tests
npm test

# ✅ Lint code
npm run lint

# ✅ Build image
docker build -t auth-service:v1.0.0 .

# ✅ Scan image
trivy image auth-service:v1.0.0

# ✅ Validate Helm chart
helm lint auth-chart/

# ✅ Render templates
helm template auth-service auth-chart/ | less

# ✅ Dry-run deployment
helm install auth-service auth-chart/ --dry-run --debug
```

### Deployment Steps

```bash
# 1. Create namespace
kubectl create namespace production

# 2. Create secrets
kubectl create secret generic auth-secrets \
  --from-literal=jwt-secret="$(openssl rand -base64 32)" \
  --from-literal=api-key="your-api-key" \
  -n production

# 3. Deploy with Helm
helm install auth-service auth-chart/ \
  --namespace production \
  --values auth-chart/values.yaml \
  --set replicaCount=3 \
  --set autoscaling.enabled=true \
  --set image.tag=v1.0.0

# 4. Verify deployment
kubectl rollout status deployment/auth-service -n production

# 5. Check logs
kubectl logs -f deployment/auth-service -n production
```

### Monitoring Production

```bash
# View all resources
kubectl get all -n production

# Monitor pods
kubectl top pods -n production

# Check events
kubectl get events -n production --sort-by='.lastTimestamp'

# Access Grafana dashboards
make port-forward
open http://localhost:3000
```

### Rollback on Issues

```bash
# View rollout history
kubectl rollout history deployment/auth-service -n production

# Rollback to previous version
kubectl rollout undo deployment/auth-service -n production

# Rollback to specific revision
kubectl rollout undo deployment/auth-service -n production --to-revision=2
```

---

## Troubleshooting

### Common Issues

#### 1. Tests Failing in CI/CD

```bash
# View workflow logs
gh run view <run-id> --log

# Run tests locally
npm install
npm test -- --coverage

# Check for environment variables
env | grep NODE_ENV
```

#### 2. Pod Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>

# Check resource limits
kubectl top pods

# Verify image exists
docker image ls | grep auth-service
```

#### 3. HPA Not Scaling

```bash
# Check HPA status
kubectl describe hpa auth-service

# Check metrics server
kubectl get deployment metrics-server -n kube-system

# Generate load to test
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# Inside container:
while sleep 0.01; do wget -q -O- http://auth-service; done
```

#### 4. Network Policy Blocking Traffic

```bash
# Check network policies
kubectl get networkpolicies

# Temporarily disable
kubectl delete networkpolicy auth-deny-all

# Re-enable
kubectl apply -f auth-chart/templates/networkpolicy.yaml
```

#### 5. Database Connection Issues

```bash
# Test connectivity
kubectl run -it postgres-test --rm --image=postgres:15 --restart=Never -- \
  psql -h postgresql -U postgres -d appdb

# Check database pod
kubectl describe pod postgresql-0

# View database logs
kubectl logs postgresql-0
```

### Helpful Commands

```bash
# Full debugging
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Previous crash
kubectl exec -it <pod-name> -- /bin/sh
kubectl port-forward pod/<pod-name> 5432:5432

# View resource usage
kubectl top nodes
kubectl top pods

# Get all resources
kubectl get all --all-namespaces

# Validate YAML
kubectl apply -f file.yaml --dry-run=client -o yaml
```

---

## Next Steps (Phase 3 - Optional)

### Phase 3: Final Polish (2-3 hours)

- [ ] Security hardening (Sealed Secrets, RBAC, Pod Security Policy)
- [ ] Testing framework (Jest, integration tests, load testing)
- [ ] CLI tools (devops.sh wrapper command)
- [ ] Final validation and documentation
- [ ] 80% project completion

### Getting Started

```bash
# Review Phase 2 implementation
./tests/test-phase2-integration.sh

# Deploy with all Phase 2 features
make setup
helm install auth-service auth-chart/ \
  --set autoscaling.enabled=true \
  --set networkPolicy.enabled=true \
  --set postgresql.enabled=true
```

---

## Support & Resources

- **Documentation**: See `/docs` directory
- **Examples**: Check `auth-service/` and `auth-chart/`
- **Tests**: Run `./tests/test-phase2-integration.sh`
- **Help**: `make help`

---

**🎉 Phase 2 Complete! Your project is now 70% production-ready.**

For detailed examples and use cases, see the individual component documentation in `/docs`.
