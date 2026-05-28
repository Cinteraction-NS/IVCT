from flask import Blueprint, request, jsonify
from app.utils.image import decode_base64_image
from app.model.detector import detector
from app.schemas import ImageItem, FaceCount, FaceCountResponse
from app.utils.image import decode_base64_image


bp = Blueprint("routes", __name__)

@bp.post("/face-counter/count")
def count():
    body = request.get_json(silent=True)

    if not body:
        return jsonify({"error": "Missing or invalid JSON"}), 400

    try:
        raw_items = body.get("images", [body])

        if not isinstance(raw_items, list):
            raw_items = [raw_items]

        items = [ImageItem(**item) for item in raw_items]

    except ValidationError as e:
        return jsonify({"error": "Invalid request", "details": e.errors()}), 400

    results = []
    valid_images = []
    valid_indexes = []

    for index, item in enumerate(items):
        results.append(
            FaceCount(
                call_id=item.call_id,
                participant_id=item.participant_id,
                score=-1,
            )
        )

        try:
            img = decode_base64_image(item.image)

            valid_images.append(img)
            valid_indexes.append(index)

        except Exception as e:
            print(
                f"Invalid image at index={index}, "
                f"call_id={item.call_id}, "
                f"participant_id={item.participant_id}: {e}"
            )
            continue

    if valid_images:
        batch_faces = detector.detect(valid_images)

        for batch_index, original_index in enumerate(valid_indexes):
            results[original_index].score = batch_faces[batch_index]

    response = FaceCountResponse(faces=results)

    return jsonify(response.model_dump()), 200