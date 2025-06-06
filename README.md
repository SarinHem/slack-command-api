# Slack API Container

This project provides a lightweight Dockerized Slack API command handler, designed to be easily built, run, and managed using a `Makefile`.

---

## 📦 Features

- Dockerized backend for handling Slack slash commands
- Simple `Makefile` to automate build, run, stop, and clean operations
- Configurable port mapping
- Docker Hub integration for image pushing

---

## 🚀 Getting Started

### 🔧 Requirements

- Docker
- GNU Make
- (Optional) ngrok — for local testing with Slack

---

### 🛠️ Usage

#### 🔨 Build the Docker image

```bash
make build
```

#### 🚀 Run the container

```bash
make run
```

The container will be accessible at:  
`http://localhost:8181` (or the port you configured in the `Makefile`)

#### 🛑 Stop and remove the container

```bash
make stop
```

#### 🧹 Remove the Docker image

```bash
make clean
```

#### 📤 Push image to Docker Hub

Make sure to update your Docker Hub username inside the `Makefile`.

```bash
make push
```

---

## 📝 Slash Command Setup (in Slack)

1. Go to your Slack app configuration.
2. Navigate to **Slash Commands**.
3. Create a new command (e.g. `/deploy`).
4. Set the **Request URL** to your server or `ngrok` endpoint:
   ```
   https://your-ngrok-url.ngrok.io/slack/commands
   ```
5. Save changes and test the command in your Slack workspace.

---

## 📁 File Structure

```
.
├── Dockerfile
├── Makefile
├── README.md
├── app.py  # or your backend implementation
```

---

## 📌 Notes

- The container exposes port `8181` by default. Change the `PORT` variable in the `Makefile` if needed.
- The container name is `slack-api-container`.

---

## 📜 License

MIT License — see [LICENSE](./LICENSE) for details.

