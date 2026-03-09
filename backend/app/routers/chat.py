from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.rag_service import RagService
from app.models.user import User
from app.utils import get_current_user
from pydantic import BaseModel
from langchain_openai import ChatOpenAI
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
import os
import logging

# Configure logging
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/chat",
    tags=["chat"]
)


class ChatRequest(BaseModel):
    question: str


class ChatResponse(BaseModel):
    answer: str
    sources: list[str] = []


GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")


@router.post("/ask", response_model=ChatResponse)
async def ask_question(
    request: ChatRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    RAG endpoint: retrieves relevant study materials and generates AI response.
    Requires authentication.
    """
    try:
        rag_service = RagService(db)
        
        # 1. Retrieve Context from RAG
        try:
            docs = await rag_service.query(request.question)
        except Exception as e:
            if "429" in str(e) or "RESOURCE_EXHAUSTED" in str(e):
                logger.warning(f"Gemini API Rate Limit Hit: {str(e)}")
                raise HTTPException(
                    status_code=429, 
                    detail="AI Rate Limit Exceeded. The free tier quota is exhausted. Please wait ~1 minute and try again."
                )
            logger.error(f"RAG query error: {str(e)}")
            raise HTTPException(status_code=500, detail=f"RAG Error: {str(e)}")

        # Handle no relevant documents
        if not docs:
            return ChatResponse(
                answer="I couldn't find any relevant study materials to answer your question.",
                sources=[]
            )

        # Combine document content as context
        context_text = "\n\n".join([doc.content for doc in docs])
        
        # 2. Check API Key Configuration
        if not OPENROUTER_API_KEY:
            logger.error("OPENROUTER_API_KEY not configured")
            return ChatResponse(
                answer="AI Service is not configured (OpenRouter API Key missing).",
                sources=[]
            )

        # 3. Generate Answer via LLM using OpenRouter via LangChain
        try:
            llm = ChatOpenAI(
                base_url="https://openrouter.ai/api/v1",
                api_key=OPENROUTER_API_KEY,
                model="nvidia/nemotron-3-nano-30b-a3b:free"
            )
            
            # Define prompt template
            prompt_template = """You are a helpful AI study assistant called BitBrains. 
Answer the question based ONLY on the following context provided from study materials.
If the answer is not in the context, say "I cannot answer this based on the available materials."

Context:
{context}

Question: {question}

Answer:"""
            
            prompt = PromptTemplate(
                template=prompt_template,
                input_variables=["context", "question"]
            )
            
            # Modern Runnable chain (replaces deprecated LLMChain)
            chain = prompt | llm | StrOutputParser()
            
            # Execute chain asynchronously
            answer = await chain.ainvoke({
                "context": context_text,
                "question": request.question
            })
            
            return ChatResponse(
                answer=answer,
                sources=[str(doc.material_id) for doc in docs]
            )
            
        except Exception as e:
            logger.error(f"LLM generation error: {str(e)}")
            raise HTTPException(
                status_code=500,
                detail=f"Error generating answer: {str(e)}"
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error in /ask: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


@router.post("/ingest/{material_id}")
async def ingest_document(
    material_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Manually trigger RAG ingestion for a specific study material.
    Chunks the document and stores embeddings in vector database.
    Requires authentication.
    """
    try:
        # Validate material_id
        if material_id <= 0:
            raise HTTPException(status_code=400, detail="Invalid material_id")
        
        rag_service = RagService(db)
        
        try:
            chunk_count = await rag_service.ingest_material(material_id)
            
            if chunk_count == 0:
                logger.warning(f"No chunks created for material_id: {material_id}")
                return {
                    "message": f"Material {material_id} processed but no chunks generated.",
                    "chunks_created": 0
                }
            
            logger.info(f"Successfully ingested material_id {material_id} into {chunk_count} chunks")
            return {
                "message": f"Successfully ingested {chunk_count} chunks.",
                "chunks_created": chunk_count,
                "material_id": material_id
            }
            
        except Exception as e:
            logger.error(f"Ingest error for material_id {material_id}: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Ingestion error: {str(e)}")
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error in /ingest/{material_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")
