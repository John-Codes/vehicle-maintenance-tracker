import json
import os
import urllib.request

BASE = os.environ['API_URL'].rstrip('/')
EXPECTED = {'Semi', 'Trailer', 'Vermeer Reclaimer', 'Vermeer Drills', 'Mud Pump', 'Other'}


def main():
    with urllib.request.urlopen(BASE + '/service-types', timeout=20) as response:
        types = json.loads(response.read())
    assert {item['name'] for item in types} >= EXPECTED
    for item in types:
        schedule = item['schedule']
        component_ids = None
        steps = []
        for frequency in ('daily', 'weekly', 'monthly'):
            components = schedule[frequency]['components']
            ids = [component['id'] for component in components]
            component_ids = component_ids or ids
            assert ids == component_ids
            steps.extend(step for component in components for step in component['steps'])
        assert steps, item['name']
        assert len({step['id'] for step in steps}) == len(steps)
    print('template catalog e2e ok')


if __name__ == '__main__':
    main()
