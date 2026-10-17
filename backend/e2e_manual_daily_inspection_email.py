"""MANUAL e2e: signs up TESTER_EMAIL (default efexzium@gmail.com) on the LOCAL
test DB and triggers the real daily-inspection job so a REAL email arrives.
Not wired into CI/local_stack on purpose (commented out there).

Run (local stack on 8022, API must be started with AGENTMAIL_API_KEY +
AGENTMAIL_INBOX_ID env for a real send):

API_URL=http://127.0.0.1:8022 APP_API_KEY=local-review-key \
MONGO_URI=mongodb://127.0.0.1:27027 DB_NAME=chat_gpt_tracker_local \
TESTER_EMAIL=efexzium@gmail.com \
backend/.venv/bin/python backend/e2e_manual_daily_inspection_email.py
"""
import json
import os
import sys
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

BASE = os.environ['API_URL'].rstrip('/')
KEY = os.environ['APP_API_KEY']
TESTER_EMAIL = os.environ.get('TESTER_EMAIL', 'efexzium@gmail.com').lower()


def reset_local_users():
    """Drop local test users first so ONLY the tester gets emailed (local DB
    only, per rules)."""
    from pymongo import MongoClient
    client = MongoClient(os.environ['MONGO_URI'])
    db = client[os.environ['DB_NAME']]
    db.users.drop()
    db.invites.drop()
    client.close()
    print(f'local test DB users cleared ({os.environ["DB_NAME"]})')


def http(method, path, body=None):
    data = None if body is None else json.dumps(body).encode()
    request = urllib.request.Request(BASE + path, data=data, method=method,
                                    headers={'Content-Type': 'application/json',
                                             'X-App-Key': KEY})
    with urllib.request.urlopen(request, timeout=120) as response:
        return json.loads(response.read() or b'{}')


def main():
    reset_local_users()
    session = http('POST', '/auth/dev-token', {'email': TESTER_EMAIL})
    workspace_id = session['user']['workspace_id']
    assert workspace_id, 'signup should auto-provision a workspace'
    print(f'signed up {TESTER_EMAIL} (workspace {workspace_id})')

    summary = http('POST', '/inspections-messages/run-daily')
    assert summary['workspaces_checked'] == 1, f'expected exactly 1 workspace, got {summary}'
    result = summary['results'][workspace_id]['email']
    assert result['ok'] is True, result
    assert result['delivered_to'] == 1, result
    if result.get('dummy'):
        print(f'DUMMY SEND ONLY (API missing AGENTMAIL_API_KEY/AGENTMAIL_INBOX_ID env). '
              f'No real email was sent to {TESTER_EMAIL}.')
    else:
        print(f'REAL EMAIL SENT to {TESTER_EMAIL}: check your inbox.')
    print(json.dumps(result, indent=2))


main()
