#!/usr/bin/env bash
#
# Database Backup Script
# Creates PostgreSQL database backups to local or cloud storage
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
RELEASE_NAME="${POSTGRES_RELEASE:-postgres}"
BACKUP_DIR="${BACKUP_DIR:-./.backups}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     PostgreSQL Database Backup Script   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo

# Step 1: Validate prerequisites
echo -e "${YELLOW}[1/5]${NC} Validating prerequisites..."

if ! command -v kubectl &> /dev/null; then
  echo -e "${RED}✗${NC} kubectl not found"
  exit 1
fi

if ! command -v pg_dump &> /dev/null; then
  echo -e "${YELLOW}⚠${NC} pg_dump not found, installing..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install postgresql
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get install -y postgresql-client
  fi
fi

echo -e "${GREEN}✓${NC} Prerequisites verified"
echo

# Step 2: Create backup directory
echo -e "${YELLOW}[2/5]${NC} Preparing backup directory..."
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/postgres_backup_${TIMESTAMP}.sql"
echo -e "${GREEN}✓${NC} Backup directory ready: $BACKUP_DIR"
echo

# Step 3: Get database connection details
echo -e "${YELLOW}[3/5]${NC} Retrieving database connection details..."

# Get pod name
POD_NAME=$(kubectl get pod -n "$NAMESPACE" -l app=postgres -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$POD_NAME" ]; then
  echo -e "${RED}✗${NC} PostgreSQL pod not found in namespace '$NAMESPACE'"
  exit 1
fi

# Get password
DB_PASSWORD=$(kubectl get secret -n "$NAMESPACE" postgres-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo "postgres")

echo -e "${GREEN}✓${NC} Using pod: $POD_NAME"
echo

# Step 4: Create backup
echo -e "${YELLOW}[4/5]${NC} Creating backup..."

PGPASSWORD="$DB_PASSWORD" kubectl exec -i "$POD_NAME" -n "$NAMESPACE" -- \
  pg_dump -U postgres postgres > "$BACKUP_FILE"

if [ -s "$BACKUP_FILE" ]; then
  SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
  echo -e "${GREEN}✓${NC} Backup created: $BACKUP_FILE ($SIZE)"
else
  echo -e "${RED}✗${NC} Backup file is empty"
  rm -f "$BACKUP_FILE"
  exit 1
fi
echo

# Step 5: Cleanup old backups
echo -e "${YELLOW}[5/5]${NC} Cleaning up old backups (older than ${RETENTION_DAYS} days)..."

find "$BACKUP_DIR" -name "postgres_backup_*.sql" -mtime +"$RETENTION_DAYS" -delete

CURRENT_COUNT=$(find "$BACKUP_DIR" -name "postgres_backup_*.sql" | wc -l)
echo -e "${GREEN}✓${NC} Cleanup complete. Kept $CURRENT_COUNT recent backups"
echo

# Summary
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      Backup Completed Successfully! ✓  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo
echo -e "${BLUE}Backup Details:${NC}"
echo "  - File: $BACKUP_FILE"
echo "  - Size: $SIZE"
echo "  - Database: postgres"
echo "  - Timestamp: $TIMESTAMP"
echo "  - Retention: ${RETENTION_DAYS} days"
echo

# Optional: Upload to S3 if configured
if [ -n "${AWS_S3_BUCKET:-}" ]; then
  echo -e "${YELLOW}Uploading to S3...${NC}"
  if command -v aws &> /dev/null; then
    aws s3 cp "$BACKUP_FILE" "s3://${AWS_S3_BUCKET}/backups/postgres/"
    echo -e "${GREEN}✓${NC} Uploaded to S3: s3://${AWS_S3_BUCKET}/backups/postgres/$(basename "$BACKUP_FILE")"
  else
    echo -e "${YELLOW}⚠${NC} AWS CLI not found, skipping S3 upload"
  fi
fi
