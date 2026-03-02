from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import database, models, utils
from ..schemas import user as schemas

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

@router.get("/me", response_model=schemas.UserResponse)
def read_users_me(current_user: models.user.User = Depends(utils.get_current_active_user)):
    return current_user

@router.put("/me", response_model=schemas.UserResponse)
def update_user_me(
    user_update: schemas.UserUpdate,
    db: Session = Depends(database.get_db),
    current_user: models.user.User = Depends(utils.get_current_active_user)
):
    # Update only provided fields
    for var, value in user_update.model_dump(exclude_unset=True).items():
        setattr(current_user, var, value)
    
    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    return current_user
