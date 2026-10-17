"""E2E AI type generation: real HTTP -> real backend -> real OpenRouter LLM.

The model drafts a general maintenance checklist for a specific vehicle and
saves it via the create_service_type tool call. Nothing is mocked; the only
external dependency is the OpenRouter key. The generated type is deleted at
the end so reruns stay clean.
"""
import json
import os
import time
import urllib.error
import urllib.request

BASE = os.environ['API_URL'].rstrip('/')
KEY = os.environ['APP_API_KEY']
VEHICLE = '2012 Toyota Prius'


def call(method, path, body=None, key=KEY, timeout=330):
    headers = {'Content-Type': 'application/json', 'X-App-Key': key}
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as res:
            raw = res.read()
            return res.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as err:
        detail = err.read().decode()
        raise SystemExit(f'{method} {path} -> {err.code} {detail[:300]}')


def status_only(method, path, body=None, key=KEY):
    try:
        call(method, path, body, key)
        return 200
    except SystemExit as err:
        return int(str(err).split('-> ')[1].split(' ')[0])


def main():
    # Guards and validation before spending tokens
    assert status_only('POST', '/service-types/ai-generate',
                       {'brand': 'Toyota', 'model': 'Prius', 'year': 2012},
                       key='wrong-key') == 401
    assert status_only('POST', '/service-types/ai-generate',
                       {'brand': '', 'model': 'Prius', 'year': 2012}) == 422
    assert status_only('POST', '/service-types/ai-generate',
                       {'brand': 'Toyota', 'model': 'Prius', 'year': 1700}) == 422
    print('ai-generate guards ok')

    # Real generation: the LLM must produce a schema-valid saved type
    print(f'asking the AI for a {VEHICLE} checklist (this can take a few minutes)...')
    started = time.time()
    payload = None
    for attempt in range(2):
        try:
            status, payload = call('POST', '/service-types/ai-generate',
                                   {'brand': 'Toyota', 'model': 'Prius', 'year': 2012},
                                   timeout=600)
            assert status == 200, status
            break
        except SystemExit as err:
            if '502' not in str(err) or attempt == 1:
                raise
            print('free model returned empty; pausing before the retry...')
            time.sleep(60)
    created = payload['type']
    assert 'reference purposes only' in payload['disclaimer'], payload
    print(f'generated in {time.time() - started:.0f}s -> "{created["name"]}"')

    name = created['name'].casefold()
    assert all(word in name for word in ('2012', 'toyota', 'prius')), created['name']

    schedule = created['schedule']
    groups = [schedule[frequency]['components'] for frequency in ('daily', 'weekly', 'monthly')]
    ids = [{c['id'] for c in group} for group in groups]
    assert ids[0] and ids[0] == ids[1] == ids[2], 'components missing from frequencies'
    steps = [s['id'] for group in groups for c in group for s in c['steps']]
    assert len(steps) >= 12 and len(set(steps)) == len(steps), 'too few or duplicate steps'
    text = json.dumps(created).casefold()
    assert any(word in text for word in ('oil', 'tire', 'brake', 'engine', 'fluid')), 'not maintenance content'
    print('ai-generated type is schema-valid and sensible')

    call('DELETE', f"/service-types/{created['id']}")
    print('e2e_ai_types ok')


if __name__ == '__main__':
    main()
