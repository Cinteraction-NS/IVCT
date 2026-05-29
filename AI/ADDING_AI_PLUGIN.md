# Adding a New AI Plugin

This document explains how to add a new AI plugin service to the IVCT AI module.

The AI module is designed so that additional AI services can be added as separate Dockerized plugins. Each plugin should run as an independent service and should be exposed through the existing Nginx API gateway.

For example, the current AI module contains a `face-count-service`. A new plugin can follow the same structure and be added as a separate service.

---

## Overview

A new AI plugin usually requires changes in the following places:

- a new plugin service directory inside `AI/`
- `docker-compose.yml`
- `api_gateway/gateway.conf`
- frontend or backend configuration, if the application needs to call the new plugin
- AI documentation

Recommended plugin structure:

~~~text
AI/
├── new-plugin-service/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── wsgi.py
│   └── app/
├── api_gateway/
│   ├── Dockerfile
│   └── gateway.conf
├── docker-compose.yml
├── README.md
└── ADDING_AI_PLUGIN.md
~~~

---

## 1. Create a New Plugin Service

Create a new directory inside the `AI` module.

Example:

~~~bash
mkdir new-plugin-service
~~~

The new plugin should be implemented as an independent HTTP service.

A recommended minimal API structure is:

~~~text
GET  /new-plugin/health
GET  /new-plugin/ready
POST /new-plugin/process
~~~

Recommended endpoint responsibilities:

| Endpoint | Purpose |
|---|---|
| `/new-plugin/health` | Checks whether the service is running. |
| `/new-plugin/ready` | Checks whether the model or required resources are loaded. |
| `/new-plugin/process` | Runs the plugin-specific AI task. |

The plugin should listen on an internal container port.

Example:

~~~text
8006
~~~

The port does not need to be exposed directly to the host machine. The service should be reachable through Docker networking and exposed publicly only through Nginx.

---

## 2. Add a Dockerfile for the Plugin

Each plugin should have its own `Dockerfile`.

Example:

~~~dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8006

CMD ["waitress-serve", "--host=0.0.0.0", "--port=8006", "wsgi:app"]
~~~

Adjust the base image, dependencies, exposed port, and startup command depending on the plugin implementation.

---

## 3. Add the Plugin to `docker-compose.yml`

Add the new plugin as a separate service in `AI/docker-compose.yml`.

Example:

~~~yaml
services:
  face_counter_service:
    build: ./face-count-service
    image: face_counter
    restart: unless-stopped
    networks:
      - microservices

  new_plugin_service:
    build: ./new-plugin-service
    image: new_plugin_service
    restart: unless-stopped
    networks:
      - microservices

  nginx:
    build:
      dockerfile: ./Dockerfile
      context: ./api_gateway/
    image: nginx
    user: root
    ports:
      - "443:443"
    networks:
      - microservices
    depends_on:
      - "face_counter_service"
      - "new_plugin_service"
    volumes:
      - ./ssl_certs/:/etc/nginx/ssl/

networks:
  microservices:
    driver: bridge
~~~

Important points:

- Add the plugin as a separate service.
- Connect it to the same `microservices` network.
- Add the plugin service to `nginx.depends_on`.
- Do not expose the plugin port directly unless direct local debugging is needed.
- Use the Docker Compose service name when referencing the plugin from Nginx.

For example, this service name:

~~~yaml
new_plugin_service:
~~~

will be used inside Nginx as:

~~~nginx
server new_plugin_service:8006;
~~~

---

## 4. Add an Upstream in `api_gateway/gateway.conf`

Open:

~~~text
AI/api_gateway/gateway.conf
~~~

Inside the `http` block, add a new `upstream` block for the plugin.

Example:

~~~nginx
upstream new_plugin_api_server {
    least_conn;
    server new_plugin_service:8006;
}
~~~

The service name must match the name from `docker-compose.yml`.

The port must match the internal port used by the plugin service.

Example mapping:

| Item | Value |
|---|---|
| Docker Compose service name | `new_plugin_service` |
| Internal plugin port | `8006` |
| Nginx upstream name | `new_plugin_api_server` |

---

## 5. Add a Public Nginx Route

Inside the `server` block in `gateway.conf`, add a new `location` block.

Example:

