import base64
import binascii
from io import BytesIO

import numpy as np
from PIL import Image


def decode_base64_image(image_base64: str) -> np.ndarray:
    if not isinstance(image_base64, str) or not image_base64.strip():
        raise ValueError("Image must be a non-empty base64 string")

    if "," in image_base64 and image_base64.lower().startswith("data:image"):
        image_base64 = image_base64.split(",", 1)[1]

    try:
        image_bytes = base64.b64decode(image_base64, validate=True)
    except binascii.Error:
        raise ValueError("Invalid base64 image")

    try:
        image = Image.open(BytesIO(image_bytes)).convert("RGB")
    except Exception:
        raise ValueError("Invalid image file")

    return np.array(image)
