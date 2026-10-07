import json
import os
import urllib.error
import urllib.request

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

def put_fields(record):
    return {k: v for k, v in record.items() if k not in ('id', 'record_type', 'created_at', 'updated_at')}

def main():
    _, record = call('POST', '/service-records')
    record['vehicle_number'] = 'E2E-STEP-FIELDS'
    record['schedule'] = {
        'daily': {'last_done_at': '', 'components': [{'id': 'lights', 'title': 'Lights', 'steps': [
            {'id': 'l-1', 'title': 'Headlights', 'done': False, 'not_applicable': False,
             'value': 'Left side, 12.4V', 'notes': 'Lens cloudy, replace soon', 'description': ''}]}]},
        'weekly': {'last_done_at': '', 'components': []},
        'monthly': {'last_done_at': '', 'components': []},
    }
    _, saved = call('PUT', f"/service-records/{record['id']}", put_fields(record))
    step = saved['schedule']['daily']['components'][0]['steps'][0]
    assert step['title'] == 'Headlights', step
    assert step['value'] == 'Left side, 12.4V', step
    assert step['notes'] == 'Lens cloudy, replace soon', step

    _, fetched = call('GET', f"/service-records/{record['id']}")
    step = fetched['schedule']['daily']['components'][0]['steps'][0]
    assert step['value'] == 'Left side, 12.4V', 'value lost on GET'
    assert step['notes'] == 'Lens cloudy, replace soon', 'notes lost on GET'
    call('DELETE', f"/service-records/{record['id']}")
    print('e2e step fields ok')

if __name__ == '__main__':
    main()
