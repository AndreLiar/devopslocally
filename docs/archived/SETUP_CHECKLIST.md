# ✅ SETUP CHECKLIST & REQUIREMENTS TRACKER

**Use this to track your progress through the setup process**

> 🪟 **Windows Users:** Follow `docs/WINDOWS_WSL2_SETUP.md` first to set up WSL2, then come back here and continue from Phase 1.

---

## PHASE 0: PREREQUISITES

### System Requirements
- [ ] macOS 10.14+, Linux (Ubuntu 20.04+), or Windows WSL2
- [ ] Minimum 8GB RAM (16GB recommended)
- [ ] 20GB available disk space
- [ ] Internet connection

### Required Accounts
- [ ] GitHub account (free)
- [ ] Docker Hub account (optional, free)

### Required Software
- [ ] Docker/Docker Desktop installed
- [ ] kubectl installed and working
- [ ] Helm installed and working
- [ ] Kind installed and working
- [ ] Git installed and working

**Verification:**
```bash
docker --version      # ✅ Should show version
kubectl version       # ✅ Should show version
helm version         # ✅ Should show version
kind version         # ✅ Should show version
git --version        # ✅ Should show version
```

**All green? Continue to Phase 1.**

---

## PHASE 1: INITIAL SETUP

### Repository Setup
- [ ] Repository cloned locally
- [ ] Current directory: `devopslocally/`
- [ ] `git status` shows main branch

### Setup Script
- [ ] Script location: `scripts/setup-cluster.sh`
- [ ] Script is executable: `chmod +x scripts/setup-cluster.sh`
- [ ] Running command: `./scripts/setup-cluster.sh`
- [ ] Script completed without errors

### Cluster Verification
```bash
# Run these commands and verify output:
```
- [ ] `kubectl cluster-info` → Shows running cluster
- [ ] `kubectl get nodes` → Shows nodes with STATUS: Ready
- [ ] `kubectl get namespaces` → Shows 3 namespaces:
  - [ ] development
  - [ ] staging
  - [ ] production

**All checked? Continue to Phase 2.**

---

## PHASE 2: MULTI-ENVIRONMENT SETUP

### Environment Manager
- [ ] Script location: `scripts/multi-env-manager.sh`
- [ ] Script is executable: `chmod +x scripts/multi-env-manager.sh`
- [ ] Running: `./scripts/multi-env-manager.sh setup`
- [ ] Command completed successfully

### Environment Verification
```bash
./scripts/multi-env-manager.sh status
```
Expected output for each environment:
- [ ] **Development namespace**
  - [ ] Status: Ready
  - [ ] Resource quota: Set
  - [ ] Replicas limit: 1

- [ ] **Staging namespace**
  - [ ] Status: Ready
  - [ ] Resource quota: Set
  - [ ] Replicas limit: 2

- [ ] **Production namespace**
  - [ ] Status: Ready
  - [ ] Resource quota: Set
  - [ ] Replicas limit: 3

### Resource Verification
```bash
kubectl get resourcequota -n development
kubectl get resourcequota -n staging
kubectl get resourcequota -n production
```
- [ ] All resource quotas created
- [ ] All limits applied

**All checked? Continue to Phase 3.**

---

## PHASE 3: GITOPS SETUP (ArgoCD)

### ArgoCD Installation
- [ ] Script location: `scripts/setup-argocd.sh`
- [ ] Script is executable: `chmod +x scripts/setup-argocd.sh`
- [ ] Running: `./scripts/setup-argocd.sh install`
- [ ] Installation completed (3-5 minutes)

### ArgoCD Verification
```bash
kubectl get pods -n argocd
```
- [ ] All ArgoCD pods running (STATUS: Running)
- [ ] Expected pods:
  - [ ] argocd-server
  - [ ] argocd-repo-server
  - [ ] argocd-controller-manager
  - [ ] argocd-redis
  - [ ] argocd-dex-server

### Access ArgoCD UI
```bash
./scripts/setup-argocd.sh access
```
- [ ] Port forwarding established on localhost:8080
- [ ] ArgoCD UI accessible at: http://localhost:8080

### Get Admin Password
```bash
./scripts/setup-argocd.sh password
```
- [ ] Password retrieved successfully
- [ ] Password saved securely

### ArgoCD Login
- [ ] Username: `admin`
- [ ] Password: [from above command]
- [ ] Successfully logged into UI

### Configure Git Repository
```bash
./scripts/setup-argocd.sh configure
```
- [ ] Command completed successfully
- [ ] Git repository connected

### Applications Created
In ArgoCD UI, verify 6 applications exist:
- [ ] app-development (dev branch → development namespace)
- [ ] app-staging (staging branch → staging namespace)
- [ ] app-production (main branch → production namespace)
- [ ] postgres-development
- [ ] postgres-staging
- [ ] postgres-production

