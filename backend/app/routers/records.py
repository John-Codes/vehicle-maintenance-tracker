from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException
from ..auth import require_key
from ..defaults import clean_steps, default_steps
from ..schemas import ServiceRecord, Technician
from ..storage import store

router = APIRouter(prefix='/service-records', dependencies=[Depends(require_key)])

@router.get('')
async def list_records(): return await store.list('service_record')

@router.post('')
async def create_record():
    records, profiles = await store.list('service_record'), await store.list('technician_profile')
    previous = records[0] if records else None
    steps = clean_steps(previous.get('steps', [])) if previous else default_steps()
    record = ServiceRecord(technician=Technician(**profiles[0]) if profiles else Technician(), steps=steps)
    return await store.create({'record_type': 'service_record', **record.model_dump(), 'created_at': now(), 'updated_at': now()})

@router.get('/{item_id}')
async def get_record(item_id: str):
    item = await store.get(item_id)
    if item.get('record_type') != 'service_record': raise HTTPException(404, 'Record not found')
    return item

@router.put('/{item_id}')
async def update_record(item_id: str, record: ServiceRecord):
    if len({step.id for step in record.steps}) != len(record.steps): raise HTTPException(422, 'Step IDs must be unique')
    return await store.update(item_id, {'record_type': 'service_record', **record.model_dump(), 'updated_at': now()})

@router.delete('/{item_id}', status_code=204)
async def delete_record(item_id: str): await store.delete(item_id)

def now(): return datetime.now(timezone.utc).isoformat()
