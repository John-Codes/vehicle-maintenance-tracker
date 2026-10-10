"""E2E RBAC + invites suite: real HTTP against the real backend + database.

Proves the two-role contract: managers delete and manage the team, techs
read and write only. Covers invites (create, redeem, single-use, revoke)
and the manager-only user CRUD endpoints.
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
        raise SystemExit(f'{method} {path} -> {err.code} {err.read().decode()}')


def _status(method, path, body=None, token=None, key=KEY):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    else:
        headers['X-App-Key'] = key
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req) as res:
            res.read()
            return res.status
    except urllib.error.HTTPError as err:
        err.read()
        return err.code


def expect_error(method, path, code, token=None, key=KEY, body=None):
    status = _status(method, path, body, token, key)
    if status != code:
        raise SystemExit(f'{method} {path} -> {status}, want {code}')


def dev_token(email, role, workspace_id):
    status, session = call('POST', '/auth/dev-token',
                            {'email': email, 'role': role, 'workspace_id': workspace_id})
    assert status == 200, status
    return session['access_token'], session['user']


def main():
    manager_tok, manager = dev_token('mgr@e2e.dev', 'manager', 'default')
    tech_tok, tech = dev_token('tech@e2e.dev', 'tech', 'default')

    # Techs read and write; managers delete
    _, record = call('POST', '/service-records', token=tech_tok)
    _, updated = call('PUT', f"/service-records/{record['id']}",
                      {k: v for k, v in record.items() if k not in ('id', 'workspace_id')},
                      token=tech_tok)
    assert updated['id'] == record['id']
    _, listed = call('GET', '/service-records', token=tech_tok)
    assert any(item['id'] == record['id'] for item in listed)
    expect_error('DELETE', f"/service-records/{record['id']}", 403, token=tech_tok)
    call('DELETE', f"/service-records/{record['id']}", token=manager_tok)
    print('manager/tech record rights ok')

    # Manager-only endpoints block techs and the legacy key
    expect_error('GET', '/users', 403, token=tech_tok)
    expect_error('GET', '/invites', 403, token=tech_tok)
    expect_error('POST', '/invites', 403, token=tech_tok, body={'role': 'tech'})
    expect_error('GET', '/users', 403)  # legacy key cannot manage the team
    status, users = call('GET', '/users', token=manager_tok)
    emails = {user['email'] for user in users}
    assert 'tech@e2e.dev' in emails and 'mgr@e2e.dev' in emails
    print('manager-only endpoints ok')

    # Role changes, self-protection, removal
    status, promoted = call('PUT', f"/users/{tech['id']}/role", {'role': 'manager'},
                            token=manager_tok)
    assert promoted['role'] == 'manager'
    status, demoted = call('PUT', f"/users/{tech['id']}/role", {'role': 'tech'},
                           token=manager_tok)
    assert demoted['role'] == 'tech'
    expect_error('PUT', f"/users/{manager['id']}/role", 403, token=manager_tok,
                 body={'role': 'tech'})
    expect_error('DELETE', f"/users/{manager['id']}", 403, token=manager_tok)
    print('role changes ok')

    # Invites: create -> share code -> pending user redeems -> joins workspace
    status, invite = call('POST', '/invites', {'role': 'tech', 'label': 'Carlos S.'},
                          token=manager_tok)
    assert status == 201 and invite['used'] is False and invite['label'] == 'Carlos S.'
    pending_tok, pending = dev_token('new-hire@e2e.dev', 'tech', '')
    status, joined = call('POST', '/invites/redeem', {'code': invite['code']},
                          token=pending_tok)
    assert joined['workspace_id'] == 'default' and joined['role'] == 'tech'
    expect_error('POST', '/invites/redeem', 409, token=pending_tok,
                 body={'code': invite['code']})  # single-use
    status, invites = call('GET', '/invites', token=manager_tok)
    assert all(item['code'] != invite['code'] for item in invites)
    print('invite redeem ok')

    # Revoke makes a code invalid before use; redeemer of revoked code fails
    status, invite2 = call('POST', '/invites', {'role': 'tech'}, token=manager_tok)
    call('DELETE', f"/invites/{invite2['id']}", token=manager_tok)
    expect_error('POST', '/invites/redeem', 409, token=pending_tok,
                 body={'code': invite2['code']})
    print('invite revoke ok')

    # Removing a user reverts them to pending
    call('DELETE', f"/users/{pending['id']}", token=manager_tok)
    expect_error('GET', '/service-records', 403, token=pending_tok)
    print('user removal ok')

    print('e2e_rbac ok')


if __name__ == '__main__':
    main()
