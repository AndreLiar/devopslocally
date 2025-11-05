#!/usr/bin/env bash
#
# Sealed Secrets Setup Script
# Initializes Sealed Secrets controller in Kubernetes cluster
# Manages encrypted secrets for GitOps workflows
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SEALED_SECRETS_VERSION="${1:-0.18.0}"
NAMESPACE="${SEALED_SECRETS_NAMESPACE:-kube-system}"
RELEASE_NAME="sealed-secrets"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Sealed Secrets Setup for Kubernetes  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo

# Step 1: Add Helm repository
echo -e "${YELLOW}[1/5]${NC} Adding Sealed Secrets Helm repository..."
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
echo -e "${GREEN}✓${NC} Repository added"
echo

# Step 2: Create namespace if it doesn't exist
echo -e "${YELLOW}[2/5]${NC} Ensuring namespace exists..."
kubectl get namespace "$NAMESPACE" &>/dev/null || kubectl create namespace "$NAMESPACE"
echo -e "${GREEN}✓${NC} Namespace '$NAMESPACE' ready"
echo

# Step 3: Install Sealed Secrets controller
echo -e "${YELLOW}[3/5]${NC} Installing Sealed Secrets controller v${SEALED_SECRETS_VERSION}..."
helm upgrade --install "$RELEASE_NAME" sealed-secrets/sealed-secrets \
  --namespace "$NAMESPACE" \
  --version "$SEALED_SECRETS_VERSION" \
  --set-string commandArgs="{--update-status=true,--skip-secret-rotation=false}" \
  --wait
echo -e "${GREEN}✓${NC} Sealed Secrets installed"
echo

# Step 4: Wait for the controller to be ready
echo -e "${YELLOW}[4/5]${NC} Waiting for Sealed Secrets controller to be ready..."
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=sealed-secrets \
  -n "$NAMESPACE" \
  --timeout=300s
echo -e "${GREEN}✓${NC} Controller is ready"
echo

# Step 5: Export and display the public key
echo -e "${YELLOW}[5/5]${NC} Setting up encryption key..."

# Create keys directory
mkdir -p "${HOME}/.sealed-secrets"

# Fetch and save the public key
kubectl get secret -n "$NAMESPACE" \
  -l sealedsecrets.bitnami.com/status=active \
  -o jsonpath='{.items[0].data.tls\.crt}' | \
  base64 -d > "${HOME}/.sealed-secrets/public-key.crt"

echo -e "${GREEN}✓${NC} Public key saved to ~/.sealed-secrets/public-key.crt"
echo

# Install kubeseal CLI if not present
if ! command -v kubeseal &> /dev/null; then
  echo -e "${YELLOW}Installing kubeseal CLI...${NC}"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install kubeseal
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v${SEALED_SECRETS_VERSION}/kubeseal-${SEALED_SECRETS_VERSION}-linux-amd64.tar.gz
    tar xfz kubeseal-${SEALED_SECRETS_VERSION}-linux-amd64.tar.gz
    sudo mv kubeseal /usr/local/bin/
    rm kubeseal-${SEALED_SECRETS_VERSION}-linux-amd64.tar.gz
  fi
  echo -e "${GREEN}✓${NC} kubeseal installed"
  echo
fi

# Display usage information
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Sealed Secrets Setup Complete! ✓    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo
echo -e "${BLUE}Usage Examples:${NC}"
echo
echo "1. Encrypt a secret and save as SealedSecret:"
echo "   echo -n 'my-password' | kubectl create secret generic my-secret --from-file=password=/dev/stdin --dry-run=client -o yaml | kubeseal -f - > my-sealed-secret.yaml"
echo
echo "2. Create a sealed secret interactively:"
echo "   kubeseal -f my-secret.yaml > my-sealed-secret.yaml"
echo
echo "3. Deploy sealed secret:"
echo "   kubectl apply -f my-sealed-secret.yaml"
echo
echo "4. List sealed secrets in namespace:"
echo "   kubectl get sealedsecrets"
echo
echo -e "${BLUE}Configuration Details:${NC}"
echo "  - Controller Namespace: $NAMESPACE"
echo "  - Public Key Location: ${HOME}/.sealed-secrets/public-key.crt"
echo "  - Version: $SEALED_SECRETS_VERSION"
echo

# Verify installation
echo -e "${YELLOW}Verifying installation...${NC}"
if kubectl get deployment -n "$NAMESPACE" "$RELEASE_NAME" &>/dev/null; then
  echo -e "${GREEN}✓${NC} Sealed Secrets is running successfully"
  kubectl get deployment -n "$NAMESPACE" "$RELEASE_NAME" -o wide
else
  echo -e "${RED}✗${NC} Sealed Secrets deployment not found"
  exit 1
fi
