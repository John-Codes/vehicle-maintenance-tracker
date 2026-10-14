import json
import os
import sys
import urllib.error
import urllib.request

import e2e_search
import e2e_step_fields

BASE = os.environ['API_URL'].rstrip('/')
KEY = os.environ['APP_API_KEY']

def call(method, path, body=None):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method, headers={'X-App-Key': KEY, 'Content-Type': 'application/json'})
    try:
        with urllib.request.urlopen(req) as res:
            raw = res.read()
            return res.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as err:
        detail = err.read().decode()
        raise SystemExit(f'{method} {path} -> {err.code} {detail}')

def main():
    status, created = call('POST', '/service-records')
    assert status == 200, status
    schedule = created['schedule']
    assert set(schedule) == {'daily', 'weekly', 'monthly'}
    schedule['daily']['components'] = [{'id': 'engine', 'title': 'Engine', 'steps': [{'id': 'oil', 'title': 'Oil level', 'done': False, 'not_applicable': False, 'value': '', 'notes': '', 'description': ''}]}]
    schedule['daily']['last_done_at'] = '2026-10-06'
    created['vehicle_number'] = 'E2E-UNIT'
    created['schedule'] = schedule
    _, saved = call('PUT', f"/service-records/{created['id']}", {k: v for k, v in created.items() if k not in ('id', 'record_type', 'created_at', 'updated_at')})
    assert saved['schedule']['daily']['last_done_at'] == '2026-10-06'
    assert saved['schedule']['daily']['components'][0]['steps'][0]['title'] == 'Oil level'
    # Vehicle identity + scanner binding round-trip (additive, defaults safe)
    saved['brand'] = 'Toyota'
    saved['model'] = 'Prius'
    saved['year'] = 2012
    saved['vehicle_type'] = 'car'
    saved['scanner'] = {'id': 'veepeak-ble', 'device_id': 'AA:BB:CC:11:22:33',
                        'kind': 'ble', 'paired_at': '2026-10-11T14:02:00Z',
                        'last_synced_at': '2026-10-11T18:40:00Z'}
    _, bound = call('PUT', f"/service-records/{created['id']}",
                    {k: v for k, v in saved.items() if k not in ('id', 'record_type', 'created_at', 'updated_at')})
    assert bound['brand'] == 'Toyota' and bound['model'] == 'Prius' and bound['year'] == 2012, bound
    assert bound['vehicle_type'] == 'car' and bound['scanner']['device_id'] == 'AA:BB:CC:11:22:33', bound
    try:
        saved['year'] = 1700
        call('PUT', f"/service-records/{created['id']}",
             {k: v for k, v in saved.items() if k not in ('id', 'record_type', 'created_at', 'updated_at')})
        raise SystemExit('invalid year was accepted')
    except SystemExit as err:
        if '422' not in str(err):
            raise
    saved['year'] = 2012
    try:
        saved['vehicle_type'] = 'spaceship'
        call('PUT', f"/service-records/{created['id']}",
             {k: v for k, v in saved.items() if k not in ('id', 'record_type', 'created_at', 'updated_at')})
        raise SystemExit('invalid vehicle_type was accepted')
    except SystemExit as err:
        if '422' not in str(err):
            raise
    saved['vehicle_type'] = 'car'
    _, listed = call('GET', '/service-records')
    assert any(item['id'] == created['id'] and 'steps' not in item for item in listed)
    try:
        call('PUT', f"/service-records/{created['id']}", {k: v for k, v in saved.items() if k not in ('id', 'record_type', 'created_at', 'updated_at', 'schedule')})
        raise SystemExit('missing schedule was accepted')
    except SystemExit as err:
        if '422' not in str(err):
            raise
    call('DELETE', f"/service-records/{created['id']}")
    _, listed = call('GET', '/service-records')
    assert all(item['id'] != created['id'] for item in listed)
    print('e2e ok')
    e2e_search.main()
    import e2e_service_types
    e2e_service_types.main()
    e2e_step_fields.main()
    import e2e_checklist
    e2e_checklist.main()
    import e2e_chat
    e2e_chat.main()

if __name__ == '__main__':
    main()
