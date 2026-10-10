from fastapi import APIRouter, Depends, HTTPException

from .. import user_store
from ..firebase_verify import verify_firebase_token
from ..models import FirebaseExchange
from ..session import Principal, require_user
from ..tokens import issue_token

router = APIRouter(prefix='/auth', tags=['Auth'])


@router.post('/firebase')
async def firebase_login(body: FirebaseExchange):
    """Exchange a Firebase ID token for a tracker session token.

    The first user ever becomes manager of the 'default' workspace. Later
    users join as pending techs until they redeem a manager's invite.
    """
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
