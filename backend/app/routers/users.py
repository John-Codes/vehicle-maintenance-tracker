from fastapi import APIRouter, Depends, HTTPException, status

from ..auth import user_store
from ..auth.guards import require_manager
from ..auth.models import RoleChange
from ..auth.session import Principal

router = APIRouter(prefix='/users', tags=['Team'])


@router.get('')
async def list_users(principal: Principal = Depends(require_manager)):
    return await user_store.list_workspace(principal.workspace_id)


@router.put('/{user_id}/role')
async def change_role(user_id: str, body: RoleChange,
                      principal: Principal = Depends(require_manager)):
    if user_id == principal.user_id:
        raise HTTPException(403, 'You cannot change your own role')
    return await user_store.set_role(user_id, principal.workspace_id, body.role)


@router.delete('/{user_id}', status_code=status.HTTP_204_NO_CONTENT)
async def remove_user(user_id: str, principal: Principal = Depends(require_manager)):
    """Remove a user from the workspace. They revert to pending until re-invited."""
    if user_id == principal.user_id:
        raise HTTPException(403, 'You cannot remove yourself')
    await user_store.remove_from_workspace(user_id, principal.workspace_id)
