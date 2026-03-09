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
    job_postings = relationship("JobPosting", back_populates="alumni", cascade="all, delete-orphan")

class JobPosting(Base):
    __tablename__ = "job_postings"

    id = Column(Integer, primary_key=True, index=True)
    alumni_id = Column(Integer, ForeignKey("alumni_profiles.id"))
    title = Column(String, nullable=False)
    company = Column(String, nullable=False)
    description = Column(String, nullable=False)
    apply_url = Column(String, nullable=True)
    
    alumni = relationship("AlumniProfile", back_populates="job_postings")
