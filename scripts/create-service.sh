#!/bin/bash

################################################################################
# Service Generator Script
# Creates a new microservice with scaffolding, Helm chart, and CI/CD pipeline
#
# Usage: ./scripts/create-service.sh <service-name> <language>
# Example: ./scripts/create-service.sh payment nodejs
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $*${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

log_error() {
    echo -e "${RED}❌ $*${NC}"
}

log_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$*${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Validate input
if [ $# -lt 2 ]; then
    log_error "Missing required arguments"
    echo ""
    echo "Usage: ./scripts/create-service.sh <service-name> <language>"
    echo ""
    echo "Supported languages:"
    echo "  • nodejs"
    echo "  • python"
    echo "  • go"
    echo ""
    echo "Examples:"
    echo "  ./scripts/create-service.sh payment nodejs"
    echo "  ./scripts/create-service.sh inventory python"
    echo "  ./scripts/create-service.sh user-service go"
    exit 1
fi

SERVICE_NAME="$1"
LANGUAGE="$2"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_DIR="$PROJECT_DIR/${SERVICE_NAME}-service"
CHART_DIR="$PROJECT_DIR/${SERVICE_NAME}-chart"

# Validate language
case "$LANGUAGE" in
    nodejs|node)
        LANGUAGE="nodejs"
        PORT=3000
        ;;
    python|py)
        LANGUAGE="python"
        PORT=5000
        ;;
    go)
        LANGUAGE="go"
        PORT=8080
        ;;
    *)
        log_error "Unsupported language: $LANGUAGE"
        echo "Supported: nodejs, python, go"
        exit 1
        ;;
esac

log_section "🎉 Creating New Service: $SERVICE_NAME ($LANGUAGE)"

# Check if service already exists
if [ -d "$SERVICE_DIR" ]; then
    log_error "Service directory already exists: $SERVICE_DIR"
    exit 1
fi

if [ -d "$CHART_DIR" ]; then
    log_error "Helm chart directory already exists: $CHART_DIR"
    exit 1
fi

# Create service directory
log_info "Creating service directory..."
mkdir -p "$SERVICE_DIR"
log_success "Service directory created"

# Create service based on language
log_section "Setting up $LANGUAGE service"

# Function to create Node.js service
create_nodejs_service() {
    log_info "Generating Node.js service boilerplate..."
    
    # Create package.json
    cat > "$SERVICE_DIR/package.json" << 'EOF'
{
  "name": "@app/SERVICE_NAME",
  "version": "1.0.0",
  "description": "SERVICE_NAME microservice",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "jest --coverage",
    "test:watch": "jest --watch",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write .",
    "health-check": "node health-check.js"
  },
  "keywords": ["microservice", "express"],
  "author": "DevOps Team",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "dotenv": "^16.0.3",
    "pino": "^8.11.0",
    "pino-http": "^8.3.3"
  },
  "devDependencies": {
    "nodemon": "^2.0.20",
    "jest": "^29.5.0",
    "supertest": "^6.3.3",
    "eslint": "^8.38.0",
    "prettier": "^2.8.7"
  }
}
EOF
    
    # Create server.js
    cat > "$SERVICE_DIR/server.js" << 'EOF'
const express = require("express");
const pinoHttp = require("pino-http");
const dotenv = require("dotenv");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(pinoHttp());
app.use(express.json());

// Routes
app.get("/", (req, res) => {
  res.json({
    message: "SERVICE_NAME service is running",
    version: "1.0.0",
    status: "healthy",
    timestamp: new Date().toISOString(),
  });
});

app.get("/health", (req, res) => {
  res.json({ status: "ok", service: "SERVICE_NAME" });
});

app.get("/ready", (req, res) => {
  res.json({ ready: true });
});

// Error handling
app.use((err, req, res, next) => {
  req.log.error(err);
  res.status(500).json({ error: "Internal Server Error" });
});

// Start server
app.listen(PORT, () => {
  console.log(`✓ SERVICE_NAME service listening on port ${PORT}`);
});

module.exports = app;
EOF
    
    # Create .env.example
    cat > "$SERVICE_DIR/.env.example" << 'EOF'
PORT=3000
NODE_ENV=development
LOG_LEVEL=info
EOF
    
    # Create Dockerfile
    cat > "$SERVICE_DIR/Dockerfile" << 'EOF'
FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application
COPY . .

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD node health-check.js

EXPOSE 3000

USER node

CMD ["npm", "start"]
EOF
    
    # Create health-check.js
    cat > "$SERVICE_DIR/health-check.js" << 'EOF'
const http = require("http");

const options = {
  hostname: "localhost",
  port: process.env.PORT || 3000,
  path: "/health",
  method: "GET",
  timeout: 2000,
};

