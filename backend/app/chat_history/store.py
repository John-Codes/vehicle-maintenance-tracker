"""Server-side chat history, private per user (user_id + workspace_id).
Photos are never stored here - only the text exchange."""
from datetime import datetime, timezone

from ..storage import store

collection = store._collection.database['chat_history']
MAX_HISTORY = 200


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _visible(principal) -> bool:
    """History is per signed-in user; the legacy shared-key flow has none."""
    return bool(principal and not principal.is_legacy and principal.user_id)


async def save_exchange(principal, user_text: str, assistant_text: str):
    if not _visible(principal):
        return
    now = _now()
    await collection.insert_many([
        {'workspace_id': principal.workspace_id, 'user_id': principal.user_id,
         'email': principal.email, 'role': 'user', 'content': user_text, 'created_at': now},
        {'workspace_id': principal.workspace_id, 'user_id': principal.user_id,
         'email': principal.email, 'role': 'assistant', 'content': assistant_text, 'created_at': now},
    ])


async def list_history(principal, limit: int = MAX_HISTORY) -> list:
    if not _visible(principal):
        return []
    query = {'user_id': principal.user_id, 'workspace_id': principal.workspace_id}
    cursor = collection.find(query).sort('created_at', 1).limit(limit)
    return [{'role': doc['role'], 'content': doc['content'], 'created_at': doc['created_at']}
            async for doc in cursor]


async def clear_history(principal):
    if not _visible(principal):
        return 0
    result = await collection.delete_many({'user_id': principal.user_id,
                                           'workspace_id': principal.workspace_id})
    return result.deleted_count
