"""Due-only weekly/monthly maintenance jobs. A workspace only hears about a
frequency when it actually has records DUE in the current window - no spam."""
from ..due_periods import due_vehicle_numbers
from ..messaging.service import send_message
from ..storage import store
from .builders_monthly import build_monthly_message
from .builders_weekly import build_weekly_message
from .service import _recipients, all_workspace_ids, users_in_workspace

_BUILDERS = {'weekly': build_weekly_message, 'monthly': build_monthly_message}


async def run_due_frequency_for_all_workspaces(frequency: str) -> dict:
    """Send the frequency's reminder to every workspace that has at least one
    record due. Workspaces with everything done are skipped."""
    builder = _BUILDERS[frequency]
    summary = {'workspaces_checked': 0, 'workspaces_skipped_not_due': 0, 'results': {}}
    for workspace_id in await all_workspace_ids():
        summary['workspaces_checked'] += 1
        users = await users_in_workspace(workspace_id)
        records = await store.list('service_record', workspace_id)
        due_names, total_due = due_vehicle_numbers(records, frequency)
        if not users or total_due == 0:
            summary['workspaces_skipped_not_due'] += 1
            summary['results'][workspace_id] = {'ok': True, 'sent_to': 0,
                                                'due': total_due,
                                                'note': 'not due; skipped'}
            continue
        message = builder(_recipients(users), due_names, total_due)
        summary['results'][workspace_id] = {
            'subject': message.subject, 'due': total_due,
            'channels': await send_message(message),
        }
    return summary


async def run_weekly_for_all_workspaces() -> dict:
    return await run_due_frequency_for_all_workspaces('weekly')


async def run_monthly_for_all_workspaces() -> dict:
    return await run_due_frequency_for_all_workspaces('monthly')
