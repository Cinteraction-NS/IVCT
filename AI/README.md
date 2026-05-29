# Intelligent Video Conferencing Toolkit

## AI Module

AI module for the Intelligent Video Conferencing Toolkit.

This module provides a Dockerized face-counting service that receives base64-encoded video frames or images and returns the number of detected faces.

The module is exposed through an Nginx HTTPS API gateway.

---

## Services

The AI module consists of the following services:

| Service | Description |
|---------|-------------|
| `face_counter_service` | Python/Flask service that loads the face detection model and counts faces in images |
| `nginx` | HTTPS API gateway that exposes the Face Counter API |

---

## Prerequisites

Before starting the AI module, make sure the following tools are installed:

| Tool | Version |
|------|---------|
| Docker | Latest stable |
| Docker Compose | Latest stable |

The module can run independently, but it is intended to be used by the backend or frontend application as an external AI service.

---

## Configuration

The module is configured through:

| File | Description |
|------|-------------|
| `docker-compose.yml` | Defines the AI services, Docker network, ports, and volumes |
| `api_gateway/gateway.conf` | Nginx gateway configuration |
| `face-count-service/Dockerfile` | Face Counter service Docker image |
| `api_gateway/Dockerfile` | Nginx Docker image |

By default, the API is exposed on HTTPS port `443`.

```text
https://127.0.0.1
```

The Face Counter service itself runs internally on port `8005` and is not exposed directly to the host machine.

---

## SSL Certificates

Nginx requires SSL certificates before the module can be started.

Create the `ssl_certs` directory in the root of the repository:

```bash
mkdir ssl_certs
```

Add the following files inside the directory:

```text
ssl_certs/
├── fullchain.pem
└── privkey.pem
```

These files are mounted into the Nginx container at:

```text
/etc/nginx/ssl/
```

The Nginx configuration expects the following certificate paths:

```nginx
ssl_certificate     /etc/nginx/ssl/fullchain.pem;
ssl_certificate_key /etc/nginx/ssl/privkey.pem;
```

### Local Development Certificates

For local development, self-signed certificates can be generated with:

```bash
mkdir -p ssl_certs

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout ssl_certs/privkey.pem \
  -out ssl_certs/fullchain.pem \
  -subj "/CN=127.0.0.1"
```

> When using self-signed certificates, browsers and HTTP clients may show a security warning.

---

## Getting Started

### 1. Create SSL certificate directory

```bash
mkdir ssl_certs
```

Add valid SSL certificate files:

```text
ssl_certs/fullchain.pem
ssl_certs/privkey.pem
```

Or generate self-signed certificates for local development:

```bash
mkdir -p ssl_certs

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout ssl_certs/privkey.pem \
  -out ssl_certs/fullchain.pem \
  -subj "/CN=127.0.0.1"
```

### 2. Build and start the services

```bash
docker compose up --build
```

Or run in detached mode:

```bash
docker compose up --build -d
```

### 3. Check running containers

```bash
docker ps
```

Expected services:

```text
face_counter_service
nginx
```

### 4. Stop the services

```bash
docker compose down
```

---

## API Endpoints

All endpoints are exposed through the Nginx API gateway.

Base URL:

```text
https://127.0.0.1
```

If self-signed certificates are used, add the `-k` flag when testing with `curl`.

---

### Health Check

Checks if the Face Counter service is running.

```http
GET /face-counter/health
```

Example:

```bash
curl -k https://127.0.0.1/face-counter/health
```

Response:

```json
{
  "status": "ok"
}
```

---

### Readiness Check

Checks if the face detection model has been loaded.

```http
GET /face-counter/ready
```

Example:

```bash
curl -k https://127.0.0.1/face-counter/ready
```

Response:

```json
{
  "ready": true
}
```

---

### Count Faces

Counts faces in one or more base64-encoded images.

```http
POST /face-counter/count
```

The endpoint supports both a single image object and a batch of images.

---

## Single Image Request

```json
{
  "call_id": 158,
  "image": "<base64-encoded image>",
  "participant_id": "2"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `call_id` | integer/string/null | Identifier of the active call |
| `image` | string/null | Base64-encoded image or video frame |
| `participant_id` | integer/string/null | Identifier of the participant |

Example:

```bash
curl -k -X POST https://127.0.0.1/face-counter/count \
  -H "Content-Type: application/json" \
  -d '{
    "call_id": 158,
    "image": "<base64-encoded image>",
    "participant_id": "2"
  }'
```

---

## Batch Image Request

```json
{
  "images": [
    {
      "call_id": 158,
      "image": "<base64-encoded image>",
      "participant_id": "2"
    },
    {
      "call_id": 158,
      "image": "<base64-encoded image>",
      "participant_id": "3"
    }
  ]
}
```

Example:

```bash
curl -k -X POST https://127.0.0.1/face-counter/count \
  -H "Content-Type: application/json" \
  -d '{
    "images": [
      {
        "call_id": 158,
        "image": "<base64-encoded image>",
        "participant_id": "2"
      },
      {
        "call_id": 158,
        "image": "<base64-encoded image>",
        "participant_id": "3"
      }
    ]
  }'
```

---

## Response

The service returns a list of face count results.

```json
{
  "faces": [
    {
      "call_id": 158,
      "participant_id": "2",
      "score": 1
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `call_id` | integer/string/null | Matches the `call_id` from the request |
| `participant_id` | integer/string/null | Matches the `participant_id` from the request |
| `score` | integer | Number of detected faces |

A `score` value of `-1` means that the image could not be decoded or processed.

Example:

```json
{
  "results": [
    {
      "call_id": 158,
      "participant_id": "2",
      "score": -1
    }
  ]
}
```

---

## Response Codes

| Code | Description |
|------|-------------|
| `200` | Request processed successfully |
| `400` | Missing JSON, invalid JSON, or invalid request schema |

Example error response:

```json
{
  "error": "Missing or invalid JSON"
}
```

Example validation error response:

```json
{
  "error": "Invalid request",
  "details": []
}
```

---

## Docker Network

The services use a shared Docker bridge network:

```text
microservices
```

Nginx communicates with the Face Counter service using the internal Docker service name:

```text
face_counter_service:8005
```

The Face Counter service is not directly exposed to the host machine.

---

## Project Structure

Expected structure:

```text
.
├── docker-compose.yml
├── ssl_certs/
│   ├── fullchain.pem
│   └── privkey.pem
├── face-count-service/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── wsgi.py
│   └── app/
└── api_gateway/
    ├── Dockerfile
    └── gateway.conf
```

---

## Troubleshooting

**Nginx fails to start because certificates are missing:**

```bash
ls -la ssl_certs
```

Expected files:

```text
fullchain.pem
privkey.pem
```

---

**Port 443 is already in use:**

Change the port mapping in `docker-compose.yml`:

```yaml
ports:
  - "8443:443"
```

Then access the API using:

```text
https://127.0.0.1:8443/face-counter/
```

---

**Check logs:**

```bash
docker compose logs -f
```

For a specific service: 

```bash
docker compose logs -f face_counter_service
docker compose logs -f nginx
```

---

**Rebuild containers from scratch:**

```bash
docker compose down
docker compose build --no-cache
docker compose up
```
