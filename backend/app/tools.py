import json
from datetime import datetime, timezone
from fastapi import HTTPException

from .defaults import empty_schedule
from .schemas import ServiceRecord
from .service_types import store as type_store
from .service_types.schema import ServiceType
from .storage import _oid, store

def _p(description):
    return {'type': 'string', 'description': description}

def _params(props, required=None):
    params = {'type': 'object', 'properties': props}
    if required: params['required'] = required
    return params

def _tool(name, description, params):
    return {'type': 'function', 'function': {'name': name, 'description': description, 'parameters': params}}
_ID = lambda description='Record id': _p(description)
_NUM = lambda description: {'type': 'number', 'description': description}
_SCHED = {'type': 'object', 'description': 'Full daily/weekly/monthly schedule of components with steps'}

TOOLS = [
    _tool('list_records', 'List all service records.', _params({})),
    _tool('search_records', 'Search records by text in vehicle number, VIN, plate, service type, notes, next steps, technicians.', _params({'text': _p('Free text')}, ['text'])),
    _tool('get_record', 'Get one service record by id.', _params({'id': _ID()}, ['id'])),
    _tool('create_record', 'Create a new empty service record.', _params({})),
    _tool('update_record', 'Update fields of an existing service record; unspecified fields keep current values.', _params({'id': _ID(), 'vehicle_number': _p('Vehicle number'), 'miles': _NUM('Mileage'), 'hours': _NUM('Engine hours'), 'date_started': _p('ISO date'), 'service_type': _p('Service type name'), 'worker_names': {'type': 'array', 'items': {'type': 'string'}}, 'technician': {'type': 'object', 'description': 'name, phone, email'}, 'notes': _p('Notes'), 'next_steps': _p('Next steps'), 'vin': _p('VIN'), 'license_plate': _p('License plate')}, ['id'])),
    _tool('delete_record', 'Delete a service record by id.', _params({'id': _ID()}, ['id'])),
    _tool('list_service_types', 'List all service types.', _params({})),
    _tool('get_service_type', 'Get a service type by id.', _params({'id': _ID('Service type id')}, ['id'])),
    _tool('create_service_type', 'Create a service type with a schedule.', _params({'name': _p('Type name'), 'schedule': _SCHED}, ['name', 'schedule'])),
    _tool('update_service_type', 'Update a service type name or schedule by id.', _params({'id': _ID('Service type id'), 'name': _p('Type name'), 'schedule': _SCHED}, ['id'])),
    _tool('delete_service_type', 'Delete a service type by id.', _params({'id': _ID('Service type id')}, ['id'])),
]

def _now():
    return datetime.now(timezone.utc).isoformat()

def _dump(data):
    return json.dumps(data, default=str)

def _draft_record():
    return {'record_type': 'service_record', 'vehicle_number': '', 'miles': None, 'hours': None, 'date_started': _now(), 'service_type': '', 'worker_names': [], 'technician': {'name': '', 'phone': '', 'email': ''}, 'schedule': empty_schedule().model_dump(), 'notes': '', 'next_steps': '', 'vin': '', 'license_plate': '', 'created_at': _now(), 'updated_at': _now()}

async def _update_record(args):
    item_id = str(args['id'])
    doc = await store.get(item_id)
    merged = {**doc, **{k: v for k, v in args.items() if k in ServiceRecord.model_fields and v is not None}}
    for key in ('id', '_id', 'record_type', 'created_at', 'updated_at'):
        merged.pop(key, None)
    record = ServiceRecord(**merged)
    return await store.update(item_id, {'record_type': 'service_record', **record.model_dump(), 'updated_at': _now()})

async def _update_type(args):
    item_id = str(args['id'])
    current = await type_store.get(item_id)
    name = args.get('name') or current['name']
    schedule = args.get('schedule') or current['schedule']
    return await type_store.save(ServiceType(name=name, schedule=schedule), item_id)

async def run_tool(name, args):
    try:
        if name == 'list_records':
            return _dump(await store.list('service_record'))
        if name == 'search_records':
            return _dump(await store.search('service_record', str(args.get('text', ''))))
        if name == 'get_record':
            return _dump(await store.get(str(args['id'])))
        if name == 'create_record':
            return _dump(await store.create(_draft_record()))
        if name == 'update_record':
            return _dump(await _update_record(args))
        if name == 'delete_record':
            await store.delete(str(args['id']))
            return '{}'
        if name == 'list_service_types':
            return _dump([type_store.public(doc) async for doc in type_store.collection.find({'deleted': False})])
        if name == 'get_service_type':
            return _dump(await type_store.get(str(args['id'])))
        if name == 'create_service_type':
            return _dump(await type_store.save(ServiceType(**args)))
        if name == 'update_service_type':
            return _dump(await _update_type(args))
        if name == 'delete_service_type':
            await type_store.collection.update_one({'_id': _oid(str(args['id'])), 'deleted': False}, {'$set': {'deleted': True}})
            return '{}'
        return _dump({'error': 'unknown tool: ' + name})
    except HTTPException as error:
        return _dump({'error': error.detail})
    except Exception as error:
        return _dump({'error': str(error).splitlines()[0][:200]})