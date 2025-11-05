# 📦 Archived Documentation

This folder contains **legacy, duplicate, or project-specific documentation** that has been archived to reduce clutter and improve clarity.

---

## 🎯 Why This Folder Exists

To keep the repository clean and easy to navigate, we've archived:
- ✅ **Duplicate content** (multiple versions of the same information)
- ✅ **Legacy documentation** (outdated or superseded by new docs)
- ✅ **Project-specific guides** (for one-time tasks or migrations)
- ✅ **Status reports** (time-specific, no longer relevant)

---

## 📋 What's Here

### Root-Level Archives (11 files)

These were moved from the project root to reduce confusion:

| File | Reason | Status |
|------|--------|--------|
| `START_HERE.md` | Superseded by `POST_CLONE_GUIDE.md` | Use POST_CLONE_GUIDE instead |
| `SEQUENTIAL_DOCUMENTATION_README.md` | Duplicate of POST_CLONE_GUIDE | Use POST_CLONE_GUIDE instead |
| `AUTOMATION_INDEX.md` | Outdated index | See DOCUMENTATION_INDEX.md |
| `DEVELOPER_QUICK_START.sh` | Duplicate info | See DEVELOPER_GUIDE.md |
| `QUICK_START.sh` | Legacy script | Use `make setup` instead |
| `COMPLETION_REPORT.md` | Time-specific status | See PROJECT_STATUS or use current git log |
| `PROJECT_STATUS.md` | Legacy status file | See git history or COMPLETION_REPORT |
| `HELM_MIGRATION.md` | One-time migration task | Completed, kept for reference |
| `SETUP_CHECKLIST.md` | Content merged into SETUP_SEQUENCE | See SETUP_SEQUENCE.md |
| `TEST_ON_NEW_COMPUTER.md` | Testing guidance | See TROUBLESHOOTING.md |
| `VERIFICATION_COMPLETE.md` | Status report | Legacy, see git history |

### Docs/ Folder Archives (12 files)

These were moved from `docs/` to keep it focused:

| File | Reason | Status |
|------|--------|--------|
| `MONITORING_STATUS.md` | Time-specific status | Use `kubectl` commands instead |
| `GRAFANA_SETUP_COMPLETE.md` | Setup archived | See MONITORING_SETUP.md |
| `CHECK_28_DASHBOARDS_QUICK.md` | One-time reference | See docs/ENVIRONMENT_QUICK_REFERENCE.md |
| `HOW_TO_CHECK_DASHBOARDS.md` | Superseded by other guides | See MONITORING_SETUP.md |
| `LOKI_DATASOURCE_FIX.md` | Bug fix (resolved) | See TROUBLESHOOTING.md for current fixes |
| `LOKI_RESOLUTION.md` | Bug fix (resolved) | See TROUBLESHOOTING.md |
| `AUTOMATED_SETUP_GUIDE.md` | Duplicate of SETUP_SEQUENCE | See SETUP_SEQUENCE.md |
| `COMPLETE_AUTOMATION_SUMMARY.md` | Summary (archived) | See SETUP_SEQUENCE.md |
| `DEVELOPER_AUTOMATION_COMPLETE.md` | Task completion report | See DEVELOPER_GUIDE.md |
| `PHASE2_GUIDE.md` | Phase-specific guide | See SETUP_SEQUENCE.md |
| `PHASE3_GUIDE.md` | Phase-specific guide | See SETUP_SEQUENCE.md |
| `PROJECT_SUMMARY.md` | Summary report | See COMPLETION_REPORT.md |
| `MULTI_ENV_IMPLEMENTATION.md` | Duplicate of MULTI_ENVIRONMENT_SETUP | See docs/MULTI_ENVIRONMENT_SETUP.md |

---

## 🔍 How to Find What You Need

### If you're looking for...

| Need | Where to Go | Alternative |
|------|-------------|-------------|
| **Setup instructions** | `SETUP_SEQUENCE.md` (root) | POST_CLONE_GUIDE.md |
| **Developer guide** | `docs/DEVELOPER_GUIDE.md` | DEVELOPER_README.md (root) |
| **System architecture** | `docs/ARCHITECTURE.md` | DOCUMENTATION_INDEX.md |
| **Monitoring setup** | `docs/MONITORING_SETUP.md` | TROUBLESHOOTING.md |
| **Troubleshooting** | `docs/TROUBLESHOOTING.md` | RUNBOOKS.md |
| **Quick reference** | `docs/ENVIRONMENT_QUICK_REFERENCE.md` | DEVELOPER_GUIDE.md |
| **Multi-environment** | `docs/MULTI_ENVIRONMENT_SETUP.md` | ARCHITECTURE.md |
| **Security** | `docs/SECURITY.md` | RUNBOOKS.md |
| **Cost optimization** | `docs/COST_OPTIMIZATION.md` | ARCHITECTURE.md |
| **Navigation** | `DOCUMENTATION_INDEX.md` (root) | README.md |

---

## 🚀 Current Active Documentation

The main documentation structure now includes:

**Root Level (4 essential files):**
- `README.md` - Project overview
- `POST_CLONE_GUIDE.md` - After cloning, what to do
- `SETUP_SEQUENCE.md` - How to set up
- `DOCUMENTATION_INDEX.md` - Navigation map

**docs/ Folder (13 active guides):**
- `ARCHITECTURE.md` - System design
- `DEVELOPER_GUIDE.md` - Daily development
- `GITOPS_PIPELINE.md` - Deployment workflow
- `TROUBLESHOOTING.md` - Problem solving
- `MONITORING_SETUP.md` - Observability
- `RUNBOOKS.md` - Standard procedures
- `SECURITY.md` - Security hardening
- `MULTI_ENVIRONMENT_SETUP.md` - Multi-env config
- `ENVIRONMENT_QUICK_REFERENCE.md` - Command reference
- `COST_OPTIMIZATION.md` - Budget optimization
- `WINDOWS_WSL2_SETUP.md` - Windows setup
- Additional specialized guides as needed

---

## 📚 When to Reference Archived Files

You might want to look in here if:

1. **Looking for historical context** - "How did we solve this before?"
2. **Need old migration steps** - "What was the HELM migration process?"
3. **Checking past status reports** - "What was the project status on X date?"
4. **Referencing old troubleshooting** - "How did we debug this bug before?"

---

## 🔄 If You Need to Restore a File

If an archived file contains important information:

1. Check if that info is now in the active documentation
2. If not, file an issue or create a PR to move it back and consolidate
3. All archived files are preserved in git history

**To restore a file:**
```bash
# See git history
git log --oneline -- docs/archived/FILENAME.md

# Restore from git
git checkout HEAD~N -- docs/archived/FILENAME.md
```

---

## 📌 Notes for Maintainers

- Archived files are preserved for reference and git history
- Don't delete them—archive them here
- If information becomes relevant again, integrate it into active docs
- Update this README when archiving new files
- Keep the main `docs/` folder focused on current needs

---

## 🎯 Summary

This archive folder helps keep documentation:
- ✅ **Organized** - No clutter, clear structure
- ✅ **Focused** - Active docs are easy to find
- ✅ **Maintainable** - Fewer files to update
- ✅ **Preserved** - Nothing is lost, just archived

**When in doubt, start with active documentation:**
1. `POST_CLONE_GUIDE.md` (after cloning)
2. `SETUP_SEQUENCE.md` (setup)
3. `DOCUMENTATION_INDEX.md` (find what you need)
4. Specific guide in `docs/` folder

---

**Last updated:** November 5, 2025
**Total archived:** 23 files
**Active documentation:** 17 files
