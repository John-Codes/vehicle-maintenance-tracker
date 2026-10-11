"""E2E telemetry suite: real HTTP against the real backend + real database.

Telemetry = manual/gps/obd mileage + engine-hours readings per vehicle,
workspace-scoped like everything else. Test data lands in ws-telem so it
never shows up in a reviewer's default workspace.
"""
import json
import os
import urllib.error
import urllib.request

BASE = os.environ['API_URL'].rstrip('/')
KEY = os.environ['APP_API_KEY']
VEHICLE = 'E2E-PRIUS'


def call(method, path, body=None, token=None, key=KEY):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    else:
        headers['X-App-Key'] = key
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req) as res:
            raw = res.read()
            return res.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as err:
        raise SystemExit(f'{method} {path} -> {err.code} {err.read().decode()}')


def status_only(method, path, body=None, token=None, key=KEY):
    try:
        call(method, path, body, token, key)
        return 200
    except SystemExit as err:
        return int(str(err).split('-> ')[1].split(' ')[0])


def dev_token(email, role, workspace_id):
    status, session = call('POST', '/auth/dev-token',
                            {'email': email, 'role': role, 'workspace_id': workspace_id})
    assert status == 200, status
    return session['access_token'], session['user']


def main():
    manager_tok, _ = dev_token('telem-mgr@e2e.dev', 'manager', 'ws-telem')
    tech_tok, _ = dev_token('telem-tech@e2e.dev', 'tech', 'ws-telem')

    # Techs can log readings (writing is allowed for every workspace user)
    status, reading = call('POST', '/telemetry',
        {'vehicle_number': VEHICLE, 'odometer_mi': 142000.5, 'engine_hours': 3120,
         'source': 'manual', 'notes': 'first'}, token=tech_tok)
    assert status == 201 and reading['workspace_id'] == 'ws-telem', (status, reading)
    call('POST', '/telemetry', {'vehicle_number': VEHICLE, 'odometer_mi': 142350},
         token=manager_tok)
    print('add readings ok')

    # Latest wins; list filters by vehicle; newest first
    status, latest = call('GET', f'/telemetry/latest?vehicle={VEHICLE}', token=tech_tok)
    assert latest['odometer_mi'] == 142350 and latest['engine_hours'] is None, latest
    status, listed = call('GET', f'/telemetry?vehicle={VEHICLE}', token=tech_tok)
    assert len(listed) == 2 and listed[0]['odometer_mi'] == 142350, listed
    status, all_ws = call('GET', '/telemetry', token=manager_tok)
    assert any(r['vehicle_number'] == VEHICLE for r in all_ws)
    print('latest + list ok')

    # Validation rejects junk
    assert status_only('POST', '/telemetry', {'vehicle_number': '', 'odometer_mi': 1},
                       token=tech_tok) == 422
    assert status_only('POST', '/telemetry', {'vehicle_number': VEHICLE, 'odometer_mi': -5},
                       token=tech_tok) == 422
    assert status_only('POST', '/telemetry', {'vehicle_number': VEHICLE, 'odometer_mi': 1,
                        'source': 'telepathy'}, token=tech_tok) == 422
    print('validation ok')

    # Workspace isolation: other workspaces see nothing, latest 404s
    outsider_tok, _ = dev_token('telem-outsider@e2e.dev', 'tech', 'ws-elsewhere')
    status, listed = call('GET', f'/telemetry?vehicle={VEHICLE}', token=outsider_tok)
    assert listed == [], listed
    assert status_only('GET', f'/telemetry/latest?vehicle={VEHICLE}',
                      token=outsider_tok) == 404
    # No auth at all -> 401
    assert status_only('GET', '/telemetry', key='wrong-key') == 401
    print('isolation + auth ok')

    print('e2e_telemetry ok')


if __name__ == '__main__':
    main()
