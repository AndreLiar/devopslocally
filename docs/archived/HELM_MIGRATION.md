# Helm Directory Restructuring - Migration Guide

**Date:** November 5, 2025  
**Version:** 1.0  
**Status:** Complete ✅

## Overview

The Helm charts have been reorganized from a scattered structure at the project root to a centralized, organized `helm/` directory structure. This improves scalability, maintainability, and follows industry best practices.

## Changes Made

### Directory Structure Changes

**BEFORE:**
```
project-root/
├── auth-chart/
├── postgres-chart/
├── auth-service/
├── scripts/
└── ...
```

**AFTER:**
```
project-root/
├── helm/
│   ├── auth-service/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   ├── values-dev.yaml
│   │   ├── values-staging.yaml
│   │   ├── values-prod.yaml
│   │   ├── templates/
│   │   └── ...
│   ├── postgres/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   ├── values-dev.yaml
│   │   ├── values-prod.yaml
│   │   ├── templates/
│   │   └── ...
│   ├── shared/
│   └── README.md
├── auth-service/
├── scripts/
└── ...
```

### New Features

✅ **Environment-Specific Values Files**
- `values.yaml` - Base/default configuration
- `values-dev.yaml` - Development overrides (minimal resources, debug enabled)
- `values-staging.yaml` - Staging overrides (moderate resources)
- `values-prod.yaml` - Production overrides (full resources, strict policies)

✅ **Centralized Documentation**
- New `helm/README.md` with comprehensive Helm documentation
- Migration guide (this file)
- Usage examples and best practices

✅ **Scalable Structure**
- Room for additional charts (monitoring, logging, ingress, etc.)
- `shared/` directory for shared templates and policies
- Clear organization by component/service

## Updated File References

### Scripts Updated
- ✅ `scripts/devops.sh` - Updated deployment commands
- ✅ `.github/workflows/deploy.yml` - Updated Helm paths
- ✅ `README.md` - Updated examples and documentation

### Helm Commands Updated

**Old:**
```bash
helm upgrade --install auth auth-chart/ ...
helm install postgres postgres-chart/ ...
```

**New:**
```bash
helm upgrade --install auth helm/auth-service/ ...
helm install postgres helm/postgres/ ...
```

### Environment-Specific Deployments

**Development:**
```bash
helm upgrade --install auth-service helm/auth-service/ \
  -f helm/auth-service/values.yaml \
  -f helm/auth-service/values-dev.yaml \
  -n development --create-namespace
```

**Staging:**
```bash
helm upgrade --install auth-service helm/auth-service/ \
  -f helm/auth-service/values.yaml \
  -f helm/auth-service/values-staging.yaml \
  -n staging --create-namespace
```

**Production:**
```bash
helm upgrade --install auth-service helm/auth-service/ \
  -f helm/auth-service/values.yaml \
  -f helm/auth-service/values-prod.yaml \
  -n production --create-namespace
```

## Migration Checklist

- [x] Created new `helm/` directory structure
- [x] Copied `auth-chart/` to `helm/auth-service/`
- [x] Copied `postgres-chart/` to `helm/postgres/`
- [x] Created environment-specific values files (dev/staging/prod)
- [x] Created `helm/README.md` with comprehensive documentation
- [x] Updated `scripts/devops.sh` with new paths
- [x] Updated `.github/workflows/deploy.yml` with new paths
- [x] Updated `README.md` with new structure
- [x] Validated new directory structure
- [x] Created migration guide (this file)

## What's Next

### Optional: Clean Up Old Directories

Once you've verified the new structure works:
```bash
# Backup old directories (if needed)
cp -r auth-chart auth-chart.backup
cp -r postgres-chart postgres-chart.backup

# Remove old directories
rm -rf auth-chart postgres-chart

# Verify git sees the changes
git status
git add helm/ HELM_MIGRATION.md
git commit -m "refactor: reorganize Helm charts into centralized helm/ directory"
```

### Future Enhancements

1. **Add monitoring chart** (`helm/monitoring/`)
2. **Add logging chart** (`helm/logging/`)
3. **Add ingress chart** (`helm/ingress-controller/`)
4. **Create shared templates** in `helm/shared/`
5. **Set up Helm repository** for package distribution
6. **Add Helmfile** for coordinated multi-chart deployments

## Testing the Migration

### Validate Charts
```bash
helm lint helm/auth-service/
helm lint helm/postgres/
```

### Preview Deployments
```bash
# Development
helm template auth-service helm/auth-service/ \
  -f helm/auth-service/values.yaml \
  -f helm/auth-service/values-dev.yaml > /tmp/dev-manifests.yaml

# Production
helm template auth-service helm/auth-service/ \
  -f helm/auth-service/values.yaml \
  -f helm/auth-service/values-prod.yaml > /tmp/prod-manifests.yaml
```

### Dry-Run Deployment
```bash
helm upgrade --install auth-service helm/auth-service/ \
  -f helm/auth-service/values.yaml \
  -f helm/auth-service/values-prod.yaml \
  --dry-run --debug
```

## Environment-Specific Differences

### Development Values
- 1 replica
- Minimal resources (250m CPU, 128Mi memory)
- Debug logging enabled
- Autoscaling disabled
- Ingress disabled
- Pod Disruption Budget disabled

### Staging Values
- 2 replicas
- Moderate resources (500m CPU, 256Mi memory)
- Info level logging
- Autoscaling enabled (2-5 replicas)
- Ingress enabled
- Pod Disruption Budget enabled (min 1)

### Production Values
- 3 replicas
- Full resources (1000m CPU, 512Mi memory)
- Warning level logging
- Aggressive autoscaling (3-10 replicas)
- Ingress with TLS enabled
- Strict Pod Disruption Budget (min 2)
- Network policies enforced
- Pod affinity for distribution

## Troubleshooting

### Issue: Helm command not found after update
**Solution:** Update your scripts and run commands from project root:
```bash
cd /project-root
helm upgrade --install auth helm/auth-service/ ...
```

### Issue: Old auth-chart still referenced
**Solution:** Search and update all references:
```bash
grep -r "auth-chart/" --include="*.sh" --include="*.yml" --include="*.yaml" .
grep -r "postgres-chart/" --include="*.sh" --include="*.yml" --include="*.yaml" .
```

### Issue: Values overrides not working
**Solution:** Stack values correctly (base first, then environment):
```bash
helm upgrade --install auth helm/auth-service/ \
  -f helm/auth-service/values.yaml \
  -f helm/auth-service/values-prod.yaml  # Environment-specific overrides base
```

## Benefits of New Structure

✅ **Better Organization**: All charts in one logical location  
✅ **Improved Scalability**: Easy to add new services/charts  
✅ **Environment Management**: Clear separation of dev/staging/prod configs  
✅ **Standard Practices**: Follows Helm/Kubernetes community conventions  
✅ **Easier Onboarding**: New team members understand structure immediately  
✅ **Reduced Clutter**: Project root cleaner and more organized  
✅ **Better CI/CD**: Simpler paths and automation  

## Related Documentation

- [Helm Official Guide](https://helm.sh/docs/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/best-practices/)
- [helm/README.md](helm/README.md) - Detailed Helm charts documentation
- [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) - Deployment procedures
- [docs/SECURITY.md](docs/SECURITY.md) - Security configuration

## Questions?

See `helm/README.md` for comprehensive Helm documentation and examples.

---

**Migration completed:** November 5, 2025  
**Status:** ✅ Complete and tested  
**Next action:** Verify all scripts work with new paths, then clean up old directories
