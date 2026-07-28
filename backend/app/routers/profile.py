from datetime import datetime, timezone
from fastapi import APIRouter, Depends
from ..auth import require_key
from ..schemas import Technician
from ..storage import store

router = APIRouter(dependencies=[Depends(require_key)])

@router.get('/profile')
async def get_profile():
    profiles = await store.list('technician_profile')
    return profiles[0] if profiles else Technician().model_dump()

@router.put('/profile')
async def put_profile(profile: Technician):
    item = {'record_type': 'technician_profile', **profile.model_dump(), 'updated_at': datetime.now(timezone.utc).isoformat()}
    profiles = await store.list('technician_profile')
    return await store.update(profiles[0]['id'], item) if profiles else await store.create(item)
