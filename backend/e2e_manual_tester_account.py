"""MANUAL e2e against the TESTER'S OWN account (default efexzium@gmail.com):
real chat marks with real attribution, real reminder emails to their inbox
(daily + weekly/monthly naming their vehicles), and the due-only skip.
Drops local test users first so ONLY the tester exists (no e2e.dev spam).
Not wired into CI. Run against the local stack (API needs AgentMail env):

API_URL=http://127.0.0.1:8024 APP_API_KEY=local-review-key \
MONGO_URI=mongodb://127.0.0.1:27027 DB_NAME=chat_gpt_tracker_local \
TESTER_EMAIL=efexzium@gmail.com \
backend/.venv/bin/python backend/e2e_manual_tester_account.py
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from e2e_helpers import call, dev_token  # noqa: E402

EMAIL = os.environ.get('TESTER_EMAIL', 'efexzium@gmail.com').lower()
VEHICLES = ['TEST-TRUCK-1', 'TEST-TRUCK-2']


def reset_local_users():
    """Local test DB only: keep ONLY the tester so reminder jobs email them."""
    from pymongo import MongoClient
    db = MongoClient(os.environ['MONGO_URI'])[os.environ['DB_NAME']]
    db.users.drop()
    db.invites.drop()
    print(f'local users cleared - {EMAIL} will be the only member')


def _chat(token, message, history=None):
    body = {'message': message, 'history': history or []}
    return call('POST', '/chat', body, token=token)['reply']


def _frequency(record, name):
    return record['schedule'][name]


def main():
    reset_local_users()
    token, user = dev_token(EMAIL)
    workspace = user['workspace_id']
    print(f'signed in {EMAIL} (workspace {workspace})')

    records = {}
    for name in VEHICLES:
        record = call('POST', '/service-records', token=token)
        records[name] = call('PUT', f"/service-records/{record['id']}",
                             {**record, 'vehicle_number': name}, token=token)
    print(f'created vehicles: {", ".join(VEHICLES)}')

    print('STEP 1: weekly + monthly + daily reminder emails to your inbox')
    for frequency in ('weekly', 'monthly', 'daily'):
        summary = call('POST', f'/inspections-messages/run-{frequency}',
                       body={}, key=os.environ['APP_API_KEY'])
        result = summary['results'][workspace]
        info = result.get('subject') or result.get('note') or result['email'].get('note', '')
        print(f'  {frequency}: {info}')
        assert result.get('due', 1) >= 1 or result['email']['ok'] is True, result
        if frequency in ('weekly', 'monthly'):
            assert all(v in result['subject'] for v in VEHICLES), result['subject']

    print('STEP 2: chat marks YOUR daily inspection (text, no photo)')
    reply = _chat(token, f'Mark the daily inspection done for vehicle {VEHICLES[0]}.')
    print(f'  reply: {reply[:110]}')
    saved = call('GET', f"/service-records/{records[VEHICLES[0]]['id']}", token=token)
    assert _frequency(saved, 'daily')['last_done_by'] == EMAIL, saved['schedule']['daily']
    assert _frequency(saved, 'daily')['last_done_via'] == 'chat', saved['schedule']['daily']

    print('STEP 3: mark-all weekly needs your confirmation first')
    reply = _chat(token, 'Mark all weekly maintenance done.')
    print(f'  reply: {reply[:110]}')
    for name in VEHICLES:
        current = call('GET', f"/service-records/{records[name]['id']}", token=token)
        assert _frequency(current, 'weekly')['last_done_at'] == '', 'must not mark before yes'
    reply = _chat(token, 'Yes, mark all weekly maintenance done.',
                  history=[{'role': 'user', 'content': 'Mark all weekly maintenance done.'},
                           {'role': 'assistant', 'content': reply}])
    print(f'  reply: {reply[:110]}')
    for name in VEHICLES:
        current = call('GET', f"/service-records/{records[name]['id']}", token=token)
        weekly = _frequency(current, 'weekly')
        assert weekly['last_done_at'] and weekly['last_done_by'] == EMAIL, weekly

    print('STEP 4: weekly job now skips your workspace (due-only, no spam)')
    summary = call('POST', '/inspections-messages/run-weekly', body={},
                   key=os.environ['APP_API_KEY'])
    assert 'skipped' in summary['results'][workspace]['note'], summary['results'][workspace]
    print(f"  note: {summary['results'][workspace]['note']}")

    print('STEP 5: your private chat history was saved per topic')
    topics = call('GET', '/chat/history', token=token)['topics']
    assert len(topics) >= 2, topics
    for topic in topics:
        print(f"  [{topic['updated_at'][:16]}] {topic['title']}")

    print(f'PASS - all flows verified against {EMAIL}. Check your inbox for '
          'the daily, weekly and monthly reminder emails; then sign in at the '
          'review link to see your saved chat threads.')


main()
