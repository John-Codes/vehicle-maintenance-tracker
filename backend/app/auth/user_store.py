from datetime import datetime, timezone

from fastapi import HTTPException

from ..storage import _oid, _to_item, store

collection = store._collection.database['users']

PUBLIC_FIELDS = ('id', 'firebase_uid', 'email', 'name', 'role', 'workspace_id', 'privileges')


def public(doc):
    if doc is None:
        return None
    item = _to_item(doc)
    item.setdefault('name', '')
    item.setdefault('role', 'technician')
    item.setdefault('workspace_id', 'default')
    item.setdefault('privileges', [])
    return item


async def by_id(user_id):
    return public(await collection.find_one({'_id': _oid(user_id)}))


async def get_or_create(firebase_uid, email, name=''):
    """Find a user by Firebase uid, link by email, or create with defaults."""
    email = email.lower()
    doc = await collection.find_one({'firebase_uid': firebase_uid})
    if doc is None:
        doc = await collection.find_one({'email': email})
        if doc is None:
            doc = {'firebase_uid': firebase_uid, 'email': email, 'name': name,
                   'role': 'technician', 'workspace_id': 'default',
                   'privileges': [], 'created_at': _now()}
            doc = await collection.find_one({'_id': (await collection.insert_one(doc)).inserted_id})
        else:
            await collection.update_one({'_id': doc['_id']}, {'$set': {'firebase_uid': firebase_uid}})
    elif name and not doc.get('name'):
        await collection.update_one({'_id': doc['_id']}, {'$set': {'name': name}})
    return public(doc)


async def upsert_dev_user(email, name, role, workspace_id):
    """Dev/test path: create or reconfigure a user by email (no Firebase)."""
    email = email.lower()
    fields = {'name': name, 'role': role,
              'workspace_id': workspace_id or 'default', 'updated_at': _now()}
    doc = await collection.find_one_and_update(
        {'email': email}, {'$set': fields}, return_document=True)
    if doc is None:
        doc = {'firebase_uid': '', 'email': email, 'privileges': [],
               'created_at': _now(), **fields}
        doc = await collection.find_one({'_id': (await collection.insert_one(doc)).inserted_id})
    return public(doc)


async def count_admins():
    return await collection.count_documents({'role': 'admin'})


async def bootstrap_admin(email):
    """Create or promote the first and only initial admin. 409 once one exists."""
    email = email.lower()
    if await count_admins():
        raise HTTPException(409, 'An admin already exists')
    doc = await collection.find_one_and_update(
        {'email': email}, {'$set': {'role': 'admin'}}, return_document=True)
    if doc is None:
        doc = {'firebase_uid': '', 'email': email, 'name': '', 'role': 'admin',
               'workspace_id': 'default', 'privileges': [], 'created_at': _now()}
        doc = await collection.find_one({'_id': (await collection.insert_one(doc)).inserted_id})
    return public(doc)


def _now():
    return datetime.now(timezone.utc).isoformat()
