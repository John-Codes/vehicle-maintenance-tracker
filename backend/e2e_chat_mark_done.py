"""E2E: the chat marks inspections done via real LLM tool calls over real
HTTP + DB. Verifies attribution (who/via), ambiguity refusal, mark-all
confirmation, and cross-workspace protection. Requires OPENROUTER_API_KEY.
No mocks."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from e2e_helpers import call, dev_token, fresh_email  # noqa: E402

TODAY = None


def _today():
    global TODAY
    if TODAY is None:
        from app.inspections_tools.service import today_date
        TODAY = today_date()
    return TODAY


def _daily(token, record_id):
    record = call('GET', f'/service-records/{record_id}', token=token)
    return record['schedule']['daily']


def _chat(token, message, history):
    return call('POST', '/chat', {'message': message, 'history': history}, token=token)['reply']


def _assert_marked(daily, email):
    assert daily['last_done_at'] == _today(), daily
    assert daily['last_done_by'] == email, daily
    assert daily['last_done_via'] == 'chat', daily


def main():
    email = fresh_email('markmgr')
    token, user = dev_token(email)
    assert user['workspace_id'], 'manager should own a workspace'

    truck1 = call('POST', '/service-records', token=token)
    truck1 = call('PUT', f"/service-records/{truck1['id']}",
                  {**truck1, 'vehicle_number': 'E2E-TRUCK-1'}, token=token)
    truck2 = call('POST', '/service-records', token=token)
    truck2 = call('PUT', f"/service-records/{truck2['id']}",
                  {**truck2, 'vehicle_number': 'E2E-TRUCK-2'}, token=token)

    print('case 1: mark one vehicle by name')
    reply = _chat(token, 'Mark the daily inspection done for vehicle E2E-TRUCK-1.', [])
    print('  reply:', reply[:120])
    _assert_marked(_daily(token, truck1['id']), email)
    assert _daily(token, truck2['id'])['last_done_at'] == ''

    print('case 2: ambiguous - assistant must ask, never call a tool')
    before = _daily(token, truck2['id'])['last_done_at']
    reply = _chat(token, 'Mark my daily inspection done.', [])
    print('  reply:', reply[:120])
    assert _daily(token, truck2['id'])['last_done_at'] == before, 'must not mark when ambiguous'

    print('case 3: mark all - assistant must confirm first')
    reply = _chat(token, 'Mark all daily inspections done.', [])
    print('  reply:', reply[:120])
    assert _daily(token, truck2['id'])['last_done_at'] == '', 'must not mark before yes'
    reply = _chat(token, 'Yes, mark all done.',
                  [{'role': 'user', 'content': 'Mark all daily inspections done.'},
                   {'role': 'assistant', 'content': reply}])
    print('  reply:', reply[:120])
    _assert_marked(_daily(token, truck2['id']), email)

    print('case 4: another workspace cannot touch these records')
    other_email = fresh_email('markother')
    other_token, _ = dev_token(other_email)
    other_truck = call('POST', '/service-records', token=other_token)
    reply = _chat(other_token,
                  f"Mark the daily inspection done for record id {truck1['id']}.", [])
    print('  reply:', reply[:160])
    daily = _daily(token, truck1['id'])
    assert daily['last_done_by'] == email, 'original attribution must stand'
    assert other_truck['workspace_id'] != truck1.get('workspace_id', 'default')

    print('PASS chat marks inspections done (workspace-scoped, attributed)')


main()
