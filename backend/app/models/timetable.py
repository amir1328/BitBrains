from sqlalchemy import Column, Integer, String, ForeignKey, Enum, Time
from sqlalchemy.orm import relationship
import enum
from ..database import Base

class DayOfWeek(str, enum.Enum):
    MONDAY = "Monday"
    TUESDAY = "Tuesday"
    WEDNESDAY = "Wednesday"
    THURSDAY = "Thursday"
    FRIDAY = "Friday"
    SATURDAY = "Saturday"
    SUNDAY = "Sunday"

class TimetableEntry(Base):
    __tablename__ = "timetable_entries"

    id = Column(Integer, primary_key=True, index=True)
    course_name = Column(String, index=True)
    semester = Column(Integer, index=True)
    day_of_week = Column(String) # Storing DayOfWeek value
    
    subject = Column(String)
    teacher_name = Column(String)
    room_no = Column(String)
    
    start_time = Column(Time)
    end_time = Column(Time)

    # Optional: Relationship to User (Teacher) if we want to link strictly
    # teacher_id = Column(Integer, ForeignKey("users.id"), nullable=True)
