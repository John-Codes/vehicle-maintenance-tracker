import json
import os
import sys
import time
import urllib.request

SERVICE_ID = sys.argv[1]
KEY = os.environ['RENDER_API_KEY']
BASE = 'https://api.render.com/v1'
FAILED = ('build_failed', 'update_failed', 'canceled')


def call(method, path):
    req = urllib.request.Request(
        BASE + path,
        data=b'{}' if method == 'POST' else None,
        method=method,
        headers={'Authorization': f'Bearer {KEY}', 'Content-Type': 'application/json'},
    )
    with urllib.request.urlopen(req) as res:
        raw = res.read()
        return json.loads(raw) if raw else None


deploy_id = call('POST', f'/services/{SERVICE_ID}/deploys')['id']
print(f'deploy {deploy_id} started', flush=True)
for attempt in range(120):
    status = call('GET', f'/services/{SERVICE_ID}/deploys/{deploy_id}')['status']
    print(f'{attempt * 15}s: {status}', flush=True)
    if status == 'live':
        print('deploy is live')
        sys.exit(0)
    if status in FAILED:
        print(f'deploy failed: {status}')
        sys.exit(1)
    time.sleep(15)
print('timed out waiting for deploy')
sys.exit(1)
