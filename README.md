# 🚀 DevOps Lab - Complete Kubernetes Setup Made Easy

Welcome! This project helps you set up a **production-ready Kubernetes environment** on your computer—automatically.

**No prior experience needed.** Just follow the steps below.

---

## 🎯 What Is This?

Think of this as a **complete starter kit** for running applications in Kubernetes (a popular platform for running software). It includes:

- **Kubernetes**: The system that runs your applications
- **Docker**: The tool that packages applications
- **Grafana & Prometheus**: Tools to monitor how your applications are performing
- **ArgoCD**: Automation for deploying updates
- **Everything automated**: One command sets it all up

---

## ⏱️ Time Commitment

- **Total setup time**: ~40 minutes
- **Reading time**: ~10 minutes
- **Hands-on time**: ~30 minutes
- **Then you're done!** Your environment is ready to use.

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

## 🚀 Getting Started (30 Minutes)

### Step 1: Get This Project (1 minute)

```bash
# Download this project
git clone https://github.com/AndreLiar/devopslocally.git
cd devopslocally
```

### Step 2: Check Your Environment (2 minutes)

```bash
# Run this to verify everything is set up correctly
./scripts/check-prerequisites.sh
```

You should see **✅ checkmarks** next to everything. If you see ❌, don't worry—the script will tell you what to install.

### Step 3: Run the Automatic Setup (20 minutes)

This is the **magic command** that sets everything up for you:

```bash
make setup
```

**What happens behind the scenes:**
- Creates namespaces (logical sections for your applications)
- Installs monitoring tools (Prometheus, Grafana)
- Sets up deployment automation (ArgoCD)
- Prepares Docker registry (for storing application images)
- Starts a sample application (to show you it works)

**Just wait** while it runs. You'll see progress messages. Grab a coffee ☕

### Step 4: Access Your Environment (5 minutes)

Once setup completes, you can see everything working:

```bash
# Open these in your web browser:
make port-forward
```

Then open these URLs in your browser:

| What | URL | Username | Password |
|------|-----|----------|----------|
| **Monitoring Dashboard** | http://localhost:3000 | admin | admin123 |
| **Metrics Database** | http://localhost:9090 | (no login) | — |
| **Deployment Tool** | http://localhost:8080 | admin | admin123 |

You can now **see your applications running** and **monitor their health**! 🎉

---

## 📚 Common Questions

### Q: "What's Kubernetes?"
**A:** It's a tool that automatically manages where and how your applications run. Think of it like an intelligent scheduler for your applications.

### Q: "Do I need to know Docker?"
**A:** No! We've set up examples. You can learn as you go.

### Q: "Can I run multiple applications?"
**A:** Yes! The system is designed for that. See the "Next Steps" section below.

### Q: "What if something breaks?"
**A:** We have a troubleshooting guide. See section **"When Things Don't Work"** below.

### Q: "Can I use this in production?"
**A:** Yes, but you'll need to customize it for your needs. See the documentation for advanced guides.

---

## 🎯 Next Steps (After Setup)

### Want to Deploy Your Own Application?

1. **Read this first** (takes 5 minutes):
   ```bash
   cat DEVELOPER_GUIDE.md
   ```

2. **See the example** (already running):
   - Application: `auth-service/` (a simple Node.js example)
   - Helm configuration: `helm/auth-service/` (Kubernetes setup)

3. **Copy and modify** the example for your application

### Want to Monitor Your Applications?

1. **Open Grafana** (the dashboard):
   - URL: http://localhost:3000
   - Look for pre-built dashboards (Kubernetes, Node metrics, etc.)
   - Add your own metrics

2. **See logs from your apps**:
   ```bash
   kubectl logs -f deployment/auth-service
   ```

### Want to Understand the System Better?

- **Quick explanation** (5 min): Read `POST_CLONE_GUIDE.md`
- **Detailed explanation** (20 min): Read `docs/ARCHITECTURE.md`
- **How deployment works** (10 min): Read `docs/GITOPS_PIPELINE.md`

