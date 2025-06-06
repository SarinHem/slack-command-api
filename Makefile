# Load environment variables from .env file
include .env
export

# Define colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[0;37m
NC := \033[0m # No Color

# Phony targets (targets that don't represent files)
.PHONY: default help build run stop push clean clean-untag pull-code logs shell status deploy health check-env check-docker

# Default target
default: help

# Help target - shows available commands
help:
	@echo ""
	@echo "$(CYAN)🐳 Slack API Docker Project$(NC)"
	@echo "$(CYAN)============================$(NC)"
	@echo ""
	@echo "$(WHITE)Usage: make [target]$(NC)"
	@echo ""
	@echo "$(GREEN)📋 Available Targets:$(NC)"
	@echo "  $(YELLOW)pull-code$(NC)    - Pull latest code from GitHub"
	@echo "  $(YELLOW)build$(NC)        - Build the Docker image"
	@echo "  $(YELLOW)run$(NC)          - Pull latest image and run container"
	@echo "  $(YELLOW)stop$(NC)         - Stop and remove the container"
	@echo "  $(YELLOW)logs$(NC)         - Show container logs"
	@echo "  $(YELLOW)shell$(NC)        - Access container shell"
	@echo "  $(YELLOW)status$(NC)       - Show container status"
	@echo "  $(YELLOW)push$(NC)         - Tag and push image to Docker Hub"
	@echo "  $(YELLOW)deploy$(NC)       - Full deployment (build + push)"
	@echo "  $(YELLOW)health$(NC)       - Check application health"
	@echo "  $(YELLOW)clean$(NC)        - Remove local Docker image"
	@echo "  $(YELLOW)clean-untag$(NC)  - Remove untagged images"
	@echo "  $(YELLOW)check-env$(NC)    - Validate environment configuration"
	@echo "  $(YELLOW)check-docker$(NC) - Check Docker setup"
	@echo ""
	@echo "$(GREEN)🔧 Configuration:$(NC)"
	@echo "  Image: $(BLUE)$(IMAGE_NAME):$(TAG)$(NC)"
	@echo "  Container: $(BLUE)$(CONTAINER_NAME)$(NC)"
	@echo "  Port: $(BLUE)$(PORT)$(NC)"
	@echo ""

# Check if .env file exists and required variables are set
check-env:
	@echo "$(BLUE)🔍 Checking environment configuration...$(NC)"
	@if [ ! -f .env ]; then \
		echo "$(RED)❌ Error: .env file not found!$(NC)"; \
		echo "$(YELLOW)💡 Please create a .env file with required variables$(NC)"; \
		exit 1; \
	fi
	@if [ -z "$(IMAGE_NAME)" ]; then echo "$(RED)❌ IMAGE_NAME not set$(NC)"; exit 1; fi
	@if [ -z "$(TAG)" ]; then echo "$(RED)❌ TAG not set$(NC)"; exit 1; fi
	@if [ -z "$(CONTAINER_NAME)" ]; then echo "$(RED)❌ CONTAINER_NAME not set$(NC)"; exit 1; fi
	@if [ -z "$(PORT)" ]; then echo "$(RED)❌ PORT not set$(NC)"; exit 1; fi
	@if [ -z "$(GITHUB_USERNAME)" ]; then echo "$(RED)❌ GITHUB_USERNAME not set$(NC)"; exit 1; fi
	@if [ -z "$(GITHUB_TOKEN)" ]; then echo "$(RED)❌ GITHUB_TOKEN not set$(NC)"; exit 1; fi
	@if [ -z "$(GIT_REPO)" ]; then echo "$(RED)❌ GIT_REPO not set$(NC)"; exit 1; fi
	@echo "$(GREEN)✅ Environment configuration is valid$(NC)"

# Check Docker installation and login status
check-docker:
	@echo "$(BLUE)🔍 Checking Docker setup...$(NC)"
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "$(RED)❌ Docker is not installed or not in PATH$(NC)"; \
		exit 1; \
	fi
	@if ! docker info >/dev/null 2>&1; then \
		echo "$(RED)❌ Docker daemon is not running$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✅ Docker is properly configured$(NC)"
	@if docker info 2>/dev/null | grep -q "Username:"; then \
		echo "$(GREEN)✅ Docker Hub login detected$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Not logged into Docker Hub (required for push)$(NC)"; \
	fi

# Pull latest code from GitHub
pull-code: check-env
	@echo "$(BLUE)📥 Pulling latest changes from GitHub...$(NC)"
	@git pull https://$(GITHUB_USERNAME):$(GITHUB_TOKEN)@$(GIT_REPO) main || { \
		echo "$(RED)❌ Failed to pull from GitHub$(NC)"; \
		echo "$(YELLOW)💡 Check your GitHub credentials and repository URL$(NC)"; \
		exit 1; \
	}
	@echo "$(GREEN)✅ Successfully pulled latest changes$(NC)"

