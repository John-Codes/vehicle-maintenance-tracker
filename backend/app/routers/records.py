from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException
from ..auth import require_key
from ..defaults import empty_schedule, step_ids
from ..schemas import ServiceRecord, Technician
from ..storage import store

router = APIRouter(prefix='/service-records', dependencies=[Depends(require_key)])

@router.get('')
async def list_records():
    return await store.list('service_record')

@router.post('')
async def create_record():
    profiles = await store.list('technician_profile')
    record = ServiceRecord(
        date_started=now(),
        technician=_technician(profiles[0]) if profiles else Technician(),
        schedule=empty_schedule(),
    )
    return await store.create({'record_type': 'service_record', **record.model_dump(), 'created_at': now(), 'updated_at': now()})

@router.get('/{item_id}')
async def get_record(item_id: str):
    item = await store.get(item_id)
    if item.get('record_type') != 'service_record':
        raise HTTPException(404, 'Record not found')
    return item

@router.put('/{item_id}')
async def update_record(item_id: str, record: ServiceRecord):
    ids = step_ids(record.schedule)
    if len(set(ids)) != len(ids):
        raise HTTPException(422, 'Step IDs must be unique')
    return await store.update(item_id, {'record_type': 'service_record', **record.model_dump(), 'updated_at': now()})

@router.delete('/{item_id}', status_code=204)
async def delete_record(item_id: str):
    await store.delete(item_id)

def now():
    return datetime.now(timezone.utc).isoformat()

def _technician(doc):
    return Technician(name=doc.get('name') or '', phone=doc.get('phone') or '', email=doc.get('email') or '')
