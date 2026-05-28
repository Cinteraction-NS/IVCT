from pydantic import BaseModel
from typing import List, Optional, Union


IdValue = Union[int, str]


class ImageItem(BaseModel):
    image: Optional[str] = None
    call_id: Optional[IdValue] = None
    participant_id: Optional[IdValue] = None


class ResponseItem(BaseModel):
    call_id: Optional[IdValue] = None
    participant_id: Optional[IdValue] = None
    score: int


class ResultsResponse(BaseModel):
    results: List[ResponseItem]