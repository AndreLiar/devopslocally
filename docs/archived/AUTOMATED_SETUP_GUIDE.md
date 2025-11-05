# Complete Automated Setup Guide

## Overview

This guide walks you through setting up a complete DevOps infrastructure with automated multi-environment deployment. Everything is automated - from installing prerequisites to setting up your Kubernetes cluster and deploying applications.

## Quick Start (5 minutes)

### One-Command Setup

```bash
./scripts/setup-cluster.sh && ./scripts/multi-env-manager.sh setup
```

This single command will:
1. ✅ Install/verify kubectl
2. ✅ Install/verify Helm
3. ✅ Install/verify git
4. ✅ Create/start Kubernetes cluster (minikube for local)
5. ✅ Create dev, staging, and production namespaces
6. ✅ Set up resource quotas for each environment
7. ✅ Configure all prerequisites

---

## Detailed Setup Steps

### Step 1: Automated Cluster Setup

```bash
./scripts/setup-cluster.sh
```

**What this does:**

- Detects your operating system (macOS, Linux, Windows)
- Checks if kubectl, Helm, and git are installed
- Installs missing tools using your system's package manager
- Auto-detects existing Kubernetes cluster OR sets up Minikube
- Verifies all components are working correctly

**Options:**

```bash
# Auto-detect everything (recommended)
./scripts/setup-cluster.sh

# Force use of minikube with custom resources
./scripts/setup-cluster.sh --cluster-type minikube --minikube-cpus 8 --minikube-memory 16384

# Use existing Kubernetes cluster (e.g., Docker Desktop, EKS, GKE)
./scripts/setup-cluster.sh --cluster-type existing

# Skip checks and continue
./scripts/setup-cluster.sh --skip-checks
```

**Minikube Resource Defaults:**
- CPUs: 4
- Memory: 8192 MB (8 GB)
- Disk: 50 GB

**Recommended Resources:**
- Development: 4 CPU, 8 GB RAM
- Testing/Staging: 8 CPU, 16 GB RAM
- Production: 16+ CPU, 32+ GB RAM

### Step 2: Initialize Multi-Environment Infrastructure

After cluster setup completes, initialize the multi-environment infrastructure:

```bash
./scripts/multi-env-manager.sh setup
```

**What this does:**

- Creates 3 Kubernetes namespaces:
  - `development` - for dev branch
  - `staging` - for staging branch
  - `production` - for main branch
- Sets resource quotas per namespace:
  - Development: 10 CPU, 20 GB memory max
  - Staging: 20 CPU, 40 GB memory max
  - Production: 20 CPU, 40 GB memory max

### Step 3: Verify Everything is Ready

```bash
./scripts/multi-env-manager.sh status
```

**Expected output:**
```
✅ Development namespace ready
✅ Staging namespace ready
✅ Production namespace ready
```

---

## Prerequisites Automation Details

### What Gets Installed

#### 1. kubectl (Kubernetes CLI)

- **Purpose:** Command-line tool to interact with Kubernetes clusters
- **Installed via:**
  - macOS: Homebrew
  - Linux: snap or package manager
  - Windows: Chocolatey (manual)

#### 2. Helm 3 (Package Manager for Kubernetes)

- **Purpose:** Deploy applications to Kubernetes using predefined charts
- **Installed via:**
  - macOS: Homebrew
  - Linux: snap or curl installation script
  - Windows: Chocolatey (manual)

#### 3. Git (Version Control)

- **Purpose:** Clone repository and manage branches
- **Installed via:**
  - macOS: Homebrew
  - Linux: package manager
  - Windows: Git Bash (manual)

#### 4. Minikube (Local Kubernetes)

- **Purpose:** Run Kubernetes locally for development/testing
- **Installed via:**
  - macOS: Homebrew
  - Linux: snap or curl
  - Windows: Chocolatey (manual)
- **Includes:**
  - Ingress addon for routing
  - Dashboard addon for UI
  - Metrics server for resource monitoring

---

## Operating System-Specific Setup

### macOS

**Prerequisites:**
- Homebrew installed

**Automatic installation:**
```bash
./scripts/setup-cluster.sh
```

**Manual alternative:**
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install kubectl helm git minikube

# Start minikube
minikube start --cpus=4 --memory=8192 --disk-size=50gb
```

### Linux (Ubuntu/Debian)

**Automatic installation:**
```bash
./scripts/setup-cluster.sh
```

**Manual alternative:**
```bash
# Update system
sudo apt-get update

