# Architecture Overview

This document describes the architecture of the devopslocally project.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          GitOps Repository                      │
│  (GitHub: main branch with manifests and configurations)        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                     │
        ▼                                     ▼
┌──────────────────────────┐        ┌──────────────────────────┐
│    GitHub Actions CI/CD  │        │       ArgoCD GitOps     │
│   (Test, Scan, Build)   │        │  (Continuous Deployment)│
└──────────────────────────┘        └──────────────────────────┘
        │                                     │
        └──────────────────┬──────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │    Kubernetes Cluster            │
        │  (Docker Desktop / Minikube)     │
        │                                  │
        │  ┌────────────────────────────┐ │
        │  │  Auth Service Pod          │ │
        │  │  - Node.js Express Server  │ │
        │  │  - Health Checks           │ │
        │  │  - Logging (Pino)          │ │
        │  └────────────────────────────┘ │
        │                                  │
        │  ┌────────────────────────────┐ │
        │  │  PostgreSQL StatefulSet    │ │
        │  │  - Persistent Volume       │ │
        │  │  - Backup/Restore Ready    │ │
        │  └────────────────────────────┘ │
        │                                  │
        │  ┌────────────────────────────┐ │
        │  │  Observability Stack       │ │
        │  │  - Prometheus              │ │
        │  │  - Grafana                 │ │
        │  │  - Loki (Log Aggregation)  │ │
        │  └────────────────────────────┘ │
        │                                  │
        │  ┌────────────────────────────┐ │
        │  │  Security & Networking     │ │
        │  │  - NetworkPolicies         │ │
        │  │  - Sealed Secrets          │ │
        │  │  - RBAC Controls           │ │
        │  │  - Pod Security Policies   │ │
        │  └────────────────────────────┘ │
        └──────────────────────────────────┘
```

## Components

### 1. Application Layer

**Auth Service (Node.js)**
- Framework: Express.js
- Logging: Pino with structured logging
- Features:
  - RESTful API endpoints
  - Health check endpoints
  - Graceful shutdown
  - Request logging
  - Error handling

**Database (PostgreSQL)**
- Type: StatefulSet for data persistence
- Storage: PersistentVolumeClaim
- Features:
  - Backup/restore capabilities
  - Connection pooling ready
  - SSL support
  - Multi-database support

### 2. Infrastructure Layer

**Helm Charts**
- `auth-chart/`: Main application chart with:
  - Deployment
  - Service
  - ConfigMap for configuration
  - Secrets management
  - HPA for auto-scaling
  - NetworkPolicy for security
  - ResourceQuota for limits
  - RBAC configuration
  - Pod Security Policies

- `postgres-chart/`: Database chart with:
  - StatefulSet for stateful deployment
  - Persistent storage
  - Service discovery
  - Secret management

### 3. Security Layer

**Authentication & Authorization**
- RBAC: Role-based access control per service
- ServiceAccounts: Minimal required permissions
- Sealed Secrets: Encrypted secret management

**Network Security**
- NetworkPolicies: Pod-to-pod communication control
- Pod Security Policies: Container runtime constraints
- Resource Quotas: Resource usage limits

**Data Protection**
- TLS/SSL: Encrypted communication
- At-rest encryption: etcd encryption ready
- Secret rotation: Automated secret management

### 4. Observability Layer

**Monitoring (Prometheus)**
- Metrics collection
- Service health metrics
- Resource utilization tracking

**Visualization (Grafana)**
- Custom dashboards
- Alert visualization
- Performance metrics

**Logging (Loki)**
- Centralized log aggregation
- Log querying and analysis
- Alert-based logging

### 5. CI/CD Pipeline

**GitHub Actions Workflows**

Test & Scan (`test-and-scan.yml`):
```
Code Push → Unit Tests → Linting → Security Scan → Docker Build → Push
```

Features:
- Jest unit testing with coverage
- ESLint code quality checks
- Prettier formatting validation
- npm audit for dependency vulnerabilities
- Trivy for container image scanning
- Helm chart linting and validation
- Conditional Docker build and push

Deploy (`deploy.yml`):
```
Main Branch → Build Image → Push to Registry → Deploy to K8s → Smoke Tests
```

### 6. Development Workflow

```
Local Development
       │
       ▼
Git Commit (Pre-commit Hooks)
  ├─ ESLint validation
  ├─ Prettier formatting
  └─ Commitlint format check
       │
       ▼
Git Push to Feature Branch
       │
       ▼
GitHub Actions CI (test-and-scan)
  ├─ Unit Tests
  ├─ Code Quality
  ├─ Security Scanning
  └─ Docker Build
       │
       ▼
Pull Request Review
       │
       ▼
Merge to Main
       │
       ▼
GitHub Actions Deploy (deploy)
  ├─ Build Image
  ├─ Push to Registry
  ├─ Deploy to Kubernetes
  └─ Smoke Tests
       │
       ▼
Production Deployment
```

## Data Flow

### Request Flow

```
Client Request
       │
       ▼
