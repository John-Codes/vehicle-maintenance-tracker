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

def step(step_id, title, done=False, done_at='', history=None):
    return {'id': step_id, 'title': title, 'done': done, 'not_applicable': False,
            'done_at': done_at, 'done_history': history or [], 'value': '', 'notes': '', 'description': ''}

def schedule(daily_steps):
    component = {'id': 'engine', 'title': 'Engine', 'steps': daily_steps}
    empty = {'id': 'engine', 'title': 'Engine', 'steps': []}
    return {'daily': {'last_done_at': '2026-10-07', 'components': [component]},
            'weekly': {'last_done_at': '', 'components': [empty]},
            'monthly': {'last_done_at': '', 'components': [empty]}}

def first_step(record):
    return record['schedule']['daily']['components'][0]['steps'][0]

def put_body(record):
    return {k: v for k, v in record.items() if k not in ('id', 'record_type', 'created_at', 'updated_at')}

def main():
    _, created = call('POST', '/service-records')
    rid = created['id']
    try:
        history = [{'at': '2026-10-07T14:30:00.000', 'lat': 51.5007, 'lng': -0.1246, 'accuracy': 8.5}]
        created['vehicle_number'] = 'E2E-HISTORY'
        created['schedule'] = schedule([step('oil', 'Oil level', done=True, done_at='2026-10-07T14:30:00.000', history=history),
                                         step('brake', 'Brake pads')])
        _, saved = call('PUT', f'/service-records/{rid}', put_body(created))
        saved_step = first_step(saved)
        assert saved_step['done_at'] == '2026-10-07T14:30:00.000', saved_step
        assert saved_step['done_history'] == history, saved_step['done_history']

        _, fetched = call('GET', f'/service-records/{rid}')
        fetched_step = first_step(fetched)
        assert fetched_step['done_history'][0]['lat'] == 51.5007, fetched_step
        assert fetched_step['done_history'][0]['accuracy'] == 8.5, fetched_step
        assert fetched['schedule']['daily']['last_done_at'] == '2026-10-07'

        # Unrelated save must round-trip history unchanged (append-only from here).
        fetched['notes'] = 'autosave touch'
        _, saved2 = call('PUT', f'/service-records/{rid}', put_body(fetched))
        assert first_step(saved2)['done_history'] == history, 'history lost on later save'

        # Unchecking clears done_at but keeps the history log.
        step2 = first_step(saved2)
        step2.update(done=False, done_at='')
        _, saved3 = call('PUT', f'/service-records/{rid}', put_body(saved2))
        assert first_step(saved3)['done_at'] == '', first_step(saved3)
        assert first_step(saved3)['done_history'] == history, 'history lost on uncheck'
    finally:
        call('DELETE', f'/service-records/{rid}')

    # Service type templates must strip completion history on save.
    name = 'E2E-History-Type'
    _, listed = call('GET', '/service-types')
    for item in listed:
        if item['name'] == name:
            call('DELETE', f"/service-types/{item['id']}")
    _, created_type = call('POST', '/service-types', {
        'name': name,
        'schedule': schedule([step('oil', 'Oil level', done=True, done_at='2026-10-07T14:30:00.000',
                                   history=[{'at': '2026-10-07T14:30:00.000', 'lat': 1.0, 'lng': 2.0, 'accuracy': 3.0}])])})
    try:
        _, fetched_type = call('GET', f"/service-types/{created_type['id']}")
        stored = fetched_type['schedule']['daily']['components'][0]['steps'][0]
        assert stored['done_at'] == '', stored
        assert stored['done_history'] == [], stored['done_history']
    finally:
        call('DELETE', f"/service-types/{created_type['id']}")
    print('e2e checklist ok')

if __name__ == '__main__':
    main()