# Build Docker image
build: check-env check-docker
	@echo "$(BLUE)🔨 Building Docker image: $(IMAGE_NAME):$(TAG)$(NC)"
	@docker build -t $(IMAGE_NAME):$(TAG) . || { \
		echo "$(RED)❌ Docker build failed$(NC)"; \
		exit 1; \
	}
	@echo "$(GREEN)✅ Successfully built image: $(IMAGE_NAME):$(TAG)$(NC)"

# Run Docker container (with latest image pull)
run: check-env check-docker stop
	@echo "$(BLUE)🐳 Pulling latest image from Docker Hub: $(IMAGE_NAME):$(TAG)$(NC)"
	@docker pull $(IMAGE_NAME):$(TAG) || { \
		echo "$(YELLOW)⚠️  Failed to pull image from Docker Hub, using local image$(NC)"; \
	}
	@echo "$(BLUE)🚀 Starting container: $(CONTAINER_NAME) on port $(PORT)$(NC)"
	@docker run -d --name $(CONTAINER_NAME) -p $(PORT):8080 $(IMAGE_NAME):$(TAG) || { \
		echo "$(RED)❌ Failed to start container$(NC)"; \
		exit 1; \
	}
	@echo "$(GREEN)✅ Container started successfully$(NC)"
	@echo "$(CYAN)🌐 Application available at: http://localhost:$(PORT)$(NC)"

# Stop and remove container
stop:
	@echo "$(BLUE)🛑 Stopping and removing container: $(CONTAINER_NAME)$(NC)"
	@if docker ps -q -f name=$(CONTAINER_NAME) | grep -q .; then \
		docker stop $(CONTAINER_NAME) && echo "$(GREEN)✅ Container stopped$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Container $(CONTAINER_NAME) is not running$(NC)"; \
	fi
	@if docker ps -aq -f name=$(CONTAINER_NAME) | grep -q .; then \
		docker rm $(CONTAINER_NAME) && echo "$(GREEN)✅ Container removed$(NC)"; \
	fi

# Show container logs
logs: check-env
	@echo "$(BLUE)📋 Showing logs for container: $(CONTAINER_NAME)$(NC)"
	@if docker ps -q -f name=$(CONTAINER_NAME) | grep -q .; then \
		docker logs -f $(CONTAINER_NAME); \
	else \
		echo "$(RED)❌ Container $(CONTAINER_NAME) is not running$(NC)"; \
		exit 1; \
	fi

# Access container shell
shell: check-env
	@echo "$(BLUE)🐚 Accessing shell for container: $(CONTAINER_NAME)$(NC)"
	@if docker ps -q -f name=$(CONTAINER_NAME) | grep -q .; then \
		docker exec -it $(CONTAINER_NAME) /bin/sh || docker exec -it $(CONTAINER_NAME) /bin/bash; \
	else \
		echo "$(RED)❌ Container $(CONTAINER_NAME) is not running$(NC)"; \
		exit 1; \
	fi

