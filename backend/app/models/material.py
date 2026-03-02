from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime, timezone

class Material(Base):
    __tablename__ = "materials"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    file_url = Column(String, nullable=False) # Local path or S3 URL
    file_type = Column(String, nullable=False) # pdf, pptx, etc.
    
    # Organization
    course_name = Column(String, nullable=False, index=True) # e.g. "Data Structures"
    semester = Column(Integer, nullable=False)
    
    uploaded_by = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.now(timezone.utc))

    uploader = relationship("User", back_populates="materials")
    embeddings = relationship("DocumentEmbedding", back_populates="material")

# Update User model to include relationship (will do in separate step or user.py if I can edit)
