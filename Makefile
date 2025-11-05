.PHONY: help setup deploy logs test clean build push port-forward status destroy check-prerequisites

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m

# Variables
PROJECT_DIR := $(shell pwd)
SCRIPTS_DIR := $(PROJECT_DIR)/scripts
REGISTRY_URL ?= localhost:5001
K8S_NAMESPACE ?= default
MONITORING_NAMESPACE ?= monitoring
GRAFANA_PORT ?= 3000
PROMETHEUS_PORT ?= 9090

help: ## Show this help message
	@echo -e "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo -e "$(BLUE)║  DevOps Lab - Makefile Commands                           ║$(NC)"
	@echo -e "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

check-prerequisites: ## Check all prerequisites (kubectl, helm, docker, git)
	@echo -e "$(BLUE)✅ Checking prerequisites...$(NC)"
	@$(SCRIPTS_DIR)/check-prerequisites.sh

setup: ## One-click infrastructure setup
	@echo -e "$(BLUE)🚀 Starting one-click setup...$(NC)"
	@$(SCRIPTS_DIR)/setup.sh

configure-env: ## Interactive environment configuration
	@echo -e "$(BLUE)⚙️  Configuring environment...$(NC)"
	@$(SCRIPTS_DIR)/configure-env.sh

create-service: ## Create new service (usage: make create-service NAME=my-api LANGUAGE=nodejs)
	@if [ -z "$(NAME)" ] || [ -z "$(LANGUAGE)" ]; then \
		echo -e "$(RED)❌ Usage: make create-service NAME=<service-name> LANGUAGE=<nodejs|python|go>$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(BLUE)📦 Creating service: $(NAME) ($(LANGUAGE))...$(NC)"
	@$(SCRIPTS_DIR)/create-service.sh "$(NAME)" "$(LANGUAGE)"

deploy: ## Deploy services to Kubernetes
	@echo -e "$(BLUE)📦 Deploying services...$(NC)"
	@helm upgrade --install auth-service ./auth-chart \
		--namespace $(K8S_NAMESPACE) \
		--set image.repository=$(REGISTRY_URL)/auth-service \
		--set image.tag=latest \
		--wait

build: ## Build auth-service Docker image
	@echo -e "$(BLUE)🐳 Building Docker image...$(NC)"
	@docker build -t $(REGISTRY_URL)/auth-service:latest -f auth-service/Dockerfile auth-service

push: build ## Build and push to registry
	@echo -e "$(BLUE)📤 Pushing image to registry...$(NC)"
	@docker push $(REGISTRY_URL)/auth-service:latest
	@echo -e "$(GREEN)✅ Image pushed to $(REGISTRY_URL)/auth-service:latest$(NC)"

logs: ## Stream logs from deployed service (usage: make logs SERVICE=auth-service)
	@if [ -z "$(SERVICE)" ]; then \
		echo -e "$(BLUE)Available pods:$(NC)"; \
		kubectl get pods -n $(K8S_NAMESPACE); \
		echo ""; \
		echo -e "$(BLUE)Usage: make logs SERVICE=<pod-name>$(NC)"; \
		exit 0; \
	fi
	@echo -e "$(BLUE)📋 Streaming logs from $(SERVICE)...$(NC)"
	@kubectl logs -f -n $(K8S_NAMESPACE) $(SERVICE) || echo "Pod not found"

exec: ## Execute command in pod (usage: make exec POD=auth-service CMD="ls -la")
	@if [ -z "$(POD)" ] || [ -z "$(CMD)" ]; then \
		echo -e "$(RED)❌ Usage: make exec POD=<pod-name> CMD=<command>$(NC)"; \
		exit 1; \
	fi
	@kubectl exec -it -n $(K8S_NAMESPACE) $(POD) -- $(CMD)

port-forward: ## Setup port forwarding for services
	@echo -e "$(BLUE)🔌 Setting up port forwarding...$(NC)"
	@echo -e "$(GREEN)Grafana:$(NC)    http://localhost:$(GRAFANA_PORT)"
	@echo -e "$(GREEN)Prometheus:$(NC) http://localhost:$(PROMETHEUS_PORT)"
	@echo ""
	@echo -e "$(BLUE)Starting port-forward in background...$(NC)"
	@kubectl port-forward -n $(MONITORING_NAMESPACE) svc/kube-prometheus-grafana $(GRAFANA_PORT):80 &
	@kubectl port-forward -n $(MONITORING_NAMESPACE) svc/kube-prometheus-prometheus $(PROMETHEUS_PORT):9090 &
	@sleep 2
	@echo -e "$(GREEN)✅ Port forwarding active$(NC)"

port-forward-grafana: ## Forward Grafana (3000:80)
	@kubectl port-forward -n $(MONITORING_NAMESPACE) svc/kube-prometheus-grafana 3000:80

