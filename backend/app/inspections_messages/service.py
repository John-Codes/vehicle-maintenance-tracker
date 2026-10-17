"""Core job logic: per-workspace daily inspection messages (unconditional,
generic by design). Weekly/monthly due-only jobs live in service_due.py."""
from ..auth.workspace_store import collection as users_collection
from ..messaging.models import MessageRecipient
from ..messaging.service import send_message
from .builders_daily import build_daily_inspection_message


async def all_workspace_ids() -> list[str]:
    """Distinct workspace ids found in any user's memberships."""
    return await users_collection.distinct('memberships.workspace_id')


async def users_in_workspace(workspace_id: str) -> list[dict]:
    """Every member of a workspace (active or not), with an email."""
    cursor = users_collection.find({'memberships.workspace_id': workspace_id})
    return [doc async for doc in cursor if doc.get('email')]


def _recipients(users: list[dict]) -> list[MessageRecipient]:
    return [MessageRecipient(email=doc['email'], name=doc.get('name') or '')
            for doc in users]


async def run_daily_inspection_for_all_workspaces() -> dict:
    """Send the generic daily inspection reminder to all users of every
    workspace. Per-workspace failures are recorded, not fatal."""
    summary = {'workspaces_checked': 0, 'users_considered': 0, 'results': {}}
    for workspace_id in await all_workspace_ids():
        summary['workspaces_checked'] += 1
        users = await users_in_workspace(workspace_id)
        summary['users_considered'] += len(users)
        if not users:
            summary['results'][workspace_id] = {'ok': True, 'sent_to': 0,
                                               'note': 'no users; nothing sent'}
            continue
        results = await send_message(build_daily_inspection_message(_recipients(users)))
        summary['results'][workspace_id] = results
    return summary
