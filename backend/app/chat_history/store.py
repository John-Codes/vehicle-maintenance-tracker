"""Chat message persistence, private per user (user_id + workspace_id).
Topic/thread management lives in topics_store.py. Text only - never photos."""
from datetime import datetime, timezone

from ..storage import store

collection = store._collection.database['chat_history']


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _visible(principal) -> bool:
    """History is per signed-in user; the legacy shared-key flow has none."""
    return bool(principal and not principal.is_legacy and principal.user_id)


async def append_exchange(principal, topic_id: str, user_text: str, assistant_text: str):
    """Save one exchange into its thread and bump the thread's activity."""
    if not _visible(principal):
        return
    now = _now()
    base = {'topic_id': topic_id, 'user_id': principal.user_id,
            'workspace_id': principal.workspace_id, 'created_at': now}
    await collection.insert_many([
        {**base, 'role': 'user', 'content': user_text},
        {**base, 'role': 'assistant', 'content': assistant_text},
    ])


async def list_messages(principal, topic_id: str) -> list | None:
    """One thread's messages, oldest first. None when not the user's topic."""
    from .topics_store import owned_topic
    if not _visible(principal) or await owned_topic(principal, topic_id) is None:
        return None
    query = {'topic_id': topic_id, 'user_id': principal.user_id}
    cursor = collection.find(query).sort('created_at', 1)
    return [{'role': doc['role'], 'content': doc['content'], 'created_at': doc['created_at']}
            async for doc in cursor]