# Show container status
status: check-env
	@echo "$(BLUE)📊 Container Status:$(NC)"
	@echo ""
	@if docker ps -q -f name=$(CONTAINER_NAME) | grep -q .; then \
		echo "$(GREEN)✅ Container $(CONTAINER_NAME) is running$(NC)"; \
		docker ps -f name=$(CONTAINER_NAME) --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"; \
	else \
		echo "$(RED)❌ Container $(CONTAINER_NAME) is not running$(NC)"; \
	fi
	@echo ""
	@echo "$(BLUE)📋 Available Images:$(NC)"
	@docker images $(IMAGE_NAME) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || echo "$(YELLOW)⚠️  No images found for $(IMAGE_NAME)$(NC)"

# Push image to Docker Hub
push: check-env check-docker
	@echo "$(BLUE)📦 Pushing image to Docker Hub: $(IMAGE_NAME):$(TAG)$(NC)"
	@if ! docker info 2>/dev/null | grep -q "Username:"; then \
		echo "$(RED)❌ Not logged into Docker Hub$(NC)"; \
		echo "$(YELLOW)💡 Please run: docker login$(NC)"; \
		exit 1; \
	fi
	@docker push $(IMAGE_NAME):$(TAG) || { \
		echo "$(RED)❌ Failed to push image$(NC)"; \
		echo "$(YELLOW)💡 Make sure the repository exists and you have push permissions$(NC)"; \
		exit 1; \
	}
	@echo "$(GREEN)✅ Successfully pushed image: $(IMAGE_NAME):$(TAG)$(NC)"

# Full deployment (build and push)
deploy: build push
	@echo "$(GREEN)🚀 Deployment completed successfully!$(NC)"

# Check application health
health: check-env
	@echo "$(BLUE)🏥 Checking application health...$(NC)"
	@if docker ps -q -f name=$(CONTAINER_NAME) | grep -q .; then \
		if curl -s -f http://localhost:$(PORT)/health >/dev/null 2>&1; then \
			echo "$(GREEN)✅ Application is healthy$(NC)"; \
		elif curl -s -f http://localhost:$(PORT) >/dev/null 2>&1; then \
			echo "$(GREEN)✅ Application is responding$(NC)"; \
		else \
			echo "$(YELLOW)⚠️  Application may not be ready yet$(NC)"; \
		fi \
	else \
		echo "$(RED)❌ Container is not running$(NC)"; \
	fi

# Clean local Docker image
clean: check-env
	@echo "$(BLUE)🧹 Removing Docker image: $(IMAGE_NAME):$(TAG)$(NC)"
	@if docker images -q $(IMAGE_NAME):$(TAG) | grep -q .; then \
		docker rmi $(IMAGE_NAME):$(TAG) && echo "$(GREEN)✅ Image removed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Image $(IMAGE_NAME):$(TAG) not found$(NC)"; \
	fi

# Remove untagged images
clean-untag: check-env
	@echo "$(BLUE)🧹 Cleaning untagged $(IMAGE_NAME) images...$(NC)"
	@UNTAGGED=$$(docker images --format '{{.Repository}} {{.Tag}} {{.ID}}' | \
		awk '$$1 == "$(IMAGE_NAME)" && $$2 == "<none>" { print $$3 }'); \
	if [ -n "$$UNTAGGED" ]; then \
		echo "$$UNTAGGED" | xargs docker rmi && echo "$(GREEN)✅ Untagged images removed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  No untagged images found for $(IMAGE_NAME)$(NC)"; \
	fi

# Clean everything (containers, images, etc.)
clean-all: stop clean clean-untag
	@echo "$(GREEN)✅ Complete cleanup finished$(NC)"

# Development helper - restart container
restart: stop run
	@echo "$(GREEN)✅ Container restarted$(NC)"