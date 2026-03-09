import os
from subprocess import CalledProcessError
# Using langchain for PDF loading and text splitting
from langchain_community.document_loaders import PyPDFLoader, TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from sqlalchemy.orm import Session
from app.models.embedding import DocumentEmbedding
from app.models.material import Material
# from dotenv import load_dotenv

# load_dotenv() # Already loaded in database.py or main.py

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

class RagService:
    def __init__(self, db: Session):
        self.db = db
        if GEMINI_API_KEY:
             self.embeddings = GoogleGenerativeAIEmbeddings(model="models/text-embedding-004", google_api_key=GEMINI_API_KEY)
        else:
            print("WARNING: GEMINI_API_KEY not found. RAG will fail.")
            self.embeddings = None

    async def ingest_material(self, material_id: int):
        if not self.embeddings:
            raise Exception("Embedding model not configured")

        material = self.db.query(Material).filter(Material.id == material_id).first()
        if not material:
            raise Exception("Material not found")

        file_path = material.file_url
        
        # Load Document
        if material.file_type == "pdf":
            loader = PyPDFLoader(file_path)
        else:
            loader = TextLoader(file_path) # Basic text loader for others
        
        docs = loader.load()

        # Split Text
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
        splits = text_splitter.split_documents(docs)

        # Generate Embeddings and Store
        for split in splits:
            vector = self.embeddings.embed_query(split.page_content)
            
            db_embedding = DocumentEmbedding(
                material_id=material.id,
                content=split.page_content,
                embedding=vector
            )
            self.db.add(db_embedding)
        
        self.db.commit()
        return len(splits)

    async def query(self, query_text: str, k: int = 4):
        if not self.embeddings:
             raise Exception("Embedding model not configured")
        
        query_vector = self.embeddings.embed_query(query_text)
        
        # PGVector Similarity Search
        # Note: This requires correct operator logic. 
        # Using l2_distance or cosine_distance. 
        # SQLAlchemy <-> pgvector syntax:
        results = self.db.query(DocumentEmbedding).order_by(
            DocumentEmbedding.embedding.l2_distance(query_vector)
        ).limit(k).all()

        return results
