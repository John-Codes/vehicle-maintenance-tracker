import asyncio

import httpx
from fastapi import HTTPException
from .config import STORE_URL

RETRYABLE_STATUS = {429, 502, 503}
BACKOFF_SECONDS = (5, 10, 20, 30)


class Store:
    def __init__(self):
        self._client = httpx.AsyncClient(timeout=30)

    async def _request(self, method, path, **kwargs):
        last_error = None
        for delay in (*BACKOFF_SECONDS, None):
            try:
                response = await self._client.request(method, f'{STORE_URL}{path}', **kwargs)
                if response.status_code >= 400:
                    if response.status_code in RETRYABLE_STATUS and delay is not None:
                        last_error = response
                        await asyncio.sleep(delay)
                        continue
                    raise HTTPException(response.status_code, response.text)
                return response.json() if response.content else None
            except httpx.HTTPError as exc:
                if delay is None:
                    break
                last_error = exc
                await asyncio.sleep(delay)
        if last_error is not None:
            if isinstance(last_error, httpx.HTTPError):
                raise HTTPException(503, 'Mongo storage is unavailable') from last_error
            raise HTTPException(last_error.status_code, last_error.text)
        raise HTTPException(503, 'Mongo storage is unavailable')

    async def close(self):
        await self._client.aclose()

    async def list(self, record_type):
        return await self._request('GET', '/items', params={'record_type': record_type, 'sort': '-created_at', 'limit': 5000})
    async def get(self, item_id): return await self._request('GET', f'/items/{item_id}')
    async def create(self, item): return await self._request('POST', '/items', json=item)
    async def update(self, item_id, item): return await self._request('PUT', f'/items/{item_id}', json=item)
    async def delete(self, item_id): return await self._request('DELETE', f'/items/{item_id}')

store = Store()
