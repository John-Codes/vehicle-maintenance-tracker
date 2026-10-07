from fastapi import APIRouter, HTTPException
from ..storage import _oid
from .schema import ServiceType
from . import store

router = APIRouter(prefix='/service-types', tags=['Service types'])

@router.get('')
async def list_types():
    return [store.public(doc) async for doc in store.collection.find({'deleted': False}).sort('name_key', 1)]

@router.post('', status_code=201)
async def create_type(item: ServiceType):
    return await store.save(item)

@router.get('/{item_id}')
async def get_type(item_id: str):
    return await store.get(item_id)

@router.put('/{item_id}')
async def update_type(item_id: str, item: ServiceType):
    return await store.save(item, item_id)

@router.delete('/{item_id}', status_code=204)
async def delete_type(item_id: str):
    result = await store.collection.update_one(
        {'_id': _oid(item_id), 'deleted': False}, {'$set': {'deleted': True}})
    if not result.matched_count:
        raise HTTPException(404, 'Service type not found')
