from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordRequestForm
from datetime import timedelta
from jose import JWTError, jwt
from app.database import get_db
from app.models.user import User
from app.schemas.user import UserCreate, UserResponse, Token, RefreshRequest, ChangePasswordRequest
from app.utils import get_password_hash, verify_password, get_current_active_user
from app.core import security

router = APIRouter(
    prefix="/auth",
    tags=["auth"]
)


@router.post("/register", response_model=UserResponse)
def register(
    user: UserCreate, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Security: Only HOD can register new users
    if current_user.role.value != "hod":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Only the Head of Department (HOD) can register new users."
        )

    # Clean Validation
    if not user.email or "@" not in user.email:
        raise HTTPException(status_code=400, detail="Invalid email format")
    if not user.full_name or len(user.full_name.strip()) < 2:
        raise HTTPException(status_code=400, detail="Full name is required and must be at least 2 characters")
    if len(user.password) < 6:
        raise HTTPException(status_code=400, detail="Password must be at least 6 characters long")
    
    # Check if email is already registered
    db_user = db.query(User).filter(User.email == user.email.lower().strip()).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email is already registered")

    hashed_password = get_password_hash(user.password)
    new_user = User(
        email=user.email.lower().strip(),
        full_name=user.full_name.strip(),
        hashed_password=hashed_password,
        role=user.role,
        department=user.department,
        year=user.year,
        roll_number=user.roll_number.strip() if user.roll_number else None
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token_data = {"sub": user.email, "role": user.role.value}
    access_token = security.create_access_token(data=token_data)
    refresh_token = security.create_refresh_token(data=token_data)

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
    }


@router.post("/refresh", response_model=Token)
def refresh_access_token(request: RefreshRequest, db: Session = Depends(get_db)):
    """
    Exchange a valid refresh token for a new access + refresh token pair.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired refresh token",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(
            request.refresh_token,
            security.SECRET_KEY,
            algorithms=[security.ALGORITHM]
        )
        # Ensure this is actually a refresh token
        if payload.get("type") != "refresh":
            raise credentials_exception

        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception

    except JWTError:
        raise credentials_exception

    user = db.query(User).filter(User.email == email).first()
    if user is None or not user.is_active:
        raise credentials_exception

    # Issue brand-new token pair
    token_data = {"sub": user.email, "role": user.role.value}
    new_access_token = security.create_access_token(data=token_data)
    new_refresh_token = security.create_refresh_token(data=token_data)

    return {
        "access_token": new_access_token,
        "refresh_token": new_refresh_token,
        "token_type": "bearer",
    }

@router.post("/change-password")
def change_password(
    request: ChangePasswordRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    if not verify_password(request.current_password, current_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect current password"
        )
    
    current_user.hashed_password = get_password_hash(request.new_password)
    db.commit()
    return {"message": "Password updated successfully"}
