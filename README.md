# 🚀 DevOps Lab - Complete Kubernetes Setup Made Easy

Welcome! This project helps you set up a **production-ready Kubernetes environment** on your computer—automatically.

**No prior experience needed.** Just follow the steps below.

---

## 🎯 What Is This?

Think of this as a **complete starter kit** for running applications in Kubernetes (a popular platform for running software). It includes:

- **Kubernetes**: The system that runs your applications
- **Docker**: The tool that packages applications
- **Grafana & Prometheus**: Tools to monitor how your applications are performing
- **ArgoCD**: Automation for deploying updates from GitHub
- **Loki & Promtail**: Log collection and monitoring
- **Everything automated**: One command sets it all up

---

## ⏱️ Time Commitment

- **Total setup time**: ~60 minutes (includes Git, ArgoCD, and monitoring)
- **Reading time**: ~15 minutes
- **Hands-on time**: ~45 minutes
- **Then you're done!** Your environment is ready to use with full monitoring.

---

## 🛠️ What You Need (Before Starting)

### 1. **A Computer** (Mac, Windows, or Linux)

### 2. **Install These Three Tools**

Don't worry—it's just downloading and clicking "Install."

#### Option A: Mac Users
```bash
# Copy and paste this into your Terminal:
brew install docker kubectl helm
```

