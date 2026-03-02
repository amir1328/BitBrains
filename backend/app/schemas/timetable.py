from pydantic import BaseModel, ConfigDict
from datetime import time
from enum import Enum

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

class TimetableEntry(TimetableEntryBase):
    id: int
    
    model_config = ConfigDict(from_attributes=True)
