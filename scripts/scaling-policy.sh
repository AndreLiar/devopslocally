#!/usr/bin/env bash
#
# Production Scaling Configuration
# HPA policies, resource optimization, multi-cluster setup
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Production Scaling Configuration     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo

# Configuration
NAMESPACE="${1:-default}"
DEPLOYMENT="${2:-auth-service}"
MIN_REPLICAS="${MIN_REPLICAS:-1}"
MAX_REPLICAS="${MAX_REPLICAS:-10}"
CPU_THRESHOLD="${CPU_THRESHOLD:-80}"
MEMORY_THRESHOLD="${MEMORY_THRESHOLD:-80}"

echo -e "${YELLOW}Configuration:${NC}"
echo "  Namespace: $NAMESPACE"
echo "  Deployment: $DEPLOYMENT"
echo "  Min replicas: $MIN_REPLICAS"
echo "  Max replicas: $MAX_REPLICAS"
echo "  CPU threshold: ${CPU_THRESHOLD}%"
echo "  Memory threshold: ${MEMORY_THRESHOLD}%"
echo

# Step 1: Create HPA
echo -e "${YELLOW}[1/4]${NC} Creating HorizontalPodAutoscaler..."

kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: $DEPLOYMENT
  namespace: $NAMESPACE
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: $DEPLOYMENT
  minReplicas: $MIN_REPLICAS
  maxReplicas: $MAX_REPLICAS
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: $CPU_THRESHOLD
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: $MEMORY_THRESHOLD
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
      - type: Pods
        value: 2
        periodSeconds: 30
      selectPolicy: Max
EOF

echo -e "${GREEN}✓${NC} HPA created"
echo

# Step 2: Verify resource requests/limits
echo -e "${YELLOW}[2/4]${NC} Checking resource requests/limits..."

REQUESTS=$(kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.requests}' 2>/dev/null)
LIMITS=$(kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.limits}' 2>/dev/null)

if [ -n "$REQUESTS" ] && [ -n "$LIMITS" ]; then
  echo -e "${GREEN}✓${NC} Resource requests/limits configured"
else
  echo -e "${YELLOW}⚠${NC} Consider setting resource requests/limits for better scaling"
  echo "  Add to values.yaml:"
  echo "    resources:"
  echo "      requests:"
  echo "        cpu: 250m"
  echo "        memory: 256Mi"
  echo "      limits:"
  echo "        cpu: 500m"
  echo "        memory: 512Mi"
fi
echo

# Step 3: Create Pod Disruption Budget
echo -e "${YELLOW}[3/4]${NC} Creating Pod Disruption Budget..."

kubectl apply -f - <<EOF
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: $DEPLOYMENT
  namespace: $NAMESPACE
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: $DEPLOYMENT
EOF

echo -e "${GREEN}✓${NC} PDB created"
echo

# Step 4: Monitor scaling
echo -e "${YELLOW}[4/4]${NC} HPA Status:"
echo

kubectl get hpa -n "$NAMESPACE" "$DEPLOYMENT" -w &
WATCH_PID=$!

sleep 5
kill $WATCH_PID 2>/dev/null || true

echo
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Scaling Configuration Complete! ✓    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo

echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Monitor scaling: kubectl get hpa -n $NAMESPACE -w"
echo "  2. Generate load: kubectl run -i --rm load-generator --image=busybox /bin/sh"
echo "  3. Inside pod: while sleep 0.01; do wget -q -O- http://$DEPLOYMENT; done"
echo "  4. Watch pods scale: kubectl get pods -n $NAMESPACE -w"
echo

echo -e "${BLUE}Resource Optimization Tips:${NC}"
echo "  • Use resource quotas per namespace"
echo "  • Set appropriate memory requests (avoid OOM)"
echo "  • Use node affinity for specific workloads"
echo "  • Consider cluster autoscaler for nodes"
echo "  • Use spot instances for non-critical workloads"
