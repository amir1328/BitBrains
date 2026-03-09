from pydantic import BaseModel, ConfigDict
from datetime import time
from enum import Enum
from typing import Optional

class DayOfWeek(str, Enum):
    MONDAY = "Monday"
    TUESDAY = "Tuesday"
    WEDNESDAY = "Wednesday"
    THURSDAY = "Thursday"
    FRIDAY = "Friday"
    SATURDAY = "Saturday"
    SUNDAY = "Sunday"

class TimetableEntryBase(BaseModel):
    course_name: str
    semester: int
    day_of_week: DayOfWeek
    subject: str
    teacher_name: str
    room_no: str
    start_time: time
    end_time: time

class TimetableEntryCreate(TimetableEntryBase):
    pass

class TimetableEntryUpdate(BaseModel):
    course_name: Optional[str] = None
    semester: Optional[int] = None
    day_of_week: Optional[DayOfWeek] = None
    subject: Optional[str] = None
    teacher_name: Optional[str] = None
    room_no: Optional[str] = None
    start_time: Optional[time] = None
    end_time: Optional[time] = None

class TimetableEntry(TimetableEntryBase):
    id: int
    
    model_config = ConfigDict(from_attributes=True)
