#!/usr/bin/env bash
#
# Database Restore Script
# Restores PostgreSQL database from backup files
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
NAMESPACE="${POSTGRES_NAMESPACE:-default}"
BACKUP_DIR="${BACKUP_DIR:-./.backups}"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     PostgreSQL Database Restore Script  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo

# Step 1: Validate input
echo -e "${YELLOW}[1/4]${NC} Validating inputs..."

if [ -z "${1:-}" ]; then
  echo -e "${RED}✗${NC} No backup file specified"
  echo
  echo "Available backups:"
  ls -lh "$BACKUP_DIR"/postgres_backup_*.sql 2>/dev/null || echo "  No backups found"
  echo
  echo "Usage: $0 <backup-file>"
  exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
  echo -e "${RED}✗${NC} Backup file not found: $BACKUP_FILE"
  exit 1
fi

SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo -e "${GREEN}✓${NC} Backup file verified: $BACKUP_FILE ($SIZE)"
echo

# Step 2: Confirm restoration
echo -e "${YELLOW}[2/4]${NC} Restoration will:"
echo "  - DROP all existing data"
echo "  - RESTORE from: $BACKUP_FILE"
echo "  - Target namespace: $NAMESPACE"
echo

read -p "Continue with restoration? (yes/no): " -r CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo -e "${RED}✗${NC} Restoration cancelled"
  exit 0
fi
echo

# Step 3: Get database connection details
echo -e "${YELLOW}[3/4]${NC} Retrieving database connection details..."

POD_NAME=$(kubectl get pod -n "$NAMESPACE" -l app=postgres -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$POD_NAME" ]; then
  echo -e "${RED}✗${NC} PostgreSQL pod not found in namespace '$NAMESPACE'"
  exit 1
fi

DB_PASSWORD=$(kubectl get secret -n "$NAMESPACE" postgres-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo "postgres")

echo -e "${GREEN}✓${NC} Using pod: $POD_NAME"
echo

# Step 4: Perform restoration
echo -e "${YELLOW}[4/4]${NC} Restoring database..."

PGPASSWORD="$DB_PASSWORD" kubectl exec -i "$POD_NAME" -n "$NAMESPACE" -- \
  psql -U postgres postgres < "$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} Restoration completed successfully"
  echo
  echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║    Restoration Completed Successfully!  ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
else
  echo -e "${RED}✗${NC} Restoration failed"
  exit 1
fi
