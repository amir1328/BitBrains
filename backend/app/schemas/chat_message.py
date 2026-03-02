from pydantic import BaseModel
from datetime import datetime

class ChatMessageBase(BaseModel):
    content: str
    room_id: str

class ChatMessageCreate(ChatMessageBase):
    pass

class ChatMessageResponse(ChatMessageBase):
    id: int
    sender_id: int
    sender_name: str
    timestamp: datetime

    class Config:
        from_attributes = True
