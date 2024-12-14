from datetime import datetime, UTC
from sqlalchemy.orm import Session
from .models import LoginSession
import logging

logger = logging.getLogger("voice-agent")


def get_user_id_from_token(db: Session, token: str) -> int | None:
    """
    Get user id from token by querying the sessions table
    Returns None if token not found or invalid
    """
    try:
        session = db.query(LoginSession).filter(LoginSession.token == token).first()
        if session is None:
            return None
        return session.user_id
    except Exception as e:
        logger.error(f"Error retrieving user_id for token: {e}")
        return None
