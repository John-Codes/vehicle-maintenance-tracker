from fastapi import APIRouter, Depends, status

from ..auth.guards import require_manager
from ..auth.models import InviteCreate, InviteRedeem
from ..auth.session import Principal, require_user
from ..auth import user_store
from . import invite_store

router = APIRouter(prefix='/invites', tags=['Invites'])


@router.post('', status_code=201)
async def create_invite(body: InviteCreate, principal: Principal = Depends(require_manager)):
    return await invite_store.create(principal.workspace_id, body.role,
                                     principal.user_id, body.label)


@router.get('')
async def list_invites(principal: Principal = Depends(require_manager)):
    return await invite_store.list_active(principal.workspace_id)


@router.delete('/{invite_id}', status_code=status.HTTP_204_NO_CONTENT)
async def revoke_invite(invite_id: str, principal: Principal = Depends(require_manager)):
    await invite_store.revoke(invite_id, principal.workspace_id)


@router.post('/redeem')
async def redeem_invite(body: InviteRedeem, principal: Principal = Depends(require_user)):
    """Consume an invite code and join its workspace with the assigned role.

    Open to pending users (no workspace yet) via require_user on purpose.
    """
    invite = await invite_store.redeem(body.code, principal.user_id)
    user = await user_store.join_workspace(principal.user_id, invite['workspace_id'], invite['role'])
    return user
