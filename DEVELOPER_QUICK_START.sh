#!/usr/bin/env bash

# DEVELOPER QUICK START GUIDE
# ==========================
# Everything you need to build and deploy services

cat << 'EOF'

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                    👨‍💻 DEVELOPER QUICK START GUIDE 👨‍💻                    ║
║                                                                              ║
║              You focus on building services.                                 ║
║              We handle everything else automatically.                        ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝


📋 WHAT YOU NEED TO KNOW
════════════════════════════════════════════════════════════════════════════════

✅ You build services (write code)
✅ You commit and push to git
✅ Everything else is automatic:
   • Docker builds
   • Kubernetes deployments
   • Multi-environment scaling
   • Health checks
   • Monitoring
   • Auto-scaling
   • Rollbacks

❌ You DON'T need to know Kubernetes
❌ You DON'T need to know kubectl commands
❌ You DON'T need to understand Docker networking
❌ You DON'T need to manage infrastructure


🎯 YOUR WORKFLOW (LITERALLY 4 COMMANDS)
════════════════════════════════════════════════════════════════════════════════

Step 1: ONE-TIME SETUP (20 minutes)
──────────────────────────────────

   $ ./scripts/setup-cluster.sh

   ✓ Creates Kubernetes cluster
   ✓ Installs all tools
   ✓ Verifies everything works
   ✓ Sets up GitOps


Step 2: BUILD YOUR SERVICE (Your code)
──────────────────────────────────────

   $ vim auth-service/server.js       # Edit your code
   $ npm install new-package          # Add dependencies
   $ npm test                         # Test locally


Step 3: COMMIT & PUSH (1 command to deploy!)
──────────────────────────────────────────

   $ git add -A
   $ git commit -m "feat: new feature"
   $ git push origin dev              # Deploy to development!


Step 4: WAIT 3-8 MINUTES
────────────────────────

   Automatic magic:
   • GitHub Actions builds Docker image
   • ArgoCD detects change
   • Kubernetes deploys new version
   • Health checks verify it works
   
   Check status:
   $ ./scripts/multi-env-manager.sh status


THAT'S IT! 🎉
═════════════

Your service is live! No kubectl. No manual deployment. Just git push.


🚀 DEPLOY TO DIFFERENT ENVIRONMENTS
════════════════════════════════════════════════════════════════════════════════

Development (instant, for testing):
   $ git push origin dev
   → Deploys to: development namespace
   → Replicas: 1
   → Update speed: Instant


Staging (pre-production, for integration testing):
   $ git push origin staging
   → Deploys to: staging namespace
   → Replicas: 2
   → Update speed: 2-3 minutes


Production (live service, user traffic):
   $ git push origin main
   → Deploys to: production namespace
   → Replicas: 3+
   → Update speed: 3-8 minutes


💡 THAT'S LITERALLY IT
════════════════════════════════════════════════════════════════════════════════

Branch        → Environment        → Automatic Deployment
──────────────────────────────────────────────────────────
dev           → development         ✅ Instant
staging       → staging             ✅ 2-3 minutes
main (master) → production          ✅ 3-8 minutes


📝 COMMON DEVELOPER TASKS
════════════════════════════════════════════════════════════════════════════════

TASK 1: Update your service code
────────────────────────────────

$ vim auth-service/server.js
$ git add auth-service/
$ git commit -m "fix: bug fix"
$ git push origin dev

✅ Automatic: Docker rebuild → Deployment → Health check


TASK 2: Add a npm dependency
──────────────────────────

$ cd auth-service
$ npm install express-cors
$ git add package*.json
$ git commit -m "feat: add cors"
$ git push origin dev

✅ Automatic: npm install in Docker → Deployment


TASK 3: Change configuration (no code change)
──────────────────────────────────────────

$ vim helm/auth-service/values-dev.yaml
# Change: replicas, memory, CPU, env vars, etc.

$ git add helm/auth-service/values-dev.yaml
$ git commit -m "config: increase replicas"
$ git push origin dev

✅ Automatic: Kubernetes updates → Pods restart → Health check


TASK 4: Scale your service in production
──────────────────────────────────────

$ vim helm/auth-service/values-prod.yaml
# Change: replicas: 3 → replicas: 5

$ git add helm/auth-service/values-prod.yaml
$ git commit -m "ops: scale to 5 replicas"
$ git push origin main

✅ Automatic: 2 new pods start → Load balancer updates


TASK 5: Rollback a bad deployment
──────────────────────────────────

$ git revert HEAD
$ git push origin main

✅ Automatic: Kubernetes rolls back to previous version (1-2 min)


🔍 CHECKING STATUS
════════════════════════════════════════════════════════════════════════════════

Quick status of all environments:
$ ./scripts/multi-env-manager.sh status

Detailed info for one environment:
$ ./scripts/multi-env-manager.sh details dev

Live logs:
$ kubectl logs -f deployment/auth-service -n development

Watch pods restart:
$ kubectl get pods -n development -w


