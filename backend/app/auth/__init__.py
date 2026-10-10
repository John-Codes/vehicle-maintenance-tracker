from fastapi import Header, HTTPException

from ..config import API_KEY


async def require_key(x_app_key: str = Header(default='')):
    """Legacy shared-key guard used by profile, chat, and service types."""
    if x_app_key != API_KEY:
        raise HTTPException(401, 'Invalid app key')
