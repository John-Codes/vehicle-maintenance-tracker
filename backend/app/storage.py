import httpx
from fastapi import HTTPException
from .config import STORE_URL

class Store:
    def __init__(self):
        self._client = httpx.AsyncClient(timeout=30)

    async def _request(self, method, path, **kwargs):
        try:
            response = await self._client.request(method, f'{STORE_URL}{path}', **kwargs)
            if response.status_code >= 400: raise HTTPException(response.status_code, response.text)
            return response.json() if response.content else None
        except httpx.HTTPError as exc:
            raise HTTPException(503, 'Mongo storage is unavailable') from exc

    async def close(self):
        await self._client.aclose()

    async def list(self, record_type):
        return await self._request('GET', '/items', params={'record_type': record_type, 'sort': '-created_at', 'limit': 5000})
    async def get(self, item_id): return await self._request('GET', f'/items/{item_id}')
    async def create(self, item): return await self._request('POST', '/items', json=item)
    async def update(self, item_id, item): return await self._request('PUT', f'/items/{item_id}', json=item)
    async def delete(self, item_id): return await self._request('DELETE', f'/items/{item_id}')

store = Store()
