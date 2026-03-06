from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from sqlalchemy.orm import Session
from .. import database, models, utils
from ..services.websocket_manager import ConnectionManager
from ..schemas import chat_message as schemas
import json
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
    await manager.connect(websocket, room_id, user_id)
    try:
        while True:
            data = await websocket.receive_text()
            message_data = json.loads(data)
            content = message_data.get("content")

            if content:
                # Persist message
                db_message = models.chat_message.ChatMessage(
                    sender_id=user_id,
                    content=content,
                    room_id=room_id,
                    timestamp=datetime.utcnow()
                )
                db.add(db_message)
                db.commit()
                db.refresh(db_message)

                user = db.query(models.user.User).filter(models.user.User.id == user_id).first()
                sender_name = user.full_name if user else "Unknown"

                response_data = {
                    "id": db_message.id,
                    "sender_id": user_id,
                    "sender_name": sender_name,
                    "content": content,
                    "room_id": room_id,
                    "timestamp": db_message.timestamp.isoformat()
                }

                await manager.broadcast(json.dumps(response_data), room_id)

                # Push notification to offline users (non-blocking)
                try:
                    from app.services.notification_service import send_multicast
                    online_user_ids = manager.get_online_users(room_id)
                    
                    # exclude the sender and anyone currently online in this WebSockets room
                    other_tokens = [
                        u.fcm_token for u in db.query(models.user.User)
                        .filter(models.user.User.fcm_token.isnot(None))
                        .filter(models.user.User.id != user_id)
                        .filter(models.user.User.id.notin_(online_user_ids))
                        .all()
                    ]
                    if other_tokens:
                        short_msg = content if len(content) <= 80 else content[:77] + "..."
                        send_multicast(
                            tokens=other_tokens,
                            title=f"💬 {sender_name} in #{room_id}",
                            body=short_msg,
                            data={"room_id": room_id, "type": "group_message"},
                        )
                except Exception as notif_err:
                    print(f"Group chat notification error: {notif_err}")

    except WebSocketDisconnect:
        manager.disconnect(websocket, room_id)


@router.get("/chat/history/{room_id}", response_model=list[schemas.ChatMessageResponse])
def get_chat_history(room_id: str, db: Session = Depends(database.get_db)):
    messages = db.query(models.chat_message.ChatMessage).filter(
        models.chat_message.ChatMessage.room_id == room_id
    ).order_by(models.chat_message.ChatMessage.timestamp.asc()).all()

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
