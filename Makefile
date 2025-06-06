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

IMAGE_NAME=slack-api
TAG=latest
CONTAINER_NAME=slack-api-container
PORT=8181

build:
	@echo "🔨 Building Docker image: $(IMAGE_NAME):$(TAG)"
	docker build -t $(IMAGE_NAME):$(TAG) .

run:
	@echo "🚀 Running container: $(CONTAINER_NAME) on port $(PORT)"
	docker run -d --name $(CONTAINER_NAME) -p $(PORT):8080 sarindockerhub/$(IMAGE_NAME):$(TAG)

stop:
	@echo "🛑 Stopping and removing container: $(CONTAINER_NAME)"
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true

push:
	@echo "📦 Tagging and pushing image to Docker Hub..."
	docker tag $(IMAGE_NAME):$(TAG) mydockerhubuser/$(IMAGE_NAME):$(TAG)
	docker push sarindockerhub/$(IMAGE_NAME):$(TAG)

clean:
	@echo "🧹 Removing Docker image: $(IMAGE_NAME):$(TAG)"
	docker rmi sarindockerhub/$(IMAGE_NAME):$(TAG) || true

