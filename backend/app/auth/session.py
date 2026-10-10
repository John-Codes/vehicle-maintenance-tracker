from dataclasses import dataclass, field

from fastapi import Header, HTTPException

from ..config import API_KEY
from . import user_store
from .config import DEFAULT_WORKSPACE
from .tokens import verify_token


@dataclass
class Principal:
    user_id: str = ''
    email: str = ''
    role: str = 'legacy'
    workspace_id: str = field(default_factory=lambda: DEFAULT_WORKSPACE)
    is_legacy: bool = True


LEGACY_PRINCIPAL = Principal()


async def require_user(
    authorization: str = Header(default=''),
    x_app_key: str = Header(default=''),
) -> Principal:
    """Accept a Bearer user token or the legacy shared X-App-Key."""
    if authorization.startswith('Bearer '):
        payload = verify_token(authorization[len('Bearer '):])
        user = await user_store.by_id(payload['sub'])
        if user is None:
            raise HTTPException(401, 'Unknown user')
        return Principal(user_id=user['id'], email=user['email'], role=user['role'],
                         workspace_id=user['workspace_id'], is_legacy=False)
    if x_app_key == API_KEY:
        return LEGACY_PRINCIPAL
    raise HTTPException(401, 'Authentication required')
