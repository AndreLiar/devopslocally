# Cost Optimization Guide

Strategies to reduce Kubernetes infrastructure costs while maintaining performance and reliability.

## Table of Contents

1. [Resource Right-Sizing](#resource-right-sizing)
2. [Spot Instances](#spot-instances)
3. [Reserved Instances](#reserved-instances)
4. [Storage Optimization](#storage-optimization)
5. [Networking Cost Reduction](#networking-cost-reduction)
6. [Monitoring & Budgeting](#monitoring--budgeting)

---

## Resource Right-Sizing

### Finding Over-Provisioned Pods

```bash
# Compare requested vs actual usage
kubectl top pod -n default --containers

# Check requests vs limits
kubectl get pod -n default -o json | jq '.items[] | {
  name: .metadata.name,
  requests: .spec.containers[0].resources.requests,
  limits: .spec.containers[0].resources.limits,
  actual_cpu: .status.containerStatuses[0].usage
}'
```

### Recommended Resource Values

**Small Services (< 100 req/sec)**:
```yaml
resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 200m
    memory: 256Mi
```

**Medium Services (100-1000 req/sec)**:
```yaml
resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

**Large Services (> 1000 req/sec)**:
```yaml
resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: 2000m
    memory: 2Gi
```

### Implementation

```bash
# Set conservative requests (actual usage + 20%)
kubectl set resources deployment auth-service \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=300m,memory=256Mi -n default

# Monitor and adjust after 1 week
watch kubectl top pod -l app=auth-service -n default
```

**Estimated Savings**: 20-40% reduction in resource costs

---

## Spot Instances

### Setup Spot Instance Node Pool

```bash
# For AWS EKS (example)
eksctl create nodegroup \
  --cluster=my-cluster \
  --name=spot-workers \
  --instance-types=t3.medium,t3.large,t2.medium \
  --spot \
  --on-demand-base-capacity=0 \
  --on-demand-percentage-above-base-capacity=0
```

### Configure Pod Affinity

```yaml
# Schedule non-critical workloads on spot instances
apiVersion: apps/v1
kind: Deployment
metadata:
  name: batch-processor
spec:
  template:
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: karpenter.sh/capacity-type
                operator: In
                values: ["spot"]
      containers:
      - name: processor
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
      tolerations:
      - key: karpenter.sh/do-not-evict
        operator: Equal
        value: "true"
        effect: NoSchedule
```

### Pod Disruption Budget for Spot Pods

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: batch-processor-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: batch-processor
```

**Estimated Savings**: 70-90% on compute for non-critical workloads

---

## Reserved Instances

### Purchase Reserved Instances

```bash
# Analyze usage to determine reserve size
kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.allocatable.cpu,MEMORY:.status.allocatable.memory

# Calculate total capacity needed
# Multiply by 1.2x for buffer
# Purchase 12-month or 3-year reservations for 30-50% savings
```

### Blend Reserved + On-Demand

**Recommendation**:
- Reserve instances for: Critical services, baseline load, 24/7 services
- On-demand for: Non-critical, bursty workloads
- Spot for: Batch jobs, analytics, non-critical processing

**Cost Formula**:
```
Total Cost = (Reserved Capacity × Reserved Price) + 
             (On-Demand Capacity × On-Demand Price) + 
             (Spot Capacity × Spot Price)
```

**Example**:
```
10 vCPU × $0.10/hr (reserved 1yr) = $8,760/year
5 vCPU × $0.15/hr (on-demand) = $6,570/year
5 vCPU × $0.06/hr (spot) = $2,628/year
Total = $17,958/year (vs $26,280 all on-demand = 32% savings)
```

---

## Storage Optimization

### Monitor Storage Usage

```bash
# Check PVC usage
kubectl get pvc -A

# Get detailed storage stats
kubectl exec postgres-0 -n default -- du -sh /var/lib/postgresql/data

# Identify large objects
kubectl exec postgres-0 -n default -- psql -U postgres -c "
  SELECT schemaname, tablename, 
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
  FROM pg_tables
  ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
  LIMIT 10;"
```

### Optimization Strategies

**1. Storage Class Selection**:
```bash
# Use cheaper storage for non-critical data
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard-gp2  # AWS: Lower cost, good performance
provisioner: ebs.csi.aws.com
parameters:
  type: gp2
  iops: "100"
  volumeBindingMode: WaitForFirstConsumer
EOF
```

**2. Data Tiering**:
```yaml
# Hot data on fast storage
# Cold data on cheaper storage
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: hot-data
spec:
  storageClassName: premium-ssd
  accessModes: [ReadWriteOnce]
  resources:
    storage: 10Gi

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cold-data
spec:
  storageClassName: standard-hdd
  accessModes: [ReadWriteOnce]
  resources:
    storage: 100Gi
```

**3. Compression & Cleanup**:
```bash
# Compress old backups
gzip .backups/postgres_backup_*.sql

# Archive to cheaper storage (S3 Glacier)
aws s3 cp postgres_backup_old.sql.gz \
  s3://my-bucket/archive/postgres_backup_old.sql.gz \
  --storage-class GLACIER

# Delete local copy
rm postgres_backup_old.sql.gz
```

**Estimated Savings**: 10-30% on storage costs

---

## Networking Cost Reduction

### Data Transfer Optimization

**1. Use NAT Gateway Efficiently**:
```bash
# Check NAT Gateway usage
aws ec2 describe-nat-gateways --filter Name=state,Values=available
```

**2. Internal Load Balancing**:
```yaml
# Use internal LoadBalancer instead of internet-facing
apiVersion: v1
kind: Service
metadata:
  name: internal-api
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 3000
    targetPort: 3000
```

**3. Eliminate Cross-AZ Traffic**:
```yaml
# Prefer same-zone deployments
affinity:
  podAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values: [my-service]
        topologyKey: topology.kubernetes.io/zone
```

**Estimated Savings**: 5-20% on networking costs

---

## Monitoring & Budgeting

### Cost Tracking Dashboard

```bash
# Install kubecost (optional but recommended)
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm install kubecost kubecost/cost-analyzer \
  --namespace kubecost --create-namespace

# Access dashboard
kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090
# Visit http://localhost:9090
```

### Budget Alerts

```bash
# Set up AWS budget alerts
aws budgets create-budget \
  --account-id 123456789012 \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

**budget.json**:
```json
{
  "BudgetName": "K8s-Monthly",
  "BudgetLimit": {
    "Amount": "1000",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
  "CostFilters": {
    "TagKeyValue": ["Environment$production"]
  }
}
```

### Cost Analysis Queries

```bash
# Get cost per namespace
kubectl get ns -o json | jq '.items[].metadata.name' | while read ns; do
  echo "Namespace: $ns"
  kubectl top pod -n $ns --no-headers | awk '{sum+=$2} END {print "Memory:", sum " Mi"}'
done

# Get cost per app
kubectl get pods -A -o json | jq -r '.items[] | "\(.metadata.labels.app) \(.spec.containers[0].resources.requests.memory)"' | sort | uniq
```

---

## Implementation Roadmap

### Month 1: Baseline
- Audit current resource usage
- Implement right-sizing
- Set up cost tracking
- **Target Savings**: 10-15%

### Month 2: Optimization
- Implement spot instances
- Optimize storage
- Configure reserved instances
- **Target Savings**: 20-30%

### Month 3: Advanced
- Implement service mesh cost optimization
- Container image optimization
- Database connection pooling
- **Target Savings**: 30-40%

---

## Cost Reduction Checklist

- [ ] Resource requests/limits optimized
- [ ] Spot instances configured
- [ ] Reserved instances purchased
- [ ] Storage classes optimized
- [ ] Data tiering implemented
- [ ] NAT Gateway usage minimized
- [ ] Cross-AZ traffic eliminated
- [ ] Cost monitoring enabled
- [ ] Budget alerts configured
- [ ] Regular cost reviews scheduled

---

## Expected Savings Summary

| Optimization | Effort | Savings | Timeline |
|---|---|---|---|
| Right-sizing | Low | 15-25% | 1-2 weeks |
| Spot instances | Medium | 70-90% (spot capacity) | 2-4 weeks |
| Reserved instances | Low | 30-50% | Ongoing |
| Storage optimization | Medium | 10-30% | 1-2 weeks |
| Networking optimization | Low | 5-20% | 1 week |
| **Total Potential** | **Medium** | **40-60%** | **1-2 months** |

---

## References

- [Kubernetes Cost Optimization](https://kubernetes.io/docs/concepts/configuration/overview/)
- [AWS Cost Optimization](https://aws.amazon.com/economics/cost-optimization/)
- [Kubecost Documentation](https://guide.kubecost.com/)
- [Spot Instances Guide](https://aws.amazon.com/ec2/spot/getting-started/)
