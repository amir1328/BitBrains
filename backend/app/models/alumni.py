from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class AlumniProfile(Base):
    __tablename__ = "alumni_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    current_company = Column(String, nullable=True)
    job_title = Column(String, nullable=True)
    graduation_year = Column(Integer, nullable=True)
    linkedin_url = Column(String, nullable=True)
    
    user = relationship("User", back_populates="alumni_profile")
