import json
import os
import urllib.error
import urllib.request

BASE = os.environ['API_URL'].rstrip('/')
KEY = os.environ['APP_API_KEY']

def call(method, path, body=None):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method, headers={'X-App-Key': KEY, 'Content-Type': 'application/json'})
    try:
        with urllib.request.urlopen(req) as res:
            raw = res.read()
            return res.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as err:
        detail = err.read().decode()
        raise SystemExit(f'{method} {path} -> {err.code} {detail}')

def put_fields(record):
    return {k: v for k, v in record.items() if k not in ('id', 'record_type', 'created_at', 'updated_at')}

def main():
    _, record = call('POST', '/service-records')
    record['vehicle_number'] = 'E2E-SEARCH-UNIT'
    record['technician'] = {'name': 'Alice Searcher', 'phone': '', 'email': ''}
    record['worker_names'] = ['Bob Worker']
    record['notes'] = 'search e2e notes'
    _, saved = call('PUT', f"/service-records/{record['id']}", put_fields(record))

    def find(items):
        return [item for item in items if item['id'] == saved['id']]

    _, hits = call('GET', '/service-records?search=e2e-search-unit')
    assert find(hits), 'vehicle number not found'
    _, hits = call('GET', '/service-records?search=alice')
    assert find(hits), 'technician name not found (case-insensitive)'
    _, hits = call('GET', '/service-records?search=bob%20worker')
    assert find(hits), 'worker name not found'
    _, hits = call('GET', '/service-records?search=notes')
    assert find(hits), 'notes not found'
    _, hits = call('GET', '/service-records?search=zzz-no-such-record-zzz')
    assert not find(hits), 'gibberish query matched a record'
    _, hits = call('GET', '/service-records?search=e2e(search')
    assert not find(hits), 'regex special chars must be escaped, not error'
    _, hits = call('GET', '/service-records')
    assert find(hits), 'empty search must list all records'

    call('DELETE', f"/service-records/{saved['id']}")
    _, hits = call('GET', '/service-records?search=e2e-search-unit')
    assert not find(hits), 'deleted record still found in search'
    print('e2e search ok')

if __name__ == '__main__':
    main()
