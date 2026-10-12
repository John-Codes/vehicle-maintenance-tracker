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

def step(step_id, title, started='', spent=0, done=False, done_at=''):
    return {'id': step_id, 'title': title, 'done': done, 'not_applicable': False,
            'done_at': done_at, 'time_started_at': started, 'time_spent_seconds': spent,
            'value': '', 'notes': '', 'description': ''}

def schedule(daily_steps):
    comp = {'id': 'engine', 'title': 'Engine', 'steps': daily_steps}
    return {f: {'last_done_at': '', 'components': [comp if f == 'daily' else {'id': 'engine', 'title': 'Engine', 'steps': []}]}
            for f in ('daily', 'weekly', 'monthly')}

def steps(record):
    return record['schedule']['daily']['components'][0]['steps']

def put_body(record):
    return {k: v for k, v in record.items() if k not in ('id', 'record_type', 'created_at', 'updated_at')}

def main():
    legacy = {'id': 'old', 'title': 'Legacy step', 'done': False, 'not_applicable': False,
              'done_at': '', 'done_history': [], 'value': '', 'notes': '', 'description': ''}
    _, created = call('POST', '/service-records')
    rid = created['id']
    try:
        # Old records without the new fields keep working (additive defaults).
        created['vehicle_number'] = 'E2E-TIME'
        created['schedule'] = schedule([step('oil', 'Oil level'), legacy])
        _, saved = call('PUT', f'/service-records/{rid}', put_body(created))
        legacy_saved = steps(saved)[1]
        assert legacy_saved['time_started_at'] == '' and legacy_saved['time_spent_seconds'] == 0, legacy_saved
        comp_saved = saved['schedule']['daily']['components'][0]
        assert comp_saved['time_started_at'] == '' and comp_saved['time_spent_seconds'] == 0, comp_saved
        assert saved['schedule']['daily']['time_started_at'] == '', saved['schedule']['daily']

        # Tap 1: start the timer -> time_started_at is saved the moment it is tapped.
        _, fetched = call('GET', f'/service-records/{rid}')
        steps(fetched)[0]['time_started_at'] = '2026-10-09T08:00:00.000'
        _, saved = call('PUT', f'/service-records/{rid}', put_body(fetched))
        assert steps(saved)[0]['time_spent_seconds'] == 0, steps(saved)[0]
        _, refetched = call('GET', f'/service-records/{rid}')
        assert steps(refetched)[0]['time_started_at'] == '2026-10-09T08:00:00.000', steps(refetched)[0]

        # Unrelated save must round-trip the running timer unchanged.
        refetched['notes'] = 'autosave touch'
        _, saved2 = call('PUT', f'/service-records/{rid}', put_body(refetched))
        assert steps(saved2)[0]['time_started_at'] == '2026-10-09T08:00:00.000', steps(saved2)[0]

        # Mark done: time_spent_seconds is stored next to time_started_at.
        steps(saved2)[0].update(done=True, done_at='2026-10-09T08:05:12.000', time_spent_seconds=312)
        _, saved3 = call('PUT', f'/service-records/{rid}', put_body(saved2))
        s3 = steps(saved3)[0]
        assert s3['time_spent_seconds'] == 312 and s3['time_started_at'] == '2026-10-09T08:00:00.000', s3

        # Delete time + start again: both fields reset to their defaults.
        steps(saved3)[0].update(done=False, done_at='', time_started_at='', time_spent_seconds=0)
        _, saved4 = call('PUT', f'/service-records/{rid}', put_body(saved3))
        reset = steps(saved4)[0]
        assert reset['done'] is False and reset['time_started_at'] == '' and reset['time_spent_seconds'] == 0, reset

        # Component timers are independent of their steps.
        comp = saved4['schedule']['daily']['components'][0]
        comp.update(time_started_at='2026-10-09T09:00:00.000', time_spent_seconds=180)
        _, saved5 = call('PUT', f'/service-records/{rid}', put_body(saved4))
        comp5 = saved5['schedule']['daily']['components'][0]
        assert comp5['time_started_at'] == '2026-10-09T09:00:00.000' and comp5['time_spent_seconds'] == 180, comp5
        assert steps(saved5)[0]['time_started_at'] == '', steps(saved5)[0]

        # Frequency timers are independent of their components.
        saved5['schedule']['daily'].update(last_done_at='2026-10-09', time_started_at='2026-10-09T08:00:00.000', time_spent_seconds=300)
        _, saved6 = call('PUT', f'/service-records/{rid}', put_body(saved5))
        daily6 = saved6['schedule']['daily']
        assert daily6['last_done_at'] == '2026-10-09', daily6
        assert daily6['time_started_at'] == '2026-10-09T08:00:00.000' and daily6['time_spent_seconds'] == 300, daily6
        assert daily6['components'][0]['time_spent_seconds'] == 180, daily6['components'][0]
    finally:
        call('DELETE', f'/service-records/{rid}')
    print('e2e time tracking ok')

if __name__ == '__main__':
    main()
