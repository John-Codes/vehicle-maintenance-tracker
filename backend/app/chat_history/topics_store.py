"""Conversation-thread (topic) management: create, list, delete. Threads are
private per user; a thread is titled from its first message."""
from datetime import datetime, timezone

from bson.objectid import ObjectId

from ..storage import store
from .store import _now, _visible, collection

topics_collection = store._collection.database['chat_topics']
MAX_TOPICS = 50
MAX_TITLE = 60


async def start_topic(principal, first_message: str) -> dict:
    """Open a new conversation thread, titled from the first message."""
    title = ' '.join((first_message or '').split())[:MAX_TITLE] or 'Conversation'
    doc = {'user_id': principal.user_id, 'workspace_id': principal.workspace_id,
           'email': principal.email, 'title': title,
           'created_at': _now(), 'updated_at': _now()}
    result = await topics_collection.insert_one(doc)
    return {'topic_id': str(result.inserted_id), 'title': title}


async def owned_topic(principal, topic_id: str) -> dict | None:
    """The thread if it exists AND belongs to this user in this workspace."""
    try:
        query = {'_id': ObjectId(topic_id), 'user_id': principal.user_id,
                 'workspace_id': principal.workspace_id}
    except Exception:
        return None
    return await topics_collection.find_one(query)


async def ensure_topic(principal, topic_id: str, first_message: str) -> dict | None:
    """Reuse the caller's thread, or start a new one. Legacy users get None."""
    if not _visible(principal):
        return None
    if topic_id:
        topic = await owned_topic(principal, topic_id)
        if topic is not None:
            return {'topic_id': topic_id, 'title': topic['title']}
    return await start_topic(principal, first_message)


async def list_topics(principal) -> list:
    """The user's threads, newest activity first."""
    if not _visible(principal):
        return []
    query = {'user_id': principal.user_id, 'workspace_id': principal.workspace_id}
    cursor = topics_collection.find(query).sort('updated_at', -1).limit(MAX_TOPICS)
    return [{'topic_id': str(doc['_id']), 'title': doc['title'],
             'updated_at': doc['updated_at']} async for doc in cursor]


async def delete_topic(principal, topic_id: str) -> bool:
    if not _visible(principal) or await owned_topic(principal, topic_id) is None:
        return False
    await topics_collection.delete_one({'_id': ObjectId(topic_id)})
    await collection.delete_many({'topic_id': topic_id, 'user_id': principal.user_id})
    return True


async def clear_history(principal) -> int:
    """Wipe every thread and message of the user in this workspace."""
    if not _visible(principal):
        return 0
    query = {'user_id': principal.user_id, 'workspace_id': principal.workspace_id}
    result = await topics_collection.delete_many(query)
    await collection.delete_many(query)
    return result.deleted_count
