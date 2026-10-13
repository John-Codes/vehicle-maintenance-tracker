from fastapi import APIRouter, Depends, HTTPException

from .. import user_store
from ..firebase_verify import verify_firebase_token
from ..models import FirebaseExchange, WorkspaceSwitch
from ..session import Principal, require_user
from ..tokens import issue_token

router = APIRouter(prefix='/auth', tags=['Auth'])


@router.post('/firebase')
async def firebase_login(body: FirebaseExchange):
    """Exchange a Firebase ID token for a tracker session token.

    Every new user becomes manager of their own workspace. Redeeming an
    invite adds the invited workspace as an extra membership.
    """
    identity = await verify_firebase_token(body.id_token)
    user = await user_store.get_or_create(identity['uid'], identity['email'], identity['name'])
    return {'access_token': issue_token(user['id']), 'token_type': 'bearer', 'user': user}


@router.put('/workspace')
async def switch_active_workspace(body: WorkspaceSwitch,
                                  principal: Principal = Depends(require_user)):
    """Activate a workspace the user already belongs to. Old data is never lost."""
    if principal.is_legacy:
        raise HTTPException(403, 'Sign in to switch workspaces')
    return await user_store.switch_workspace(principal.user_id, body.workspace_id)


@router.get('/me')
async def current_user(principal: Principal = Depends(require_user)):
    if principal.is_legacy:
        return {'id': '', 'email': '', 'name': 'Legacy app key',
                'role': 'legacy', 'workspace_id': principal.workspace_id, 'privileges': []}
    user = await user_store.by_id(principal.user_id)
    if user is None:
        raise HTTPException(401, 'Unknown user')
    return user
