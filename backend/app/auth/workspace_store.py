"""Workspace memberships: a user belongs to many workspaces, one is active.

Each user doc keeps `memberships` (workspace_id + role per workspace) plus an
active `workspace_id`/`role`. Old workspaces are never dropped, so switching
never loses data.
"""
from datetime import datetime, timezone

from bson.objectid import ObjectId
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
    item.setdefault('memberships', [])
    return item


def _now():
    return datetime.now(timezone.utc).isoformat()


def _own_workspace():
    return f'ws-{ObjectId()}'


def _activation(workspace_id):
    """Fields that make a workspace the user's active one."""
    return {'workspace_id': workspace_id, 'updated_at': _now()}


async def by_id(user_id):
    return public(await collection.find_one({'_id': _oid(user_id)}))


async def join_workspace(user_id, workspace_id, role):
    """Invite redeem: upsert a membership and make the invited workspace active."""
    doc = await collection.find_one({'_id': _oid(user_id)})
    if doc is None:
        raise HTTPException(404, 'User not found')
    memberships = [m for m in doc.get('memberships', [])
                   if m.get('workspace_id') != workspace_id]
    memberships.append({'workspace_id': workspace_id, 'role': role})
    doc = await collection.find_one_and_update(
        {'_id': _oid(user_id)},
        {'$set': {'role': role, **_activation(workspace_id), 'memberships': memberships}},
        return_document=True)
    return public(doc)


async def switch_workspace(user_id, workspace_id):
    """Activate a workspace the user already belongs to (never loses old data)."""
    doc = await collection.find_one({'_id': _oid(user_id)})
    if doc is None:
        raise HTTPException(404, 'User not found')
    membership = next((m for m in doc.get('memberships', [])
                       if m.get('workspace_id') == workspace_id), None)
    if membership is None:
        raise HTTPException(403, 'Not a member of this workspace')
    doc = await collection.find_one_and_update(
        {'_id': _oid(user_id)},
        {'$set': {'role': membership.get('role', 'tech'), **_activation(workspace_id)}},
        return_document=True)
    return public(doc)


async def list_workspace(workspace_id):
    cursor = collection.find({'workspace_id': workspace_id}).sort('created_at', 1)
    return [public(doc) async for doc in cursor]


async def set_role(user_id, workspace_id, role):
    if role not in ROLES:
        raise HTTPException(422, 'Role must be manager or tech')
    doc = await collection.find_one({'_id': _oid(user_id), 'workspace_id': workspace_id})
    if doc is None:
        raise HTTPException(404, 'User not found in this workspace')
    memberships = [{'workspace_id': m['workspace_id'],
                    'role': role if m['workspace_id'] == workspace_id else m['role']}
                   for m in doc.get('memberships', [])]
    doc = await collection.find_one_and_update(
        {'_id': _oid(user_id)},
        {'$set': {'role': role, 'memberships': memberships, 'updated_at': _now()}},
        return_document=True)
    return public(doc)


async def remove_from_workspace(user_id, workspace_id):
    doc = await collection.find_one({'_id': _oid(user_id), 'workspace_id': workspace_id})
    if doc is None:
        raise HTTPException(404, 'User not found in this workspace')
    remaining = [m for m in doc.get('memberships', [])
                 if m.get('workspace_id') != workspace_id]
    if remaining:
        fallback = remaining[0]
        fields = {'role': fallback.get('role', 'tech'), 'memberships': remaining,
                  'workspace_id': fallback.get('workspace_id', ''), 'updated_at': _now()}
    else:
        fields = {'role': 'tech', 'memberships': [], 'workspace_id': '',
                  'updated_at': _now()}
    await collection.find_one_and_update({'_id': _oid(user_id)}, {'$set': fields})