from typing import List, Dict
from fastapi import WebSocket

class ConnectionManager:
    def __init__(self):
        # Map room_id to dict of {websocket: user_id}
        self.active_rooms: Dict[str, Dict[WebSocket, int]] = {}

    async def connect(self, websocket: WebSocket, room_id: str, user_id: int):
        await websocket.accept()
        if room_id not in self.active_rooms:
            self.active_rooms[room_id] = {}
        self.active_rooms[room_id][websocket] = user_id

    def disconnect(self, websocket: WebSocket, room_id: str):
        if room_id in self.active_rooms:
            if websocket in self.active_rooms[room_id]:
                del self.active_rooms[room_id][websocket]
            if not self.active_rooms[room_id]:
                del self.active_rooms[room_id]

    async def broadcast(self, message: str, room_id: str):
        if room_id in self.active_rooms:
            for connection in list(self.active_rooms[room_id].keys()):
                try:
                    await connection.send_text(message)
                except Exception:
                    pass

    def get_online_users(self, room_id: str) -> List[int]:
        """Returns a list of unique user IDs currently connected to the room."""
        if room_id in self.active_rooms:
            return list(set(self.active_rooms[room_id].values()))
        return []
