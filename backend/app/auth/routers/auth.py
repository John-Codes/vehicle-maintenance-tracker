from fastapi import APIRouter, Depends, Header, HTTPException

from ...config import API_KEY
from .. import user_store
from ..firebase_verify import verify_firebase_token
from ..models import BootstrapAdminRequest, FirebaseExchange
from ..session import Principal, require_user
from ..tokens import issue_token

router = APIRouter(prefix='/auth', tags=['Auth'])


@router.post('/firebase')
async def firebase_login(body: FirebaseExchange):
    """Exchange a Firebase ID token for a tracker session token."""
    identity = await verify_firebase_token(body.id_token)
    user = await user_store.get_or_create(identity['uid'], identity['email'], identity['name'])
    return {'access_token': issue_token(user['id']), 'token_type': 'bearer', 'user': user}


@router.get('/me')
async def current_user(principal: Principal = Depends(require_user)):
    if principal.is_legacy:
        return {'id': '', 'email': '', 'name': 'Legacy app key',
                'role': 'legacy', 'workspace_id': principal.workspace_id, 'privileges': []}
    user = await user_store.by_id(principal.user_id)
    if user is None:
        raise HTTPException(401, 'Unknown user')
    return user


@router.post('/bootstrap-admin', status_code=201)
async def bootstrap_first_admin(body: BootstrapAdminRequest, x_app_key: str = Header(default='')):
    """Create the first admin. Master key required; 409 once any admin exists."""
    if x_app_key != API_KEY:
        raise HTTPException(401, 'Master app key required')
    return await user_store.bootstrap_admin(body.email)