const req = http.request(options, (res) => {
  if (res.statusCode == 200) {
    process.exit(0);
  } else {
    process.exit(1);
  }
});

req.on("error", (err) => {
  console.error("Health check failed:", err.message);
  process.exit(1);
});

req.end();
EOF
    
    # Create .gitignore
    cat > "$SERVICE_DIR/.gitignore" << 'EOF'
node_modules/
dist/
coverage/
.env.local
.env.*.local
npm-debug.log*
.DS_Store
.vscode/
.idea/
EOF
    
    log_success "Node.js service boilerplate created"
}

# Function to create Python service
create_python_service() {
    log_info "Generating Python service boilerplate..."
    
    # Create requirements.txt
    cat > "$SERVICE_DIR/requirements.txt" << 'EOF'
Flask==2.3.2
python-dotenv==1.0.0
gunicorn==20.1.0
Werkzeug==2.3.6
EOF
    
    # Create server.py
    cat > "$SERVICE_DIR/server.py" << 'EOF'
import os
from flask import Flask, jsonify
from datetime import datetime
import logging

from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
PORT = int(os.getenv("PORT", 5000))
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

# Configure logging
logging.basicConfig(level=LOG_LEVEL)
logger = logging.getLogger(__name__)

@app.route("/")
def index():
    return jsonify({
        "message": "SERVICE_NAME service is running",
        "version": "1.0.0",
        "status": "healthy",
        "timestamp": datetime.now().isoformat()
    })

@app.route("/health")
def health():
    return jsonify({"status": "ok", "service": "SERVICE_NAME"})

@app.route("/ready")
def ready():
    return jsonify({"ready": True})

@app.errorhandler(500)
def internal_error(error):
    logger.error(f"Internal server error: {error}")
    return jsonify({"error": "Internal Server Error"}), 500

if __name__ == "__main__":
    logger.info(f"Starting SERVICE_NAME service on port {PORT}")
    app.run(host="0.0.0.0", port=PORT, debug=False)
EOF
    
    # Create .env.example
    cat > "$SERVICE_DIR/.env.example" << 'EOF'
PORT=5000
FLASK_ENV=development
LOG_LEVEL=INFO
EOF
    
    # Create Dockerfile
    cat > "$SERVICE_DIR/Dockerfile" << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health').read()"

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "server:app"]
EOF
    
    # Create .gitignore
    cat > "$SERVICE_DIR/.gitignore" << 'EOF'
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.env.local
.env.*.local
.vscode/
.idea/
.DS_Store
*.egg-info/
dist/
build/
EOF
    
    log_success "Python service boilerplate created"
}

# Function to create Go service
create_go_service() {
    log_info "Generating Go service boilerplate..."
    
    # Create go.mod
    cat > "$SERVICE_DIR/go.mod" << 'EOF'
module github.com/app/SERVICE_NAME

go 1.21

require github.com/gin-gonic/gin v1.9.1
EOF
    
    # Create main.go
    cat > "$SERVICE_DIR/main.go" << 'EOF'
package main

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	router := gin.Default()

	router.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message":   "SERVICE_NAME service is running",
			"version":   "1.0.0",
			"status":    "healthy",
			"timestamp": time.Now().Format(time.RFC3339),
		})
	})

	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"service": "SERVICE_NAME",
		})
	})

	router.GET("/ready", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"ready": true,
		})
	})

	fmt.Printf("Starting SERVICE_NAME service on port %s\n", port)
	router.Run(":" + port)
}
EOF
    
    # Create .env.example
    cat > "$SERVICE_DIR/.env.example" << 'EOF'
PORT=8080
GIN_MODE=debug
LOG_LEVEL=info
EOF
    
    # Create Dockerfile
    cat > "$SERVICE_DIR/Dockerfile" << 'EOF'
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum* ./
RUN go mod download || true
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o service .

# Runtime stage
FROM alpine:latest

WORKDIR /app
COPY --from=builder /app/service .

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

EXPOSE 8080

CMD ["./service"]
EOF
    
    # Create .gitignore
    cat > "$SERVICE_DIR/.gitignore" << 'EOF'
service
*.o
*.a
*.so
.DS_Store
.env.local
.env.*.local
.vscode/
.idea/
vendor/
.git/
EOF
    
    log_success "Go service boilerplate created"
}

# Execute service creation
case "$LANGUAGE" in
    nodejs)
        create_nodejs_service
        ;;
    python)
        create_python_service
        ;;
    go)
        create_go_service
        ;;
esac

# Create Helm chart
create_helm_chart

# Create CI/CD workflow
create_workflow

# Print summary
print_summary