port-forward-prometheus: ## Forward Prometheus (9090:9090)
	@kubectl port-forward -n $(MONITORING_NAMESPACE) svc/kube-prometheus-prometheus 9090:9090

port-forward-service: ## Forward auth-service (3001:3000)
	@kubectl port-forward -n $(K8S_NAMESPACE) svc/auth-service 3001:3000

status: ## Show cluster status
	@echo -e "$(BLUE)📊 Cluster Status$(NC)"
	@echo ""
	@echo -e "$(BLUE)Kubernetes Nodes:$(NC)"
	@kubectl get nodes -o wide
	@echo ""
	@echo -e "$(BLUE)Namespaces:$(NC)"
	@kubectl get namespaces
	@echo ""
	@echo -e "$(BLUE)Deployments:$(NC)"
	@kubectl get deployments -A
	@echo ""
	@echo -e "$(BLUE)Pods:$(NC)"
	@kubectl get pods -A
	@echo ""
	@echo -e "$(BLUE)Services:$(NC)"
	@kubectl get svc -A

test: ## Run tests
	@echo -e "$(BLUE)🧪 Running tests...$(NC)"
	@if [ -f "./tests/test-grafana-quick.sh" ]; then \
		./tests/test-grafana-quick.sh; \
	else \
		echo -e "$(RED)❌ Test file not found$(NC)"; \
	fi

lint: ## Lint Kubernetes manifests
	@echo -e "$(BLUE)🔍 Linting manifests...$(NC)"
	@helm lint ./auth-chart
	@echo -e "$(GREEN)✅ Helm chart validated$(NC)"

validate: ## Validate Helm charts
	@echo -e "$(BLUE)🔍 Validating charts...$(NC)"
	@helm template ./auth-chart --validate > /dev/null
	@echo -e "$(GREEN)✅ Charts validated$(NC)"

template: ## Show Helm template output
	@echo -e "$(BLUE)📄 Helm template output:$(NC)"
	@helm template auth-service ./auth-chart \
		--namespace $(K8S_NAMESPACE) \
		--set image.repository=$(REGISTRY_URL)/auth-service \
		--set image.tag=latest

shell: ## Open shell in auth-service pod
	@echo -e "$(BLUE)🐚 Opening shell in auth-service pod...$(NC)"
	@kubectl exec -it -n $(K8S_NAMESPACE) deployment/auth-service -- /bin/sh || \
		echo -e "$(RED)Pod not found. Deploy first with: make deploy$(NC)"

restart: ## Restart deployment
	@echo -e "$(BLUE)🔄 Restarting auth-service...$(NC)"
	@kubectl rollout restart deployment/auth-service -n $(K8S_NAMESPACE)
	@echo -e "$(GREEN)✅ Restart initiated$(NC)"

clean: ## Clean up local files and stopped containers
	@echo -e "$(BLUE)🧹 Cleaning up...$(NC)"
	@docker system prune -f
	@echo -e "$(GREEN)✅ Cleanup complete$(NC)"

destroy: ## WARNING: Destroy all resources (WARNING!)
	@echo -e "$(RED)⚠️  WARNING: This will delete all Kubernetes resources!$(NC)"
	@read -p "Are you sure? Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		echo -e "$(RED)🔥 Destroying resources...$(NC)"; \
		kubectl delete namespace argocd monitoring default --ignore-not-found=true; \
		echo -e "$(GREEN)✅ Resources destroyed$(NC)"; \
	else \
		echo "Cancelled"; \
	fi

docker-cleanup: ## Remove Docker images and containers
	@echo -e "$(BLUE)🐳 Cleaning Docker...$(NC)"
	@docker system prune -a -f
	@echo -e "$(GREEN)✅ Docker cleanup complete$(NC)"

check: ## Quick health check
	@echo -e "$(BLUE)🏥 Health Check$(NC)"
	@echo -n "Kubernetes: "
	@kubectl cluster-info > /dev/null 2>&1 && echo -e "$(GREEN)✓$(NC)" || echo -e "$(RED)✗$(NC)"
	@echo -n "Docker: "
	@docker ps > /dev/null 2>&1 && echo -e "$(GREEN)✓$(NC)" || echo -e "$(RED)✗$(NC)"
	@echo -n "Helm: "
	@helm version > /dev/null 2>&1 && echo -e "$(GREEN)✓$(NC)" || echo -e "$(RED)✗$(NC)"
	@echo ""
	@echo -e "$(BLUE)Cluster Info:$(NC)"
	@kubectl cluster-info | head -2
	@echo ""
	@echo -e "$(BLUE)Get started:$(NC)"
	@echo "  1. make setup              # One-click infrastructure setup"
	@echo "  2. make port-forward       # Start port forwarding"
	@echo "  3. open http://localhost:3000  # Access Grafana"
	@echo ""

.DEFAULT_GOAL := help
