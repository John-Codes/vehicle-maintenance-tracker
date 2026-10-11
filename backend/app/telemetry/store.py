from datetime import datetime, timezone

from ..storage import _to_item, store

collection = store._collection.database['telemetry']

FIELDS = ('id', 'workspace_id', 'vehicle_number', 'odometer_mi',
          'engine_hours', 'source', 'notes', 'captured_at')


def public(doc):
    if doc is None:
        return None
    item = _to_item(doc)
    item.setdefault('engine_hours', None)
    item.setdefault('source', 'manual')
    item.setdefault('notes', '')
    return {key: item.get(key) for key in FIELDS}


def _now():
    return datetime.now(timezone.utc).isoformat()


async def add(workspace_id, body):
    """Store one reading. Later readings win for 'latest' by time."""
    doc = {'workspace_id': workspace_id,
           'vehicle_number': body.vehicle_number.strip(),
           'odometer_mi': body.odometer_mi,
           'engine_hours': body.engine_hours,
           'source': body.source, 'notes': body.notes,
           'captured_at': _now()}
    result = await collection.insert_one(doc)
    return public(await collection.find_one({'_id': result.inserted_id}))


def _query(workspace_id, vehicle_number):
    query = {'workspace_id': workspace_id}
    if vehicle_number:
        query['vehicle_number'] = vehicle_number
    return query


async def list_readings(workspace_id, vehicle_number=None):
    cursor = collection.find(_query(workspace_id, vehicle_number)).sort('captured_at', -1).limit(200)
    return [public(doc) async for doc in cursor]


async def latest(workspace_id, vehicle_number):
    doc = await collection.find_one(
        {'workspace_id': workspace_id, 'vehicle_number': vehicle_number},
        sort=[('captured_at', -1)])
    return public(doc)
