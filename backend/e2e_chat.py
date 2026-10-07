import json
import os
import urllib.error
import urllib.request

BASE = os.environ['API_URL'].rstrip('/')
KEY = os.environ['APP_API_KEY']

def call(path, body=None, method='POST', with_key=True):
    headers = {'Content-Type': 'application/json'}
    if with_key:
        headers['X-App-Key'] = KEY
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req) as res:
            raw = res.read()
            return res.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as err:
        return err.code, err.read().decode()

def ask(message, history=None):
    body = {'message': message}
    if history is not None:
        body['history'] = history
    return call('/chat', body)

def live_round_trip():
    history = [{'role': 'user', 'content': 'Remember the number seven.'},
               {'role': 'assistant', 'content': 'Noted: seven.'}]
    for attempt in range(3):
        try:
            status, body = ask('What number did I mention?', history)
            assert status == 200, f'{status} {body}'
            reply = body['reply']
            assert reply and any(word in reply.lower() for word in ('7', 'seven')), reply[:200]
            return
        except AssertionError:
            if attempt == 2:
                raise

def tool_round_trip():
    status, created = call('/service-records')
    assert status == 200, status
    created['vehicle_number'] = 'E2E-CHAT'
    created['notes'] = 'alpha quokka beta'
    try:
        put = {k: v for k, v in created.items() if k not in ('id', 'record_type', 'created_at', 'updated_at')}
        status, _ = call(f"/service-records/{created['id']}", put, method='PUT')
        assert status == 200, status
        for attempt in range(3):
            status, body = ask("Use the search_records tool with text 'quokka' and report the vehicle_number you find.")
            assert status == 200, f'{status} {body}'
            if 'E2E-CHAT' in body['reply']:
                return
            if attempt == 2:
                raise AssertionError(f'tool result missing from reply: {body["reply"][:200]}')
    finally:
        call(f"/service-records/{created['id']}", method='DELETE')

def main():
    status, _ = call('/chat', {'message': 'hello'}, with_key=False)
    assert status == 401, status
    status, _ = call('/chat', {'message': '   '})
    assert status == 422, status
    if not os.environ.get('OPENROUTER_API_KEY'):
        status, _ = call('/chat', {'message': 'hello'})
        assert status == 503, status
        print('e2e chat ok (LLM skipped: OPENROUTER_API_KEY not set)')
        return
    live_round_trip()
    tool_round_trip()
    print('e2e chat ok (live LLM round-trip + tool round-trip)')

if __name__ == '__main__':
    main()