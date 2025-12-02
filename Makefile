.PHONY: help build build-gpu up up-gpu up-external down logs logs-ollama shell shell-ollama test test-local test-cov test-watch lint clean restart restart-gpu stop start pull-model

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Docker compose files
COMPOSE_FILE := docker-compose.yml
COMPOSE_FILE_GPU := docker-compose.gpu.yml
COMPOSE_FILE_EXTERNAL := docker-compose.external.yml

# Default Ollama model
OLLAMA_MODEL ?= llama3.1:8b

help: ## Show this help message
	@echo "$(BLUE)AI Text Converter with Ollama - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make setup          # First time setup"
	@echo "  make up             # Start with local Ollama (CPU)"
	@echo "  make up-gpu         # Start with local Ollama (GPU)"
	@echo "  make up-external    # Use external Ollama instance"
	@echo "  make pull-model     # Download Ollama model"
	@echo "  make logs           # View logs"
	@echo "  make down           # Stop and remove containers"

setup: ## Initial setup - copy .env.example to .env
	@if [ ! -f .env ]; then \
		echo "$(GREEN)Creating .env file from .env.example...$(NC)"; \
		cp .env.example .env; \
		echo "$(YELLOW)⚠️  Please edit .env and add your API keys!$(NC)"; \
	else \
		echo "$(BLUE).env file already exists$(NC)"; \
	fi
	@mkdir -p temp
	@echo "$(GREEN)✓ Setup complete!$(NC)"

build: ## Build the Docker image (CPU version)
	@echo "$(BLUE)Building CPU version...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build
	@echo "$(GREEN)✓ Build complete!$(NC)"

build-gpu: ## Build the Docker image (GPU version)
	@echo "$(BLUE)Building GPU version...$(NC)"
	docker-compose -f $(COMPOSE_FILE_GPU) build
	@echo "$(GREEN)✓ Build complete!$(NC)"

up: setup ## Start the application with local Ollama (CPU version)
	@echo "$(BLUE)Starting CPU version with local Ollama...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✓ Application started!$(NC)"
	@echo "$(YELLOW)⏳ Waiting for Ollama to be ready...$(NC)"
	@sleep 5
	@echo "$(YELLOW)📥 Pull Ollama model with: make pull-model$(NC)"
	@echo "$(GREEN)🌐 Access at: http://localhost:8000/static/$(NC)"
	@echo "$(GREEN)📚 API docs at: http://localhost:8000/docs$(NC)"

up-gpu: setup ## Start the application with local Ollama (GPU version)
	@echo "$(BLUE)Starting GPU version with local Ollama...$(NC)"
	docker-compose -f $(COMPOSE_FILE_GPU) up -d
	@echo "$(GREEN)✓ Application started with GPU support!$(NC)"
	@echo "$(YELLOW)⏳ Waiting for Ollama to be ready...$(NC)"
	@sleep 5
	@echo "$(YELLOW)📥 Pull Ollama model with: make pull-model$(NC)"
	@echo "$(GREEN)🌐 Access at: http://localhost:8000/static/$(NC)"
	@echo "$(GREEN)📚 API docs at: http://localhost:8000/docs$(NC)"

up-external: setup ## Start using external Ollama instance
	@echo "$(BLUE)Starting with external Ollama...$(NC)"
	@echo "$(YELLOW)⚠️  Make sure EXTERNAL_OLLAMA_HOST is set in .env$(NC)"
	docker-compose -f $(COMPOSE_FILE_EXTERNAL) up -d
	@echo "$(GREEN)✓ Application started!$(NC)"
	@echo "$(GREEN)🌐 Access at: http://localhost:8000/static/$(NC)"
	@echo "$(GREEN)📚 API docs at: http://localhost:8000/docs$(NC)"

down: ## Stop and remove containers
	@echo "$(YELLOW)Stopping containers...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down 2>/dev/null || true
	@docker-compose -f $(COMPOSE_FILE_GPU) down 2>/dev/null || true
	@docker-compose -f $(COMPOSE_FILE_EXTERNAL) down 2>/dev/null || true
	@echo "$(GREEN)✓ Containers stopped$(NC)"

