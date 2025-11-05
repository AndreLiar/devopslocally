# 🚀 GitOps Pipeline Documentation

## Overview

This document explains the complete GitOps workflow in the `devopslocally` repository. The pipeline automates the process of building, deploying, and syncing containerized applications to a Kubernetes cluster using GitHub Actions and ArgoCD.

```
Push → GitHub Actions builds & updates chart → ArgoCD syncs → Cluster updated
```

---

## 🔄 Pipeline Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        GITOPS PIPELINE FLOW                            │
└─────────────────────────────────────────────────────────────────────────┘

  Developer Push       GitHub Actions           ArgoCD                 Kubernetes
  ════════════         ═══════════════          ══════                 ══════════
       │                     │                    │                       │
       │  Push commit        │                    │                       │
       ├────────────────────►│                    │                       │
       │  (auth-service/**)  │                    │                       │
       │                     │                    │                       │
       │                ┌────────────────────┐    │                       │
       │                │ 1. Checkout code  │    │                       │
       │                └────────────────────┘    │                       │
       │                         │                 │                       │
       │                ┌────────────────────┐    │                       │
       │                │ 2. Build Docker   │    │                       │
       │                │    image:tag       │    │                       │
       │                └────────────────────┘    │                       │
       │                         │                 │                       │
       │                ┌────────────────────┐    │                       │
       │                │ 3. Push to        │    │                       │
       │                │    registry:5001  │    │                       │
       │                └────────────────────┘    │                       │
       │                         │                 │                       │
       │                ┌────────────────────┐    │                       │
       │                │ 4. Update Helm    │    │                       │
       │                │    values.yaml    │    │                       │
       │                │    (new tag)      │    │                       │
       │                └────────────────────┘    │                       │
       │                         │                 │                       │
       │                ┌────────────────────┐    │                       │
       │                │ 5. Commit & push  │    │                       │
       │                │    chart update   │    │                       │
       │                └────────────────────┘    │                       │
       │                         │                 │                       │
       │                    Push to main ──────────┤►┌───────────────┐    │
       │                                           │ │ 6. Detect    │    │
       │                                           │ │    Git change│    │
       │                                           │ └───────────────┘    │
       │                                           │         │            │
       │                                           │  ┌──────────────┐   │
       │                                           │  │ 7. Sync Helm│   │
       │                                           │  │    chart    │   │
       │                                           │  └──────────────┘   │
       │                                           │         │            │
       │                                           │  ┌──────────────┐   │
       │                                           │  │ 8. Generate │   │
       │                                           │  │    manifests│   │
       │                                           │  └──────────────┘   │
       │                                           │         │            │
       │                                           └────────►│            │
       │                                                     │            │
       │                                           ┌──────────────────┐  │
       │                                           │ 9. Apply to      │  │
       │                                           │    cluster       │  │
       │                                           └──────────────────┘  │
       │                                                     │            │
       │                                                     └───────────►│
       │                                                                  │
       │                                           ┌──────────────────┐  │
       │                                           │ 10. Pod updated  │  │
       │                                           │     with new     │  │
       │                                           │     image:tag    │  │
       │                                           └──────────────────┘  │
       │                                                     ▲            │
       │                                                     │            │
       └──────────────────────────────────────────────────────────────────┘
                              CYCLE COMPLETE
```

---

## 📋 Step-by-Step Breakdown

### **Step 1: Developer Push**

Developer makes a change to the `auth-service/` directory and pushes to the `main` branch:

```bash
# Edit code
nano auth-service/server.js

# Stage and commit
git add auth-service/server.js
git commit -m "chore: update auth-service message"

# Push to GitHub
git push origin main
```

**Trigger condition:** Any push to `main` branch that modifies files in `auth-service/**`

---

### **Step 2–5: GitHub Actions Workflow (CI)**

**Workflow file:** `.github/workflows/deploy.yml`

The workflow is triggered by the push and performs these steps:

#### **2. Checkout Code**
```yaml
- name: Checkout code
  uses: actions/checkout@v4
```
Clones the repository at the commit that was pushed.

#### **3. Build Docker Image**
```yaml
- name: Build Docker image
  run: |
    docker build -t localhost:5001/auth-service:${{ github.run_number }} ./auth-service
```
- Builds a Docker image from `auth-service/Dockerfile`
- Tags it as `localhost:5001/auth-service:<run-number>`
- Example: `localhost:5001/auth-service:13`

#### **4. Push to Local Registry**
```yaml
- name: Push to local registry
  run: |
    docker push localhost:5001/auth-service:${{ github.run_number }}
```
Pushes the newly built image to the local Docker registry at `localhost:5001`.

#### **5. Update Helm Chart Values**
```yaml
- name: Bump Helm chart image tag
  run: |
    sed -i "s/tag:.*/tag: ${{ github.run_number }}/" ./auth-chart/values.yaml
```
Updates `auth-chart/values.yaml` with the new image tag:
```yaml
image:
  repository: localhost:5001/auth-service
  tag: "13"  # Updated from previous tag
```

#### **6. Commit & Push Chart Update**
```yaml
- name: Commit & push Helm chart update
  run: |
    git config user.name "github-actions"
    git config user.email "actions@github.com"
    git add ./auth-chart/values.yaml
    git commit -m "Update image tag to ${{ github.run_number }}"
    git push
```
Commits the updated `values.yaml` back to the `main` branch.

---

### **Step 7–10: ArgoCD Sync & Deployment**

**ArgoCD Configuration:** `argocd-app.yaml` (points to `auth-chart/` and watches `main` branch)

#### **7. ArgoCD Detects Git Change**
- ArgoCD continuously watches the GitHub repository `main` branch (polling or webhook)
- Detects the new commit with the updated `values.yaml`
- Compares desired state (Git) with actual state (Kubernetes cluster)

#### **8. Sync Application**
```
ArgoCD Application Status: OutOfSync → Syncing → Synced
```
- ArgoCD fetches the updated Helm chart
- Renders the Helm templates with the new `values.yaml`
- Generates Kubernetes manifests with the new image tag

#### **9. Apply Manifests to Cluster**
```yaml
# Generated Deployment manifest (example)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service-auth-chart
spec:
  template:
    spec:
      containers:
      - name: auth-service
        image: localhost:5001/auth-service:13  # ← Updated tag
        ports:
        - containerPort: 3000
```
Applies the new manifests to the Kubernetes cluster.

#### **10. Pod Updated**
- Kubernetes pulls the new image `localhost:5001/auth-service:13`
- Creates a new pod with the updated application
- Old pod is gracefully terminated
- Service automatically routes traffic to the new pod

---

## 🔧 Key Configuration Files

### **1. `.github/workflows/deploy.yml`**
**Purpose:** GitHub Actions workflow definition  
**Trigger:** Push to `main` with changes in `auth-service/**`  
**Actions:** Build, push image, update Helm chart, commit & push

```yaml
on:
  push:
    branches:
      - main
    paths:
      - "auth-service/**"
```

### **2. `auth-chart/values.yaml`**
**Purpose:** Helm chart default values  
**Updated by:** GitHub Actions workflow  
**Contains:** Image repository, tag, service port, replicas, etc.

```yaml
image:
  repository: localhost:5001/auth-service
  tag: "13"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 3000
```

### **3. `auth-chart/templates/deployment.yaml`**
**Purpose:** Kubernetes Deployment template  
**Rendered by:** Helm using values from `values.yaml`  
**Output:** Manifest with the specified image tag

```yaml
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```
Becomes: `image: localhost:5001/auth-service:13`

### **4. ArgoCD Application** (managed via ArgoCD UI or manifest)
**Purpose:** Defines what to deploy and how  
**Configuration:**
- **Git Repository:** https://github.com/AndreLiar/devopslocally.git
- **Branch:** main
- **Path:** auth-chart/
- **Sync Policy:** Auto sync enabled
- **Destination:** Kubernetes cluster (local)

---

## 🧪 Testing the Pipeline Locally

### **1. Make a Change**
```bash
cd auth-service
nano server.js
# Edit the response message
git add server.js
git commit -m "test: update message"
git push origin main
```

### **2. Monitor GitHub Actions**
```
Visit: https://github.com/AndreLiar/devopslocally/actions
```
Watch the workflow run through all steps.

### **3. Check ArgoCD**
```bash
# Port-forward ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access: https://localhost:8080
# Login with default credentials
```

### **4. Verify Deployment**
```bash
# Check pod status
kubectl get pods -n default -l app.kubernetes.io/name=auth-chart

# Describe pod to see new image
kubectl describe pod -n default -l app.kubernetes.io/name=auth-chart

# Port-forward service
kubectl port-forward service/auth-service-auth-chart 3000:3000

# Test in another terminal
curl http://localhost:3000
# Should see: ✅ Auth Service v2.1 — triggered pipeline!
```

---

## 📊 Status Indicators

### **GitHub Actions**
- ✅ **Success** — Image built, pushed, chart updated, changes committed
- ❌ **Failure** — Check logs in Actions tab for details (Docker build failed, push error, etc.)

### **ArgoCD**
- 🟢 **Synced** — Cluster state matches Git state
- 🟡 **OutOfSync** — Git has changes not yet applied to cluster
- 🔴 **Error** — Sync failed (invalid manifest, resource conflict, etc.)

### **Kubernetes**
- ✅ **Running** — Pod is healthy and serving traffic
- ⏳ **Pending** — Pod is being scheduled
- ❌ **CrashLoopBackOff** — Application error or missing image

---

## 🔐 Security & Best Practices

1. **Image Registry Authentication**
   - Currently using `localhost:5001` (local/internal)
   - For production: Use `imagePullSecrets` with credentials for private registries

2. **Git Credentials**
   - GitHub Actions uses built-in `GITHUB_TOKEN`
   - For custom repos: Add `secrets.GITHUB_TOKEN` to workflow

3. **Auto Sync**
   - ArgoCD auto sync is enabled (recommended for GitOps)
   - Can be set to manual for controlled deployments

4. **Helm Chart Versioning**
   - Tag charts in `Chart.yaml` for production releases
   - Example: `version: 1.0.0`

---

## 🚨 Troubleshooting

### **GitHub Actions Fails**
```bash
# Check workflow logs
# Visit: https://github.com/AndreLiar/devopslocally/actions
# Click failed workflow → See error details
```

### **ArgoCD Shows OutOfSync**
```bash
# Manual sync from UI or CLI
argocd app sync auth-service

# Or wait — ArgoCD syncs every 3 minutes by default
```

### **Pod Not Starting**
```bash
# Check pod logs
kubectl logs -n default -l app.kubernetes.io/name=auth-chart

# Describe pod for events
kubectl describe pod -n default -l app.kubernetes.io/name=auth-chart
```

### **Image Not Found**
```bash
# Verify image exists in registry
docker images | grep auth-service

# Check if registry is running
docker ps | grep registry
```

---

## 🎯 Summary

| Step | Component | Action | Status |
|------|-----------|--------|--------|
| 1 | Developer | Push code to `main` | ✅ |
| 2-6 | GitHub Actions | Build, push image, update chart | ✅ |
| 7-8 | ArgoCD | Detect change, sync app | ✅ |
| 9-10 | Kubernetes | Apply manifests, update pods | ✅ |

**Result:** Your application is automatically deployed with zero downtime using GitOps principles!

---

## 📚 References

- **GitHub Actions:** https://github.com/features/actions
- **ArgoCD:** https://argoproj.github.io/cd/
- **Helm:** https://helm.sh/
- **Kubernetes:** https://kubernetes.io/

---

**Last Updated:** November 5, 2025  
**Maintained by:** DevOps Team
