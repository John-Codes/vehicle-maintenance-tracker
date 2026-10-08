from datetime import datetime, timezone

from fastapi import HTTPException

from ..storage import _oid, _to_item, store

collection = store._collection.database['users']
ROLES = ('manager', 'tech')


def public(doc):
    if doc is None:
        return None
    item = _to_item(doc)
    item.setdefault('name', '')
    item.setdefault('role', 'tech')
    item.setdefault('workspace_id', '')
    item.setdefault('privileges', [])
    return item


def _now():
    return datetime.now(timezone.utc).isoformat()


async def count_users():
    return await collection.count_documents({})


async def by_id(user_id):
    return public(await collection.find_one({'_id': _oid(user_id)}))


async def get_or_create(firebase_uid, email, name=''):
    """Find by Firebase uid, link by email, or create. First user is manager."""
    email = email.lower()
    doc = await collection.find_one({'firebase_uid': firebase_uid}) if firebase_uid else None
    if doc is None:
        doc = await collection.find_one({'email': email})
        if doc is None:
            first = await count_users() == 0
            doc = {'firebase_uid': firebase_uid, 'email': email, 'name': name,
                   'role': 'manager' if first else 'tech',
                   'workspace_id': 'default' if first else '', 'privileges': [],
                   'created_at': _now()}
            doc = await collection.find_one({'_id': (await collection.insert_one(doc)).inserted_id})
        elif firebase_uid:
            await collection.update_one({'_id': doc['_id']}, {'$set': {'firebase_uid': firebase_uid}})
            doc = await collection.find_one({'_id': doc['_id']})
    elif name and not doc.get('name'):
        await collection.update_one({'_id': doc['_id']}, {'$set': {'name': name}})
    return public(doc)


async def upsert_dev_user(email, name, role, workspace_id):
    """Dev/test path. None role/workspace triggers the same auto logic as Firebase."""
    email = email.lower()
    doc = await collection.find_one({'email': email})
    if doc is None and role is None and workspace_id is None:
        return await get_or_create('', email, name)
    role = role or 'tech'
    workspace_id = workspace_id or ''
    fields = {'name': name, 'role': role, 'workspace_id': workspace_id,
              'updated_at': _now()}
    doc = await collection.find_one_and_update(
        {'email': email}, {'$set': fields}, return_document=True)
    if doc is None:
        doc = {'firebase_uid': '', 'email': email, 'privileges': [],
               'created_at': _now(), **fields}
        doc = await collection.find_one({'_id': (await collection.insert_one(doc)).inserted_id})
    return public(doc)


async def join_workspace(user_id, workspace_id, role):
    fields = {'workspace_id': workspace_id, 'role': role, 'updated_at': _now()}
    doc = await collection.find_one_and_update(
        {'_id': _oid(user_id)}, {'$set': fields}, return_document=True)
    if doc is None:
        raise HTTPException(404, 'User not found')
    return public(doc)


async def list_workspace(workspace_id):
    cursor = collection.find({'workspace_id': workspace_id}).sort('created_at', 1)
    return [public(doc) async for doc in cursor]


async def set_role(user_id, workspace_id, role):
    if role not in ROLES:
        raise HTTPException(422, 'Role must be manager or tech')
    doc = await collection.find_one_and_update(
        {'_id': _oid(user_id), 'workspace_id': workspace_id},
        {'$set': {'role': role, 'updated_at': _now()}}, return_document=True)
    if doc is None:
        raise HTTPException(404, 'User not found in this workspace')
    return public(doc)


async def remove_from_workspace(user_id, workspace_id):
    doc = await collection.find_one_and_update(
        {'_id': _oid(user_id), 'workspace_id': workspace_id},
        {'$set': {'workspace_id': '', 'role': 'tech', 'updated_at': _now()}},
        return_document=True)
    if doc is None:
        raise HTTPException(404, 'User not found in this workspace')