❓ FAQ FOR DEVELOPERS
════════════════════════════════════════════════════════════════════════════════

Q: Do I need to know Kubernetes?
A: No! You just need:
   • git push (to deploy)
   • git revert (to rollback)
   • That's it!

Q: What if my deployment fails?
A: You'll see the error. Fix it and:
   $ git push origin dev
   (Automatic retry, usually works second time)

Q: Can I test locally before pushing?
A: Yes! Do this first:
   $ cd auth-service
   $ npm install && npm start
   $ curl http://localhost:3000/health
   Then push when ready.

Q: How long does deployment take?
A: Typically:
   • Development: 1-2 minutes
   • Staging: 2-3 minutes
   • Production: 3-8 minutes (includes safety checks)

Q: Can I rollback quickly?
A: Yes! Within 30 seconds:
   $ git revert HEAD && git push origin main
   (Automatic rollback in 1-2 minutes)

Q: What if multiple developers push at same time?
A: No problem! Git queues them:
   • Each push creates a deployment
   • They execute sequentially
   • All tracked in Git history
   • Latest change wins

Q: Can I change config without rebuilding?
A: Yes! Edit values-*.yaml files:
   $ vim helm/auth-service/values-dev.yaml
   $ git push origin dev
   (Instant update, no Docker rebuild)

Q: Where do I find my service?
A: After deployment:
   $ ./scripts/multi-env-manager.sh status
   (Shows URLs for each environment)

Q: Do I need to write Kubernetes YAML?
A: No! All YAML is pre-configured.
   Just use Helm values to customize.

Q: What if I need different config per environment?
A: Easy! Each environment has its own values file:
   helm/auth-service/values-dev.yaml
   helm/auth-service/values-staging.yaml
   helm/auth-service/values-prod.yaml
   
   Update any, push, automatic deployment!


✨ WHAT HAPPENS WHEN YOU GIT PUSH
════════════════════════════════════════════════════════════════════════════════

Your git push origin main
        ↓
GitHub Actions triggered
        ↓
Docker image built
        ↓
Image pushed to registry
        ↓
Helm values updated with new tag
        ↓
Git commit created
        ↓
ArgoCD detects change (within 3 minutes)
        ↓
Kubernetes deployment updated
        ↓
New pods start with new image
        ↓
Health checks verify it works
        ↓
✅ Service live!

Total time: 3-8 minutes
Manual steps: 0
Error recovery: Automatic


🎓 LEARNING PATH
════════════════════════════════════════════════════════════════════════════════

Week 1: Learn the basics
────────────────────────
✓ Run setup-cluster.sh (one-time)
✓ Edit a file in auth-service
✓ Push to dev
✓ Watch it deploy
✓ Check status

Week 2: Build confidence
─────────────────────────
✓ Add a new endpoint
✓ Deploy to dev → staging → production
✓ Test in each environment
✓ Try a rollback
✓ Change configuration

Week 3: Add new services
────────────────────────
✓ Copy auth-service template
✓ Create new service
✓ Deploy to all environments
✓ Monitor performance

Week 4: Advanced (optional)
───────────────────────────
✓ Customize Helm values per environment
✓ Setup monitoring alerts
✓ Configure database backups
✓ Learn Kubernetes concepts (if curious)


🎯 NEXT STEPS
════════════════════════════════════════════════════════════════════════════════

1. Read: docs/DEVELOPER_GUIDE.md (20 min)
   ├─ Detailed examples
   ├─ Common tasks
   ├─ Architecture explanation
   └─ Everything you need to know

2. Run: ./scripts/setup-cluster.sh (20 min, one-time)
   ├─ Creates your Kubernetes cluster
   ├─ Installs all tools
   └─ Sets up GitOps

3. Deploy: git push origin dev (1 command)
   ├─ Automatic Docker build
   ├─ Automatic Kubernetes deployment
   └─ Automatic health checks

4. Check: ./scripts/multi-env-manager.sh status (1 command)
   ├─ See all services
   ├─ See their status
   └─ See their URLs


💬 REMEMBER
════════════════════════════════════════════════════════════════════════════════

✅ You focus on writing code
✅ Git handles everything else
✅ No Kubernetes knowledge needed
✅ No manual deployment needed
✅ Automatic rollbacks if needed
✅ Monitoring is automatic
✅ Scaling is automatic

You're literally just a developer now.
Enjoy! 🚀


📚 DETAILED DOCS
════════════════════════════════════════════════════════════════════════════════

Need more help?
• Developer Guide: docs/DEVELOPER_GUIDE.md
• General Info: AUTOMATION_INDEX.md
• Troubleshooting: docs/AUTOMATED_SETUP_GUIDE.md
• ArgoCD Details: docs/ARGOCD_SETUP_GUIDE.md


═══════════════════════════════════════════════════════════════════════════════

READY TO BUILD? 🚀

$ ./scripts/setup-cluster.sh     # One-time setup
$ git push origin dev             # Deploy!

═══════════════════════════════════════════════════════════════════════════════

EOF
