"""E2E auth suite: real HTTP against the real backend + real database.

Uses the dev-token fast path (AUTH_MODE=dev) so no Firebase credentials
are needed. Exercises the full real pipeline: token issue, verification,
user store, workspace scoping, and the legacy shared-key fallback.
"""
import json
import os
import urllib.error
import urllib.request

BASE = os.environ['API_URL'].rstrip('/')
KEY = os.environ['APP_API_KEY']


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
        detail = err.read().decode()
        raise SystemExit(f'{method} {path} -> {err.code} {detail}')


def expect_error(method, path, expected_code, token=None, key=KEY, body=None):
    try:
        call(method, path, body, token, key)
        raise SystemExit(f'{method} {path} should have failed with {expected_code}')
    except SystemExit as err:
        if expected_code not in str(err):
            raise


def call_status(method, path, body=None, token=None, key=KEY):
    """Like call() but returns (status, body) instead of dying on HTTP errors."""
    headers = {'Content-Type': 'application/json'}
    headers['Authorization' if token else 'X-App-Key'] = token if token else key
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req) as res:
            raw = res.read()
            return res.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as err:
        return err.code, err.read().decode()


def dev_token(email, role='technician', workspace_id=''):
    status, session = call('POST', '/auth/dev-token',
                           {'email': email, 'role': role, 'workspace_id': workspace_id})
    assert status == 200, status
    return session['access_token'], session['user']


def main():
    # Dev-token issue + /auth/me round trip
    token_a, user_a = dev_token('manager-a@e2e.dev', 'manager', 'ws-alpha')
    assert user_a['workspace_id'] == 'ws-alpha' and user_a['role'] == 'manager'
    status, me = call('GET', '/auth/me', token=token_a)
    assert status == 200 and me['email'] == 'manager-a@e2e.dev'
    print('dev-token + me ok')

    # Workspace scoping: ws-alpha record invisible to ws-beta
    _, record_a = call('POST', '/service-records', token=token_a)
    assert record_a['workspace_id'] == 'ws-alpha'
    token_b, _ = dev_token('tech-b@e2e.dev', 'technician', 'ws-beta')
    _, listed_b = call('GET', '/service-records', token=token_b)
    assert all(item['id'] != record_a['id'] for item in listed_b), 'workspace leak in list'
    expect_error('GET', f"/service-records/{record_a['id']}", '404', token=token_b)
    expect_error('DELETE', f"/service-records/{record_a['id']}", '404', token=token_b)
    print('workspace isolation ok')

    # Default workspace (dev-token default) sees legacy unscoped records
    _, legacy_record = call('POST', '/service-records')
    assert legacy_record['workspace_id'] == 'default'
    token_d, _ = dev_token('default-user@e2e.dev')
    _, listed_d = call('GET', '/service-records', token=token_d)
    assert any(item['id'] == legacy_record['id'] for item in listed_d), 'default ws missing legacy'
    assert all(item['id'] != record_a['id'] for item in listed_d), 'cross-workspace leak'
    _, listed_legacy = call('GET', '/service-records')
    assert any(item['id'] == legacy_record['id'] for item in listed_legacy)
    assert not any(item['id'] == record_a['id'] for item in listed_legacy)
    print('default + legacy key ok')

    # Bad tokens rejected
    expect_error('GET', '/service-records', '401', token='not-a-real-token')
    expect_error('GET', '/service-records', '401', key='wrong-key')
    # Garbage Firebase token rejected by the verifier
    expect_error('POST', '/auth/firebase', '401', body={'id_token': 'x' * 40})
    print('token rejection ok')

    # Bootstrap admin: first call wins (201 on a fresh DB), then permanently 409
    status, admin = call_status('POST', '/auth/bootstrap-admin', {'email': 'boss@e2e.dev'})
    if status == 201:
        assert admin['role'] == 'admin', admin
    else:
        assert status == 409, (status, admin)  # admin from an earlier run
    status, _ = call_status('POST', '/auth/bootstrap-admin', {'email': 'other-boss@e2e.dev'})
    assert status == 409, f'second bootstrap returned {status}, want 409'
    status, me = call('GET', '/auth/me', token=token_a)
    assert me['email'] == 'manager-a@e2e.dev'
    print('bootstrap-admin ok')

    # Cleanup test records
    call('DELETE', f"/service-records/{record_a['id']}", token=token_a)
    call('DELETE', f"/service-records/{legacy_record['id']}")
    print('e2e_auth ok')


if __name__ == '__main__':
    main()
