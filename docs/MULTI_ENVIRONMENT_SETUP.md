# Multi-Environment Branch Mapping Configuration

## Branch to Environment Mapping

```
Git Branch    →  Environment  →  Namespace      →  Replicas  →  Resources
────────────────────────────────────────────────────────────────────────────
main          →  production    →  production    →  3          →  High
staging       →  staging       →  staging       →  2          →  Medium
dev           →  development   →  development   →  1          →  Low
```

## Environment-Specific Configuration

### Production Environment (main branch)

**Branch:** `main`
**Namespace:** `production`
**Replicas:** 3
**Auto-scaling:** Enabled (2-10 replicas)

**Characteristics:**
- High availability with 3+ replicas
- Strict health checks (liveness & readiness)
- Production-grade resources (1000m CPU, 512Mi memory)
- Horizontal Pod Autoscaling enabled
- Pod Disruption Budgets enforced
- Network policies: strict zero-trust
- Ingress: enabled with TLS
- Monitoring: aggressive alerting thresholds
- Log level: WARNING
- Image pull policy: IfNotPresent (stable versions)

**Deployment Values:** `helm/auth-service/values-prod.yaml`

### Staging Environment (staging branch)

**Branch:** `staging`
**Namespace:** `staging`
**Replicas:** 2
**Auto-scaling:** Enabled (1-5 replicas)

**Characteristics:**
- 2 replicas for testing HA
- Medium resource allocation (500m CPU, 256Mi memory)
- Health checks: moderate strictness
- Pod Disruption Budgets: enabled (1 available)
- Network policies: moderate restrictions
- Ingress: enabled with staging TLS
- Monitoring: standard thresholds
- Log level: INFO
- Image pull policy: IfNotPresent

**Deployment Values:** `helm/auth-service/values-staging.yaml`

### Development Environment (dev branch)

**Branch:** `dev`
**Namespace:** `development`
**Replicas:** 1
**Auto-scaling:** Disabled

**Characteristics:**
- Single replica for development
- Minimal resources (250m CPU, 128Mi memory)
- Health checks: relaxed (30s initial delay)
- Pod Disruption Budgets: disabled
- Network policies: minimal restrictions
- Ingress: disabled (use port-forward or NodePort)
- Monitoring: relaxed thresholds
- Log level: DEBUG
- Image pull policy: Always (latest changes)

**Deployment Values:** `helm/auth-service/values-dev.yaml`

## GitHub Actions Workflow

### Automatic Deployments

1. **Push to main** → Deploys to production (3 replicas)
2. **Push to staging** → Deploys to staging (2 replicas)
3. **Push to dev** → Deploys to development (1 replica)

### Manual Deployments

Trigger with workflow_dispatch:
```bash
gh workflow run multi-env-deploy.yml -f environment=prod
gh workflow run multi-env-deploy.yml -f environment=staging
gh workflow run multi-env-deploy.yml -f environment=dev
```

## Deployment Process

### Pre-Deployment

1. ✅ Code validation and testing
2. ✅ Security scanning
3. ✅ Determine target environment from branch
4. ✅ Select appropriate Helm values
5. ✅ Set resource limits and replicas

### Deployment

1. 🔧 Create namespace if needed
2. 📦 Deploy ConfigMaps (non-sensitive config)
3. 🔐 Deploy Secrets (sensitive data)
4. 🚀 Deploy Helm chart with environment-specific values
5. ⏳ Wait for rollout (5min timeout)
6. ✓ Verify deployment with smoke tests

### Post-Deployment

1. 📊 Verify pod health and logs
2. 📈 Check resource utilization
3. 🔄 Auto-rollback on failure
4. 📢 Notify deployment status

## Configuration Files

### ConfigMap per Environment

**Location:** `helm/auth-service/templates/configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: auth-config-{{ .Values.environment }}
data:
  LOG_LEVEL: {{ .Values.config.logLevel }}
  ENVIRONMENT: {{ .Values.environment }}
  NODE_ENV: {{ .Values.config.environment }}
  DATABASE_HOST: {{ .Release.Name }}-postgresql
  REDIS_HOST: {{ .Release.Name }}-redis-master
  API_URL: {{ .Values.config.apiUrl }}
```

### Secrets per Environment

**Location:** `helm/auth-service/templates/secrets.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: auth-secrets-{{ .Values.environment }}
type: Opaque
data:
  JWT_SECRET: {{ .Values.secrets.jwtSecret | b64enc }}
  DATABASE_PASSWORD: {{ .Values.postgresql.auth.password | b64enc }}
  API_KEY: {{ .Values.secrets.apiKey | b64enc }}
```

## Namespace Isolation

Each environment has its own Kubernetes namespace:

```bash
# Development namespace
kubectl create namespace development

# Staging namespace
kubectl create namespace staging

# Production namespace
kubectl create namespace production
```

Resources are isolated per namespace:
- ConfigMaps
- Secrets
- Deployments
- Services
- StatefulSets (PostgreSQL)
- Ingress rules
- Network policies
- Resource quotas
- RBAC policies

## Environment-Specific Secrets

### Development Secrets

