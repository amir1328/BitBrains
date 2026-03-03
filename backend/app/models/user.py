from sqlalchemy import Column, Integer, String, Boolean, Enum
from app.database import Base
import enum

class UserRole(str, enum.Enum):
    STUDENT = "student"
    STAFF = "staff"
    HOD = "hod"
    ALUMNI = "alumni"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(Enum(UserRole), default=UserRole.STUDENT)
    is_active = Column(Boolean, default=True)
    
    # Additional fields specific to BitBrains
    department = Column(String, default="AI&DS")
    year = Column(Integer, nullable=True) # For students
    roll_number = Column(String, nullable=True) # For students
    
    # Profile Extensions
    bio = Column(String, nullable=True)
    phone_number = Column(String, nullable=True)
    avatar_url = Column(String, nullable=True)
    fcm_token = Column(String, nullable=True)  # Firebase Cloud Messaging token

    from sqlalchemy.orm import relationship
    materials = relationship("Material", back_populates="uploader")
    alumni_profile = relationship("AlumniProfile", back_populates="user", uselist=False)
