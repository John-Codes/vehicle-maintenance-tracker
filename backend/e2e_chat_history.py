"""E2E: chat history is organized by TOPIC (conversation thread), saved
server-side per signed-in user, private between users, and deletable per
thread or all at once. No mocks."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from e2e_helpers import call, dev_token, fresh_email  # noqa: E402


def _chat(token, message, topic_id=''):
    return call('POST', '/chat', {'message': message, 'history': [], 'topic_id': topic_id},
                token=token)


def _topics(token):
    return call('GET', '/chat/history', token=token)['topics']


def _messages(token, topic_id):
    return call('GET', f'/chat/history/{topic_id}', token=token)['messages']


def main():
    email = fresh_email('topicmgr')
    token, user = dev_token(email)
    call('POST', '/service-records', token=token)

    assert _topics(token) == [], 'fresh user has no topics'

    print('case 1: first message auto-creates a titled topic')
    turn = _chat(token, 'How many service records do I have?')
    assert turn['topic_id'], turn
    assert 'service records' in turn['topic'].lower(), turn
    topic_a = turn['topic_id']
    topics = _topics(token)
    assert len(topics) == 1 and topics[0]['topic_id'] == topic_a, topics

    print('case 2: same topic_id continues the thread')
    turn = _chat(token, 'And how many technicians?', topic_id=topic_a)
    assert turn['topic_id'] == topic_a, turn
    assert len(_messages(token, topic_a)) == 4, 'two exchanges = four messages'

    print('case 3: empty topic_id starts a separate topic')
    turn = _chat(token, 'Summarize my maintenance schedule.')
    topic_b = turn['topic_id']
    assert topic_b != topic_a and 'maintenance schedule' in turn['topic'].lower(), turn
    assert [t['topic_id'] for t in _topics(token)] == [topic_b, topic_a], 'newest first'

    print('case 4: history stays private per user')
    other_token, _ = dev_token(fresh_email('topicother'))
    assert _topics(other_token) == [], 'topics must be private per user'
    from e2e_helpers import expect_error
    expect_error('GET', f'/chat/history/{topic_a}', 404, token=other_token)

    print('case 5: delete one topic, then clear the rest')
    call('DELETE', f'/chat/history/{topic_b}', token=token)
    assert [t['topic_id'] for t in _topics(token)] == [topic_a], 'topic b must be gone'
    expect_error('GET', f'/chat/history/{topic_b}', 404, token=token)
    cleared = call('DELETE', '/chat/history', token=token)
    assert cleared['ok'] is True and cleared['deleted'] == 1, cleared
    assert _topics(token) == []

    print('PASS topic-based chat history (private, per-thread delete, clear all)')


main()
