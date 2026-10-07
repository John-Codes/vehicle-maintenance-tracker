import re

from bson import ObjectId
from fastapi import HTTPException
from motor.motor_asyncio import AsyncIOMotorClient
from .config import COLLECTION, DB_NAME, MONGO_URI


def _oid(item_id):
    try:
        return ObjectId(item_id)
    except Exception:
        raise HTTPException(400, 'Invalid ID format')


def _to_item(doc):
    if doc is None:
        return None
    doc['id'] = str(doc.pop('_id'))
    return doc


class Store:
    def __init__(self):
        self._client = AsyncIOMotorClient(
            MONGO_URI,
            serverSelectionTimeoutMS=5000,
            connectTimeoutMS=5000,
            socketTimeoutMS=10000,
        )
        self._collection = self._client[DB_NAME][COLLECTION]

    async def list(self, record_type):
        cursor = self._collection.find({'record_type': record_type}).sort('created_at', -1).limit(5000)
        return [_to_item(doc) for doc in await cursor.to_list(length=5000)]

    async def search(self, record_type, text):
        escaped = re.escape(text)
        query = {'record_type': record_type, '$or': [
            {'vehicle_number': {'$regex': escaped, '$options': 'i'}},
            {'service_type': {'$regex': escaped, '$options': 'i'}},
            {'vin': {'$regex': escaped, '$options': 'i'}},
            {'license_plate': {'$regex': escaped, '$options': 'i'}},
            {'notes': {'$regex': escaped, '$options': 'i'}},
            {'next_steps': {'$regex': escaped, '$options': 'i'}},
            {'technician.name': {'$regex': escaped, '$options': 'i'}},
            {'worker_names': {'$regex': escaped, '$options': 'i'}},
        ]}
        cursor = self._collection.find(query).sort('created_at', -1).limit(5000)
        return [_to_item(doc) for doc in await cursor.to_list(length=5000)]

    async def get(self, item_id):
        doc = await self._collection.find_one({'_id': _oid(item_id)})
        if doc is None:
            raise HTTPException(404, 'Item not found')
        return _to_item(doc)

    async def create(self, item):
        result = await self._collection.insert_one(item)
        return _to_item(await self._collection.find_one({'_id': result.inserted_id}))

    async def update(self, item_id, item):
        fields = {k: v for k, v in item.items() if k not in ('id', '_id')}
        if not fields:
            raise HTTPException(400, 'No fields to update')
        doc = await self._collection.find_one_and_update(
            {'_id': _oid(item_id)}, {'$set': fields}, return_document=True)
        if doc is None:
            raise HTTPException(404, 'Item not found')
        return _to_item(doc)

    async def delete(self, item_id):
        result = await self._collection.delete_one({'_id': _oid(item_id)})
        if result.deleted_count == 0:
            raise HTTPException(404, 'Item not found')

    async def close(self):
        self._client.close()


store = Store()
