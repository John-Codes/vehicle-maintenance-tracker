from fastapi import APIRouter, Depends, HTTPException

from ..auth.guards import require_workspace_user
from ..auth.session import Principal
from .store import list_messages
from .topics_store import clear_history, delete_topic, list_topics

router = APIRouter(prefix='/chat', dependencies=[Depends(require_workspace_user)])


@router.get('/history')
async def get_topics(principal: Principal = Depends(require_workspace_user)):
    """The signed-in user's conversation threads, newest activity first."""
    return {'topics': await list_topics(principal)}


@router.get('/history/{topic_id}')
async def get_topic_messages(topic_id: str,
                             principal: Principal = Depends(require_workspace_user)):
    """One conversation's messages (oldest first). Private to its owner."""
    messages = await list_messages(principal, topic_id)
    if messages is None:
        raise HTTPException(404, 'Conversation not found')
    return {'messages': messages}


@router.delete('/history')
async def delete_all_history(principal: Principal = Depends(require_workspace_user)):
    """Wipe the signed-in user's every conversation."""
    return {'ok': True, 'deleted': await clear_history(principal)}


@router.delete('/history/{topic_id}')
async def delete_one_topic(topic_id: str,
                           principal: Principal = Depends(require_workspace_user)):
    """Delete a single conversation of the signed-in user."""
    if not await delete_topic(principal, topic_id):
        raise HTTPException(404, 'Conversation not found')
    return {'ok': True}
