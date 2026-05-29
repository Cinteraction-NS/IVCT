# Intelligent Video Conferencing Toolkit

**Intelligent Video Conferencing Toolkit (IVCT)** is a modular video conferencing platform with support for WebRTC communication, a backend service, and an AI module for video frame analysis.

The project is divided into three main parts:

- **Frontend** — a Flutter Web application for the user interface and video conferencing.
- **Backend** — the server-side part of the application.
- **AI** — a Dockerized AI service for analyzing images and video frames.

---

## System Architecture

The diagram below shows the overall system architecture and the relationship between the main application components.

![IVCT Architecture](images/IVCT_architecture.png)

---

## Application Demo

The image below shows an example of the application in use.

![IVCT Demo](images/demo.jpg)

---

## Modules

Detailed documentation for each module is available in its own README file:

| Module | Description | Documentation |
|---|---|---|
| Frontend | Flutter Web application for video conferencing, communication with the backend, Janus WebRTC Gateway, and AI service. | [frontend/README.md](frontend/README.md) |
| Backend | Server-side part of the system. | [backend/README.md](backend/README.md) |
| AI | Dockerized AI service for image and video frame analysis. | [AI/README.md](AI/README.md) |

---

## Technologies

The project uses the following main technologies:

- **Flutter / Dart** for the frontend application.
- **Janus WebRTC Gateway** for WebRTC communication.
- **STUN/TURN server**, such as Coturn, for WebRTC connectivity.
- **Python / Flask** for the AI service.
- **Docker / Docker Compose** for running the AI module.
- **Nginx** as the HTTPS API gateway for the AI service.

---

## System Workflow

1. The user accesses the application through the Flutter Web frontend.
2. The frontend communicates with the backend service.
3. Video communication is established through the Janus WebRTC Gateway.
4. The STUN/TURN server enables WebRTC connections under different network conditions.
5. The frontend or backend sends video frames to the AI module.
6. The AI module returns the analysis result, such as the number of detected faces per participant.

---

## Recommended Startup Order

The recommended startup order is:

1. Start the **STUN/TURN server**.
2. Start the **Janus WebRTC Gateway**.
3. Start the **backend** service.
4. Start the **AI** module, if used.
5. Start the **frontend** application.

---

## Running the Project

For detailed setup and run instructions, see the module-specific documentation:

- [Frontend documentation](frontend/README.md)
- [Backend documentation](backend/README.md)
- [AI documentation](AI/README.md)

A typical local development setup assumes that the backend, Janus WebRTC Gateway, and STUN/TURN server are running before starting the frontend application.

---

## AI Module

The AI module receives images or video frames and returns analysis results. The current implementation supports face counting.

Example AI service response:

```json
{
  "results": [
    {
      "call_id": 158,
      "participant_id": "2",
      "score": 1
    }
  ]
}
```

## Licensing

IVCT uses a two-tier licensing model. **Read this section before
you contribute or deploy.**

### The framework — GPL-3.0-only

Everything except `AI/face-count-service/` and `docs/plugin-author/`
is licensed under the GNU General Public License, version 3. The
full text is in [`LICENSE`](LICENSE). This is the same license used
by the upstream Janus gateway on which IVCT depends.

If you modify the framework and distribute the modified version,
GPL-3.0 requires you to release your modifications under the same
license. Running a modified version of the framework as a service
does *not* trigger source-release obligations — IVCT deliberately
uses GPL-3.0 rather than AGPL-3.0 for this reason, following the
precedent set by Janus when its authors relicensed from AGPL-3.0 to
GPL-3.0.

### The reference plugin and the plugin author guide — MIT

The reference face-counter plugin in `AI/face-count-service/` and the
plugin author guide in `docs/plugin-author/` are licensed under the
MIT License (see [`AI/face-count-service/LICENSE`](AI/face-count-service/LICENSE)).
The permissive licensing is deliberate: it signals that any analysis
module you write for IVCT — including model weights, training code,
and any pre- or post-processing — is yours to license as you choose.

### Are third-party plugins derivative works of the framework?

**No.** The plugin interface is a documented inter-process REST
contract; plugins run in their own container, in their own process,
and never link against any framework code. In the standard reading
of GPL-3.0, such independent programs are not derivative works of
the framework even though they cooperate with it at runtime. Plugin
authors are free to license their plugins under any license they
choose, including proprietary licenses.

This boundary is described in more detail in
[`docs/plugin-author/licensing.md`](docs/plugin-author/licensing.md).
If you have a specific question about a particular plugin's
licensing posture, please open an issue or contact us before
deploying in production.

### Commercial licensing

An alternative commercial license for the framework is available on
request for organisations whose business model is incompatible with
GPL-3.0 obligations. Contact: `kresimir.krsto@cinteraction.com`.

### SPDX headers

Every source file in this repository carries an
`SPDX-License-Identifier` header recording which of the two licenses
applies. Tooling that scans for SPDX metadata (Reuse, FOSSology,
Scancode, etc.) will see the correct license for each file without
manual intervention.

### Bundled and required third-party components

A non-exhaustive list of the licenses of the components IVCT
depends on is in [`NOTICE`](NOTICE).

## Contact

- Code and issues: https://github.com/Cinteraction-NS/IVCT/
- Commercial licensing: `kresimir.krsto@cinteraction.com`
- Research enquiries: `dubravko.culibrk@cinteraction.com`
