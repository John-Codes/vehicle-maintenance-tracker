from fastapi import Depends, HTTPException

from .session import Principal, require_user


async def require_workspace_user(principal: Principal = Depends(require_user)) -> Principal:
    """Signed-in user who belongs to a workspace. Pending users must redeem an invite."""
    if principal.is_legacy:
        return principal
    if not principal.workspace_id:
        raise HTTPException(403, 'No workspace. Ask a manager for an invite link.')
    return principal


async def require_manager(principal: Principal = Depends(require_workspace_user)) -> Principal:
    """Manager-only guard for team, invite, and user management endpoints."""
    if principal.is_legacy:
        raise HTTPException(403, 'Sign in as a manager to manage the team')
    if principal.role != 'manager':
        raise HTTPException(403, 'Managers only')
    return principal
