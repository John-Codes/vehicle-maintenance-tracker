import secrets

from fastapi import HTTPException

from ..storage import _oid, _to_item, store


def _now():
    from datetime import datetime, timezone
    return datetime.now(timezone.utc).isoformat()


collection = store._collection.database['invites']


def public(doc):
    if doc is None:
        return None
    item = _to_item(doc)
    item.setdefault('workspace_id', '')
    item.setdefault('role', 'tech')
    item.setdefault('used', False)
    item.setdefault('created_by', '')
    item.setdefault('used_by', '')
    return item


async def create(workspace_id, role, created_by):
    """One invite = one single-use code, revocable, scoped to a workspace."""
    invite = {'code': secrets.token_urlsafe(6), 'workspace_id': workspace_id,
              'role': role, 'created_by': created_by, 'created_at': _now(),
              'used': False, 'used_by': '', 'used_at': ''}
    result = await collection.insert_one(invite)
    return public(await collection.find_one({'_id': result.inserted_id}))


async def list_active(workspace_id):
    cursor = collection.find({'workspace_id': workspace_id, 'used': False}).sort('created_at', -1)
    return [public(doc) async for doc in cursor]


async def redeem(code, user_id):
    """Atomically consume a code so it can never be redeemed twice."""
    doc = await collection.find_one_and_update(
        {'code': code, 'used': False},
        {'$set': {'used': True, 'used_by': user_id, 'used_at': _now()}},
        return_document=True)
    if doc is None:
        raise HTTPException(409, 'Invite code is invalid or already used')
    return public(doc)


async def revoke(invite_id, workspace_id):
    result = await collection.update_one(
        {'_id': _oid(invite_id), 'workspace_id': workspace_id, 'used': False},
        {'$set': {'used': True, 'used_by': 'revoked', 'used_at': _now()}})
    if not result.matched_count:
        raise HTTPException(404, 'Invite not found')