#### Option B: Windows Users
1. Download and install:
   - [Docker Desktop](https://www.docker.com/products/docker-desktop) (includes Kubernetes)
   - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
   - [Helm](https://helm.sh/docs/intro/install/)

#### Option C: Linux Users
```bash
# Ubuntu/Debian
sudo apt-get install docker.io kubectl helm

# Or use Snap:
sudo snap install docker kubectl helm
```

### 3. **Check Your Installation**

Run this in your Terminal/Command Prompt to verify everything is installed:

```bash
docker --version
kubectl version --client
helm version
```

If you see version numbers (not errors), you're good to go! ✅

---

## 🚀 Getting Started (60 Minutes Total)

### **Phase 1: Git & GitHub Setup** (5 Minutes)

Your GitHub account is needed for ArgoCD to automatically deploy your applications.

#### Step 1a: Create a GitHub Account (if you don't have one)
1. Go to [github.com](https://github.com)
2. Click **"Sign up"**
3. Fill in your email, password, and username
4. Verify your email

**Your GitHub username** (e.g., `john-developer`) — you'll need this later! ✍️

#### Step 1b: Generate a GitHub Personal Access Token
ArgoCD needs permission to read your repositories. Here's how to create a token:

1. Go to [github.com/settings/tokens](https://github.com/settings/tokens)
2. Click **"Generate new token"** (classic)
3. Fill in these details:
   ```
   Token name: devopslocally-argocd
   Expiration: 90 days (or Custom: 1 year)
   ```
4. **Select scopes** (permissions):
   - ✅ `repo` (Full control of private repositories)
   - ✅ `read:org` (Read organization data)
   - ✅ `admin:repo_hook` (Full control of repository hooks)

5. Click **"Generate token"**
6. **Copy and save this token** somewhere safe (we'll use it soon!)
   ```
   ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```
   ⚠️ **Important**: You won't see this token again! Copy it now.

#### Step 1c: Fork This Repository to Your GitHub Account
1. Go to [github.com/AndreLiar/devopslocally](https://github.com/AndreLiar/devopslocally)
2. Click **"Fork"** (top-right corner)
3. This creates a copy under your account: `github.com/YOUR-USERNAME/devopslocally`

**Save your repository URL:**
```
https://github.com/YOUR-USERNAME/devopslocally
```

---

### **Phase 2: Basic Infrastructure Setup** (20 Minutes)

This step sets up Kubernetes, Docker, and networking.

#### Step 2a: Clone Your Fork Locally
```bash
git clone https://github.com/YOUR-USERNAME/devopslocally.git
cd devopslocally
```

Replace `YOUR-USERNAME` with your actual GitHub username.

#### Step 2b: Check Your Installation
```bash
./scripts/check-prerequisites.sh
```

**Expected output:** All ✅ checkmarks. If you see ❌, run the installer:

**Mac Users:**
```bash
brew install docker kubectl helm
```

**Windows Users:**
1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Download [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
3. Download [Helm](https://helm.sh/docs/intro/install/)

**Linux Users:**
```bash
sudo apt-get update
sudo apt-get install docker.io kubectl helm
```

#### Step 2c: Start the Cluster
```bash
make setup
```

**What happens:**
- Creates a local Kubernetes cluster
- Installs basic infrastructure
- Takes about 15-20 minutes
- Watch the progress messages

**Expected result:** `✅ Setup complete! Your cluster is ready.`

---

### **Phase 3: ArgoCD Configuration** (15 Minutes)

ArgoCD automatically deploys your applications when you push code to GitHub.

#### Step 3a: Install ArgoCD
```bash
./scripts/setup-argocd.sh install
```

**Expected output:**
```
✅ ArgoCD installed successfully
ℹ️  Namespace: argocd
ℹ️  Status: Running
```

Wait for all ArgoCD pods to be ready:
```bash
kubectl get pods -n argocd
```

**Expected:** All pods showing `Running` status. Wait 2-3 minutes if needed.

#### Step 3b: Get ArgoCD Admin Password
```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

This will print your ArgoCD admin password. **Save it!** 
```
Example output: randompassword123xyz
```

#### Step 3c: Access ArgoCD Dashboard
1. Forward ArgoCD to your computer:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

2. Open in your browser: `https://localhost:8080`
   
3. **Accept the security warning** (self-signed certificate)

4. Login:
   ```
   Username: admin
   Password: [paste from step 3b]
   ```

#### Step 3d: Connect Your GitHub Repository to ArgoCD
Now you'll tell ArgoCD where your application code lives.

1. In ArgoCD Dashboard, click ⚙️ **Settings** (left sidebar)
2. Click **Repositories**
3. Click **"+ Connect a repo using HTTPS"**

4. Fill in these details:
   ```
   Repository URL: https://github.com/YOUR-USERNAME/devopslocally
   Username: YOUR-GITHUB-USERNAME
   Password: [paste your GitHub token from Step 1b]
   ```
   
5. Click **"Connect"**

**Expected result:** 
```
✅ Connection successful
Repository https://github.com/YOUR-USERNAME/devopslocally
```

#### Step 3e: Create an Application in ArgoCD
This tells ArgoCD to deploy your application automatically.

1. In ArgoCD, click **"+ NEW APP"** (top left)

2. Fill in these details:

   **General:**
   ```
   Application Name: auth-service
   Project Name: default
   Sync Policy: Automatic
   ```

   **Source:**
   ```
   Repository URL: https://github.com/YOUR-USERNAME/devopslocally
   Revision: main (your branch)
   Path: helm/auth-chart
   ```

   **Destination:**
   ```
   Cluster URL: https://kubernetes.default.svc
   Namespace: default
   ```

3. Click **"Create"**

**What happens next:** ArgoCD watches your GitHub repository. When you push changes, it automatically deploys them!

---

### **Phase 4: Monitoring Stack Setup** (Prometheus, Grafana, Loki)** (15 Minutes)

Set up complete monitoring with metrics, dashboards, and logs.

#### Step 4a: Create Monitoring Namespace
```bash
kubectl create namespace monitoring
```

#### Step 4b: Add Grafana Helm Repository
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

#### Step 4c: Deploy Prometheus + Grafana Stack
```bash
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set prometheus.prometheusSpec.retention=10d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]=ReadWriteOnce \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=10Gi
```

**Wait for pods to be ready:**
```bash
kubectl get pods -n monitoring
```

Expected: All pods showing `Running` after 2-3 minutes.

#### Step 4d: Deploy Loki (Log Storage) + Promtail (Log Shipper)
```bash
helm install loki grafana/loki-stack \
  -n monitoring \
  --set loki.persistence.enabled=true \
  --set loki.persistence.size=10Gi \
  --set promtail.enabled=true
```

**Verify deployment:**
```bash
kubectl get pods -n monitoring | grep loki
```

#### Step 4e: Access Grafana Dashboard
1. Port forward Grafana:
   ```bash
   kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &
   ```

2. Open in browser: `http://localhost:3000`

3. **Login credentials:**
   ```
   Username: admin
   Password: prom-operator
   ```

4. Change password immediately:
   - Click your profile (bottom left)
   - Click **"Change password"**
   - Enter a new password

#### Step 4f: Configure Loki Data Source in Grafana
1. In Grafana, click ⚙️ **Configuration** (left gear icon)
2. Click **Data Sources**
3. Click **"Add data source"**
4. Select **Loki**
5. Fill in:
   ```
   Name: Loki
   URL: http://loki:3100
   ```
6. Click **"Save & Test"** → should show "Data source is working"

#### Step 4g: Configure Prometheus Data Source (Usually Pre-added)
Prometheus should already be configured. Verify:
1. Click ⚙️ **Configuration**
2. Click **Data Sources**
3. Look for **"Prometheus"** in the list

If missing, click **"Add data source"** → **Prometheus** and enter:
```
Name: Prometheus
URL: http://prometheus-kube-prometheus-prometheus:9090
```

#### Step 4h: Import Pre-built Dashboards
Pre-built dashboards make monitoring easier.

1. Click **+ (plus icon)** in the left sidebar → **Import**
2. Enter Dashboard ID: `315` (Kubernetes Cluster Monitoring)
3. Click **Load**
4. Select data source: **Prometheus**
5. Click **Import**

**Repeat for these useful dashboards:**
- **1860** - Node Exporter Full (system metrics)
- **3662** - Prometheus (Prometheus health)

#### Step 4i: View Your Application Logs in Grafana
1. Click **Explore** (left sidebar)
2. Select data source: **Loki**
3. Run this query to see logs from your auth-service:
   ```
   {app="auth-service"}
   ```
4. You'll see real-time logs from your application!

---

### **Phase 5: Verify Everything Works** (5 Minutes)

#### Step 5a: Check All Services Are Running
```bash
# Check cluster
kubectl get nodes

# Check monitoring
kubectl get pods -n monitoring

# Check ArgoCD
kubectl get pods -n argocd

# Check applications
kubectl get pods
```

All should show `Running` status.

#### Step 5b: Access All Dashboards

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| **Grafana** | http://localhost:3000 | admin | (your new password) |
| **Prometheus** | http://localhost:9090 | (no login) | — |
| **ArgoCD** | https://localhost:8080 | admin | (saved from step 3b) |

#### Step 5c: Deploy a Test Application Through ArgoCD
1. Open ArgoCD dashboard
2. You should see your "auth-service" application
3. Click on it to see deployment status
4. Watch as ArgoCD syncs your application

#### Step 5d: View Metrics in Grafana
1. Open Grafana
2. Click a pre-built dashboard (e.g., "Kubernetes Cluster Monitoring")
3. You'll see real-time metrics: CPU, memory, network, etc.

#### Step 5e: View Logs in Grafana Loki
1. Open Grafana
2. Click **Explore**
3. Select **Loki** data source
4. Run:
   ```
   {namespace="default"}
   ```
5. You'll see logs from your applications in real-time!

---

### **Summary: What You've Done**

| Step | Component | What Happened |
|------|-----------|---------------|
| 1 | Git/GitHub | Created access token, forked repository |
| 2 | Kubernetes | Set up local cluster with Docker and Helm |
| 3 | ArgoCD | Configured automatic deployments from GitHub |
| 4 | Monitoring | Deployed Prometheus, Grafana, Loki, Promtail |
| 5 | Verification | Confirmed all services working together |

**Now you have:**
- ✅ Local Kubernetes cluster running
- ✅ ArgoCD automatically deploying your code
- ✅ Prometheus collecting metrics
- ✅ Grafana showing dashboards
- ✅ Loki collecting and displaying logs
- ✅ Full production-grade observability stack

---

## 🆘 Troubleshooting During Setup

### **Problem: GitHub Token Not Working**
**Symptoms:** ArgoCD shows "Authentication failed" when connecting to your repository

**Solution:**
1. Verify token has correct permissions:
   - Go to [github.com/settings/tokens](https://github.com/settings/tokens)
   - Click your token
   - Check: `repo`, `read:org`, `admin:repo_hook` are selected
   
2. If permissions changed, you need a new token:
   - Delete the old one
   - Generate a new token (follow Step 1b again)
   - Update ArgoCD with new token (Step 3d)

### **Problem: "Connection refused" on http://localhost:3000**
**Symptoms:** Can't access Grafana or other dashboards

**Solution:**
```bash
# Start port forwarding again
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090 &
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
```

### **Problem: ArgoCD Pod Not Running**
**Symptoms:** `kubectl get pods -n argocd` shows `Pending` or `ImagePullBackOff`

**Solution:**
```bash
# Check what's wrong
kubectl describe pod -n argocd

# If it's internet/DNS issue
kubectl delete pod -n argocd --all  # restart pods

# If completely broken, reinstall
./scripts/setup-argocd.sh cleanup
./scripts/setup-argocd.sh install
```

### **Problem: "Insufficient disk space" during setup**
**Symptoms:** Setup fails with storage errors

**Solution:**
```bash
# Free up disk space (at least 10GB needed)
# On Mac: delete Docker images
docker image prune -a

# Then try setup again
make setup
```

### **Problem: Grafana Shows "No Data"**
**Symptoms:** Grafana dashboard is empty, no metrics showing

**Solution:**
1. Wait 2-3 minutes (Prometheus takes time to collect metrics)
2. Verify Prometheus is scraping:
   ```bash
   # Open Prometheus at http://localhost:9090
   # Go to: Status → Targets
   # All should show "UP"
   ```
3. If targets show "DOWN":
   ```bash
   # Restart Prometheus
   kubectl rollout restart deployment prometheus-kube-prometheus-prometheus -n monitoring
   ```

### **Problem: "Repository connection failed" in ArgoCD**
**Symptoms:** ArgoCD can't connect to your GitHub repository

**Solution:**
```bash
# Test your credentials
git clone https://github.com/YOUR-USERNAME/devopslocally.git --depth=1

# If that fails, try:
# 1. Verify GitHub username
# 2. Verify token is current (not expired)
# 3. Verify you forked the repository
# 4. Try disconnecting and reconnecting in ArgoCD
```

### **Need More Help?**
```bash
# See detailed troubleshooting guide
cat docs/TROUBLESHOOTING.md

# Check setup logs
kubectl logs -n argocd deployment/argocd-server | head -50
kubectl logs -n monitoring deployment/kube-prometheus-grafana | head -50
```

---

## 📚 Common Questions (FAQ)

### **Git & GitHub Questions**

### Q: "What's a GitHub Personal Access Token?"
**A:** It's like a temporary password that allows ArgoCD to read your code without using your actual password. It's safer because:
- You can limit what it can do (scope)
- You can delete it anytime
- It's safer than storing your real GitHub password

### Q: "Can I use the main devopslocally repository instead of forking?"
**A:** You can read from the main repo, but you won't be able to push changes. We recommend forking so you can:
- Modify configurations for your needs
- Push custom changes
- Practice DevOps workflows

### Q: "My GitHub token expired. What do I do?"
**A:** 
1. Generate a new token (follow Step 1b)
2. Copy the new token
3. In ArgoCD, go to Settings → Repositories
4. Edit your repository connection
5. Paste the new token and save

### **ArgoCD Questions**

### Q: "What's ArgoCD and why do I need it?"
**A:** ArgoCD watches your GitHub repository. Whenever you push code changes, it automatically:
1. Detects the change
2. Downloads your updated code
3. Deploys it to Kubernetes
4. Shows you the status in the dashboard

This is called "GitOps" — your Git repository is the source of truth for what's deployed.

### Q: "Can I deploy without ArgoCD?"
**A:** Yes, but you'd have to deploy manually:
```bash
helm upgrade --install auth-service ./auth-chart -n default
```
ArgoCD just automates this, making it easier and safer.

### Q: "How do I know if ArgoCD deployed my changes?"
**A:** Open the ArgoCD dashboard:
1. Look for your application ("auth-service")
2. The status shows:
   - 🟢 **Synced** = deployed successfully
   - 🟡 **OutOfSync** = GitHub has changes not yet deployed
   - 🔴 **Error** = something went wrong

### Q: "Can I rollback a deployment?"
**A:** Yes! ArgoCD tracks all deployments:
1. Click your application in ArgoCD
2. Click **History**
3. Select a previous version
4. Click **Rollback**

### **Monitoring Questions**

### Q: "Why do I need Prometheus, Grafana, AND Loki?"
**A:** They do different things:
- **Prometheus** = collects metrics (CPU, memory, requests)
- **Grafana** = displays metrics in pretty dashboards
- **Loki** = stores and searches logs from your applications

Together they give you complete visibility.

### Q: "How long does Prometheus keep data?"
**A:** By default, 10 days. You can change this in the Helm values if needed.

### Q: "Can I see logs from my application?"
**A:** Yes! In Grafana:
1. Click **Explore**
2. Select **Loki**
3. Run: `{app="auth-service"}`
4. You'll see all logs from your app in real-time

### Q: "How do I create custom dashboards in Grafana?"
**A:** 
1. Click **+** (plus icon) → **Dashboard**
2. Click **Add a new panel**
3. Select your data source (Prometheus or Loki)
4. Write a query (e.g., `rate(http_requests_total[5m])`)
5. Click **Save**

Read `docs/MONITORING_SETUP.md` for detailed examples.

### **General Questions**

### Q: "What's Kubernetes?"
**A:** It's a tool that automatically manages where and how your applications run. Think of it like an intelligent scheduler for your applications that:
- Keeps apps running even if one fails
- Scales apps up/down automatically
- Handles updates with zero downtime

### Q: "Do I need to know Docker?"
**A:** Not for basic use! We've set up examples. You can learn as you go. Start with `DEVELOPER_GUIDE.md` when you're ready.

### Q: "Can I run multiple applications?"
**A:** Yes! The system is designed for that. Each application gets its own Helm chart and ArgoCD application.

### Q: "What if something breaks?"
**A:** Don't panic! We have a troubleshooting guide. See section **"Troubleshooting During Setup"** above.

### Q: "Can I use this in production?"
**A:** Yes, but you'll need to customize it for your needs:
- Use a real registry (Docker Hub, ECR, etc.)
- Set up proper backup/recovery
- Configure persistent storage
- Set up proper networking/security

See `docs/MULTI_ENVIRONMENT_SETUP.md` for production guidelines.

### Q: "How much does this cost?"
**A:** Nothing! Everything is open source and free. Costs depend on your hosting (AWS, Google Cloud, etc.) if you use cloud Kubernetes.

### Q: "Can I integrate this with cloud platforms (AWS, Google Cloud)?"
**A:** Yes! It works with:
- AWS EKS (Elastic Kubernetes Service)
- Google Cloud GKE (Google Kubernetes Engine)
- Microsoft Azure AKS (Azure Kubernetes Service)
- Any Kubernetes cluster

See `docs/MULTI_ENVIRONMENT_SETUP.md` for cloud setup guides.

---

## 🎯 Next Steps (After Setup)

### **Option 1: Deploy Your Own Application Through ArgoCD**

ArgoCD makes deploying applications simple. Here's how:

#### 1a. Create Your Application
```bash
# Create a new directory for your app
mkdir my-app
cd my-app

# Create a simple application (or copy auth-service as template)
cp -r ../auth-service/* .

# Customize it for your needs
```

#### 1b. Create Helm Chart for Your App
```bash
# Copy the Helm chart template
mkdir -p helm/my-app-chart
cp -r ../helm/auth-chart/* helm/my-app-chart/

# Edit the values.yaml to match your app
# - Change image names
# - Update service ports
# - Adjust resource limits
```

#### 1c: Push to GitHub
```bash
git add .
git commit -m "Add my-app application"
git push origin main
```

#### 1d: Create Application in ArgoCD
1. Open ArgoCD dashboard: https://localhost:8080
2. Click **"+ NEW APP"**
3. Fill in:
   ```
   Name: my-app
   Repository: https://github.com/YOUR-USERNAME/devopslocally
   Path: helm/my-app-chart
   Namespace: default
   ```
4. Click **Create**

**Result:** ArgoCD automatically deploys your app! 🎉

### **Option 2: Push a Code Change and Watch ArgoCD Deploy It**

1. Make a change to your application:
   ```bash
   # Edit auth-service code
   nano auth-service/server.js
   ```

2. Build and push new Docker image:
   ```bash
   docker build -t YOUR-REGISTRY/auth-service:v2 -f auth-service/Dockerfile auth-service
   docker push YOUR-REGISTRY/auth-service:v2
   ```

3. Update the Helm values:
   ```bash
   # Edit auth-chart/values.yaml
   # Change image.tag: from latest to v2
   ```

4. Commit and push:
   ```bash
   git add auth-chart/values.yaml
   git commit -m "Update auth-service to v2"
   git push origin main
   ```

5. Watch ArgoCD deploy it:
   - Open ArgoCD: https://localhost:8080
   - Click on "auth-service" application
   - See it automatically sync and deploy! 🚀

### **Option 3: Monitor Your Applications**

1. **View Real-Time Metrics in Grafana:**
   - Open http://localhost:3000
   - Click a dashboard (e.g., "Kubernetes Cluster Monitoring")
   - See CPU, memory, network usage

2. **View Application Logs in Loki:**
   - In Grafana, click **Explore** → **Loki**
   - Run: `{app="auth-service"}`
   - Watch logs update in real-time

3. **Create Custom Alerts:**
   - Read `docs/MONITORING_SETUP.md`
   - Configure alerts for critical metrics
   - Get notified when issues occur

### **Option 4: Learn More About Git & DevOps Workflows**

1. **Read Git workflow guide:**
   ```bash
   cat docs/GITOPS_PIPELINE.md
   ```

2. **Practice Git branching:**
   ```bash
   # Create feature branch
   git checkout -b feature/my-feature
   
   # Make changes
   # Commit and push
   git push origin feature/my-feature
   
   # Create Pull Request on GitHub
   # Merge to main when ready
   ```

3. **Understand GitOps:**
   - Your Git repo is source of truth
   - ArgoCD watches the repo
   - Any change triggers deployment
   - Full audit trail of all changes

---

## 🚀 Quick Commands (Cheat Sheet)

### **Git & GitHub Commands**
```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/devopslocally.git
cd devopslocally

# Create feature branch
git checkout -b feature/my-feature

# Make changes, then commit
git add .
git commit -m "Description of changes"

# Push to GitHub
git push origin feature/my-feature

# Create Pull Request (use GitHub web interface)

# Update from main branch
git pull origin main
```

### **ArgoCD Commands**
```bash
# Get ArgoCD password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

# Port forward to access dashboard
kubectl port-forward svc/argocd-server -n argocd 8080:443

# List all applications
kubectl get applications -n argocd

# Check application status
kubectl get application auth-service -n argocd -o yaml

# Manually sync an application
argocd app sync auth-service --auth-token $(argocd account generate-token)
```

### **Monitoring Commands**
```bash
# Port forward Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &

# Port forward Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090 &

# Check Prometheus targets
# Open: http://localhost:9090 → Status → Targets

# View Loki logs
kubectl logs -f -n monitoring deployment/loki

# Check monitoring pod status
kubectl get pods -n monitoring
```

### **Kubernetes/Deployment Commands**
```bash
# Setup everything
make setup

# Check status
kubectl get nodes
kubectl get pods
kubectl get services

# View specific pod logs
kubectl logs -f deployment/auth-service

# Execute command in pod
kubectl exec -it deployment/auth-service -- bash

# Port forward to service
kubectl port-forward svc/auth-service 3001:3000

# Deploy with Helm
helm upgrade --install auth-service ./auth-chart -n default

# Delete deployment
helm uninstall auth-service -n default

# Restart pods
kubectl rollout restart deployment/auth-service
```

### **Cleanup Commands**
```bash
# Stop port forwarding
pkill port-forward

# Delete monitoring stack
helm uninstall kube-prometheus -n monitoring
helm uninstall loki -n monitoring

# Delete ArgoCD
./scripts/setup-argocd.sh cleanup

# Tear down everything
make teardown

# Start fresh
make reset
```

## 📖 Documentation for Different Audiences

### 👨‍💼 **Project Managers / Decision Makers**
Start here to understand what this system does:
- `docs/ARCHITECTURE.md` — system overview (5-minute read)
- `docs/COST_OPTIMIZATION.md` — understand costs

### 👨‍💻 **Developers (Just Want to Deploy Code)**
Start here to learn how to deploy your application:
- This README (especially Phase 1-5)
- `DEVELOPER_GUIDE.md` — how to create and deploy applications
- `docs/GITOPS_PIPELINE.md` — how code gets deployed automatically
- **Workflow:** Write code → Push to GitHub → ArgoCD deploys automatically

### 🏗️ **DevOps / Infrastructure Engineers**
Start here for advanced setup and management:
- `docs/MULTI_ENVIRONMENT_SETUP.md` — dev/staging/production setup
- `docs/ARCHITECTURE.md` — detailed system design
- `docs/SECURITY.md` — security hardening
- `docs/MONITORING_SETUP.md` — advanced monitoring configuration
- `scripts/` — automation scripts for everything

### 🐍 **Python Developers**
See example application structure:
- `auth-service/` — Node.js example (shows structure)
- Copy pattern to create Python app with similar Helm chart

### 🪟 **Windows Users**
Special setup guide:
- `docs/WINDOWS_WSL2_SETUP.md` — Windows-specific installation

### 🆘 **Troubleshooting**
When something goes wrong:
- This README → "Troubleshooting During Setup" section
- `docs/TROUBLESHOOTING.md` — comprehensive troubleshooting guide

### 🗺️ **Lost or Confused?**
Find what you need:
- `DOCUMENTATION_INDEX.md` — complete index of all documentation

---

## 🤝 Need Help?

### **Step 1: Check the Documentation**
```bash
# Troubleshooting guide
cat docs/TROUBLESHOOTING.md

# Specific component guide
cat docs/GITOPS_PIPELINE.md    # For ArgoCD issues
cat docs/MONITORING_SETUP.md   # For Prometheus/Grafana issues
cat docs/ARCHITECTURE.md       # To understand the system
```

### **Step 2: Check Common Issues**
See **"Troubleshooting During Setup"** section above for common problems and solutions.

### **Step 3: Report an Issue**
If you found a bug or have a feature request:
1. Go to [GitHub Issues](https://github.com/AndreLiar/devopslocally/issues)
2. Click **"New Issue"**
3. Describe your problem and include:
   - What you tried
   - What happened
   - What you expected
   - Output of `kubectl get pods -A`

### **Step 4: Join the Community**
- **GitHub Discussions:** Share ideas and best practices
- **Issues:** Ask questions and report bugs

---

## 🎉 Congratulations!

You now have a **professional-grade Kubernetes environment** running on your computer. You can:

✅ **Run multiple applications**  
✅ **Monitor their performance in real-time**  
✅ **Deploy updates automatically from GitHub**  
✅ **Scale applications up and down**  
✅ **See complete logs and metrics**  
✅ **Use the same system for development and production**  
✅ **Practice DevOps workflows** with GitOps

**You've mastered the essentials of modern DevOps!** 🚀

---

## 📞 Support & Resources

### **Quick Links:**
- 📄 [Full Documentation](./DOCUMENTATION_INDEX.md)
- 🐛 [Report Issues](https://github.com/AndreLiar/devopslocally/issues)
- 💬 [Discussions](https://github.com/AndreLiar/devopslocally/discussions)
- 📚 [Learning Resources](./docs/)

### **Key Documentation Files:**
| File | Purpose | Read Time |
|------|---------|-----------|
| `POST_CLONE_GUIDE.md` | Step-by-step after cloning | 10 min |
| `DEVELOPER_GUIDE.md` | How to create applications | 15 min |
| `docs/GITOPS_PIPELINE.md` | How deployments work | 10 min |
| `docs/ARCHITECTURE.md` | System design overview | 15 min |
| `docs/TROUBLESHOOTING.md` | Solutions to common issues | As needed |
| `docs/MONITORING_SETUP.md` | Advanced monitoring | 20 min |
| `docs/MULTI_ENVIRONMENT_SETUP.md` | Production setup | 25 min |

---

## 📄 License & Credits

This project is open source. See LICENSE file for details.

**Built with:**
- Kubernetes
- Docker
- Helm
- ArgoCD
- Prometheus
- Grafana
- Loki

---

**Last Updated:** November 5, 2025  
**Status:** Production Ready ✅  
**Next:** Start with **"Phase 1: Git & GitHub Setup"** above!

**Questions?** See the "Need Help?" section or read `docs/TROUBLESHOOTING.md`

---

## 🎓 Learning Path (If You're New to This)

**Week 1: Setup & Basic Understanding**
- [ ] Create GitHub account and personal access token
- [ ] Fork the devopslocally repository
- [ ] Complete all 5 phases of getting started
- [ ] Access all three dashboards:
  - [ ] Grafana (http://localhost:3000)
  - [ ] Prometheus (http://localhost:9090)
  - [ ] ArgoCD (https://localhost:8080)
- [ ] View your first metrics in Grafana
- [ ] View your first logs in Loki
- [ ] Read `DEVELOPER_GUIDE.md`

**Week 2: Git & ArgoCD Workflows**
- [ ] Create a feature branch: `git checkout -b feature/my-first-change`
- [ ] Make a change to code or configuration
- [ ] Commit and push: `git push origin feature/my-first-change`
- [ ] Create a Pull Request on GitHub
- [ ] Merge to main branch
- [ ] Watch ArgoCD automatically deploy the change
- [ ] Read `docs/GITOPS_PIPELINE.md` (understand GitOps)

**Week 3: Custom Application Deployment**
- [ ] Create your own application (or copy auth-service)
- [ ] Create Helm chart for your application
- [ ] Push to GitHub
- [ ] Add application to ArgoCD
- [ ] Watch it deploy automatically
- [ ] Monitor it in Grafana dashboards
- [ ] Read `docs/ARCHITECTURE.md`

**Week 4+: Advanced Topics**
- [ ] Create custom Grafana dashboards
- [ ] Set up alerts in Prometheus/Grafana
- [ ] Explore Kubernetes advanced features
- [ ] Set up automated backups
- [ ] Deploy to cloud platform (AWS/Google Cloud)
- [ ] Read `docs/MULTI_ENVIRONMENT_SETUP.md`

**Recommended Documentation Reading:**
1. `POST_CLONE_GUIDE.md` — detailed post-clone steps
2. `DEVELOPER_GUIDE.md` — how to develop applications
3. `docs/GITOPS_PIPELINE.md` — how deployments work
4. `docs/ARCHITECTURE.md` — system architecture
5. `docs/MONITORING_SETUP.md` — advanced monitoring
6. `docs/MULTI_ENVIRONMENT_SETUP.md` — cloud deployment

---

## ✅ Success Checklist

### **After Phase 1 (Git Setup):**
- [ ] Have a GitHub account
- [ ] Generated a personal access token (saved safely)
- [ ] Forked the devopslocally repository to your account
- [ ] Know your GitHub username and repository URL

### **After Phase 2 (Infrastructure):**
- [ ] docker --version shows v20.10+
- [ ] kubectl version --client shows v1.24+
- [ ] helm version shows v3+
- [ ] `make setup` completed without major errors
- [ ] Kubernetes cluster is running

### **After Phase 3 (ArgoCD):**
- [ ] ArgoCD is installed: `kubectl get pods -n argocd`
- [ ] Can access ArgoCD dashboard: https://localhost:8080
- [ ] ArgoCD is connected to your GitHub repository
- [ ] "auth-service" application shows "Synced" status
- [ ] Have saved the ArgoCD admin password somewhere safe

### **After Phase 4 (Monitoring):**
- [ ] Prometheus is running: `kubectl get pods -n monitoring | grep prometheus`
- [ ] Grafana is running and accessible: http://localhost:3000
- [ ] Loki is running and storing logs
- [ ] Can see metrics in Grafana dashboards
- [ ] Can search logs in Grafana Loki
- [ ] Pre-built dashboards are imported (315, 1860, 3662)

### **After Phase 5 (Verification):**
- [ ] All pods showing "Running" status
- [ ] All three dashboards accessible (Grafana, Prometheus, ArgoCD)
- [ ] Can see your application in ArgoCD
- [ ] Can see metrics from your application in Grafana
- [ ] Can see logs from your application in Loki
- [ ] No error messages in any dashboard

### **Congratulations!** 🎉
If all checkboxes are ✅, your production-ready Kubernetes environment is fully operational with:
- ✅ Container orchestration (Kubernetes)
- ✅ Automated deployments (ArgoCD + GitHub)
- ✅ Metrics collection (Prometheus)
- ✅ Dashboards & visualization (Grafana)
- ✅ Log aggregation (Loki)

## 💡 Pro Tips

1. **Bookmark the dashboards** (http://localhost:3000 for Grafana)
2. **Keep Terminal open** during setup (don't close it)
3. **Start with the examples** before creating your own
4. **Read the troubleshooting guide** if stuck
5. **Ask questions** in the GitHub discussions

---

## ✅ Success Checklist

After completing setup, check off these items:

- [ ] All prerequisites installed (docker, kubectl, helm)
- [ ] `make setup` completed without errors
- [ ] Can access Grafana (http://localhost:3000)
- [ ] Can access Prometheus (http://localhost:9090)
- [ ] Can access ArgoCD (http://localhost:8080)
- [ ] See running pods: `kubectl get pods`
- [ ] Can view application logs: `kubectl logs -f deployment/auth-service`

If all ✅, you're ready to go!

---

## 🤝 Need Help?

1. **Check the troubleshooting guide:**
   ```bash
   cat docs/TROUBLESHOOTING.md
   ```

2. **Check the FAQ:**
   - See "FAQ" section above

3. **Read the detailed docs:**
   ```bash
   cat POST_CLONE_GUIDE.md
   ```

4. **Open an issue on GitHub:**
   - [GitHub Issues](https://github.com/AndreLiar/devopslocally/issues)

---

## 🎉 Congratulations!

You now have a **professional-grade Kubernetes environment** running on your computer. You can:

✅ Run multiple applications  
✅ Monitor their performance  
✅ Deploy updates automatically  
✅ Scale applications up and down  
✅ Use the same system for development and production  

**Welcome to DevOps! 🚀**

---

## 📞 Support & Community

- **GitHub Issues:** Report bugs or ask questions
- **Discussions:** Share ideas and best practices
- **Documentation:** See docs/ folder for detailed guides
- **Email:** Contact the maintainers

---

## 📄 License

This project is open source. See LICENSE file for details.

---

**Last Updated:** November 5, 2025  
**Status:** Production Ready ✅  
**Next:** Read `POST_CLONE_GUIDE.md` to get started!
