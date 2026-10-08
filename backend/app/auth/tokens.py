from datetime import datetime, timedelta, timezone

from fastapi import HTTPException
from jose import JWTError, jwt

from .config import JWT_SECRET, TOKEN_HOURS

ALGORITHM = 'HS256'


def issue_token(user_id: str) -> str:
    expires = datetime.now(timezone.utc) + timedelta(hours=TOKEN_HOURS)
    return jwt.encode({'sub': user_id, 'exp': expires}, JWT_SECRET, algorithm=ALGORITHM)


def verify_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[ALGORITHM])
    except JWTError:
        raise HTTPException(401, 'Invalid or expired token')
    if not payload.get('sub'):
        raise HTTPException(401, 'Invalid token payload')
    return payload
