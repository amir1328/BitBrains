from pydantic import BaseModel
from typing import Optional

class AlumniProfileBase(BaseModel):
    current_company: Optional[str] = None
    job_title: Optional[str] = None
    graduation_year: Optional[int] = None
    linkedin_url: Optional[str] = None

class AlumniProfileCreate(AlumniProfileBase):
    pass

class AlumniProfileResponse(AlumniProfileBase):
    id: int
    user_id: int
    user_name: Optional[str] = None
    user_email: Optional[str] = None

    class Config:
        from_attributes = True

class JobPostingBase(BaseModel):
    title: str
    company: str
    description: str
    apply_url: Optional[str] = None

class JobPostingCreate(JobPostingBase):
    pass

class JobPostingResponse(JobPostingBase):
    id: int
    alumni_id: int
    alumni_name: Optional[str] = None
    alumni_company: Optional[str] = None

    class Config:
        from_attributes = True
