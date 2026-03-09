from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import database, models, utils
from ..schemas import alumni as schemas

router = APIRouter(
    prefix="/alumni",
    tags=["alumni"]
)

@router.post("/profile", response_model=schemas.AlumniProfileResponse)
def create_or_update_profile(
    profile: schemas.AlumniProfileCreate,
    db: Session = Depends(database.get_db),
    current_user: models.user.User = Depends(utils.get_current_active_user)
):
    # Check if profile exists
    db_profile = db.query(models.alumni.AlumniProfile).filter(models.alumni.AlumniProfile.user_id == current_user.id).first()
    
    if db_profile:
        # Update
        for key, value in profile.model_dump(exclude_unset=True).items():
            setattr(db_profile, key, value)
    else:
        # Create
        db_profile = models.alumni.AlumniProfile(
            **profile.model_dump(),
            user_id=current_user.id
        )
        db.add(db_profile)
    
    db.commit()
    db.refresh(db_profile)
    
    return schemas.AlumniProfileResponse(
        id=db_profile.id,
        user_id=db_profile.user_id,
        current_company=db_profile.current_company,
        job_title=db_profile.job_title,
        graduation_year=db_profile.graduation_year,
        linkedin_url=db_profile.linkedin_url,
        user_name=current_user.full_name,
        user_email=current_user.email
    )

@router.get("/", response_model=List[schemas.AlumniProfileResponse])
def read_alumni(
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(database.get_db)
):
    profiles = db.query(models.alumni.AlumniProfile).offset(skip).limit(limit).all()
    
    results = []
    for prof in profiles:
        results.append(schemas.AlumniProfileResponse(
            id=prof.id,
            user_id=prof.user_id,
            current_company=prof.current_company,
            job_title=prof.job_title,
            graduation_year=prof.graduation_year,
            linkedin_url=prof.linkedin_url,
            user_name=prof.user.full_name if prof.user else "Unknown",
            user_email=prof.user.email if prof.user else ""
        ))
    return results

@router.get("/jobs", response_model=List[schemas.JobPostingResponse])
def get_job_postings(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(database.get_db)
):
    jobs = db.query(models.alumni.JobPosting).offset(skip).limit(limit).all()
    results = []
    for job in jobs:
        alumni_name = job.alumni.user.full_name if job.alumni and job.alumni.user else "Unknown"
        alumni_company = job.alumni.current_company if job.alumni else "Unknown"
        results.append(schemas.JobPostingResponse(
            id=job.id,
            alumni_id=job.alumni_id,
            title=job.title,
            company=job.company,
            description=job.description,
            apply_url=job.apply_url,
            alumni_name=alumni_name,
            alumni_company=alumni_company
        ))
    return results

@router.post("/jobs", response_model=schemas.JobPostingResponse)
def create_job_posting(
    job: schemas.JobPostingCreate,
    db: Session = Depends(database.get_db),
    current_user: models.user.User = Depends(utils.get_current_active_user)
):
    if current_user.role.value != "alumni":
        raise HTTPException(status_code=403, detail="Only alumni can post jobs.")
    
    alumni_profile = db.query(models.alumni.AlumniProfile).filter(models.alumni.AlumniProfile.user_id == current_user.id).first()
    if not alumni_profile:
        raise HTTPException(status_code=404, detail="Alumni profile not found. Create one first.")
    
    db_job = models.alumni.JobPosting(
        **job.model_dump(),
        alumni_id=alumni_profile.id
    )
    db.add(db_job)
    db.commit()
    db.refresh(db_job)
    
    return schemas.JobPostingResponse(
        id=db_job.id,
        alumni_id=db_job.alumni_id,
        title=db_job.title,
        company=db_job.company,
        description=db_job.description,
        apply_url=db_job.apply_url,
        alumni_name=current_user.full_name,
        alumni_company=alumni_profile.current_company
    )
