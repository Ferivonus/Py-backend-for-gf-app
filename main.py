import uvicorn
from fastapi import FastAPI, Depends
from routers import auth_router
from routers import ws_router
from config_py.database import engine, Base
from auth import get_current_user
from models.models import User

app = FastAPI()

# Include the authentication router
app.include_router(auth_router.router)

# Include the WebSocket router
app.include_router(ws_router.router)

# Endpoint for a protected page
@app.get("/secret")
def read_secret_data(user: User = Depends(get_current_user)):
    return {
        "message": f"Hello, {user.username}! This is a protected endpoint.",
        "data": "Here is some confidential information."
    }

if __name__ == "__main__":
    # Create the database tables
    Base.metadata.create_all(bind=engine)
    uvicorn.run(app, host="127.0.0.1", port=80)
