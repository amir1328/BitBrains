from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship, mapped_column
from pgvector.sqlalchemy import Vector
from app.database import Base

class DocumentEmbedding(Base):
    __tablename__ = "document_embeddings"

    id = Column(Integer, primary_key=True, index=True)
    material_id = Column(Integer, ForeignKey("materials.id"))
    content = Column(String, nullable=False) # The text chunk
    embedding = mapped_column(Vector(3072)) # 3072 dim for gemini-embedding-001

    material = relationship("Material", back_populates="embeddings")
