# Operational Runbooks

Quick reference guides for common operational tasks and emergency procedures.

## Table of Contents

1. [Daily Operations](#daily-operations)
2. [Emergency Procedures](#emergency-procedures)
3. [Incident Response](#incident-response)
4. [Deployment Procedures](#deployment-procedures)
5. [Rollback Procedures](#rollback-procedures)
6. [Maintenance Tasks](#maintenance-tasks)

---

## Daily Operations

### Health Check (5 minutes, every 4 hours)

```bash
# Quick health verification
./scripts/devops.sh health

# Detailed status
./scripts/devops.sh status

# Check specific namespace
kubectl get all -n default -o wide
```

**Checklist**:
- [ ] All pods are Running
- [ ] All services have endpoints
- [ ] No pending pods
- [ ] No CrashLoopBackOff pods
- [ ] Resource usage is normal

### Backup Database (Daily, 2 AM)

```bash
# Create backup
./scripts/backup-database.sh

# Verify backup
ls -lh .backups/postgres_backup_latest.sql

# Optional: Upload to S3
AWS_S3_BUCKET=my-bucket ./scripts/backup-database.sh
```

**Verification**:
```bash
# Check backup size
du -h .backups/postgres_backup_*.sql

# Verify backup integrity
gzip -t .backups/postgres_backup_*.sql.gz
```

### Review Logs (3 times daily)

```bash
# Last 100 lines from all pods
./scripts/devops.sh logs

# Follow logs real-time
kubectl logs -f -l app=auth-service -n default

# Check for errors
kubectl logs -l app=auth-service -n default | grep -i error
```

### Security Audit (Weekly)

```bash
# Full security audit
./scripts/security-audit.sh default

# Check RBAC
kubectl auth can-i get pods --as=system:serviceaccount:default:auth

# Verify secrets encryption
kubectl get secrets -n default -o json | jq '.items[].type' | sort | uniq -c
```

---

## Emergency Procedures

### Service Down - Immediate Action (< 5 minutes)

```bash
# 1. Check pod status
kubectl describe pod <pod-name> -n default

# 2. View recent logs
kubectl logs <pod-name> -n default --tail=50

# 3. Check resource constraints
kubectl top pod <pod-name> -n default

# 4. Restart pod (if needed)
kubectl delete pod <pod-name> -n default

# 5. Monitor recovery
kubectl get pod <pod-name> -n default -w
```

### Database Connectivity Lost

```bash
# 1. Check PostgreSQL pod
kubectl get pod -l app=postgres -n default

# 2. View database logs
kubectl logs postgres-0 -n default --tail=100

# 3. Check PVC
kubectl get pvc -n default

# 4. Verify connectivity
kubectl run -i --rm debug --image=postgres:14 --restart=Never -- \
  psql -h postgres -U postgres -d postgres -c "SELECT 1"

# 5. If corrupted, restore from backup
./scripts/restore-database.sh .backups/postgres_backup_latest.sql
```

### High Memory Usage

```bash
# 1. Identify pods consuming memory
kubectl top pod -n default

# 2. Get specific pod details
kubectl describe pod <pod-name> -n default

# 3. Check limits
kubectl get pod <pod-name> -n default -o json | \
  jq '.spec.containers[].resources'

# 4. Increase limits if needed
kubectl set resources deployment <deployment> \
  --limits=memory=1024Mi \
  --requests=memory=512Mi

# 5. Monitor after change
kubectl top pod -l app=<label> -n default -w
```

### High CPU Usage

```bash
# 1. Identify hot pods
kubectl top pod -n default --sort-by=cpu

# 2. Check CPU limits
kubectl get pod <pod-name> -n default -o json | \
  jq '.spec.containers[].resources.limits.cpu'

# 3. Scale horizontally if possible
kubectl scale deployment <deployment> --replicas=3

# 4. Optimize application (if not transient)
# Review application code for inefficiencies
```

### Disk Space Critical

```bash
# 1. Check disk usage
kubectl exec <pod-name> -n default -- df -h

# 2. Find large files
kubectl exec <pod-name> -n default -- du -sh /*

# 3. Clean up
kubectl exec <pod-name> -n default -- rm -rf /tmp/*

# 4. Expand volume if needed
# Update PVC size in values.yaml and redeploy
```

---

## Incident Response

### Incident Template

```
INCIDENT REPORT
===============
Time Discovered: [TIME]
Severity: [CRITICAL|HIGH|MEDIUM|LOW]
Service: [SERVICE_NAME]
Status: [INVESTIGATING|MITIGATING|RESOLVED|POST-MORTEM]

TIMELINE:
- HH:MM - Discovered issue
- HH:MM - Action taken
- HH:MM - Mitigation applied
- HH:MM - Issue resolved

ROOT CAUSE:
[Description of what went wrong]

RESOLUTION:
[What was done to fix it]

PREVENTION:
[What to do to prevent this in future]
```

### Service Degradation

**1. Assess Impact** (< 1 min)
```bash
kubectl describe event -n default | grep Warning
```

**2. Identify Root Cause** (< 5 min)
```bash
# Check logs
kubectl logs -l app=<service> -n default --tail=200

# Check metrics
kubectl top pod -l app=<service> -n default

# Check events
kubectl get events -n default --sort-by='.lastTimestamp' | tail -20
```

**3. Mitigate** (< 10 min)
- Increase replicas
- Restart problematic pod
- Scale backend resources
- Switch to fallback service

**4. Resolve**
```bash
# Restart deployment
kubectl rollout restart deployment/<name> -n default

# Or redeploy
helm upgrade <release> <chart> -n default
```

### Data Corruption

**1. Verify Data Integrity**
```bash
# Connect to database
kubectl exec -it postgres-0 -n default -- psql -U postgres

# Run integrity check
postgres=# REINDEX DATABASE postgres;
postgres=# VACUUM ANALYZE;
```

**2. If Critical**
```bash
# Restore from last good backup
./scripts/restore-database.sh .backups/postgres_backup_<date>.sql

# Verify restored data
kubectl run -i --rm debug --image=postgres:14 --restart=Never -- \
  psql -h postgres -U postgres -d postgres -c "SELECT COUNT(*) FROM users;"
```

**3. Post-Incident**
- Document what went wrong
- Create backup immediately after
- Add monitoring/alerts to catch early
- Review backup procedures

---

## Deployment Procedures

### Standard Deployment

```bash
# 1. Test locally
./scripts/devops.sh test

# 2. Build image
docker build -t auth-service:latest auth-service/

# 3. Push to registry
docker push auth-service:latest

# 4. Update Helm values
helm repo update
vi auth-chart/values.yaml

# 5. Dry run
helm upgrade --dry-run --install auth auth-chart/ -n default

# 6. Deploy
helm upgrade --install auth auth-chart/ -n default --wait

# 7. Verify
kubectl get deployment auth-service -n default -o wide
kubectl rollout status deployment/auth-service -n default
```

### Canary Deployment

```bash
# 1. Deploy to canary track
helm upgrade auth auth-chart/ \
  --set canaryPercent=10 \
  -n default --wait

# 2. Monitor metrics
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80

# 3. If good, increase
helm upgrade auth auth-chart/ \
  --set canaryPercent=50 \
  -n default --wait

# 4. Full rollout
helm upgrade auth auth-chart/ \
  --set canaryPercent=100 \
  -n default --wait
```

### Blue-Green Deployment

```bash
# 1. Deploy blue (stable)
helm install blue auth-chart/ -n blue

# 2. Deploy green (new)
helm install green auth-chart/ -n green

# 3. Test green
kubectl run -i --rm test --image=curlimages/curl --restart=Never -- \
  curl -s http://green-auth-service:3000/health

# 4. Switch traffic
kubectl patch service auth-service -n default \
  -p '{"spec":{"selector":{"track":"green"}}}'

# 5. Cleanup
helm uninstall blue -n blue
```

---

## Rollback Procedures

### Emergency Rollback (< 2 minutes)

```bash
# 1. Check deployment history
kubectl rollout history deployment/auth-service -n default

# 2. Rollback to previous
kubectl rollout undo deployment/auth-service -n default

# 3. Verify
kubectl rollout status deployment/auth-service -n default

# 4. Confirm application working
./scripts/devops.sh health
```

### Rollback via Helm

```bash
# 1. Check release history
helm history auth -n default

# 2. Rollback to previous
helm rollback auth -n default

# 3. Or rollback to specific revision
helm rollback auth 3 -n default

# 4. Verify
kubectl get deployment auth-service -n default -o wide
```

### Manual Rollback

```bash
# 1. Apply previous manifest
kubectl apply -f previous-deployment.yaml

# 2. Or edit deployment directly
kubectl edit deployment/auth-service -n default
# Change image tag to previous version

# 3. Trigger rollout
kubectl rollout restart deployment/auth-service -n default

# 4. Monitor
kubectl rollout status deployment/auth-service -n default -w
```

---

## Maintenance Tasks

### Monthly Checklist

- [ ] Review and optimize resource limits
- [ ] Update all container images
- [ ] Rotate secrets and credentials
- [ ] Archive logs and metrics
- [ ] Review and update runbooks
- [ ] Test disaster recovery procedures
- [ ] Audit RBAC permissions
- [ ] Security compliance check
- [ ] Backup integrity verification
- [ ] Performance optimization review

### Certificate Renewal

```bash
# 1. Check certificate expiration
kubectl get secret <tls-secret> -n default -o json | \
  jq -r '.data["tls.crt"]' | base64 -d | openssl x509 -text -noout | grep "Not After"

# 2. Generate new certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt

# 3. Update secret
kubectl create secret tls <tls-secret> \
  --cert=tls.crt --key=tls.key \
  --dry-run=client -o yaml | kubectl apply -f -

# 4. Rollout restart to pick up new cert
kubectl rollout restart deployment/auth-service -n default
```

### Secrets Rotation

```bash
# 1. Generate new password
NEW_PASSWORD=$(openssl rand -base64 32)

# 2. Update in database
kubectl exec postgres-0 -n default -- \
  psql -U postgres -c "ALTER USER postgres WITH PASSWORD '$NEW_PASSWORD';"

# 3. Update Kubernetes secret
kubectl create secret generic db-password \
  --from-literal=password=$NEW_PASSWORD \
  --dry-run=client -o yaml | \
  kubeseal -f - | kubectl apply -f -

# 4. Restart applications
kubectl rollout restart deployment -n default
```

### Storage Cleanup

```bash
# 1. List old backups
ls -lh .backups/ | head -20

# 2. Remove backups older than 60 days
find .backups/ -name "*.sql" -mtime +60 -delete

# 3. Compress remaining backups
gzip .backups/*.sql

# 4. Verify
du -sh .backups/
```

---

## Contact Information

### On-Call Escalation

- **Level 1**: Automated monitoring (Alert to Slack)
- **Level 2**: On-call engineer (page)
- **Level 3**: Team lead (conference bridge)
- **Level 4**: Management (executive notification)

### Response Times

- **Critical (P1)**: 15 minutes
- **High (P2)**: 1 hour
- **Medium (P3)**: 4 hours
- **Low (P4)**: 24 hours

---

## Common Issues & Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| Pod CrashLoop | Pod keeps restarting | Check logs, verify env vars, increase resources |
| High latency | Slow requests | Scale horizontally, check DB, optimize code |
| Memory leak | Increasing memory use | Restart pod, review code, enable profiling |
| Disk full | Disk pressure | Clean logs, expand volume, archive old data |
| Connection refused | Cannot reach service | Check pod status, verify network policy, check DNS |
| TLS cert expired | HTTPS not working | Renew certificate, update secret, restart pods |

---

## References

- [Kubernetes Operations](https://kubernetes.io/docs/tasks/administer-cluster/)
- [Deployment Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Troubleshooting Guide](../../docs/TROUBLESHOOTING.md)
- [Security Guide](../../docs/SECURITY.md)