---

## 🆘 When Things Don't Work

### Problem: "The setup command failed"

**Try this:**
```bash
./scripts/check-prerequisites.sh
```
This will tell you exactly what's missing.

### Problem: "I can't access the dashboard"

**Try this:**
```bash
# Start port forwarding
make port-forward

# Then check if services are running
kubectl get pods
```

### Problem: "Something else broke"

**Read the guide:**
```bash
cat docs/TROUBLESHOOTING.md
```

**Or ask for help:**
- Check the issue tracker on GitHub
- Read the FAQ (see below)

---

## ❓ FAQ (Frequently Asked Questions)

**Q: Can I stop everything and start fresh?**
```bash
make teardown
# Then run: make setup
```

**Q: How do I see what's running?**
```bash
kubectl get pods -A
```

**Q: How do I check if everything is working?**
```bash
make status
```

**Q: Where do I put my own applications?**
1. Create a folder: `auth-service-2/`
2. Copy the structure from `auth-service/`
3. Modify it for your application
4. Deploy with Helm

**Q: How do I update my application?**
1. Make changes to your code
2. Rebuild the Docker image
3. Deploy: `helm upgrade ...`

**Q: Can I use this with cloud platforms?**
Yes! It works with:
- AWS (EKS)
- Google Cloud (GKE)
- Microsoft Azure (AKS)
- Any Kubernetes cluster

---

## 📖 Documentation for Different Audiences

### 👨‍💼 **Project Managers / Decision Makers**
→ Start here: `docs/ARCHITECTURE.md` (5-minute overview)

### 👨‍💻 **Developers**
→ Start here: `DEVELOPER_GUIDE.md` (learns how to deploy)

### 🏗️ **DevOps / Infrastructure Engineers**
→ Start here: `docs/MULTI_ENVIRONMENT_SETUP.md` (advanced setup)

### 🪟 **Windows Users**
→ Start here: `docs/WINDOWS_WSL2_SETUP.md` (Windows-specific guide)

### 🆘 **Troubleshooting**
→ Start here: `docs/TROUBLESHOOTING.md` (solutions to common issues)

### 🗺️ **Lost?**
→ Start here: `DOCUMENTATION_INDEX.md` (find what you need)

---

## 🎓 Learning Path (If You're New to This)

**Week 1:**
- [ ] Complete "Getting Started" above
- [ ] Access all three dashboards (Grafana, Prometheus, ArgoCD)
- [ ] Read `DEVELOPER_GUIDE.md`

**Week 2:**
- [ ] Read `docs/ARCHITECTURE.md` (understand the system)
- [ ] Read `docs/GITOPS_PIPELINE.md` (understand deployments)
- [ ] Try deploying a simple change

**Week 3:**
- [ ] Create your first custom application
- [ ] Deploy it to your Kubernetes environment
- [ ] Monitor it with Grafana

**Week 4+:**
- [ ] Explore advanced features
- [ ] Customize for your needs
- [ ] Integrate with your CI/CD pipeline

---

## ✨ What You Get

| Feature | What It Does |
|---------|-------------|
| **Kubernetes** | Runs your applications automatically |
| **Docker** | Packages your applications |
| **Grafana** | Shows dashboards of how your apps are performing |
| **Prometheus** | Collects performance metrics |
| **ArgoCD** | Automatically deploys updates when you push code |
| **Helm** | Packages and deploys your applications |
| **Loki** | Collects and stores logs from your applications |

---

## 🚀 Quick Commands (Cheat Sheet)

```bash
# Setup
make setup              # Run automatic setup
make check-prerequisites  # Verify installation
make port-forward       # Access dashboards locally

# Monitoring
make status            # See what's running
kubectl get pods       # List all running applications
kubectl logs -f <pod>  # Watch application logs
open http://localhost:3000  # Open Grafana

# Cleanup
make teardown          # Stop everything
make reset             # Start fresh

# Help
make help              # Show all commands
cat DEVELOPER_GUIDE.md # Developer documentation
```

---

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