# Install kubectl
sudo snap install kubectl --classic
# OR: sudo apt-get install -y kubectl

# Install Helm
sudo snap install helm --classic
# OR: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install git
sudo apt-get install -y git

# Install minikube
sudo snap install minikube --classic
# OR: curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
#     sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start minikube
minikube start --cpus=4 --memory=8192 --disk-size=50gb
```

### macOS with Docker Desktop

If you're using Docker Desktop:

1. **Enable Kubernetes:**
   - Open Docker Desktop → Preferences
   - Go to Kubernetes tab
   - Check "Enable Kubernetes"
   - Click "Apply & Restart"

2. **Run setup:**
   ```bash
   ./scripts/setup-cluster.sh --cluster-type docker
   ```

### Using Cloud Kubernetes (AWS EKS, GCP GKE, Azure AKS)

If you already have a cloud Kubernetes cluster:

1. **Configure kubectl:**
   ```bash
   # AWS EKS example
   aws eks update-kubeconfig --name my-cluster --region us-east-1
   
   # Or use cloud provider CLI to get kubeconfig
   ```

2. **Run setup:**
   ```bash
   ./scripts/setup-cluster.sh --cluster-type existing
   ```

---

## Complete Setup Walkthrough

### Example: Complete Fresh Start

```bash
# Navigate to project directory
cd devopslocally

# Step 1: Install all prerequisites and create cluster
./scripts/setup-cluster.sh

# Step 2: Verify cluster is running
kubectl cluster-info

# Step 3: Initialize multi-environment infrastructure
./scripts/multi-env-manager.sh setup

# Step 4: Check status
./scripts/multi-env-manager.sh status

# Step 5: Configure git branches (if needed)
git checkout -b dev
git checkout -b staging

# Step 6: Deploy to development
git push origin dev

# Step 7: Monitor deployment
./scripts/multi-env-manager.sh details development
```

---

## Troubleshooting

### Issue: Minikube fails to start

**Solution:**
```bash
# Reset minikube
minikube delete

# Start fresh with more resources
./scripts/setup-cluster.sh --cluster-type minikube --minikube-cpus 8 --minikube-memory 16384
```

### Issue: kubectl not found after installation

**Solution (macOS):**
```bash
# Refresh shell
exec $SHELL

# Or manually add to PATH
export PATH="/usr/local/bin:$PATH"
```

**Solution (Linux):**
```bash
# If using snap
sudo snap install kubectl --classic --edge

# Or install system-wide
sudo mv kubectl /usr/local/bin/
```

### Issue: Helm chart pull fails

**Solution:**
```bash
# Update helm repos
helm repo update

# Clear helm cache
rm -rf ~/.helm/cache
```

### Issue: Cluster connectivity error

**Solution:**
```bash
# Check kubectl config
kubectl config view

# Set correct context
kubectl config use-context minikube
# OR: kubectl config use-context docker-desktop
# OR: kubectl config use-context aws-eks-cluster
```

### Issue: Disk space issues with Minikube

**Solution:**
```bash
# Check minikube disk usage
minikube ssh -- df -h

# Clean up unused resources
kubectl delete --all pods --namespace=default

# Or recreate minikube with larger disk
minikube delete
./scripts/setup-cluster.sh --cluster-type minikube --minikube-disk 100
```

---

## Verification Checklist

After running the setup scripts, verify everything:

```bash
# ✅ Check kubectl
kubectl version --client

# ✅ Check Helm
helm version

# ✅ Check git
git --version

# ✅ Check Kubernetes cluster
kubectl cluster-info

# ✅ Check cluster nodes
kubectl get nodes

# ✅ Check namespaces
kubectl get namespaces

# ✅ Check resource quotas
kubectl describe resourcequota env-quota -n development
kubectl describe resourcequota env-quota -n staging
kubectl describe resourcequota env-quota -n production

# ✅ Check Helm repos
helm repo list

# ✅ Check cluster addon status
kubectl get deployment --namespace kube-system
```

---

## Next Steps After Setup

Once the setup is complete, your infrastructure is ready:

### 1. Deploy to Development
```bash
git push origin dev
# Automatically deploys to development namespace with 1 replica
```

### 2. Deploy to Staging
```bash
git push origin staging
# Automatically deploys to staging namespace with 2 replicas
```

### 3. Deploy to Production
```bash
git push origin main
# Automatically deploys to production namespace with 3 replicas
```

### 4. Monitor Deployments
```bash
# Check all environments
./scripts/multi-env-manager.sh status

