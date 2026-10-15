"""E2E: chat history is saved server-side per signed-in user, stays private
between workspaces/users, loads oldest-first, and can be cleared. No mocks."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from e2e_helpers import call, dev_token, fresh_email  # noqa: E402


def _history(token):
    return call('GET', '/chat/history', token=token)['messages']


def main():
    email = fresh_email('histmgr')
    token, user = dev_token(email)
    call('POST', '/service-records', token=token)

    assert _history(token) == [], 'fresh user has no history'

    call('POST', '/chat', {'message': 'How many service records do I have?',
                           'history': []}, token=token)
    saved = _history(token)
    assert len(saved) == 2, saved
    assert saved[0]['role'] == 'user' and 'service records' in saved[0]['content']
    assert saved[1]['role'] == 'assistant' and saved[1]['content'], saved[1]

    other_token, _ = dev_token(fresh_email('histother'))
    assert _history(other_token) == [], 'history must be private per user'

    cleared = call('DELETE', '/chat/history', token=token)
    assert cleared['ok'] is True and cleared['deleted'] >= 2, cleared
    assert _history(token) == []

    print('PASS chat history saved, private, and clearable')


main()
