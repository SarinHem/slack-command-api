# Slack API Docker Project

A Dockerized Slack API service with automated build, deployment, and management tools using Make. This project provides a streamlined development workflow with secure configuration management and Docker Hub integration.

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Configuration](#-configuration)
- [Available Commands](#-available-commands)
- [Development Workflow](#-development-workflow)
- [Deployment](#-deployment)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## ✨ Features

- **Dockerized Environment**: Consistent development and production environments
- **Makefile Automation**: Simple commands for common Docker operations
- **Secure Configuration**: Environment variables stored in `.env` file
- **Docker Hub Integration**: Automated image building and pushing
- **Git Integration**: Seamless code updates and version control
- **Development Tools**: Local testing support with ngrok integration

## 📋 Prerequisites

Ensure you have the following installed and configured:

### Required Software
- **Docker**: Version 20.10+ ([Installation Guide](https://docs.docker.com/get-docker/))
- **Git**: Version 2.25+ ([Installation Guide](https://git-scm.com/downloads))
- **GNU Make**: Usually pre-installed on Linux/macOS, available via package managers

### Required Accounts & Tokens
- **Docker Hub Account**: For image registry ([Sign up](https://hub.docker.com/))
- **GitHub Personal Access Token**: With `repo` permissions ([Create Token](https://github.com/settings/tokens))
- **Slack App**: For API integration ([Create App](https://api.slack.com/apps))

### Optional Tools
- **ngrok**: For local Slack webhook testing ([Download](https://ngrok.com/download))

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/slack-command-api.git
cd slack-command-api
```

### 2. Set Up Environment Configuration

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Edit the `.env` file with your configuration:

```env
# GitHub Configuration
GITHUB_USERNAME=your-github-username
GITHUB_TOKEN=ghp_your-personal-access-token
GIT_REPO=github.com/your-user/your-repo.git

# Docker Configuration
IMAGE_NAME=your-dockerhub-username/slack-api
TAG=latest
CONTAINER_NAME=slack-api-container
PORT=8181

# Slack Configuration (add your Slack-specific variables)
SLACK_BOT_TOKEN=xoxb-your-bot-token
SLACK_SIGNING_SECRET=your-signing-secret
SLACK_APP_TOKEN=xapp-your-app-token

# Application Configuration
NODE_ENV=development
LOG_LEVEL=info
```

### 3. Secure Your Environment File

```bash
chmod 600 .env
echo ".env" >> .gitignore
```

### 4. Login to Docker Hub

```bash
docker login
```

### 5. Build and Run

```bash
# Build the Docker image
make build

# Run the container
make run
```

Your Slack API service will be available at `http://localhost:8181`

## 🔧 Configuration

### Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `GITHUB_USERNAME` | Your GitHub username | ✅ | `johndoe` |
| `GITHUB_TOKEN` | GitHub personal access token | ✅ | `ghp_abc123...` |
| `GIT_REPO` | Git repository URL | ✅ | `github.com/user/repo.git` |
| `IMAGE_NAME` | Docker image name | ✅ | `username/slack-api` |
| `TAG` | Docker image tag | ✅ | `latest` |
| `CONTAINER_NAME` | Docker container name | ✅ | `slack-api-container` |
| `PORT` | Application port | ✅ | `8181` |
| `SLACK_BOT_TOKEN` | Slack bot token | ✅ | `xoxb-...` |
| `SLACK_SIGNING_SECRET` | Slack signing secret | ✅ | `abc123...` |
| `NODE_ENV` | Node.js environment | ❌ | `production` |

### Example `.env` File

```env
# GitHub Configuration
GITHUB_USERNAME=johndoe
GITHUB_TOKEN=ghp_abc123def456ghi789
GIT_REPO=github.com/johndoe/slack-api.git

# Docker Configuration
IMAGE_NAME=johndoe/slack-api
TAG=v1.0.0
CONTAINER_NAME=slack-api-prod
PORT=8181

# Slack Configuration
SLACK_BOT_TOKEN=xoxb-your-bot-token
SLACK_SIGNING_SECRET=your-signing-secret
SLACK_APP_TOKEN=xapp-your-app-token

# Application Configuration
NODE_ENV=production
LOG_LEVEL=info
```

## 🔨 Available Commands

### Development Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `make build` | Build Docker image | `make build` |
| `make run` | Run container (detached) | `make run` |
| `make stop` | Stop running container | `make stop` |
| `make logs` | View container logs | `make logs` |
| `make shell` | Access container shell | `make shell` |
| `make status` | Check container status | `make status` |
| `make health` | Check application health | `make health` |

### Deployment Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `make push` | Push image to Docker Hub | `make push` |
| `make pull-code` | Pull latest code from Git | `make pull-code` |
| `make deploy` | Build, push, and deploy | `make deploy` |

### Maintenance Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `make clean` | Remove local Docker image | `make clean` |
| `make clean-untag` | Remove dangling images | `make clean-untag` |
| `make clean-all` | Full cleanup | `make clean-all` |

### Setup Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `make check-env` | Validate environment config | `make check-env` |
| `make check-docker` | Check Docker setup | `make check-docker` |

### Detailed Command Examples

#### Build and Development
```bash
# Build the Docker image
make build

# Run the container in detached mode
make run

# View real-time logs
make logs

# Access the running container
make shell

# Stop the container
make stop
```

#### Deployment Workflow
```bash
# Pull latest code changes
make pull-code

# Build and push to Docker Hub
make build
make push

# Or use the combined deploy command
make deploy
```

#### Maintenance and Cleanup
```bash
# Remove local images
make clean

# Remove dangling images
make clean-untag

# Complete cleanup
make clean-all

# Check environment and Docker setup
make check-env
make check-docker
```

## 🔄 Development Workflow

### Local Development

1. **Start Development Environment**
   ```bash
   make build
   make run
   ```

2. **Make Code Changes**
   - Edit your source code
   - Test locally using ngrok if needed

3. **Test with ngrok** (Optional)
   ```bash
   # In another terminal
   ngrok http 8181
   # Use the generated URL for Slack webhook configuration
   ```

4. **Rebuild After Changes**
   ```bash
   make stop
   make build
   make run
   ```

### Production Deployment

1. **Update Code**
   ```bash
   make pull-code
   ```

2. **Deploy to Production**
   ```bash
   make deploy
   ```

3. **Monitor Deployment**
   ```bash
   make status
   make logs
   make health
   ```

## 🚀 Deployment

### Docker Hub Deployment

1. **Ensure Docker Hub Login**
   ```bash
   docker login
   ```

2. **Build and Push**
   ```bash
   make build
   make push
   ```

3. **Deploy on Target Server**
   ```bash
   # On production server
   docker pull your-username/slack-api:latest
   docker run -d --name slack-api-prod -p 8181:8181 your-username/slack-api:latest
   ```

### Kubernetes Deployment (Optional)

Create a `k8s-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: slack-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: slack-api
  template:
    metadata:
      labels:
        app: slack-api
    spec:
      containers:
      - name: slack-api
        image: your-username/slack-api:latest
        ports:
        - containerPort: 8181
        env:
        - name: SLACK_BOT_TOKEN
          valueFrom:
            secretKeyRef:
              name: slack-secrets
              key: bot-token
---
apiVersion: v1
kind: Service
metadata:
  name: slack-api-service
spec:
  selector:
    app: slack-api
  ports:
  - port: 80
    targetPort: 8181
  type: LoadBalancer
```

## 🔒 Security

### Environment File Security

- **Never commit `.env` files**: Always add to `.gitignore`
- **Restrict file permissions**: `chmod 600 .env`
- **Use different `.env` files**: Separate for development and production
- **Regular token rotation**: Update GitHub and Slack tokens periodically

### Docker Security Best Practices

- **Non-root user**: Run containers as non-root user
- **Minimal base images**: Use Alpine or distroless images
- **Security scanning**: Regularly scan images for vulnerabilities
- **Resource limits**: Set memory and CPU limits

### Token Management

```bash
# Set restrictive permissions
chmod 600 .env

# Use environment-specific files
.env.development
.env.production
.env.staging
```

### Recommended `.gitignore` Additions

```gitignore
# Environment files
.env
.env.local
.env.*.local
.env.development
.env.production

# Docker
.dockerignore

# Logs
*.log
logs/

# Runtime data
pids
*.pid
*.seed
*.pid.lock
```

## 🔍 Troubleshooting

### Common Issues

#### Docker Build Fails
```bash
# Check Dockerfile syntax
docker build --no-cache -t test .

# Verify base image availability
docker pull node:18-alpine
```

#### Container Won't Start
```bash
# Check container logs
make logs

# Inspect container
docker inspect slack-api-container

# Check port conflicts
netstat -tulpn | grep 8181
```

#### Authentication Issues
```bash
# Verify Docker Hub login
docker info

# Test GitHub token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

#### Slack API Issues
```bash
# Test Slack token
curl -H "Authorization: Bearer $SLACK_BOT_TOKEN" https://slack.com/api/auth.test

# Verify webhook URL with ngrok
curl -X POST http://localhost:4040/api/tunnels
```

### Debug Commands

```bash
# View all running containers
docker ps -a

# Check system resources
docker system df

# View detailed logs
docker logs --tail 100 -f slack-api-container

# Network troubleshooting
docker network ls
docker inspect bridge
```

### Health Checks

Add health check endpoint to your application:

```javascript
// Add to your Express app
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});
```

## 🤝 Contributing

### Development Setup

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/new-feature
   ```
3. **Make your changes**
4. **Test thoroughly**
   ```bash
   make build
   make run
   # Test your changes
   ```
5. **Submit a pull request**

### Code Standards

- Follow existing code style
- Add tests for new features
- Update documentation
- Use conventional commit messages

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested locally
- [ ] Added/updated tests
- [ ] All tests pass

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check this README and inline comments
- **Issues**: Create a [GitHub Issue](https://github.com/your-username/slack-command-api/issues)
- **Discussions**: Use [GitHub Discussions](https://github.com/your-username/slack-command-api/discussions)
- **Slack API Docs**: https://api.slack.com/
- **Docker Docs**: https://docs.docker.com/

## 📝 Changelog

### v1.2.0 (Latest)
- Added Kubernetes deployment support
- Enhanced security configurations
- Improved error handling
- Added health check endpoints

### v1.1.0
- Added ngrok integration for local testing
- Enhanced Makefile with more commands
- Improved documentation
- Added troubleshooting section

### v1.0.0
- Initial release
- Basic Docker setup
- Makefile automation
- Environment configuration