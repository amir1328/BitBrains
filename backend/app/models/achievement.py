from sqlalchemy import Column, Integer, String, Date, ForeignKey
from sqlalchemy.orm import relationship
from datetime import date
from app.database import Base

class Achievement(Base):
    __tablename__ = "achievements"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    date = Column(Date, default=date.today)
    category = Column(String, default="General") # e.g. Workshop, Hackathon, Sports
    
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User")
