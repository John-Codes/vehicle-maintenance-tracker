"""Shared real-HTTP client helpers for backend e2e suites (no mocks)."""
import json
import os
import uuid
import urllib.error
import urllib.request

BASE = os.environ['API_URL'].rstrip('/')
KEY = os.environ['APP_API_KEY']


def call(method, path, body=None, token=None, key=KEY):
    status, payload = raw(method, path, body, token, key)
    if status >= 400:
        raise SystemExit(f'{method} {path} -> {status} {payload}')
    return payload


def raw(method, path, body=None, token=None, key=KEY):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    else:
        headers['X-App-Key'] = key
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req) as res:
            content = res.read()
            return res.status, json.loads(content) if content else None
    except urllib.error.HTTPError as err:
        return err.code, err.read().decode()


def expect_error(method, path, expected_code, token=None, key=KEY, body=None):
    status, _ = raw(method, path, body, token, key)
    if status != expected_code:
        raise SystemExit(f'{method} {path} -> {status}, want {expected_code}')


def dev_token(email, role=None, workspace_id=None):
    body = {'email': email}
    if role:
        body['role'] = role
    if workspace_id is not None:
        body['workspace_id'] = workspace_id
    session = call('POST', '/auth/dev-token', body)
    return session['access_token'], session['user']


def fresh_email(kind):
    return f'{kind}-{uuid.uuid4().hex[:10]}@e2e.dev'


def memberships_ws(user):
    return {m['workspace_id'] for m in user.get('memberships', [])}


def switch(token, workspace_id):
    return call('PUT', '/auth/workspace', {'workspace_id': workspace_id}, token=token)


def team_invite(token, role='tech'):
    return call('POST', '/invites', {'role': role}, token=token)