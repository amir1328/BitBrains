from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from .. import database, models, utils
from ..schemas import timetable as schemas
from ..models import user as user_models

router = APIRouter(
    prefix="/timetable",
    tags=["timetable"]
)

@router.post("/", response_model=schemas.TimetableEntry)
def create_timetable_entry(
    entry: schemas.TimetableEntryCreate,
    db: Session = Depends(database.get_db),
    current_user: models.user.User = Depends(utils.get_current_active_user)
):
    # Only Staff and HOD can create/edit timetable
    if current_user.role not in [user_models.UserRole.STAFF, user_models.UserRole.HOD]:
       raise HTTPException(status_code=403, detail="Not authorized to manage timetable")

    db_entry = models.timetable.TimetableEntry(**entry.model_dump())
    db.add(db_entry)
    db.commit()
    db.refresh(db_entry)
    return db_entry

@router.get("/", response_model=List[schemas.TimetableEntry])
def get_timetable(
    course_name: Optional[str] = None,
    semester: Optional[int] = None,
    day: Optional[schemas.DayOfWeek] = None,
    db: Session = Depends(database.get_db)
):
    query = db.query(models.timetable.TimetableEntry)
    
    if course_name:
        query = query.filter(models.timetable.TimetableEntry.course_name == course_name)
    if semester:
         query = query.filter(models.timetable.TimetableEntry.semester == semester)
    if day:
        query = query.filter(models.timetable.TimetableEntry.day_of_week == day)
        
    # Sort by day and time
    # Note: Sorting by string day might not be chronological. 
    # Frontend handles display, but for API we might want to ensure time sort.
    return query.order_by(models.timetable.TimetableEntry.start_time).all()

@router.delete("/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_timetable_entry(
    entry_id: int,
    db: Session = Depends(database.get_db),
    current_user: models.user.User = Depends(utils.get_current_active_user)
):
     if current_user.role not in [user_models.UserRole.STAFF, user_models.UserRole.HOD]:
       raise HTTPException(status_code=403, detail="Not authorized to manage timetable")
       
     db_entry = db.query(models.timetable.TimetableEntry).filter(models.timetable.TimetableEntry.id == entry_id).first()
     if not db_entry:
         raise HTTPException(status_code=404, detail="Entry not found")
         
     db.delete(db_entry)
     db.commit()
