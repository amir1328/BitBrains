from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import database, models, utils
from ..schemas import achievement as schemas

router = APIRouter(
    prefix="/achievements",
    tags=["achievements"]
)

@router.post("/", response_model=schemas.AchievementResponse)
def create_achievement(
    achievement: schemas.AchievementCreate,
    db: Session = Depends(database.get_db),
    current_user: models.user.User = Depends(utils.get_current_active_user)
):
    # Depending on requirements, maybe only Staff can add? Or Students add their own?
    # Assuming students can add their own for now.
    db_achievement = models.achievement.Achievement(
        **achievement.model_dump(),
        user_id=current_user.id
    )
    db.add(db_achievement)
    db.commit()
    db.refresh(db_achievement)
    
    # Return with user_name
    return schemas.AchievementResponse(
        id=db_achievement.id,
        title=db_achievement.title,
        description=db_achievement.description,
        date=db_achievement.date,
        category=db_achievement.category,
        user_id=db_achievement.user_id,
        user_name=current_user.full_name
    )

@router.get("/", response_model=List[schemas.AchievementResponse])
def read_achievements(
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(database.get_db)
):
    achievements = db.query(models.achievement.Achievement).offset(skip).limit(limit).all()
    
    results = []
    for ach in achievements:
        user_name = ach.user.full_name if ach.user else "Unknown"
        results.append(schemas.AchievementResponse(
            id=ach.id,
            title=ach.title,
            description=ach.description,
            date=ach.date,
            category=ach.category,
            user_id=ach.user_id,
            user_name=user_name
        ))
    return results
