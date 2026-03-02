from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class MaterialBase(BaseModel):
    title: str
    description: Optional[str] = None
    course_name: str
    semester: int

class MaterialCreate(MaterialBase):
    pass # File is handled via UploadFile, this is for metadata

class MaterialResponse(MaterialBase):
    id: int
    file_url: str
    file_type: str
    uploaded_by: int
    created_at: datetime

    class Config:
        from_attributes = True
