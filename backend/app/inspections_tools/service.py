"""Implementation of the mark-done chat tools. Same last_done_at field the UI
writes, so both paths stay consistent. Workspace-scoped for signed-in users."""
from datetime import datetime
from zoneinfo import ZoneInfo

from ..config import SCHEDULE_TZ
from ..storage import store

FREQUENCIES = ('daily', 'weekly', 'monthly')


def today_date() -> str:
    """The workspace 'inspection day' in the scheduler's timezone (America/Chicago)."""
    return datetime.now(ZoneInfo(SCHEDULE_TZ)).strftime('%Y-%m-%d')


def _frequency(args) -> str:
    frequency = str(args.get('frequency') or 'daily').strip().lower()
    if frequency not in FREQUENCIES:
        raise ValueError(f'frequency must be one of {FREQUENCIES}, got {frequency!r}')
    return frequency


def _who(principal) -> str:
    return principal.email if (principal and principal.email) else 'legacy-app-key'


def _workspace_scope(principal):
    """None = legacy shared-key flow (unscoped, existing behavior)."""
    if principal is None or principal.is_legacy:
        return None
    return principal.workspace_id


def _assert_same_workspace(doc, principal):
    scope = _workspace_scope(principal)
    if scope is None:
        return
    effective = doc.get('workspace_id') or 'default'
    if effective != scope:
        raise LookupError('Record not found in your workspace')


async def _mark(doc_id: str, doc: dict, frequency: str, by: str, via: str) -> dict:
    today = today_date()
    schedule = doc.get('schedule') or {}
    frequency_list = schedule.get(frequency) or {}
    already = frequency_list.get('last_done_at') == today
    frequency_list.update(last_done_at=today, last_done_by=by, last_done_via=via)
    schedule[frequency] = frequency_list
    saved = await _save(doc_id, schedule)
    return {'ok': True, 'record_id': doc_id,
            'vehicle_number': saved.get('vehicle_number', ''),
            'frequency': frequency, 'last_done_at': today,
            'last_done_by': by, 'last_done_via': via,
            'was_already_done_today': already}


async def _save(doc_id: str, schedule: dict) -> dict:
    return await store.update(doc_id, {'schedule': schedule, 'record_type': 'service_record',
                                        'updated_at': datetime.now().isoformat()})


async def mark_inspection_done(args: dict, principal) -> dict:
    frequency = _frequency(args)
    doc_id = str(args.get('record_id') or '')
    if not doc_id:
        raise ValueError('record_id is required')
    doc = await store.get(doc_id)
    _assert_same_workspace(doc, principal)
    return await _mark(doc_id, doc, frequency, _who(principal), 'chat')


async def mark_all_inspections_done(args: dict, principal) -> dict:
    frequency = _frequency(args)
    scope = _workspace_scope(principal)
    records = await store.list('service_record', scope)
    marked, skipped = [], []
    for doc in records:
        if ((doc.get('schedule') or {}).get(frequency) or {}).get('last_done_at') == today_date():
            skipped.append(doc.get('vehicle_number', doc['id']))
            continue
        result = await mark_inspection_done({'record_id': doc['id'], 'frequency': frequency}, principal)
        marked.append({'record_id': result['record_id'], 'vehicle_number': result['vehicle_number']})
    return {'ok': True, 'frequency': frequency, 'marked': marked,
            'already_done_today': skipped, 'last_done_by': _who(principal)}


async def run_inspection_tool(name: str, args: dict, principal) -> dict | None:
    """Run an inspection tool by name; returns None when the name is not ours."""
    if name == 'mark_inspection_done':
        return await mark_inspection_done(args, principal)
    if name == 'mark_all_inspections_done':
        return await mark_all_inspections_done(args, principal)
    return None
