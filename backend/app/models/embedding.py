from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship, mapped_column
from pgvector.sqlalchemy import Vector
from app.database import Base

class DocumentEmbedding(Base):
    __tablename__ = "document_embeddings"

    id = Column(Integer, primary_key=True, index=True)
    material_id = Column(Integer, ForeignKey("materials.id"))
    content = Column(String, nullable=False) # The text chunk
    embedding = mapped_column(Vector(768)) # 768 dim for Gemini/OpenAI (adjust based on model)

    material = relationship("Material", back_populates="embeddings")
