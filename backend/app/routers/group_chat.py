from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from sqlalchemy.orm import Session
from .. import database, models, utils
from ..services.websocket_manager import ConnectionManager
from ..schemas import chat_message as schemas
import json # Import json
from datetime import datetime

router = APIRouter(
    prefix="/ws",
    tags=["chat"]
)

manager = ConnectionManager()

@router.websocket("/chat/{room_id}/{user_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    room_id: str,
    user_id: int,
    db: Session = Depends(database.get_db)
):
    await manager.connect(websocket, room_id)
    try:
        while True:
            data = await websocket.receive_text()
            # Persist message to DB
            message_data = json.loads(data)
            content = message_data.get("content")
            
            if content:
                db_message = models.chat_message.ChatMessage(
                    sender_id=user_id,
                    content=content,
                    room_id=room_id,
                    timestamp=datetime.utcnow()
                )
                db.add(db_message)
                db.commit()
                db.refresh(db_message)
                
                # Retrieve sender name for broadcast
                user = db.query(models.user.User).filter(models.user.User.id == user_id).first()
                sender_name = user.full_name if user else "Unknown"
                
                # Broadcast format
                response_data = {
                    "id": db_message.id,
                    "sender_id": user_id,
                    "sender_name": sender_name,
                    "content": content,
                    "room_id": room_id,
                    "timestamp": db_message.timestamp.isoformat()
                }
                
                await manager.broadcast(json.dumps(response_data), room_id)
            
    except WebSocketDisconnect:
        manager.disconnect(websocket, room_id)
        # Optional: Broadcast user left

@router.get("/chat/history/{room_id}", response_model=list[schemas.ChatMessageResponse])
def get_chat_history(room_id: str, db: Session = Depends(database.get_db)):
    messages = db.query(models.chat_message.ChatMessage).filter(
        models.chat_message.ChatMessage.room_id == room_id
    ).order_by(models.chat_message.ChatMessage.timestamp.asc()).all()
    
    # Enrich with sender_name manually if not eager loaded, or rely on relationship
    # Simple mapping
    result = []
    for msg in messages:
        sender_name = msg.sender.full_name if msg.sender else "Unknown"
        result.append(schemas.ChatMessageResponse(
            id=msg.id,
            sender_id=msg.sender_id,
            sender_name=sender_name,
            content=msg.content,
            room_id=msg.room_id,
            timestamp=msg.timestamp
        ))
    return result