**All checked? Continue to Phase 4.**

---

## PHASE 4: BUILD FIRST SERVICE

### Sample Service (Auth Service)
```bash
cd auth-service
```
- [ ] Directory exists: `auth-service/`
- [ ] Files present:
  - [ ] `package.json` - Dependencies defined
  - [ ] `server.js` - Application code
  - [ ] `Dockerfile` - Container definition
  - [ ] `.dockerignore` - Files to exclude

### Dependencies Installation
```bash
npm install
```
- [ ] Command completed successfully
- [ ] `node_modules/` directory created
- [ ] `package-lock.json` generated

### Tests
```bash
npm test
```
- [ ] All tests pass
- [ ] No errors or failures

### Docker Image Build
```bash
docker build -t auth-service:latest .
```
- [ ] Image builds successfully
- [ ] No build errors

### Image Verification
```bash
docker images | grep auth-service
```
- [ ] Image appears in list
- [ ] Size reasonable (< 200MB for Node)

**For new services:**
- [ ] Copied template from `helm/auth-service` to `helm/your-service`
- [ ] Updated `Chart.yaml` with service name
- [ ] Updated `values.yaml` with service configuration
- [ ] All Helm values files exist (dev, staging, prod)

**All checked? Continue to Phase 5.**

---

## PHASE 5: DEPLOYMENT

### Push Code to Dev
```bash
git push origin dev
```
- [ ] Code pushed successfully
- [ ] Branch is `dev` (not `main`)

### GitHub Actions Trigger
Monitor at: `https://github.com/YOUR_USERNAME/devopslocally/actions`
- [ ] Workflow triggered automatically
- [ ] All steps completed:
  - [ ] Checkout code (success)
  - [ ] Run tests (success)
  - [ ] Build image (success)
  - [ ] Push to registry (success)
  - [ ] Update Helm values (success)

### ArgoCD Sync
Check at: `http://localhost:8080`
- [ ] ArgoCD detected Git change
- [ ] app-development application synced
- [ ] Status shows: "Synced"

### Deployment Verification
```bash
kubectl get pods -n development
```
- [ ] New pod(s) running
- [ ] STATUS: Running
- [ ] READY: 1/1 or similar

### Access Service
```bash
kubectl port-forward -n development svc/auth-service 3000:3000
```
In another terminal:
```bash
curl http://localhost:3000/health
```
- [ ] Response received
- [ ] HTTP 200 status
- [ ] JSON response with service info

**All checked? Continue to Phase 6.**

---

## PHASE 6: MONITORING

### Access Monitoring Namespace
```bash
kubectl get namespaces | grep monitoring
```
- [ ] `monitoring` namespace exists

### Grafana Setup
```bash
kubectl -n monitoring get secrets kube-prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d && echo ""
```
- [ ] Admin password retrieved

### Grafana Access
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80
```
- [ ] Port forwarding established
- [ ] URL: http://localhost:3000

### Grafana Login
- [ ] Username: `admin`
- [ ] Password: [from command above]
- [ ] Successfully logged in

### Dashboards Visible
In Grafana UI:
- [ ] Dashboards → Browse available
- [ ] At least 5 dashboards visible:
  - [ ] Cluster Overview
  - [ ] Application Metrics
  - [ ] Node Exporter
  - [ ] Kubernetes Cluster
  - [ ] [Your service dashboards]

### Prometheus Access (Optional)
```bash
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
```
- [ ] Prometheus accessible at: http://localhost:9090
- [ ] Can query metrics

### Loki Access (Optional)
```bash
kubectl logs -n development -l app=auth-service
```
- [ ] Logs displayed without errors
- [ ] Can filter by service

**All checked? Continue to Phase 7.**

---

## PHASE 7: MULTI-ENVIRONMENT

### Staging Branch
```bash
git checkout -b staging
git push origin staging
```
- [ ] Staging branch created
- [ ] Branch pushed to GitHub

### Deploy to Staging
Make a change and:
```bash
git push origin staging
```
- [ ] GitHub Actions triggered
- [ ] Workflow completed
- [ ] ArgoCD synced app-staging

### Verify Staging Deployment
```bash
kubectl get pods -n staging
```
- [ ] Pods running in staging namespace
- [ ] 2 replicas running (staging configuration)

### Production Branch
Main branch already exists:
```bash
git checkout main
```
- [ ] Main branch ready
- [ ] Latest code present

### Deploy to Production
```bash
git push origin main
```
- [ ] GitHub Actions triggered
- [ ] Additional security scans run
- [ ] Workflow completed
- [ ] ArgoCD synced app-production

### Verify Production Deployment
```bash
kubectl get pods -n production
```
- [ ] Pods running in production namespace
- [ ] 3 replicas running (production configuration)

### Verify Environment Isolation
All three environments running independently:
- [ ] Dev service: 1 replica
- [ ] Staging service: 2 replicas
- [ ] Prod service: 3 replicas
- [ ] Environments don't interfere with each other

**All checked? Continue to Phase 8.**

---

## PHASE 8: SECURITY & SECRETS

### Secrets Namespace
```bash
kubectl get namespace | grep kube-system
```
- [ ] System namespace exists

### Create Test Secret
```bash
kubectl create secret generic test-secret \
  --from-literal=key=value \
  -n development