Kubernetes Ingress/Service
       │
       ▼
Auth Service Pod
  ├─ Request logging (Pino)
  ├─ Request validation
  ├─ Authentication check
  └─ Business logic
       │
       ▼
PostgreSQL Database
  ├─ Data retrieval/storage
  └─ Transaction management
       │
       ▼
Response
  ├─ Result serialization
  ├─ Response logging
  └─ Client delivery
```

### Log Flow

```
Application Logs (stdout/stderr)
       │
       ▼
Kubernetes Log Collection
       │
       ▼
Loki Log Aggregation
       │
       ▼
Grafana Visualization
       │
       ▼
User Queries & Dashboards
```

### Metrics Flow

```
Application Metrics (Prometheus format)
       │
       ▼
Prometheus Scraping (every 15s)
       │
       ▼
Metrics Storage (TSDB)
       │
       ▼
Grafana Queries
       │
       ▼
Dashboard Visualization & Alerts
```

## Scalability

### Horizontal Scaling

- HPA monitors CPU/memory usage
- Automatically scales pods 1-10
- Threshold: 80% CPU/Memory

```yaml
autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
```

### Vertical Scaling

- Resource requests/limits per pod
- CPU: 100m - 500m per pod
- Memory: 128Mi - 512Mi per pod

## High Availability

### Pod Redundancy
- Multiple replicas running
- Health checks (liveness, readiness probes)
- Rolling updates for zero downtime

### Database Redundancy
- StatefulSet for persistence
- PVC for data retention
- Backup/restore capabilities

### Backup Strategy
```
Daily Automated Backups
       │
       ▼
Local Storage (.backups/)
       │
       ▼
Optional: S3 Upload
       │
       ▼
30-Day Retention
```

## Security Zones

### Trust Boundaries

```
┌─────────────────────────────────┐
│   Cluster Boundary              │
│  (Secure, Encrypted)            │
│                                 │
│  ┌───────────────────────────┐ │
│  │  Service Account Boundary │ │
│  │  (RBAC Controlled)        │ │
│  │                           │ │
│  │  ┌─────────────────────┐ │ │
│  │  │ Pod Security Zone   │ │ │
│  │  │ (Runtime Enforced)  │ │ │
│  │  │                     │ │ │
│  │  │ App Container       │ │ │
│  │  │ (Non-root, RO FS)   │ │ │
│  │  └─────────────────────┘ │ │
│  │                           │ │
│  └───────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

## Disaster Recovery

### RTO/RPO Targets

- **RTO (Recovery Time Objective)**: < 30 minutes
- **RPO (Recovery Point Objective)**: < 1 hour

### Recovery Procedures

1. **Pod Failure**: Kubernetes auto-restarts within seconds
2. **Data Loss**: Restore from backup (< 30 min)
3. **Cluster Failure**: Redeploy manifests with `make setup`

## Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Orchestration | Kubernetes | 1.24+ |
| Container Runtime | Docker | 20.10+ |
| Package Manager | Helm | 3.0+ |
| CI/CD | GitHub Actions | Native |
| GitOps | ArgoCD | 2.0+ |
| Application | Node.js | 18+ |
| Database | PostgreSQL | 14+ |
| Monitoring | Prometheus | 2.40+ |
| Visualization | Grafana | 9.0+ |
| Logging | Loki | 2.0+ |
| Security | Sealed Secrets | 0.18+ |

## Deployment Modes

### Development
```bash
docker-compose up  # Local development
make setup         # Single-node cluster
```

### Staging
```bash
kubectl apply -f manifests/  # Single cluster
helm upgrade --install auth auth-chart/
```

### Production
```bash
# GitOps-driven deployment via ArgoCD
# Sealed Secrets for sensitive data
# Multi-region failover ready
# Full monitoring and alerting
```

## Networking Architecture

### Service Discovery
- Kubernetes DNS for internal service discovery
- Service names resolve to ClusterIP

### Ingress
- HTTP/HTTPS exposure
- TLS termination
- Path-based routing

### Network Policies
- Default deny all ingress
- Explicit allow rules per service
- Egress restrictions for outbound traffic

## Configuration Management

### ConfigMaps
- Non-sensitive configuration
- Application settings
- Feature flags

### Secrets
- Sensitive data (passwords, keys)
- Database credentials
- API tokens

### Environment Variables
- Container-level configuration
- Helm value overrides
- Runtime configuration

## Monitoring & Alerting

### Metrics Collected
- Pod CPU/Memory usage
- Request rate and latency
- Error rates
- Database connection pools
- Custom application metrics

### Alerting Rules
- High CPU usage (> 90%)
- High memory usage (> 90%)
- Pod restart loops
- Failed deployments
- Database connection errors

## References

- [Kubernetes Architecture](https://kubernetes.io/docs/concepts/architecture/)
- [Helm Documentation](https://helm.sh/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Best Practices](https://kubernetes.io/docs/concepts/overview/)
