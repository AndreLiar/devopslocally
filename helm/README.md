# Helm Charts Directory

This directory contains all Helm charts for the devopslocally project.

## Structure

```
helm/
├── auth-service/           # Auth service microservice chart
│   ├── Chart.yaml
│   ├── values.yaml         # Default values (baseline)
│   ├── values-dev.yaml     # Development environment overrides
│   ├── values-staging.yaml # Staging environment overrides
│   ├── values-prod.yaml    # Production environment overrides
│   └── templates/          # Kubernetes manifest templates
│
├── postgres/               # PostgreSQL database chart
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-dev.yaml
│   ├── values-prod.yaml
│   └── templates/
│
├── monitoring/             # Monitoring stack (future)
│   ├── Chart.yaml
│   └── ...
│
└── shared/                 # Shared templates and helpers
    ├── rbac-templates/
    ├── security-policies/
    └── README.md
```

## Quick Start

### Deploy to Development
```bash
helm upgrade --install auth-service ./auth-service \
  -f ./auth-service/values.yaml \
  -f ./auth-service/values-dev.yaml \
  -n development \
  --create-namespace
```

### Deploy to Staging
```bash
helm upgrade --install auth-service ./auth-service \
  -f ./auth-service/values.yaml \
  -f ./auth-service/values-staging.yaml \
  -n staging \
  --create-namespace
```

### Deploy to Production
```bash
helm upgrade --install auth-service ./auth-service \
  -f ./auth-service/values.yaml \
  -f ./auth-service/values-prod.yaml \
  -n production \
  --create-namespace
```

## Environment-Specific Values

Each chart includes base `values.yaml` and environment-specific overrides:

- **values.yaml**: Default/baseline configuration
- **values-dev.yaml**: Development overrides (minimal resources, debugging enabled)
- **values-staging.yaml**: Staging overrides (moderate resources, realistic config)
- **values-prod.yaml**: Production overrides (full resources, strict policies)

When deploying, stack the appropriate values files:
```bash
helm upgrade --install <release> <chart> \
  -f <chart>/values.yaml \
  -f <chart>/values-<env>.yaml
```

## Chart Details

### auth-service/
The main authentication microservice.

**Key Features:**
- Horizontal Pod Autoscaling (1-10 replicas depending on environment)
- RBAC and Pod Security Policies
- TLS/SSL support
- Monitoring integration (Prometheus)
- Ingress configuration
- Network policies

**Configuration via values:**
- Image repository and tag
- Resource limits and requests
- Autoscaling thresholds
- Ingress hosts and TLS
- Database connection settings

### postgres/
PostgreSQL database deployment.

**Key Features:**
- Persistent volume storage
- Backup and restore capability
- Replication support (production only)
- Monitoring integration
- High availability setup

**Environment-Specific:**
- Dev: 1 replica, minimal storage, no backups
- Prod: 2 replicas, large storage, daily backups

## Adding New Charts

To add a new chart:

1. Create directory: `helm/<service-name>/`
2. Create templates subdirectory: `helm/<service-name>/templates/`
3. Create base values: `helm/<service-name>/values.yaml`
4. Create Chart.yaml with metadata
5. Add environment-specific values files
6. Document in this README

Example:
```bash
mkdir -p helm/cache-service/templates
cp helm/auth-service/Chart.yaml helm/cache-service/
# Edit Chart.yaml with new service name
cp helm/auth-service/values.yaml helm/cache-service/
# ... repeat for values-dev.yaml, values-staging.yaml, values-prod.yaml
```

## Validation

Validate chart syntax:
```bash
helm lint ./auth-service
helm lint ./postgres
```

Dry-run to see what would be deployed:
```bash
helm upgrade --install auth-service ./auth-service \
  -f ./auth-service/values.yaml \
  -f ./auth-service/values-prod.yaml \
  --dry-run --debug
```

Template rendering:
```bash
helm template auth-service ./auth-service \
  -f ./auth-service/values.yaml \
  -f ./auth-service/values-prod.yaml
```

## Best Practices

1. **Use specific image tags** in production (never `latest`)
2. **Stack values files** to progressively override
3. **Validate with `helm lint`** before deploying
4. **Use `--dry-run`** to preview changes
5. **Keep base values.yaml minimal** and generic
6. **Use environment values for overrides** not base values
7. **Document custom values** in templates or README
8. **Use consistent naming** across all charts

## Troubleshooting

### Check what would be deployed
```bash
helm diff upgrade auth-service ./auth-service -f values.yaml -f values-prod.yaml
```

### View current release values
```bash
helm get values auth-service -n production
```

### See deployment history
```bash
helm history auth-service -n production
```

### Rollback to previous version
```bash
helm rollback auth-service 1 -n production
```

## Related Documentation

- [Helm Official Documentation](https://helm.sh/docs/)
- [Kubernetes Deployment Guide](../docs/DEPLOYMENT.md)
- [Security Guide](../docs/SECURITY.md)
- [Cost Optimization](../docs/COST_OPTIMIZATION.md)
