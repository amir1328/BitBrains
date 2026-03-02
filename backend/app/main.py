from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import engine, Base
from app.routers import auth, materials, chat, timetable, users, group_chat, achievements, alumni
# Import models to ensure tables are created
from app.models import user, material, embedding, timetable as timetable_model, achievement, alumni as alumni_model, chat_message

# Create Tables (for dev purposes; use Alembic for prod)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="BitBrains API",
    description="Backend API for BitBrains - AI&DS Department Platform",
    version="0.1.0",
)

# Origins for CORS (Allow Flutter app/web to connect)
origins = [
    "http://localhost",
    "http://localhost:8000",
    "http://127.0.0.1",
    "http://127.0.0.1:8000",
]

app.add_middleware(
    CORSMiddleware,
    # allow_origins=origins, # Wildcard "*" fails with allow_credentials=True in some browsers
    allow_origin_regex="https?://.*", # Allow all origins (development only) to support random Flutter ports
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(materials.router)
app.include_router(chat.router)
app.include_router(timetable.router)
app.include_router(users.router)
app.include_router(group_chat.router)
app.include_router(achievements.router)
app.include_router(alumni.router)

@app.get("/")
async def root():
    return {"message": "Welcome to BitBrains API. System is online."}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
