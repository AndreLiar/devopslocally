#!/bin/bash

################################################################################
# Quick Start - Complete Automation Demo
# This script shows you exactly what to run
################################################################################

cat << 'EOF'

╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║          🚀 COMPLETE DEVOPS AUTOMATION - QUICK START GUIDE 🚀            ║
║                                                                            ║
║                    Everything is now FULLY AUTOMATED!                      ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝


┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ PHASE 1: AUTOMATED PREREQUISITES INSTALLATION                              ┃
┃ Duration: 15-30 minutes                                                    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

This script automatically:
  ✅ Detects your operating system
  ✅ Installs kubectl (Kubernetes CLI)
  ✅ Installs Helm (Kubernetes package manager)
  ✅ Installs git (version control)
  ✅ Creates/starts Kubernetes cluster (minikube locally)
  ✅ Verifies everything is working

Run this ONCE:

    cd devopslocally
    ./scripts/setup-cluster.sh

Options:
    # Auto-detect everything (recommended)
    ./scripts/setup-cluster.sh

    # Force Minikube with more resources
    ./scripts/setup-cluster.sh --cluster-type minikube --minikube-cpus 8 --minikube-memory 16384

    # Use existing cluster (Docker Desktop, EKS, GKE, etc.)
    ./scripts/setup-cluster.sh --cluster-type existing

Expected output:
    ✅ kubectl is already installed
    ✅ Helm is already installed
    ✅ git is already installed
    ✅ Minikube cluster is running
    ✅ Kubernetes cluster connected


┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ PHASE 2: MULTI-ENVIRONMENT SETUP                                           ┃
┃ Duration: 2 minutes                                                        ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

This script automatically:
  ✅ Creates 3 Kubernetes namespaces
  ✅ Sets resource quotas
  ✅ Configures networking

Run this ONCE (after Phase 1):

    ./scripts/multi-env-manager.sh setup

What gets created:
    • development namespace  (for dev branch)
    • staging namespace      (for staging branch)
    • production namespace   (for main branch)

Expected output:
    ✅ Namespace development configured
    ✅ Namespace staging configured
    ✅ Namespace production configured


┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ PHASE 3: VERIFY EVERYTHING IS READY                                       ┃
┃ Duration: 1 minute                                                         ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

Verify your setup:

    ./scripts/multi-env-manager.sh status

Expected output:
    ✅ DEVELOPMENT NAMESPACE
       • Deployments: 0
       • Pods: 0
       • Services: 0
       • CPU Used: 0m / 10000m
       • Memory Used: 0Mi / 20Gi

    ✅ STAGING NAMESPACE
       • Deployments: 0
       • Pods: 0
       • Services: 0
       • CPU Used: 0m / 20000m
       • Memory Used: 0Mi / 40Gi

    ✅ PRODUCTION NAMESPACE
       • Deployments: 0
       • Pods: 0
       • Services: 0
       • CPU Used: 0m / 20000m
       • Memory Used: 0Mi / 40Gi


┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ PHASE 4: DEPLOY APPLICATIONS                                               ┃
┃ Duration: 3-8 minutes (depending on environment)                           ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

Now deployment is FULLY AUTOMATED! Just push code:

Deploy to Development (1 replica):
    git push origin dev

Deploy to Staging (2 replicas):
    git push origin staging

Deploy to Production (3 replicas):
    git push origin main

What happens automatically:
    1. GitHub Actions detects the push
    2. Determines which branch was pushed
    3. Maps to correct environment:
       • dev branch        → development namespace
       • staging branch    → staging namespace
       • main branch       → production namespace
    4. Deploys application with correct configuration:
       • Correct number of replicas
       • Correct resource limits
       • Correct ConfigMaps & Secrets
    5. Runs health checks
    6. Auto-rollback if anything fails

NO MORE MANUAL DEPLOYMENTS! 🎉


┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ ONGOING OPERATIONS - MONITORING & MANAGEMENT                               ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

