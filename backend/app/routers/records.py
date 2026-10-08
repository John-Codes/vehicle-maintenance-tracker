from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException
from ..auth.session import Principal, require_user
from ..defaults import empty_schedule, step_ids
from ..schemas import ServiceRecord, Technician
from ..storage import store

router = APIRouter(prefix='/service-records', dependencies=[Depends(require_user)])


def effective_workspace(doc):
    return doc.get('workspace_id') or 'default'


def _forbid_other_workspaces(doc, principal):
    if effective_workspace(doc) != principal.workspace_id:
        raise HTTPException(404, 'Record not found')


@router.get('')
async def list_records(search: str = '', principal: Principal = Depends(require_user)):
    workspace = principal.workspace_id
    if search.strip():
        return await store.search('service_record', search.strip(), workspace)
    return await store.list('service_record', workspace)


@router.post('')
async def create_record(principal: Principal = Depends(require_user)):
    profiles = await store.list('technician_profile')
    record = ServiceRecord(
        date_started=now(),
        technician=_technician(profiles[0]) if profiles else Technician(),
        schedule=empty_schedule(),
    )
    item = {'record_type': 'service_record', 'workspace_id': principal.workspace_id,
            **record.model_dump(), 'created_at': now(), 'updated_at': now()}
    return await store.create(item)


@router.get('/{item_id}')
async def get_record(item_id: str, principal: Principal = Depends(require_user)):
    item = await store.get(item_id)
    if item.get('record_type') != 'service_record':
        raise HTTPException(404, 'Record not found')
    _forbid_other_workspaces(item, principal)
    return item


@router.put('/{item_id}')
async def update_record(item_id: str, record: ServiceRecord, principal: Principal = Depends(require_user)):
    ids = step_ids(record.schedule)
    if len(set(ids)) != len(ids):
        raise HTTPException(422, 'Step IDs must be unique')
    existing = await store.get(item_id)
    if existing.get('record_type') != 'service_record':
        raise HTTPException(404, 'Record not found')
    _forbid_other_workspaces(existing, principal)
    return await store.update(item_id, {'record_type': 'service_record',
                                        'workspace_id': principal.workspace_id,
                                        **record.model_dump(), 'updated_at': now()})


@router.delete('/{item_id}', status_code=204)
async def delete_record(item_id: str, principal: Principal = Depends(require_user)):
    existing = await store.get(item_id)
    if existing.get('record_type') != 'service_record':
        raise HTTPException(404, 'Record not found')
    _forbid_other_workspaces(existing, principal)
    await store.delete(item_id)


def now():
    return datetime.now(timezone.utc).isoformat()


def _technician(doc):
    return Technician(name=doc.get('name') or '', phone=doc.get('phone') or '', email=doc.get('email') or '')