stop: ## Stop containers without removing them
	@echo "$(YELLOW)Stopping containers...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) stop 2>/dev/null || true
	@docker-compose -f $(COMPOSE_FILE_GPU) stop 2>/dev/null || true
	@docker-compose -f $(COMPOSE_FILE_EXTERNAL) stop 2>/dev/null || true
	@echo "$(GREEN)✓ Containers stopped$(NC)"

start: ## Start existing containers (CPU)
	@echo "$(BLUE)Starting containers...$(NC)"
	docker-compose -f $(COMPOSE_FILE) start
	@echo "$(GREEN)✓ Containers started$(NC)"

start-gpu: ## Start existing containers (GPU)
	@echo "$(BLUE)Starting containers...$(NC)"
	docker-compose -f $(COMPOSE_FILE_GPU) start
	@echo "$(GREEN)✓ Containers started$(NC)"

restart: ## Restart the application (CPU version)
	@echo "$(YELLOW)Restarting application...$(NC)"
	docker-compose -f $(COMPOSE_FILE) restart
	@echo "$(GREEN)✓ Application restarted$(NC)"

restart-gpu: ## Restart the application (GPU version)
	@echo "$(YELLOW)Restarting application...$(NC)"
	docker-compose -f $(COMPOSE_FILE_GPU) restart
	@echo "$(GREEN)✓ Application restarted$(NC)"

pull-model: ## Pull/download Ollama model (usage: make pull-model OLLAMA_MODEL=llama3.1:8b)
	@echo "$(BLUE)Pulling Ollama model: $(OLLAMA_MODEL)...$(NC)"
	@docker exec ollama-cpu ollama pull $(OLLAMA_MODEL) 2>/dev/null || docker exec ollama-gpu ollama pull $(OLLAMA_MODEL) 2>/dev/null || echo "$(RED)Ollama container not running. Start with 'make up' first.$(NC)"
	@echo "$(GREEN)✓ Model pulled successfully!$(NC)"

list-models: ## List available Ollama models
	@echo "$(BLUE)Available Ollama models:$(NC)"
	@docker exec ollama-cpu ollama list 2>/dev/null || docker exec ollama-gpu ollama list 2>/dev/null || echo "$(RED)Ollama container not running$(NC)"

logs: ## Show application logs (follow mode)
	@echo "$(BLUE)Showing logs (Ctrl+C to exit)...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) logs -f 2>/dev/null || docker-compose -f $(COMPOSE_FILE_GPU) logs -f 2>/dev/null || docker-compose -f $(COMPOSE_FILE_EXTERNAL) logs -f 2>/dev/null || echo "$(RED)No running containers found$(NC)"

logs-ollama: ## Show Ollama logs (follow mode)
	@echo "$(BLUE)Showing Ollama logs (Ctrl+C to exit)...$(NC)"
	@docker logs -f ollama-cpu 2>/dev/null || docker logs -f ollama-gpu 2>/dev/null || echo "$(RED)No Ollama container running$(NC)"

logs-tail: ## Show last 100 lines of logs
	@docker-compose -f $(COMPOSE_FILE) logs --tail=100 2>/dev/null || docker-compose -f $(COMPOSE_FILE_GPU) logs --tail=100 2>/dev/null || docker-compose -f $(COMPOSE_FILE_EXTERNAL) logs --tail=100 2>/dev/null || echo "$(RED)No running containers found$(NC)"

shell: ## Open a shell in the running container
	@echo "$(BLUE)Opening shell...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) exec text-converter /bin/bash 2>/dev/null || docker-compose -f $(COMPOSE_FILE_GPU) exec text-converter /bin/bash 2>/dev/null || docker exec -it text-converter-external /bin/bash 2>/dev/null || echo "$(RED)No running container found. Start it with 'make up' first.$(NC)"

shell-ollama: ## Open a shell in the Ollama container
	@echo "$(BLUE)Opening Ollama shell...$(NC)"
	@docker exec -it ollama-cpu /bin/bash 2>/dev/null || docker exec -it ollama-gpu /bin/bash 2>/dev/null || echo "$(RED)No Ollama container running$(NC)"

