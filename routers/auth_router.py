from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from config_py.database import get_db, Base, engine
from models.models import User
from auth import hash_password, verify_password, get_current_user

# Create the 'users' table if it doesn't exist
Base.metadata.create_all(bind=engine)

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)

class UserCredentials(BaseModel):
    username: str
    password: str

@router.post("/register")
def register_user(user: UserCredentials, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.username == user.username).first()
    if existing_user:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Username already exists")

    hashed_pass = hash_password(user.password)
    new_user = User(username=user.username, hashed_password=hashed_pass)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"message": f"User '{user.username}' registered successfully."}

@router.post("/login")
def login(user: UserCredentials, db: Session = Depends(get_db)):
    user_db = db.query(User).filter(User.username == user.username).first()

    if not user_db or not verify_password(user.password, user_db.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
        )
    return {"message": f"User '{user.username}' logged in successfully."}

@router.delete("/delete-user")
def delete_user(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    db.delete(user)
    db.commit()
    return {"message": f"User '{user.username}' deleted successfully."}
