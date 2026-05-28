from flask import Flask

from app.model.detector import detector


def create_app():
    app = Flask(__name__)

    detector.load()

    from app.routes import bp
    app.register_blueprint(bp)

    @app.get("/face-counter/health")
    def health():
        return {"status": "ok"}

    @app.get("/face-counter/ready")
    def ready():
        return {"ready": detector.detector is not None}

    return app