ps: ## Show running containers
	@echo "$(BLUE)Running containers:$(NC)"
	@docker ps --filter "name=text-converter\|ollama" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

health: ## Check application health
	@echo "$(BLUE)Checking application health...$(NC)"
	@curl -s http://localhost:8000/health | python3 -m json.tool || echo "$(RED)Application is not responding$(NC)"

test: ## Run integration tests with curl
	@echo "$(BLUE)Running integration tests...$(NC)"
	@chmod +x test.sh
	@./test.sh

lint: ## Run code linting
	@echo "$(BLUE)Running linters...$(NC)"
	@if command -v flake8 > /dev/null; then \
		echo "$(YELLOW)Running flake8...$(NC)"; \
		flake8 backend tests --max-line-length=120 --statistics || true; \
	fi
	@if command -v black > /dev/null; then \
		echo "$(YELLOW)Running black...$(NC)"; \
		black --check backend tests || true; \
	fi
	@if command -v isort > /dev/null; then \
		echo "$(YELLOW)Running isort...$(NC)"; \
		isort --check-only backend tests || true; \
	fi
	@echo "$(GREEN)✓ Linting complete$(NC)"

format: ## Auto-format code
	@echo "$(BLUE)Formatting code...$(NC)"
	@if command -v black > /dev/null && command -v isort > /dev/null; then \
		black backend tests; \
		isort backend tests; \
		echo "$(GREEN)✓ Code formatted$(NC)"; \
	else \
		echo "$(RED)black and isort required. Install with: pip install black isort$(NC)"; \
		exit 1; \
	fi

clean: down ## Clean up everything (containers, images, volumes)
	@echo "$(RED)Cleaning up...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down -v --rmi local 2>/dev/null || true
	@docker-compose -f $(COMPOSE_FILE_GPU) down -v --rmi local 2>/dev/null || true
	@docker-compose -f $(COMPOSE_FILE_EXTERNAL) down -v --rmi local 2>/dev/null || true
	@rm -rf temp/*
	@echo "$(YELLOW)⚠️  Note: Ollama models are preserved in volume 'ollama-data'$(NC)"
	@echo "$(YELLOW)   To remove models: docker volume rm text-converter_ollama-data$(NC)"
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

clean-temp: ## Clean temporary files
	@echo "$(YELLOW)Cleaning temporary files...$(NC)"
	@rm -rf temp/*
	@mkdir -p temp
	@echo "$(GREEN)✓ Temporary files cleaned$(NC)"

rebuild: down build up ## Rebuild and restart (CPU version)

rebuild-gpu: down build-gpu up-gpu ## Rebuild and restart (GPU version)

dev: ## Start in development mode with hot reload (CPU)
	@echo "$(BLUE)Starting in development mode...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up

dev-gpu: ## Start in development mode with hot reload (GPU)
	@echo "$(BLUE)Starting in development mode with GPU...$(NC)"
	docker-compose -f $(COMPOSE_FILE_GPU) up

status: ## Show application status and URLs
	@echo "$(BLUE)=== Application Status ===$(NC)"
	@echo ""
	@$(MAKE) -s ps
	@echo ""
	@echo "$(GREEN)Access URLs:$(NC)"
	@echo "  Web Interface: http://localhost:8000/static/"
	@echo "  API Documentation: http://localhost:8000/docs"
	@echo "  Health Check: http://localhost:8000/health"
	@echo "  Ollama API: http://localhost:11434"
	@echo ""
	@echo "$(YELLOW)Ollama Commands:$(NC)"
	@echo "  make pull-model OLLAMA_MODEL=llama3.1:8b  - Pull a model"
	@echo "  make list-models                           - List installed models"
	@echo "  make logs-ollama                           - View Ollama logs"
	@echo "  make shell-ollama                          - Open Ollama shell"
	@echo ""
	@echo "$(YELLOW)Testing Commands:$(NC)"
	@echo "  make test              - Run integration tests"
	@echo "  make lint              - Run code linters"
	@echo ""
	@echo "$(YELLOW)Useful commands:$(NC)"
	@echo "  make logs       - View logs"
	@echo "  make shell      - Open container shell"
	@echo "  make health     - Check health status"