```
- [ ] Secret created successfully

### Verify Secret
```bash
kubectl get secrets -n development
```
- [ ] Secret appears in list
- [ ] Can describe secret (value hidden)

### Sealed Secrets Setup (Production)
```bash
./scripts/setup-sealed-secrets.sh
```
- [ ] Script installed sealed-secrets operator
- [ ] Pods running in `kube-system`

### RBAC Configuration
```bash
kubectl get rolebindings -n development
```
- [ ] Role bindings exist
- [ ] Permissions properly configured

### Network Policies (Optional)
```bash
kubectl get networkpolicies -n development
```
- [ ] Network policies applied (if configured)
- [ ] Traffic restrictions working

**All checked? Continue to Phase 9.**

---

## PHASE 9: SCALING & PERFORMANCE

### HPA (Horizontal Pod Autoscaler)
```bash
kubectl get hpa -n development
```
- [ ] HPA exists for services
- [ ] Min replicas: 1 (dev)
- [ ] Max replicas: 3 (dev)

### Resource Limits
```bash
kubectl describe deployment auth-service -n development
```
- [ ] Resources defined:
  - [ ] Requests: CPU and Memory set
  - [ ] Limits: CPU and Memory set

### Monitor Metrics
In Grafana:
- [ ] CPU usage visible
- [ ] Memory usage visible
- [ ] Network metrics visible
- [ ] Pod count visible

### Scale Manually (Test)
```bash
kubectl scale deployment auth-service --replicas=2 -n development
```
- [ ] Replicas scale up/down
- [ ] New pods created/removed
- [ ] Service continues working

### Revert Scale
```bash
kubectl scale deployment auth-service --replicas=1 -n development
```
- [ ] Back to original replicas

**All checked? Continue to Phase 10.**

---

## PHASE 10: TESTING & VALIDATION

### Unit Tests
```bash
npm test
```
- [ ] All tests pass
- [ ] No failures or errors
- [ ] Coverage report generated (if configured)

### Health Checks
```bash
curl http://localhost:3000/health
```
- [ ] HTTP 200 response
- [ ] JSON response received
- [ ] Service status "ok"

### Readiness Check
```bash
curl http://localhost:3000/ready
```
- [ ] HTTP 200 response (or similar)
- [ ] Service ready to receive traffic

### Integration Tests (Optional)
```bash
npm run test:integration
```
- [ ] Tests run against real cluster
- [ ] All tests pass
- [ ] No connectivity issues

### End-to-End Test
Test all three environments:
- [ ] Development service responds
- [ ] Staging service responds
- [ ] Production service responds
- [ ] All show correct status

### Load Test (Optional)
Simulate load on services:
- [ ] Service handles load
- [ ] HPA scales appropriately
- [ ] Response times acceptable

**All checked? Continue to Phase 11.**

---

## PHASE 11: DOCUMENTATION & LEARNING

### Core Documentation Read
- [ ] README.md (5 min) - Overview
- [ ] docs/ARCHITECTURE.md (10 min) - System design
- [ ] docs/GITOPS_PIPELINE.md (10 min) - Deployment flow
- [ ] DEVELOPER_GUIDE.md (15 min) - Daily workflows
- [ ] docs/TROUBLESHOOTING.md (10 min) - Common issues

### Understand Components
- [ ] Docker/Containers - How images are built
- [ ] Kubernetes - How services run
- [ ] Helm - How templates work
- [ ] ArgoCD - How GitOps works
- [ ] GitHub Actions - How CI/CD works

### Review Architecture
- [ ] Understand flow: Code → GitHub Actions → ArgoCD → Kubernetes
- [ ] Understand environments: Dev → Staging → Production
- [ ] Understand tools: Docker, Kubernetes, Helm, ArgoCD
- [ ] Understand monitoring: Prometheus, Grafana, Loki

### Create Quick Reference
- [ ] Common kubectl commands documented
- [ ] Common helm commands documented
- [ ] Common argocd commands documented
- [ ] Common Git workflows documented

**All checked? Continue to Phase 12.**

---

## PHASE 12: TEAM ONBOARDING

### Team Documentation
- [ ] docs/team-guidelines/CODING_STANDARDS.md created
- [ ] docs/team-guidelines/DEPLOYMENT_PROCESS.md created
- [ ] docs/team-guidelines/TROUBLESHOOTING_COMMON.md created
- [ ] docs/team-guidelines/RUNBOOK.md created

### Runbook Creation
Runbook includes:
- [ ] Check service status command
- [ ] View logs command
- [ ] Restart service command
- [ ] Rollback deployment command
- [ ] Scale service command
- [ ] Check monitoring command

### Alert Configuration
- [ ] Slack notifications (optional) - Configured
- [ ] Email alerts (optional) - Configured
- [ ] PagerDuty (optional) - Configured

### Team Training
- [ ] Brief team on setup
- [ ] Demo the deployment flow
- [ ] Show monitoring dashboards
- [ ] Explain troubleshooting steps

### Onboarding Checklist for New Developers
Create: `docs/ONBOARDING_NEW_DEVELOPER.md`
- [ ] Prerequisites checklist
- [ ] Phase 1 setup instructions
- [ ] Phase 2 environment setup
- [ ] Phase 3 ArgoCD setup
- [ ] First service deployment
- [ ] Common gotchas and tips

**All checked? Congratulations! Setup complete!**

---

## ✨ POST-SETUP: DAILY OPERATIONS

### Every Push (Dev Developer)
- [ ] Write code
- [ ] Run tests locally
- [ ] `git commit` with message
- [ ] `git push origin dev`
- [ ] GitHub Actions runs
- [ ] ArgoCD syncs
- [ ] Service deployed to dev namespace
- [ ] Check Grafana dashboards

### Before Staging Push
- [ ] Test thoroughly in dev
- [ ] Get code review (if applicable)
- [ ] Review ArgoCD logs
- [ ] Verify monitoring metrics

### Before Production Push
- [ ] Test in staging environment
- [ ] QA approval
- [ ] Review change log
- [ ] Have rollback plan ready
- [ ] Monitor closely after deploy

### Daily Checks
- [ ] `./scripts/multi-env-manager.sh status` - System healthy
- [ ] Check Grafana dashboards - No alerts
- [ ] Check ArgoCD apps - All synced
- [ ] Check logs - No errors

---

## 🔧 TROUBLESHOOTING DURING SETUP

If any step fails, check:

### Cluster Issues
```bash
kind get clusters                    # ✅ Cluster running?
kubectl cluster-info                # ✅ K8s responsive?
kubectl get nodes                   # ✅ Nodes ready?
```
- [ ] All checks pass

### Pod Issues
```bash
kubectl get pods -n development     # ✅ Pods running?
kubectl describe pod <name> -n development  # ✅ Any errors?
kubectl logs <pod-name> -n development      # ✅ Check logs
```
- [ ] All checks pass

### GitHub Actions Issues
- [ ] Check GitHub repo → Actions tab
- [ ] View failed workflow
- [ ] Read error messages
- [ ] Fix based on error type

### ArgoCD Issues
```bash
kubectl get applications -n argocd  # ✅ Apps exist?
kubectl describe app app-development -n argocd # ✅ Synced?
```
- [ ] All checks pass

### Docker Build Issues
```bash
docker build -t test:latest .       # ✅ Builds locally?
docker run test:latest             # ✅ Runs locally?
```
- [ ] All checks pass

---

## 📋 FINAL VERIFICATION

Run this to confirm complete setup:

```bash
# 1. Cluster
kubectl cluster-info ✅

