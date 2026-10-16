"""E2E: weekly and monthly maintenance reminder jobs. Real users + records
over real HTTP, then the real jobs against the same local test DB:
due-only workspaces get vehicle-specific email, done workspaces are skipped.
No mocks."""
import asyncio
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from e2e_helpers import call, dev_token, fresh_email  # noqa: E402


def make_workspace_with_records(tag: str, due_names: list, done_names: list) -> str:
    """A workspace whose manager owns one record per vehicle name. 'done'
    vehicles have weekly+monthly already done within the current window."""
    from app.due_periods import today_date
    email = fresh_email(f'{tag}-mgr')
    token, user = dev_token(email)
    workspace_id = user['workspace_id']
    assert workspace_id, 'manager should own a workspace'
    for name in due_names + done_names:
        record = call('POST', '/service-records', token=token)
        record = call('PUT', f"/service-records/{record['id']}",
                      {**record, 'vehicle_number': name}, token=token)
        if name in done_names:
            for frequency in ('weekly', 'monthly'):
                record['schedule'][frequency]['last_done_at'] = today_date()
            call('PUT', f"/service-records/{record['id']}", record, token=token)
    return workspace_id


def _run_jobs():
    """Both jobs in ONE event loop: the shared Motor client cannot outlive
    a closed loop, so a single asyncio.run drives everything async."""
    from app.inspections_messages.service_due import (run_monthly_for_all_workspaces,
                                                      run_weekly_for_all_workspaces)

    async def both():
        return (await run_weekly_for_all_workspaces(),
                await run_monthly_for_all_workspaces())
    return asyncio.run(both())


def main():
    print('setup: workspace A (DUE-1, DUE-2 due; DONE-1 done), '
          'workspace B (ALLDONE-1 done)')
    ws_a = make_workspace_with_records('wk', ['DUE-1', 'DUE-2'], ['DONE-1'])
    ws_b = make_workspace_with_records('wkdone', [], ['ALLDONE-1'])

    print('case 1+2: weekly and monthly jobs (single event loop)')
    weekly, monthly = _run_jobs()
    result_a = weekly['results'][ws_a]
    assert result_a['due'] == 2, result_a
    assert 'DUE-1' in result_a['subject'] and 'DUE-2' in result_a['subject'], result_a
    assert 'DONE-1' not in result_a['subject'], result_a
    assert result_a['channels']['email']['delivered_to'] == 1, result_a
    result_b = weekly['results'][ws_b]
    assert result_b['due'] == 0 and 'skipped' in result_b['note'], result_b
    print('  weekly A subject:', result_a['subject'])
    print('  weekly B note:', result_b['note'])
    assert 'DUE-1' in monthly['results'][ws_a]['subject'], monthly['results'][ws_a]
    assert monthly['results'][ws_b]['due'] == 0, monthly['results'][ws_b]

    print('case 3: manual trigger endpoints return the same shape')
    triggered = _run_trigger('weekly')
    assert triggered['workspaces_skipped_not_due'] >= 1, triggered
    assert triggered['results'][ws_a]['due'] == 2, triggered['results'][ws_a]
    triggered = _run_trigger('monthly')
    assert triggered['results'][ws_a]['due'] == 2, triggered['results'][ws_a]

    print('PASS weekly/monthly maintenance reminders (due-only, vehicle-specific)')


def _run_trigger(frequency: str):
    import json
    import urllib.request
    base = os.environ['API_URL'].rstrip('/')
    request = urllib.request.Request(f'{base}/inspections-messages/run-{frequency}',
                                     data=b'{}', method='POST',
                                     headers={'X-App-Key': os.environ['APP_API_KEY']})
    with urllib.request.urlopen(request, timeout=120) as response:
        return json.loads(response.read())


main()