~~~nginx
location /new-plugin/ {
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'DELETE, GET, OPTIONS, PATCH, POST, PUT';
        add_header 'Vary' 'Origin';
        add_header 'Access-Control-Allow-Headers' 'authorization, reqheader, accept, accept-encoding, authorization, content-type, dnt, origin, user-agent, x-csrftoken, x-requested-with, x-socket-id';
        add_header 'Access-Control-Max-Age' 86400;
        add_header 'Content-Type' 'text/html; charset=utf-8';
        return 200;
    }

    proxy_pass http://new_plugin_api_server;
}
~~~

The plugin will then be available through the API gateway at:

~~~text
https://127.0.0.1/new-plugin/
~~~

Example health check:

~~~bash
curl -k https://127.0.0.1/new-plugin/health
~~~

Example readiness check:

~~~bash
curl -k https://127.0.0.1/new-plugin/ready
~~~

Example processing request:

~~~bash
curl -k -X POST https://127.0.0.1/new-plugin/process \
  -H "Content-Type: application/json" \
  -d '{
    "call_id": 158,
    "participant_id": "2",
    "image": "<base64-encoded image>"
  }'
~~~

---

## 6. Recommended Request Format

A plugin that processes video frames or images should use a predictable request format.

Example:

~~~json
{
  "call_id": 158,
  "participant_id": "2",
  "image": "<base64-encoded image>"
}
~~~

Recommended fields:

| Field | Description |
|---|---|
| `call_id` | Identifier of the call/session. |
| `participant_id` | Identifier of the participant. |
| `image` | Base64-encoded image or frame. |


---

## 7. Recommended Response Format

A plugin should return a consistent JSON response.

Example:

~~~json
{
  "results": [
    {
      "call_id": 158,
      "participant_id": "2",
      "score": 1
    }
  ]
}
~~~

---

## 8. Optional: Add Rate Limiting

If the plugin receives frequent requests, especially video frame requests, add rate limiting in `gateway.conf`.

Inside the `http` block:

~~~nginx
limit_req_zone $binary_remote_addr zone=new_plugin_rate:10m rate=100r/s;
~~~

Inside the plugin `location` block:

~~~nginx
location /new-plugin/ {
    limit_req zone=new_plugin_rate burst=200 nodelay;
    limit_req_status 429;

    proxy_pass http://new_plugin_api_server;
}
~~~

Rate limiting is recommended for plugins that process frames continuously.

---

## 9. Optional: Increase Request Body Size

If the plugin receives large base64-encoded images, videos, or payloads, increase the request body size in Nginx.

Inside the `server` block:

~~~nginx
client_max_body_size 20M;
~~~

Or inside only the plugin route:

~~~nginx
location /new-plugin/ {
    client_max_body_size 20M;

    proxy_pass http://new_plugin_api_server;
}
~~~

Adjust the size depending on the expected payload.

---


## 10. Rebuild and Start the AI Module

After adding the plugin and updating Nginx, rebuild the AI module.

From the `AI/` directory, run:

~~~bash
docker compose down
docker compose up --build
~~~

Or run it in detached mode:

~~~bash
docker compose up --build -d
~~~

Check that all containers are running:

~~~bash
docker ps
~~~

Expected services should include:

~~~text
face_counter_service
new_plugin_service
nginx
~~~

---

## 11. Check Logs

Check all logs:

~~~bash
docker compose logs -f
~~~

Check only the new plugin logs:

~~~bash
docker compose logs -f new_plugin_service
~~~

Check Nginx logs:

~~~bash
docker compose logs -f nginx
~~~

---

## 12. Minimal Example

For a plugin named `new_plugin_service` running internally on port `8006`, the minimal required changes are:

### `docker-compose.yml`

~~~yaml
new_plugin_service:
  build: ./new-plugin-service
  image: new_plugin_service
  restart: unless-stopped
  networks:
    - microservices
~~~

Also add it to Nginx dependencies:

~~~yaml
nginx:
  depends_on:
    - "face_counter_service"
    - "new_plugin_service"
~~~

### `api_gateway/gateway.conf`

~~~nginx
upstream new_plugin_api_server {
    least_conn;
    server new_plugin_service:8006;
}
~~~

Inside the `server` block:

~~~nginx
location /new-plugin/ {
    proxy_pass http://new_plugin_api_server;
}
~~~

Then rebuild:

~~~bash
docker compose up --build
~~~
