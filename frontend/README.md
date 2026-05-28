# Intelligent Video Conferencing Platform

A Flutter web application for video conferencing built on top of the Janus WebRTC Gateway.

---

## Prerequisites

The following services must be running before starting the application:

- **Backend server** (located in the same repository)
- **Janus WebRTC Gateway**
- **STUN/TURN server** (e.g. Coturn)

---

## Configuration

All configuration values are located in `lib/config/conf.dart`:

| Parameter | Description |
|-----------|-------------|
| `baseUrl` | Backend server URL |
| `url` | Janus WebSocket URL (WSS) |
| `iceServers` | List of STUN/TURN servers for WebRTC |
| `mixTurnServerUsername` | TURN server username |
| `mixTurnServerCredential` | TURN server password |

Adjust these values to match your environment before running the app.

---

## Getting Started

### Requirements

| Tool | Version |
|------|---------|
| Flutter | 3.29.3 |
| Dart | 3.7.2 |

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Run the web app

```bash
flutter run -d chrome
```

Or on a specific port:

```bash
flutter run -d chrome --web-port 8080
```

### 3. Production build

```bash
flutter build web
```

The output will be available in the `build/web/` directory.

---

## Service Startup Order

> **Important:** Services must be started in the following order:

1. **STUN/TURN server** — must be running before Janus
2. **Janus WebRTC Gateway** — must be running before the backend
3. **Backend server** — must be running before the Flutter app
4. **Flutter web app**

---

## AI Module Testing

The application supports a pluggable AI engagement analysis module. For testing purposes, you can implement a custom AI module of your choice — the only requirement is that it conforms to the expected request/response contract.

### Request

The app periodically sends video frames to the AI module endpoint as a POST request with the following payload:

```json
{
  "call_id": 158,
  "image": "<base64-encoded frame>",
  "participant_id": "2"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `call_id` | integer | Unique identifier of the active call |
| `image` | string | Base64-encoded video frame (JPEG/PNG) |
| `participant_id` | string | Identifier of the participant |

### Response

The AI module must return a JSON response in the following format:

```json
{
  "engagements": [
    {
      "call_id": 158,
      "participant_id": "2",
      "score": 0.7978
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `call_id` | integer | Must match the `call_id` from the request |
| `participant_id` | string | Must match the `participant_id` from the request |
| `score` | float | Engagement score between `0.0` (no engagement) and `1.0` (full engagement) |

### Example Stub (Python/Flask)

A minimal mock server for local testing:

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/analyze", methods=["POST"])
def analyze():
    data = request.json
    return jsonify({
        "engagements": [
            {
                "call_id": data["call_id"],
                "participant_id": data["participant_id"],
                "score": 0.85
            }
        ]
    })

if __name__ == "__main__":
    app.run(port=5000)
```

---

## Troubleshooting

**Web support not enabled:**
```bash
flutter config --enable-web
```

**List available devices:**
```bash
flutter devices
```