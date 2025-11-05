# Troubleshooting Guide

Comprehensive troubleshooting guide for common issues in devopslocally deployment.

## Table of Contents

1. [Kubernetes Issues](#kubernetes-issues)
2. [Application Issues](#application-issues)
3. [Database Issues](#database-issues)
4. [Networking Issues](#networking-issues)
5. [Performance Issues](#performance-issues)
6. [Security Issues](#security-issues)

## Kubernetes Issues

### Pod not starting

**Problem**: Pod is stuck in `Pending` or `CrashLoopBackOff` state

**Diagnosis**:
```bash
# Check pod status
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace>

# Check events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

**Solutions**:

1. **Pending state** - Usually insufficient resources:
```bash
# Check node resources
kubectl top nodes
kubectl top pods -n <namespace>

# Scale down other deployments or add more resources
```

2. **CrashLoopBackOff** - Application crashing:
```bash
# View detailed logs
kubectl logs <pod-name> -n <namespace> --previous

# Check readiness/liveness probes
kubectl describe pod <pod-name> -n <namespace> | grep -A 5 "Readiness"
```

3. **ImagePullBackOff** - Cannot pull container image:
```bash
# Verify image exists in registry
docker image ls <image-name>

# Check image pull policy
kubectl describe pod <pod-name> | grep "Image:"

# Verify credentials for private registry
kubectl get secrets -n <namespace>
```

### Service not accessible

**Problem**: Cannot reach service from outside cluster

**Diagnosis**:
```bash
# Check service exists
kubectl get svc -n <namespace>

# Check endpoints
kubectl get endpoints <service-name> -n <namespace>

# Check service port
kubectl describe svc <service-name> -n <namespace>
```

**Solutions**:

1. **No endpoints**:
```bash
# Service has no backing pods
kubectl get pods -l app=<label> -n <namespace>

# Debug selectors
kubectl get pods --show-labels -n <namespace>
```

2. **Port mismatch**:
```bash
# Service port doesn't match container port
kubectl describe svc <service-name> -n <namespace>

# Test with port-forward
kubectl port-forward svc/<service-name> 8080:3000 -n <namespace>
```

### Node issues

**Problem**: Node not ready or not scheduling pods

**Diagnosis**:
```bash
# Check node status
kubectl describe node <node-name>

# Check node resources
kubectl top node <node-name>

# Check kubelet status
systemctl status kubelet  # On the node
```

**Solutions**:

1. **Disk pressure**:
```bash
# Clean up unused images
docker image prune -a

# Clean up unused volumes
docker volume prune
```

2. **Memory pressure**:
```bash
# Check memory usage
free -h

# Restart services
systemctl restart kubelet
```

## Application Issues

### Application crashes

**Problem**: App container keeps restarting

**Diagnosis**:
```bash
# Check restart count
kubectl describe pod <pod-name> -n <namespace>

# View crash logs
kubectl logs <pod-name> -n <namespace> --previous

# Check exit code
kubectl logs <pod-name> -n <namespace> -c <container> --previous | tail -20
```

**Solutions**:

1. **Missing environment variables**:
```bash
# Check ConfigMap/Secret
kubectl describe configmap <name> -n <namespace>
kubectl describe secret <name> -n <namespace>

# Update deployment
kubectl set env deployment/<name> VAR_NAME=value -n <namespace>
```

2. **Incorrect application config**:
```bash
# View application logs in detail
kubectl logs <pod-name> -n <namespace> -f

# Check application health endpoint
kubectl exec <pod-name> -n <namespace> -- curl localhost:3000/health
```

### High latency

**Problem**: Requests are slow

**Diagnosis**:
```bash
# Check pod resource usage
kubectl top pod <pod-name> -n <namespace>

# Check network performance
kubectl exec <pod-name> -n <namespace> -- ping google.com

# Check application metrics
kubectl logs <pod-name> -n <namespace> | grep "duration"
```

**Solutions**:

1. **Resource constraints**:
```bash
# Increase resource limits
kubectl set resources deployment/<name> \
  --limits=cpu=1000m,memory=1024Mi \
  --requests=cpu=500m,memory=512Mi \
  -n <namespace>
```

2. **Network issues**:
```bash
# Check pod network connectivity
kubectl exec <pod-name> -n <namespace> -- traceroute <target>

# Check DNS resolution
kubectl exec <pod-name> -n <namespace> -- nslookup kubernetes.default
```

### Memory leaks

**Problem**: Pod memory usage grows over time

**Diagnosis**:
```bash
# Monitor memory usage
kubectl top pod <pod-name> -n <namespace> --containers

# View memory over time (Grafana recommended)
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80
```

**Solutions**:

1. **Code optimization**:
```bash
# Take heap dump (for Node.js)
kubectl exec <pod-name> -n <namespace> -- \
  node -e "require('heapdump').writeSnapshot('./heap-' + Date.now() + '.heapsnapshot')"
```

2. **Pod restart policy**:
```bash
# Configure automatic restart on memory threshold
# Use deployment strategy with recreate for reset
```

## Database Issues

### Connection refused

**Problem**: Cannot connect to PostgreSQL

**Diagnosis**:
```bash
# Check PostgreSQL pod
kubectl get pods -n <namespace> -l app=postgres

# Check pod logs
kubectl logs postgres-0 -n <namespace>

# Test connection
kubectl exec postgres-0 -n <namespace> -- \
  psql -U postgres -d postgres -c "SELECT 1"
```

**Solutions**:

1. **Pod not running**:
```bash
# Check describe output for errors
kubectl describe pod postgres-0 -n <namespace>

# Check PVC status
kubectl get pvc -n <namespace>
```

2. **Password incorrect**:
```bash
# Get password from secret
kubectl get secret postgres-secret -n <namespace> \
  -o jsonpath='{.data.password}' | base64 -d
```

### Data corruption

**Problem**: Database is corrupted or inaccessible

**Solutions**:

1. **Restore from backup**:
```bash
# List available backups
ls -la .backups/

# Restore specific backup
./scripts/restore-database.sh .backups/postgres_backup_20231115_143022.sql
```

2. **Manual recovery**:
```bash
# Connect to database
kubectl exec -it postgres-0 -n <namespace> -- \
  psql -U postgres -d postgres

# Run VACUUM FULL to recover space
VACUUM FULL;

# Reindex if needed
REINDEX DATABASE postgres;
```

### Backup failures

**Problem**: Database backup not working

**Diagnosis**:
```bash
# Check backup script
./scripts/backup-database.sh --help

# Check available disk space
kubectl exec postgres-0 -n <namespace> -- df -h

# Check PostgreSQL logs
kubectl logs postgres-0 -n <namespace> | tail -50
```

**Solutions**:

1. **Insufficient disk space**:
```bash
# Check PVC size
kubectl get pvc -n <namespace>

# Resize PVC (if supported by storage class)
kubectl patch pvc postgres-pvc -n <namespace> -p \
  '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'
```

2. **Permission issues**:
```bash
# Check backup directory permissions
kubectl exec postgres-0 -n <namespace> -- \
  ls -la /var/lib/postgresql/data/
```

## Networking Issues

### Pod cannot reach external service

**Problem**: Pods can't connect outside cluster

**Diagnosis**:
```bash
# Test DNS resolution
kubectl exec <pod-name> -n <namespace> -- nslookup google.com

# Test connectivity
kubectl exec <pod-name> -n <namespace> -- ping google.com

# Check NetworkPolicies
kubectl get networkpolicies -n <namespace>
```

**Solutions**:

1. **NetworkPolicy blocking**:
```bash
# List all network policies
kubectl get networkpolicies -n <namespace>

# Check if default deny policy exists
kubectl get networkpolicy -A

# Temporarily remove policy for testing
kubectl delete networkpolicy <policy-name> -n <namespace>
```

2. **DNS not working**:
```bash
# Check CoreDNS pod
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Restart CoreDNS
kubectl rollout restart deployment coredns -n kube-system
```

### Service-to-service communication fails

**Problem**: Pods in one namespace can't reach pods in another

**Solutions**:

1. **Cross-namespace network policy**:
```bash
# Update network policy to allow cross-namespace
kubectl get networkpolicies -A

# Update rule to include other namespace
```

2. **DNS across namespaces**:
```bash
# Use fully qualified domain names
# Format: <service>.<namespace>.svc.cluster.local

# Test resolution
kubectl exec <pod-name> -- nslookup <service>.<namespace>.svc.cluster.local
```

## Performance Issues

### Slow deployments

**Problem**: Rolling updates take too long

**Solutions**:

1. **Adjust surge/unavailable**:
```yaml
# In values.yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

2. **Optimize readiness probes**:
```yaml
# Reduce initial delay
readinessProbe:
  initialDelaySeconds: 5  # Reduce from 15
  periodSeconds: 5
  timeoutSeconds: 2
```

### High resource utilization

**Problem**: CPU/Memory usage high

**Solutions**:

```bash
# Scale replicas
kubectl scale deployment <name> --replicas=3 -n <namespace>

# Adjust resource requests/limits
kubectl set resources deployment/<name> \
  --requests=cpu=250m,memory=256Mi \
  --limits=cpu=500m,memory=512Mi
```

## Security Issues

### Secret access denied

**Problem**: Pod cannot read sealed secrets

**Diagnosis**:
```bash
# Check if sealed-secrets controller is running
kubectl get deployment -n kube-system sealed-secrets

# Verify service account has permissions
kubectl auth can-i get sealedsecrets \
  --as=system:serviceaccount:<namespace>:<sa-name>
```

**Solutions**:

```bash
# Reinstall sealed-secrets
./scripts/setup-sealed-secrets.sh

# Re-seal secrets with new key
kubeseal < my-secret.yaml > my-sealed-secret.yaml
```

### RBAC permission denied

**Problem**: "permission denied" errors

**Diagnosis**:
```bash
# Check service account permissions
kubectl auth can-i get pods --as=system:serviceaccount:<ns>:<sa>

# View role details
kubectl describe role <role-name> -n <namespace>
```

**Solutions**:

```bash
# Create proper role binding
kubectl create rolebinding <name> \
  --clusterrole=<role> \
  --serviceaccount=<namespace>:<sa> \
  -n <namespace>
```

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `ImagePullBackOff` | Cannot pull image | Check registry credentials, image name |
| `CrashLoopBackOff` | App crashes on startup | Check logs with `kubectl logs --previous` |
| `Pending` | Insufficient resources | Add resources or scale down other pods |
| `Connection refused` | Service not running | Check pod status and logs |
| `Timeout` | Service too slow | Increase timeouts or optimize performance |
| `Out of memory` | Pod memory exceeded | Increase memory limit or fix memory leak |
| `Disk pressure` | Low disk space | Clean up images or expand disk |
| `Network unreachable` | Network issue | Check NetworkPolicies and DNS |

## Getting Help

### Debug Bundles

```bash
# Generate diagnostic data
kubectl cluster-info dump --output-directory=./cluster-dump

# Check system components
kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl describe node <node-name>
```

### Useful Commands

```bash
# View recent events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Monitor pod changes
kubectl get pods -n <namespace> -w

# Stream logs from multiple pods
kubectl logs -f -l app=<label> -n <namespace>

# Port-forward for debugging
kubectl port-forward <pod-name> 8080:3000 -n <namespace>
```

## References

- [Kubernetes Troubleshooting](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application/)
- [Debugging Services](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service/)
- [Common Issues](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-pod-replication-controller/)
