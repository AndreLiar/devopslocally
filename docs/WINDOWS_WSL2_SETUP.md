# 🪟 Windows WSL2 Setup Guide

**Complete step-by-step guide for running this DevOps template on Windows using WSL2**

**Last Updated:** November 5, 2025  
**Status:** Production Ready  
**Audience:** Windows Users, DevOps Engineers

---

## 📋 Table of Contents

1. [Quick Overview](#quick-overview)
2. [What is WSL2?](#what-is-wsl2)
3. [System Requirements](#system-requirements)
4. [Step-by-Step Setup](#step-by-step-setup)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)
7. [Daily Operations on Windows](#daily-operations-on-windows)
8. [Performance Tips](#performance-tips)
9. [Common Issues & Solutions](#common-issues--solutions)

---

## 🎯 Quick Overview

**YES! This system works on Windows!** ✅

You just need to use **Windows Subsystem for Linux 2 (WSL2)** - which is a lightweight Linux environment that runs on Windows.

**Why WSL2?**
- Kubernetes and Docker work best on Linux
- WSL2 gives you a real Linux kernel
- Near-native performance
- Seamless Windows ↔ Linux integration
- Free and built into Windows

**Time to Setup:** ~30 minutes (including downloads)

---

## 🐧 What is WSL2?

WSL2 is a compatibility layer that lets you run Linux on Windows.

**Think of it like this:**
```
Your Windows Computer
    ↓
WSL2 (Linux Environment)
    ↓
Docker, Kubernetes, Git (running in Linux)
    ↓
DevOps Template (works perfectly!)
```

**Key Benefits:**
- ✅ Runs actual Linux kernel
- ✅ Near-native performance
- ✅ All Linux tools work
- ✅ Can access Windows files
- ✅ Can run from Windows Terminal
- ✅ Can use Windows VS Code

---

## 📊 System Requirements

### Hardware
- **Processor:** Intel or AMD (released 2015 or later)
- **RAM:** Minimum 8GB (16GB recommended)
- **Disk:** 50GB free space recommended
- **Windows Version:** Windows 10 (version 2004+) or Windows 11

### Windows Features to Enable
- Hyper-V (or Virtual Machine Platform)
- Windows Subsystem for Linux

---

## 🚀 Step-by-Step Setup

### STEP 1: Enable WSL2 (5 minutes)

#### Option A: Automatic (Windows 10/11 - Recommended)

Open **PowerShell as Administrator** and run:

```powershell
# Enable WSL2 with everything you need in one command
wsl --install

# This installs:
# - WSL2
# - Ubuntu Linux distribution
# - Virtual Machine Platform
# - Necessary Windows features
```

**After running this:**
- Your computer will restart
- WSL2 will be set up
- Ubuntu will be installed

#### Option B: Manual Step-by-Step (if Option A doesn't work)

1. **Open PowerShell as Administrator:**
   - Press `Windows Key + R`
   - Type `powershell`
   - Right-click → "Run as Administrator"

2. **Enable Virtual Machine Platform:**
   ```powershell
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

3. **Enable Windows Subsystem for Linux:**
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   ```

4. **Restart your computer:**
   ```powershell
   Restart-Computer
   ```

5. **Set WSL2 as default:**
   ```powershell
   wsl --set-default-version 2
   ```

6. **Install Ubuntu:**
   ```powershell
   wsl --install -d Ubuntu
   ```

---

### STEP 2: Start Ubuntu & Create User Account (3 minutes)

After WSL2 installation completes:

1. **Open Ubuntu** (search "Ubuntu" in Windows Start menu, or in Windows Terminal select Ubuntu tab)

2. **First launch will take 1-2 minutes to initialize**

3. **Create your Linux username and password:**
   ```bash
   Enter new UNIX username: myusername
   New password: (type your password)
   Retype new password: (confirm password)
   ```

4. **Verify you're in Ubuntu:**
   ```bash
   uname -a
   # Should show: Linux xxxxx 5.10.16 ... x86_64 GNU/Linux
   ```

✅ **WSL2 is now ready!**

---

### STEP 3: Update Ubuntu System (5 minutes)

Inside your Ubuntu terminal:

```bash
# Update package lists
sudo apt-get update

# Upgrade installed packages
sudo apt-get upgrade -y

# Install essential tools
sudo apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    jq
```

---

### STEP 4: Clone the DevOps Template (2 minutes)

Inside Ubuntu terminal:

```bash
# Create a projects directory
mkdir ~/projects
cd ~/projects

# Clone the repository
git clone https://github.com/YOUR_USERNAME/devopslocally.git
cd devopslocally

# Verify it cloned successfully
ls -la
```

---

### STEP 5: Run the Automated Setup (15 minutes)

Still in the Ubuntu terminal:

```bash
# Make setup script executable
chmod +x scripts/setup-cluster.sh

# Run the setup script
./scripts/setup-cluster.sh
```

**What this does automatically:**
- ✅ Detects you're on Linux (WSL2)
- ✅ Installs Docker
- ✅ Installs kubectl
- ✅ Installs Helm
- ✅ Installs Kind (or minikube)
- ✅ Creates Kubernetes cluster
- ✅ Sets up namespaces
- ✅ Configures everything

**Expected output:**
```
✅ Checking prerequisites...
✅ Installing Docker...
✅ Installing Kubernetes tools...
✅ Creating cluster...
✅ Setting up namespaces...
✅ Verifying installation...
✅ Setup complete!
```

---

### STEP 6: Initialize Multi-Environment Infrastructure (5 minutes)

```bash
# Make script executable
chmod +x scripts/multi-env-manager.sh

# Setup multi-environment infrastructure
./scripts/multi-env-manager.sh setup

# Verify everything is ready
./scripts/multi-env-manager.sh status
```

**Expected output:**
```
✅ Development namespace ready
✅ Staging namespace ready
✅ Production namespace ready
✅ Resource quotas configured
```

---

## ✅ Verification

### Verify Everything is Working

```bash
# Check Kubernetes cluster
kubectl cluster-info

# Expected output:
# Kubernetes control plane is running...
# DNS is running...

# Check nodes
kubectl get nodes

# Expected output:
# NAME       STATUS   ROLES    AGE   VERSION
# kindXXXX   Ready    master   5m    vX.XX.X

# Check namespaces
kubectl get namespaces

# Expected output should include:
# development
# staging
# production

# Check pods
kubectl get pods -A

# Should show various running pods
```

---

## 🪟 Daily Operations on Windows

### Starting Your Work Day

1. **Open Windows Terminal** (built-in on Windows 11, or install from Microsoft Store)

2. **Select Ubuntu tab** (or it opens by default)

3. **Navigate to your project:**
   ```bash
   cd ~/projects/devopslocally
   ```

4. **Check cluster status:**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

5. **Start developing!**

### Accessing Windows Files from WSL2

Your Windows files are available at:

```bash
# Navigate to Windows user directory
cd /mnt/c/Users/YOUR_USERNAME/

# Navigate to Desktop
cd /mnt/c/Users/YOUR_USERNAME/Desktop/

# Navigate to Documents
cd /mnt/c/Users/YOUR_USERNAME/Documents/
```

### Accessing WSL2 Files from Windows

Your Ubuntu files are available at:

- In File Explorer: `\\wsl$\Ubuntu\home\YOUR_USERNAME\`
- Easy access in Windows Terminal

### Port Forwarding (For Local Access)

When you run services in WSL2, you can access them from Windows:

```bash
# Port 8080 in WSL2 is accessible at:
# http://localhost:8080 on Windows

# Example: Access Kubernetes Dashboard
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443
# Then open: https://localhost:8443 on Windows
```

---

## ⚡ Performance Tips

### Tip 1: Use WSL2 File System (Faster)

**✅ DO THIS (Fast):**
```bash
cd ~/projects/devopslocally    # In /home directory
# File operations are fast here
```

**❌ AVOID THIS (Slow):**
```bash
cd /mnt/c/Users/YourName/...   # In Windows directory
# File operations are slower here
```

**Best Practice:** Keep your code in WSL2 file system (`~/projects/`), not in Windows directories.

### Tip 2: Allocate Enough Resources

Edit `%USERPROFILE%\.wslconfig` on Windows (create if doesn't exist):

```ini
[wsl2]
# Increase memory for better performance
memory=8GB
# Use 4 CPU cores
processors=4
# Swap memory
swap=4GB
```

Then restart WSL2:
```powershell
# In PowerShell (as Administrator)
wsl --shutdown
wsl
```

### Tip 3: Keep WSL2 Updated

Regularly update the Linux kernel:

```powershell
# In PowerShell (as Administrator)
wsl --update
```

---

## 🔧 Troubleshooting

### Issue 1: "WSL 2 requires update to its kernel component"

**Solution:**
```powershell
# In PowerShell (as Administrator)
wsl --update
```

### Issue 2: "Docker daemon is not running"

**Solution - Inside Ubuntu:**
```bash
# Docker might not auto-start in WSL2
sudo service docker start

# Or use the Docker Desktop app:
# 1. Install Docker Desktop from docker.com
# 2. Enable WSL2 integration in Docker settings
# 3. Restart Docker
```

### Issue 3: "Cannot connect to Kubernetes cluster"

**Solution:**
```bash
# Check if cluster is running
kind get clusters

# If no clusters, create one:
kind create cluster

# If still issues, restart everything:
kind delete cluster
./scripts/setup-cluster.sh
```

### Issue 4: "Permission denied" errors

**Solution:**
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Or run with bash explicitly
bash scripts/setup-cluster.sh
```

### Issue 5: "Out of disk space"

**Solution:**
```bash
# Check WSL2 disk usage
df -h

# Clean up Docker
docker system prune -a

# Clean up Kind
kind delete cluster

# If still full, increase WSL2 disk size in .wslconfig:
# [wsl2]
# maxSize=200GB  # Increase as needed
```

### Issue 6: "Port 8080/3000/etc already in use"

**Solution:**
```bash
# Find process using port
netstat -ano | findstr :8080

# Kill the process (replace 12345 with PID)
taskkill /PID 12345 /F

# Or choose a different port:
kubectl port-forward svc/myservice 9000:8080
```

---

## 🔄 Common Issues & Solutions

### Performance is Slow

```bash
# Check if running from Windows directory
pwd
# If it shows /mnt/c/... - MOVE YOUR PROJECT to /home

# Move to WSL2 filesystem
mkdir -p ~/projects
cp -r /mnt/c/Users/YourName/devopslocally ~/projects/
cd ~/projects/devopslocally
```

### Can't Find kubectl/helm/docker

```bash
# May not be in PATH yet, restart terminal:
exit
# Close Ubuntu and reopen

# Or manually add to PATH:
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
```

### Git Credentials Not Working

```bash
# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Set up credential helper
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"
```

### WSL2 Takes Too Much RAM

```bash
# Edit .wslconfig
notepad $env:USERPROFILE\.wslconfig

# Set memory limit:
[wsl2]
memory=4GB
```

Then restart:
```powershell
wsl --shutdown
```

---

## 📚 Additional Resources

### Windows Terminal Setup (Optional but Recommended)

Windows Terminal is a modern terminal for Windows:

1. **Install from Microsoft Store:** Search "Windows Terminal"
2. **Or use winget:**
   ```powershell
   winget install Microsoft.WindowsTerminal
   ```

### Enable WSL2 Better Integration

In **Windows Terminal settings.json**:
```json
{
    "profiles": {
        "defaults": {
            "fontFace": "Cascadia Code",
            "fontSize": 11
        }
    }
}
```

### VS Code with WSL2

1. **Install VS Code:** https://code.visualstudio.com
2. **Install Remote WSL Extension:** Search "Remote - WSL" in Extensions
3. **Open project in WSL:**
   ```bash
   cd ~/projects/devopslocally
   code .
   ```

---

## ✨ You're All Set!

Once setup is complete, your Windows machine will have:

✅ Full Linux environment (WSL2)  
✅ Docker running natively  
✅ Kubernetes cluster ready  
✅ Helm configured  
✅ DevOps template ready to use  
✅ Git version control  
✅ All automation scripts working  

**Next Steps:**
1. Follow `SETUP_SEQUENCE.md` starting from Phase 4 (Build Services)
2. Use `DOCUMENTATION_INDEX.md` to find what you need
3. Check `SETUP_CHECKLIST.md` for verification
4. Enjoy full DevOps infrastructure on your Windows machine! 🎉

---

## 🆘 Need Help?

- **WSL2 Issues:** See Troubleshooting section above
- **Docker Issues:** Check Docker Desktop settings
- **Kubernetes Issues:** Refer to `docs/TROUBLESHOOTING.md`
- **Setup Issues:** Check `SETUP_CHECKLIST.md`
- **General Questions:** Open an issue on GitHub

---

**Status:** ✅ Ready to use on Windows  
**Last Updated:** November 5, 2025  
**Compatible with:** Windows 10 (2004+), Windows 11
