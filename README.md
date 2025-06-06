
# Slack API Docker Project

This project contains a Dockerized Slack API service with convenient build, run, and deployment commands managed via a Makefile. Configuration variables are stored securely in a `.env` file.

---

## Prerequisites

- Docker installed
- Git installed
- A GitHub personal access token with repo permissions
- `.env` file configured with your credentials and settings

---

## Setup

1. **Create `.env` file in the project root:**

```env
GITHUB_USERNAME=your-github-username
GITHUB_TOKEN=your-personal-access-token
GIT_REPO=github.com/your-user/your-repo.git
IMAGE_NAME=repositry-name/slack-api
TAG=latest
CONTAINER_NAME=slack-api-container
PORT=8181
```

> **Important:** Add `.env` to your `.gitignore` to avoid committing secrets.

---

## Makefile Commands

Use the following commands to manage your project.

### Build Docker Image

```bash
make build
```

Builds the Docker image with the tag specified in `.env`.

---

### Run Docker Container

```bash
make run
```

Runs the Docker container exposing the port defined in `.env`.

---

### Stop Docker Container

```bash
make stop
```

Stops the running Docker container.

---

### Push Docker Image to Docker Hub

```bash
make push
```

Tags and pushes the image to your Docker Hub repository. Make sure to update `IMAGE_NAME` accordingly.

---

### Clean Local Docker Images

```bash
make clean
```

Removes the local Docker image by tag.

---

### Remove Untagged Docker Images

```bash
make clean-untag
```

Removes dangling (untagged) Docker images related to `IMAGE_NAME`.

---

### Pull Latest Code from GitHub

```bash
make pull
```

Pulls the latest changes from the GitHub repository using credentials stored in `.env`.  
**Note:** This uses the token-based HTTPS URL from `.env`. For better security, consider SSH key authentication.

---

## Security Notes

- **Never commit your `.env` file to Git.** It contains sensitive credentials.
- Prefer using SSH keys for GitHub authentication to avoid exposing tokens in URLs.
- Make sure your `.env` file permissions are restrictive (`chmod 600 .env`).

---
