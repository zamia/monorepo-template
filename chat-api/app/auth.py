from fastapi import Depends, HTTPException, Request
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.crud import get_user_id_from_token
from functools import wraps
import logging


async def get_current_user_id(request: Request, db: Session = Depends(get_db)) -> int:
    """Dependency to get authenticated user_id from token"""
    auth_header = request.headers.get("Authorization")
    if not auth_header:
        raise HTTPException(status_code=401, detail="No authorization header")

    token = auth_header.split(" ")[1]
    user_id = get_user_id_from_token(db, token)

    if user_id is None:
        raise HTTPException(status_code=401, detail="Unauthorized")
    
    logger = logging.getLogger("agent-api")
    logger.info(f"Authenticated user_id: {user_id}")

    return user_id


def require_auth(func):
    @wraps(func)
    async def wrapper(*args, user_id: int = Depends(get_current_user_id), **kwargs):
        return func(*args, user_id=user_id, **kwargs)

    return wrapper
