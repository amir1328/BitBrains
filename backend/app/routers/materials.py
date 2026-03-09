from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from typing import List
import shutil
import os
from datetime import datetime, timezone
from app.database import get_db
from app.models.user import User
from app.models.material import Material
from app.models.embedding import DocumentEmbedding
from app.schemas.material import MaterialResponse
from app.core import security
from app.utils import get_password_hash # Not needed here but for reference
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt

router = APIRouter(
    prefix="/materials",
    tags=["materials"]
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, security.SECRET_KEY, algorithms=[security.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception
    return user

UPLOAD_DIR = "uploads"
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

@router.post("/upload", response_model=MaterialResponse)
async def upload_material(
    title: str = Form(...),
    course_name: str = Form(...),
    semester: int = Form(...),
    description: str = Form(None),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Only Staff/HOD can upload? For now let's allow everyone or restrict
    if current_user.role not in ["staff", "hod", "student"]: # Students can upload? Maybe not.
         pass # Let's restrict later based on requirements. User said "Students upload or access". So Yes students can upload.

    file_ext = file.filename.split(".")[-1]
    file_name = f"{datetime.now().timestamp()}_{file.filename}"
    file_path = os.path.join(UPLOAD_DIR, file_name)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    new_material = Material(
        title=title,
        description=description,
        course_name=course_name,
        semester=semester,
        file_url=file_path,
        file_type=file_ext,
        uploaded_by=current_user.id
    )

    db.add(new_material)
    db.commit()
    db.refresh(new_material)

    # Trigger Ingestion Background Task
    from app.services.rag_service import RagService
    try:
        rag_service = RagService(db)
        await rag_service.ingest_material(new_material.id)
    except Exception as e:
        print(f"Ingestion failed: {e}")

    # Send push notification to all registered users
    from app.services.notification_service import send_multicast
    try:
        all_tokens = [
            u.fcm_token for u in db.query(User).filter(User.fcm_token.isnot(None)).all()
            if u.id != current_user.id
        ]
        if all_tokens:
            send_multicast(
                tokens=all_tokens,
                title="📚 New Study Material",
                body=f"{title} has been uploaded by {current_user.full_name}",
                data={"material_id": str(new_material.id), "type": "new_material"},
            )
    except Exception as e:
        print(f"Push notification failed: {e}")

    return new_material

@router.get("/", response_model=List[MaterialResponse])
def get_materials(
    course_name: str = None, 
    semester: int = None, 
    db: Session = Depends(get_db)
):
    query = db.query(Material)
    if course_name:
        query = query.filter(Material.course_name == course_name)
    if semester:
        query = query.filter(Material.semester == semester)
    return query.all()

@router.get("/{material_id}/download")
async def download_material(
    material_id: int,
    db: Session = Depends(get_db)
):
    """Download a material file by its ID."""
    material = db.query(Material).filter(Material.id == material_id).first()
    if not material:
        raise HTTPException(status_code=404, detail="Material not found")
    
    file_path = material.file_url
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found on server")
        
    return FileResponse(
        path=file_path, 
        filename=os.path.basename(file_path),
        media_type="application/octet-stream"
    )

@router.delete("/{material_id}")
async def delete_material(
    material_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a material, its file, and its associated embeddings."""
    material = db.query(Material).filter(Material.id == material_id).first()
    if not material:
        raise HTTPException(status_code=404, detail="Material not found")
        
    # ONLY HOD/Staff can delete materials. Students cannot, even if they uploaded them.
    if current_user.role not in ["staff", "hod"]:
        raise HTTPException(status_code=403, detail="Only Staff or HOD can delete study materials")
        
    # 1. Delete the actual file from storage
    file_path = material.file_url
    try:
        if file_path and os.path.exists(file_path):
            os.remove(file_path)
    except Exception as e:
        print(f"Error removing file {file_path}: {e}")
        
    # 2. Delete the associated vector embeddings
    try:
        db.query(DocumentEmbedding).filter(DocumentEmbedding.material_id == material_id).delete()
    except Exception as e:
        print(f"Error deleting embeddings: {e}")
        
    # 3. Delete the material database record
    db.delete(material)
    db.commit()
    
    return {"message": "Material safely deleted"}

