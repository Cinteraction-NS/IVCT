import sys
from pathlib import Path

import torch

from app.config import settings
import cv2

FACEBOXES_ROOT = Path(__file__).resolve().parent / "FaceBoxesV2"
FACEBOXES_UTILS = FACEBOXES_ROOT / "utils"

sys.path.insert(0, str(FACEBOXES_ROOT))
sys.path.insert(0, str(FACEBOXES_UTILS))

from faceboxes_detector import FaceBoxesDetector


class FaceCounterDetector:
    def __init__(self):
        self.detector = None

    def load(self):
        device = torch.device(settings.device)

        self.detector = FaceBoxesDetector(
            model_arch=settings.model_arch,
            model_weights=settings.model_path,
            use_gpu=settings.use_gpu,
            device=device,
        )

        return self

    def detect(self, images):
        """
        images: list[np.ndarray]

        returns:
        [
            num_faces_for_image_1,
            num_faces_for_image_2,
            ...
        ]
        """
        if self.detector is None:
            raise RuntimeError("Detector is not loaded")

        batch_results = []

        for image in images:
            image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
            detections, _ = self.detector.detect(
                image,
                thresh=settings.confidence_threshold,
            )

            batch_results.append(len(detections))

        return batch_results


detector = FaceCounterDetector()