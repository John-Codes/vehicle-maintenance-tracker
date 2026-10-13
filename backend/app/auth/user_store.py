"""User identity + auto-provisioning. Workspace membership operations live in
workspace_store.py; this module re-exports them so old import paths keep working.
"""
from .workspace_store import (collection, public, _now, _own_workspace,
                              _activation, by_id, join_workspace,
                              switch_workspace, list_workspace, set_role,
                              remove_from_workspace)

ROLES = ('manager', 'tech')


async def get_or_create(firebase_uid, email, name=''):
    """Link by Firebase uid or email, or provision a user's own workspace."""
    email = email.lower()
    doc = None
    if firebase_uid:
        doc = await collection.find_one({'firebase_uid': firebase_uid})
        if doc is None:
            linked = await collection.find_one({'email': email})
            if linked is not None:
                await collection.update_one({'_id': linked['_id']},
                                            {'$set': {'firebase_uid': firebase_uid}})
                doc = await collection.find_one({'_id': linked['_id']})
    if doc is None:
        workspace_id = _own_workspace()
        doc = {'firebase_uid': firebase_uid or '', 'email': email, 'name': name,
               'role': 'manager', 'workspace_id': workspace_id, 'privileges': [],
               'memberships': [{'workspace_id': workspace_id, 'role': 'manager'}],
               'created_at': _now()}
        doc = await collection.find_one({'_id': (await collection.insert_one(doc)).inserted_id})
    elif not doc.get('memberships'):
        workspace_id = _own_workspace()
        doc = await collection.find_one_and_update(
            {'_id': doc['_id']},
            {'$set': {'role': 'manager', **_activation(workspace_id),
                      'memberships': [{'workspace_id': workspace_id, 'role': 'manager'}]}},
            return_document=True)
    elif name and not doc.get('name'):
        doc = await collection.find_one_and_update(
            {'_id': doc['_id']}, {'$set': {'name': name}}, return_document=True)
    return public(doc)


async def upsert_dev_user(email, name, role, workspace_id):
    """Dev/test fast path. Omitting role and workspace_id mirrors Firebase
    auto-assign; explicit values force-assign (dev/test only)."""
    email = email.lower()
    doc = await collection.find_one({'email': email})
    if doc is None and role is None and workspace_id is None:
        return await get_or_create('', email, name)
    if role is not None or workspace_id is not None:
        role = role or 'tech'
        workspace_id = workspace_id or ''
        memberships = [dict(m) for m in ((doc or {}).get('memberships') or []) if m.get('workspace_id') != workspace_id]
        if workspace_id:
            memberships.append({'workspace_id': workspace_id, 'role': role})
        fields = {'name': name, 'role': role, 'workspace_id': workspace_id,
                  'memberships': memberships, 'updated_at': _now()}
        doc = await collection.find_one_and_update(
            {'email': email}, {'$set': fields}, return_document=True)
        if doc is None:
            doc = {'firebase_uid': '', 'email': email, 'privileges': [],
                   'created_at': _now(), **fields}
            doc = await collection.find_one({'_id': (await collection.insert_one(doc)).inserted_id})
        return public(doc)
    if name and not doc.get('name'):
        doc = await collection.find_one_and_update(
            {'_id': doc['_id']}, {'$set': {'name': name}}, return_document=True)
    return public(doc)