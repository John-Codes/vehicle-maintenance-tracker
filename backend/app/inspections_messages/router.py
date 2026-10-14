"""Manual trigger for the daily inspection job (testing/ops). Guarded by
the app key so anyone signed-in can't spam workspaces."""
from fastapi import APIRouter, Depends, Header, HTTPException

from ..config import API_KEY
from .jobs import run_daily_inspection_job

router = APIRouter(prefix='/inspections-messages')


async def require_app_key(x_app_key: str = Header(default='')):
    if x_app_key != API_KEY:
        raise HTTPException(401, 'Invalid app key')


@router.post('/run-daily', dependencies=[Depends(require_app_key)])
async def trigger_daily_inspection():
    """Run the 03:00 job now. Returns the same per-workspace summary."""
    return await run_daily_inspection_job()