# 2. Namespaces
kubectl get ns | grep -E "development|staging|production" ✅

# 3. ArgoCD
kubectl get pods -n argocd ✅

# 4. Applications
kubectl get applications -n argocd ✅

# 5. Services
kubectl get deployments -n development ✅

# 6. Monitoring
kubectl get pods -n monitoring ✅

# 7. Helm
helm list -n development ✅

# 8. DNS/Network
kubectl get services -n development ✅

# 9. Logs
kubectl logs -n development -l app=auth-service ✅

# 10. Grafana
curl http://localhost:3000/api/health ✅
```

**All green? Setup complete! 🎉**

---

## 📞 KEEP THIS HANDY

**Important Commands Reference:**
```bash
# Cluster status
./scripts/multi-env-manager.sh status

# View logs
kubectl logs -f <pod> -n <namespace>

# Access service
kubectl port-forward -n <namespace> svc/<service> <port>:<port>

# Check deployment
kubectl get deployment <name> -n <namespace>

# Restart service
kubectl rollout restart deployment/<name> -n <namespace>

# View config
kubectl get configmap <name> -n <namespace>

# Check secret
kubectl get secret <name> -n <namespace>

# Test service
curl http://localhost:<port>/health

# View metrics
# Open Grafana: http://localhost:3000
```

---

**Status:** ✅ Ready to develop  
**Next:** Start building services!  
**Questions?** Check docs/ or TROUBLESHOOTING.md
