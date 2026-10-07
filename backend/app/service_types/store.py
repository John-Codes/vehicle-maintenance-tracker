import hashlib
import json
from pathlib import Path
from bson import ObjectId
from fastapi import HTTPException
from pymongo.errors import DuplicateKeyError
from ..storage import store, _oid, _to_item

collection = store._collection.database['service_types']

async def initialize():
    await collection.create_index('name_key', unique=True, partialFilterExpression={'deleted': False})
    for item in json.loads(Path(__file__).with_name('defaults.json').read_text()):
        key = ObjectId(hashlib.sha256(item['name'].encode()).hexdigest()[:24])
        await collection.update_one({'_id': key}, {'$setOnInsert': {
            **item, 'name_key': item['name'].casefold(), 'deleted': False}}, upsert=True)

async def get(item_id):
    doc = await collection.find_one({'_id': _oid(item_id), 'deleted': False})
    if doc is None:
        raise HTTPException(404, 'Service type not found')
    return public(doc)

def public(doc):
    item = _to_item(doc)
    return {k: item[k] for k in ('id', 'name', 'schedule')}

async def save(model, item_id=None):
    fields = {**model.model_dump(), 'name_key': model.name.casefold(), 'deleted': False}
    try:
        if item_id:
            doc = await collection.find_one_and_update(
                {'_id': _oid(item_id), 'deleted': False}, {'$set': fields}, return_document=True)
            if doc is None:
                raise HTTPException(404, 'Service type not found')
            return public(doc)
        result = await collection.insert_one(fields)
        return await get(str(result.inserted_id))
    except DuplicateKeyError:
        raise HTTPException(409, 'A service type with this name already exists')