Monitor all environments:
    ./scripts/multi-env-manager.sh status

Get detailed information about specific environment:
    ./scripts/multi-env-manager.sh details development
    ./scripts/multi-env-manager.sh details staging
    ./scripts/multi-env-manager.sh details production

View pod logs:
    ./scripts/multi-env-manager.sh details development  # Includes pod logs

Compare configurations across environments:
    ./scripts/multi-env-manager.sh compare

Rollback to previous version (if needed):
    ./scripts/multi-env-manager.sh rollback development
    ./scripts/multi-env-manager.sh rollback staging
    ./scripts/multi-env-manager.sh rollback production


┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ COMPLETE AUTOMATION WORKFLOW                                               ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

Your new workflow (FULLY AUTOMATED):

    1. Write code
           ↓
    2. Commit changes
           git add .
           git commit -m "feature: something awesome"
           ↓
    3. Push to branch
           git push origin dev         # → development
           git push origin staging     # → staging
           git push origin main        # → production
           ↓
    4. GitHub Actions automatically:
           ✅ Runs tests
           ✅ Builds container image
           ✅ Deploys to correct environment
           ✅ Runs health checks
           ✅ Monitors deployment
           ↓
    5. Monitor with:
           ./scripts/multi-env-manager.sh status
           ↓
    6. If needed, rollback:
           ./scripts/multi-env-manager.sh rollback production

THAT'S IT! Everything else is automated! 🚀


┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ COMMAND REFERENCE - COPY & PASTE                                           ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# Initial Setup (run once)
./scripts/setup-cluster.sh
./scripts/multi-env-manager.sh setup

# Verify setup
./scripts/multi-env-manager.sh status

# Deploy (just push code!)
git push origin dev
git push origin staging
git push origin main

# Monitor
./scripts/multi-env-manager.sh status
./scripts/multi-env-manager.sh details development

# Rollback if needed
./scripts/multi-env-manager.sh rollback production


┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ ENVIRONMENT SPECIFICATIONS (AUTOMATIC)                                     ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

DEVELOPMENT (from dev branch):
    • Namespace: development
    • Replicas: 1
    • CPU: 250m request, 500m limit
    • Memory: 128Mi request, 256Mi limit
    • Database: 1 replica, 5Gi storage, no backups
    • Logging: DEBUG level
    • Health checks: Relaxed

STAGING (from staging branch):
    • Namespace: staging
    • Replicas: 2
    • CPU: 500m request, 1000m limit
    • Memory: 256Mi request, 512Mi limit
    • Database: 2 replicas, 20Gi storage, daily backups
    • Logging: INFO level
    • Health checks: Standard

PRODUCTION (from main branch):
    • Namespace: production
    • Replicas: 3 with auto-scaling (2-10)
    • CPU: 1000m request, 2000m limit
    • Memory: 512Mi request, 1Gi limit
    • Database: 2 replicas, 100Gi+ storage, hourly backups
    • Logging: WARNING level
    • Health checks: Strict


┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ DOCUMENTATION                                                               ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

For more detailed information, read:

    # Complete automation guide
    docs/COMPLETE_AUTOMATION_SUMMARY.md

    # Automated setup guide with troubleshooting
    docs/AUTOMATED_SETUP_GUIDE.md

    # Multi-environment detailed guide
    docs/MULTI_ENVIRONMENT_SETUP.md

    # Quick reference for operations
    docs/ENVIRONMENT_QUICK_REFERENCE.md


╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                           🎉 YOU'RE ALL SET! 🎉                          ║
║                                                                            ║
║                    Your DevOps infrastructure is now                        ║
║                         FULLY AUTOMATED!                                   ║
║                                                                            ║
║                   Run: ./scripts/setup-cluster.sh                          ║
║                         to get started!                                    ║
║                                                                            ║
║                      Time to deployment: 20-50 min                         ║
║                      Effort required: MINIMAL                              ║
║                      Reliability: MAXIMUM                                  ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝

EOF
