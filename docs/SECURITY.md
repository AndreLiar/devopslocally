# Security Best Practices

This guide covers security hardening for the devopslocally project deployment.

## Table of Contents

1. [Sealed Secrets](#sealed-secrets)
2. [Role-Based Access Control (RBAC)](#rbac)
3. [Pod Security](#pod-security)
4. [Network Security](#network-security)
5. [Data Protection](#data-protection)
6. [Audit and Compliance](#audit-and-compliance)

## Sealed Secrets

Sealed Secrets encrypt your secrets at rest and in transit.

### Setup

```bash
# Initialize Sealed Secrets
./scripts/setup-sealed-secrets.sh

# Create a sealed secret
echo -n 'my-password' | kubectl create secret generic my-secret \
  --from-file=password=/dev/stdin --dry-run=client -o yaml | \
  kubeseal -f - > my-sealed-secret.yaml

# Deploy
kubectl apply -f my-sealed-secret.yaml
```

### Best Practices

- Use a separate encryption key per namespace
- Store the sealing key securely
- Rotate keys regularly (quarterly recommended)
- Enable backup of sealed secret keys
- Use sealed secrets for all sensitive data

### Backup Sealing Keys

```bash
# Export sealing key
kubectl get secret -n kube-system \
  -l sealedsecrets.bitnami.com/status=active \
  -o jsonpath='{.items[0].data.tls\.crt}' | base64 -d > sealing-key.crt

kubectl get secret -n kube-system \
  -l sealedsecrets.bitnami.com/status=active \
  -o jsonpath='{.items[0].data.tls\.key}' | base64 -d > sealing-key.key

# Store securely (e.g., encrypted backup)
```

## RBAC

Role-Based Access Control restricts who can do what in your cluster.

### Default Roles

The project includes default RBAC configuration:

```yaml
# Only read access to ConfigMaps and Secrets
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list", "watch"]

# Read-only pod discovery
- apiGroups: [""]
  resources: ["pods", "services", "endpoints"]
  verbs: ["get", "list", "watch"]
```

### Creating Custom Roles

```bash
# View current RBAC
kubectl get roles -n default
kubectl get rolebindings -n default

# Create custom role
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# Bind to service account
kubectl create rolebinding pod-reader-binding \
  --clusterrole=pod-reader \
  --serviceaccount=default:myapp
```

### Audit RBAC

```bash
# Check what permissions a service account has
kubectl auth can-i get pods --as=system:serviceaccount:default:myapp

# Check all permissions for a role
kubectl describe role my-role
```

## Pod Security

### Security Context

Configure security context in your Helm values:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 3000
  fsGroup: 2000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
    add:
      - NET_BIND_SERVICE
```

### Pod Security Standards

Enable Pod Security Standards (PSS):

```bash
# Label namespace for restricted policy
kubectl label namespace default \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
```

### Pod Disruption Budgets

Ensure availability during disruptions:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: myapp-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: myapp
```

## Network Security

### NetworkPolicies

Restrict pod-to-pod communication:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: client
    ports:
    - protocol: TCP
      port: 3000
```

### Ingress Security

Configure TLS for ingress:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: myapp
            port:
              number: 3000
```

## Data Protection

### Encryption at Rest

Enable etcd encryption (cluster-level):

```bash
# Check if encryption is enabled
kubectl get secrets -A -o json | \
  jq '.items[] | select(.type=="kubernetes.io/service-account-token")' | wc -l
```

### Encryption in Transit

Use TLS for all communication:

```bash
# Generate TLS certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt

# Create secret
kubectl create secret tls myapp-tls \
  --cert=tls.crt \
  --key=tls.key

# Use in ingress
# See examples above
```

## Audit and Compliance

### Security Audit Script

Run comprehensive security checks:

```bash
# Full namespace audit
./scripts/security-audit.sh default

# Check specific issues
kubectl get pods -n default -o json | \
  jq '.items[] | select(.spec.containers[].securityContext.privileged==true)'
```

### Logging and Monitoring

Monitor security events:

```bash
# View authentication failures
kubectl logs -n kube-system deployment/kube-apiserver | grep "authentication failed"

# Monitor RBAC denials
kubectl get events -n default --field-selector reason=Forbidden

# Check for privilege escalation
kubectl get pods -A -o json | \
  jq '.items[] | select(.spec.containers[].securityContext.allowPrivilegeEscalation!=false)'
```

### Compliance Checks

Regular compliance verification:

```bash
# CIS Kubernetes Benchmark checks
./scripts/security-audit.sh <namespace>

# Pod security scan
kubectl get pods -n default -o json | \
  jq '.items[] | {name: .metadata.name, securityContext: .spec.containers[].securityContext}'
```

## Security Checklist

- [ ] Sealed Secrets configured
- [ ] RBAC roles defined and assigned
- [ ] Pod Security Standards enforced
- [ ] NetworkPolicies in place
- [ ] Pod Disruption Budgets configured
- [ ] TLS certificates installed
- [ ] Resource limits set
- [ ] Non-root containers
- [ ] Regular security audits scheduled
- [ ] Audit logging enabled
- [ ] Secrets rotated quarterly
- [ ] Image scanning enabled
- [ ] Runtime security monitoring
- [ ] Compliance checks passing

## Troubleshooting

### Sealed Secrets not decrypting

```bash
# Check if sealing key is accessible
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/status=active

# Verify controller is running
kubectl get deployment -n kube-system sealed-secrets
```

### RBAC permission denied

```bash
# Check permissions for service account
kubectl auth can-i get pods --as=system:serviceaccount:default:myapp -n default

# View role bindings
kubectl describe rolebinding <name> -n default
```

### Network policies blocking traffic

```bash
# Check network policies
kubectl get networkpolicies -n default

# Test connectivity between pods
kubectl run -it debug --image=busybox:1.28 -- sh
```

## References

- [Kubernetes Security Documentation](https://kubernetes.io/docs/concepts/security/)
- [Sealed Secrets GitHub](https://github.com/bitnami-labs/sealed-secrets)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [NetworkPolicy Documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
