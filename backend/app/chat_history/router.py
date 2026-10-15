from fastapi import APIRouter, Depends

from ..auth.guards import require_workspace_user
from ..auth.session import Principal
from .store import clear_history, list_history

router = APIRouter(prefix='/chat', dependencies=[Depends(require_workspace_user)])


@router.get('/history')
async def get_history(principal: Principal = Depends(require_workspace_user)):
    """The signed-in user's private chat thread (oldest first)."""
    return {'messages': await list_history(principal)}


@router.delete('/history')
async def delete_history(principal: Principal = Depends(require_workspace_user)):
    """Wipe the signed-in user's chat thread."""
    return {'ok': True, 'deleted': await clear_history(principal)}
