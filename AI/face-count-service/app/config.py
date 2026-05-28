from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    model_arch: str = "FaceBoxesV2"
    model_path: str = "app/model/FaceBoxesV2/weights/FaceBoxesV2.pth"
    device: str = "cpu"
    use_gpu: bool = False
    confidence_threshold: float = 0.6

    class Config:
        env_file = ".env"


settings = Settings()