from fastapi import APIRouter, Header, HTTPException

from ...config import API_KEY
from .. import user_store
from ..config import AUTH_MODE
from ..models import DevTokenRequest
from ..tokens import issue_token

router = APIRouter(prefix='/auth', tags=['Auth dev'])


@router.post('/dev-token')
async def dev_token(body: DevTokenRequest, x_app_key: str = Header(default='')):
    """Local/CI-only fast path: issue a real tracker token without Firebase.

    Enabled only when AUTH_MODE=dev. Never enable in production. Omitting
    role and workspace_id applies the same auto-assign logic as /auth/firebase.
    """
    if AUTH_MODE != 'dev':
        raise HTTPException(404, 'Not found')
    if x_app_key != API_KEY:
        raise HTTPException(401, 'Master app key required')
    user = await user_store.upsert_dev_user(body.email, body.name, body.role, body.workspace_id)
    return {'access_token': issue_token(user['id']), 'token_type': 'bearer', 'user': user}
