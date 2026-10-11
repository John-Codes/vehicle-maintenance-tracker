from fastapi import APIRouter, Depends, HTTPException, Query

from ..auth.session import Principal
from ..auth.guards import require_workspace_user
from . import store
from .models import TelemetryIn

router = APIRouter(prefix='/telemetry', tags=['Telemetry'])


@router.post('', status_code=201)
async def add_reading(body: TelemetryIn, principal: Principal = Depends(require_workspace_user)):
    """Log one mileage/engine-hours reading for a vehicle."""
    return await store.add(principal.workspace_id, body)


@router.get('')
async def list_readings(
    vehicle: str = Query(default='', max_length=120),
    principal: Principal = Depends(require_workspace_user),
):
    """Newest-first readings, optionally filtered to one vehicle."""
    return await store.list_readings(principal.workspace_id, vehicle.strip())


@router.get('/latest')
async def latest_reading(
    vehicle: str = Query(max_length=120),
    principal: Principal = Depends(require_workspace_user),
):
    """The most recent reading for a vehicle, or 404 when none exists."""
    reading = await store.latest(principal.workspace_id, vehicle.strip())
    if reading is None:
        raise HTTPException(404, 'No readings yet for this vehicle')
    return reading