# Detailed environment information
./scripts/multi-env-manager.sh details development

# Compare configurations
./scripts/multi-env-manager.sh compare
```

### 5. Configure GitHub Actions (for automated CI/CD)

For GitHub-based deployments, add these secrets to your repository:

**Steps:**
1. Go to GitHub → Settings → Secrets and variables → Actions
2. Add `KUBE_CONFIG` secret:
   ```bash
   # Get your kubeconfig content
   cat ~/.kube/config | base64 | pbcopy  # macOS
   # OR
   cat ~/.kube/config | base64 -w 0      # Linux
   ```
3. Paste into GitHub secret

---

## Reference Documentation

- **[MULTI_ENVIRONMENT_SETUP.md](./docs/MULTI_ENVIRONMENT_SETUP.md)** - Complete multi-environment guide
- **[ENVIRONMENT_QUICK_REFERENCE.md](./docs/ENVIRONMENT_QUICK_REFERENCE.md)** - Quick reference for operations
- **[MULTI_ENV_IMPLEMENTATION.md](./docs/MULTI_ENV_IMPLEMENTATION.md)** - Implementation details

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Your Local/Cloud Machine                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         Kubernetes Cluster (1 cluster)                │ │
│  │                                                         │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │ │
│  │  │ development  │  │   staging    │  │ production   │ │ │
│  │  │ namespace    │  │  namespace   │  │  namespace   │ │ │
│  │  │              │  │              │  │              │ │ │
│  │  │ 1 replica    │  │ 2 replicas   │  │ 3 replicas   │ │ │
│  │  │ 250m CPU     │  │ 500m CPU     │  │ 1000m CPU    │ │ │
│  │  │ 128Mi RAM    │  │ 256Mi RAM    │  │ 512Mi RAM    │ │ │
│  │  │              │  │              │  │              │ │ │
│  │  │ PostgreSQL   │  │ PostgreSQL   │  │ PostgreSQL   │ │ │
│  │  │ 1 replica    │  │ 2 replicas   │  │ 2 replicas   │ │ │
│  │  │ 5Gi storage  │  │ 20Gi storage │  │ 100Gi+       │ │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘ │ │
│  │                                                         │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
│  Tools:                                                       │
│  • kubectl  - Manage cluster                                │
│  • Helm     - Deploy applications                           │
│  • git      - Manage code versions                          │
│                                                               │
└─────────────────────────────────────────────────────────────┘

Git Branches:
┌─────────────┬─────────────┬────────────┐
│  dev        │  staging    │  main      │
│  branch     │  branch     │  branch    │
└──────┬──────┴──────┬──────┴──────┬─────┘
       │             │             │
       ▼             ▼             ▼
   GitHub Actions (CI/CD)
   Auto-deploys to correct environment
```

---

## File Locations

```
devopslocally/
├── scripts/
│   ├── setup-cluster.sh              # ← MAIN: Automated cluster setup
│   ├── multi-env-manager.sh          # ← Multi-environment management
│   └── ...
├── helm/
│   ├── auth-service/
│   │   ├── values.yaml
│   │   ├── values-dev.yaml
│   │   ├── values-staging.yaml
│   │   └── values-prod.yaml
│   └── postgres/
│       ├── values.yaml
│       ├── values-dev.yaml
│       ├── values-staging.yaml
│       └── values-prod.yaml
├── .github/
│   └── workflows/
│       └── multi-env-deploy.yml      # ← GitHub Actions automation
└── docs/
    ├── AUTOMATED_SETUP_GUIDE.md      # ← This file
    ├── MULTI_ENVIRONMENT_SETUP.md
    └── ...
```

---

## Summary

Your complete DevOps setup is now **fully automated**:

```bash
# One command to rule them all:
./scripts/setup-cluster.sh && ./scripts/multi-env-manager.sh setup

# Then just push code:
git push origin dev         # → development namespace
git push origin staging     # → staging namespace
git push origin main        # → production namespace

# And monitor:
./scripts/multi-env-manager.sh status
```

**What you get:**
✅ Kubernetes cluster (local or cloud)
✅ kubectl, Helm, git installed
✅ 3 isolated environments
✅ Automated deployments
✅ Resource isolation
✅ Easy rollbacks
✅ Production-ready infrastructure

**Ready to go!** 🚀
