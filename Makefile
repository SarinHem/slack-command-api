include .env
export

.PHONY: default help build run stop push clean

default: help

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build   - Build the Docker image"
	@echo "  run     - Run the Docker container"
	@echo "  stop    - Stop and remove the container"
	@echo "  push    - Tag and push the image to Docker Hub"
	@echo "  clean   - Remove the Docker image"

pull:
	@echo "📥 Pulling latest changes from GitHub..."
	GIT_REPO=https://$(GITHUB_USERNAME):$(GITHUB_TOKEN)@$(GIT_REPO) \
	git pull $(GIT_REPO) main

build:
	@echo "🔨 Building Docker image: $(IMAGE_NAME):$(TAG)"
	docker build -t $(IMAGE_NAME):$(TAG) .

run:
	@echo "🐳 Pull Lasted Image  from DockerHub $(IMAGE_NAME):$(TAG)"
	docker pull $(IMAGE_NAME)
	@echo "🚀 Pull Lasted Image  And Running container: $(CONTAINER_NAME) on port $(PORT)"
	docker run -d --name $(CONTAINER_NAME) -p $(PORT):8080 $(IMAGE_NAME):$(TAG)

stop:
	@echo "🛑 Stopping and removing container: $(CONTAINER_NAME)"
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true

push:
	@echo "📦 Tagging and pushing image to Docker Hub..."
	docker tag $(IMAGE_NAME):$(TAG) mydockerhubuser/$(IMAGE_NAME):$(TAG)
	docker push $(IMAGE_NAME):$(TAG)

clean:
	@echo "🧹 Removing Docker image: $(IMAGE_NAME):$(TAG)"
	docker rmi $(IMAGE_NAME):$(TAG) || true

clean-untag:
	@echo "🧹 Cleaning untagged $(IMAGE_NAME) images..."
	@docker images --format '{{.Repository}} {{.Tag}} {{.ID}}' | \
	awk '$$1 == "$(IMAGE_NAME)" && $$2 == "<none>" { print $$3 }' | \
	xargs -r docker rmi