```bash
kubectl create secret generic auth-secrets-dev \
  --from-literal=JWT_SECRET="dev-secret-key" \
  --from-literal=API_KEY="dev-api-key" \
  -n development
```

### Staging Secrets

```bash
kubectl create secret generic auth-secrets-staging \
  --from-literal=JWT_SECRET="staging-secret-key" \
  --from-literal=API_KEY="staging-api-key" \
  -n staging
```

### Production Secrets

```bash
kubectl create secret generic auth-secrets-prod \
  --from-literal=JWT_SECRET="$(openssl rand -base64 32)" \
  --from-literal=API_KEY="$(openssl rand -base64 32)" \
  -n production
```

## Monitoring and Alerting per Environment

### Development Alerts (dev namespace)
- Pod crashes (alert on 2+ restarts)
- High error rates (>50%)
- Deployment failures

### Staging Alerts (staging namespace)
- Pod crashes (alert on 1+ restart)
- High error rates (>10%)
- Deployment failures
- High memory usage (>75%)

### Production Alerts (production namespace)
- Pod crashes (alert immediately)
- High error rates (>1%)
- Deployment failures
- High resource usage (>80%)
- Response time degradation (>1s p95)
- Database connection issues

## Promotion Strategy

### Code Promotion Path

```
Feature Branch
    ↓
    PR → Code Review
    ↓
    dev branch (Development Environment)
    ↓
    Tests Pass
    ↓
    staging branch (Staging Environment)
    ↓
    User Acceptance Testing
    ↓
    main branch (Production Environment)
```

### Automated Testing per Environment

**Development:**
- Unit tests
- Integration tests
- Basic smoke tests

**Staging:**
- End-to-end tests
- Performance tests
- Security scanning
- Load testing

**Production:**
- Smoke tests
- Health checks
- Canary deployment (optional)

## Rollback Strategy

### Automatic Rollback Triggers

1. **Deployment failure** - Helm rollback to previous release
2. **Health check failure** - Revert to previous version
3. **Error rate spike** - Alert and manual rollback

### Manual Rollback

```bash
# Rollback production
helm rollback auth-service -n production

# Rollback staging
helm rollback auth-service -n staging

# Rollback development
helm rollback auth-service -n development
```

## Environment-Specific URLs

```
Development:  http://localhost:3000 (port-forward)
Staging:      https://staging-auth.example.com
Production:   https://auth.example.com
```

## Database Per Environment

### Development
- PostgreSQL: Minimal setup
- Backup: Optional
- Replicas: 1

### Staging
- PostgreSQL: Standard setup
- Backup: Daily
- Replicas: 2 (read-only replicas)

### Production
- PostgreSQL: HA setup
- Backup: Hourly + point-in-time recovery
- Replicas: 2 (streaming replication)

## Environment Variables Hierarchy

1. Base values: `helm/auth-service/values.yaml`
2. Environment override: `helm/auth-service/values-{env}.yaml`
3. Secrets: `auth-secrets-{env}` Secret object
4. ConfigMaps: `auth-config-{env}` ConfigMap object

**Resolution order (highest to lowest priority):**
```
Secrets > ConfigMaps > values-{env}.yaml > values.yaml
```

## CI/CD Pipeline Summary

```
┌─────────────┐
│ Git Push    │
└──────┬──────┘
       │
       ├─→ main branch
       │   ↓
       │   Production Environment
       │   ├─ 3 replicas
       │   ├─ Strict health checks
       │   ├─ High resources
       │   └─ Alerting enabled
       │
       ├─→ staging branch
       │   ↓
       │   Staging Environment
       │   ├─ 2 replicas
       │   ├─ Medium health checks
       │   ├─ Medium resources
       │   └─ Standard alerting
       │
       └─→ dev branch
           ↓
           Development Environment
           ├─ 1 replica
           ├─ Relaxed health checks
           ├─ Low resources
           └─ Debug logging
```

## Quick Commands

```bash
# Check deployments across all environments
kubectl get deployments -n development
kubectl get deployments -n staging
kubectl get deployments -n production

# View environment-specific ConfigMaps
kubectl get configmap -n development
kubectl get configmap -n staging
kubectl get configmap -n production

# View environment-specific Secrets
kubectl get secrets -n development
kubectl get secrets -n staging
kubectl get secrets -n production

# Check namespace resources
kubectl describe namespace production
kubectl describe namespace staging
kubectl describe namespace development

# View all resources in an environment
kubectl get all -n production
```

## Security Considerations

### Network Policies
- Development: Allow all traffic
- Staging: Restrict to CI/CD ingress
- Production: Strict ingress/egress rules

### RBAC
- Each namespace has dedicated service accounts
- Minimal permissions per environment
- Production uses sealed-secrets

### Secrets Management
- Development: Plain text (test values only)
- Staging: Base64 encoded
- Production: Sealed Secrets or external secret management

## Troubleshooting

### Check deployment status
```bash
kubectl rollout status deployment/auth-service -n production
```

### View recent events
```bash
kubectl get events -n production --sort-by='.lastTimestamp'
```

### Check pod logs
```bash
kubectl logs -n production -l app=auth-service --tail=100
```

### Describe pod for issues
```bash
kubectl describe pod -n production -l app=auth-service
```
