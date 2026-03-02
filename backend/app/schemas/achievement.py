from pydantic import BaseModel
from typing import Optional
from datetime import date

class AchievementBase(BaseModel):
    title: str
    description: Optional[str] = None
    date: date
    category: Optional[str] = "General"

class AchievementCreate(AchievementBase):
    pass

class AchievementResponse(AchievementBase):
    id: int
    user_id: int
    user_name: Optional[str] = None # Enriched field

    class Config:
        from_attributes = True
