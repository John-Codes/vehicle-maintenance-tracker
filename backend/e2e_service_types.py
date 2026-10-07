"""Real HTTP checks; run only against the isolated local/CI database."""
import copy
import json
import os
import urllib.error
import urllib.request
import uuid

BASE = os.environ['API_URL'].rstrip('/')

def call(method, path, body=None, expected=200):
    request = urllib.request.Request(BASE + path, method=method,
        data=None if body is None else json.dumps(body).encode(),
        headers={'Content-Type': 'application/json'})
    try:
        response = urllib.request.urlopen(request, timeout=20)
    except urllib.error.HTTPError as error:
        response = error
    with response:
        data = response.read()
        assert response.status == expected, (method, path, response.status, data)
        return json.loads(data) if data else None

def main():
    import e2e_schedule
    name = 'E2E type ' + uuid.uuid4().hex
    seed = call('GET', '/service-types')
    assert seed, 'Built-in templates were not initialized'
    schedule = {f: {'last_done_at': '', 'components': [{'id': 'engine', 'title': 'Engine',
        'steps': [{'id': f + '-oil', 'title': 'Oil', 'description': 'Check level',
        'value': 'Dipstick', 'notes': 'Cold engine', 'done': False, 'not_applicable': False}]}]}
        for f in ('daily', 'weekly', 'monthly')}
    body = {'name': name, 'schedule': schedule}
    created = call('POST', '/service-types', body, 201)
    path = '/service-types/' + created['id']
    record_id = None
    try:
        assert call('GET', path)['schedule'] == schedule
        assert any(t['id'] == created['id'] for t in call('GET', '/service-types'))
        call('POST', '/service-types', {**body, 'name': ' ' + name.upper() + ' '}, 409)
        call('POST', '/service-types', {**body, 'name': '   '}, 422)
        invalid = copy.deepcopy(body)
        invalid['schedule']['weekly']['components'][0]['steps'][0]['id'] = 'daily-oil'
        call('PUT', path, invalid, 422)
        invalid = copy.deepcopy(body)
        invalid['schedule']['monthly']['components'] = []
        call('PUT', path, invalid, 422)
        invalid = copy.deepcopy(body)
        del invalid['schedule']['daily']
        call('PUT', path, invalid, 422)
        _, record = e2e_schedule.call('POST', '/service-records')
        record_id = record['id']
        record.update(service_type=name, schedule=copy.deepcopy(schedule))
        e2e_schedule.call('PUT', '/service-records/' + record_id, record)
        body['name'] += ' renamed'
        body['schedule']['daily']['components'][0]['steps'][0]['notes'] = 'Updated child'
        saved = call('PUT', path, body)
        assert saved['schedule'] == body['schedule']
        assert call('GET', path)['name'] == body['name']
        call('DELETE', path, expected=204)
        call('GET', path, expected=404)
        call('PUT', path, body, 404)
        call('DELETE', path, expected=404)
        _, historical = e2e_schedule.call('GET', '/service-records/' + record_id)
        assert historical['service_type'] == name
        assert historical['schedule']['daily']['components'][0]['steps'][0]['notes'] == 'Cold engine'
        assert all(t['id'] != created['id'] for t in call('GET', '/service-types'))
        print('service types e2e ok: full child persistence, CRUD, validation, historical records, no auth')
    finally:
        if any(t['id'] == created['id'] for t in call('GET', '/service-types')):
            call('DELETE', path, expected=204)
        if record_id:
            e2e_schedule.call('DELETE', '/service-records/' + record_id)

if __name__ == '__main__':
    main()
