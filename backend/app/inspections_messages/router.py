"""Manual triggers for the maintenance reminder jobs (testing/ops). Guarded
by the app key so anyone signed-in can't spam workspaces."""
from fastapi import APIRouter, Depends, Header, HTTPException

from ..config import API_KEY
from .jobs import (run_daily_inspection_job, run_monthly_maintenance_job,
                   run_weekly_maintenance_job)

router = APIRouter(prefix='/inspections-messages')


async def require_app_key(x_app_key: str = Header(default='')):
    if x_app_key != API_KEY:
        raise HTTPException(401, 'Invalid app key')


@router.post('/run-daily', dependencies=[Depends(require_app_key)])
async def trigger_daily_inspection():
    """Run the 03:00 daily job now. Returns the per-workspace summary."""
    return await run_daily_inspection_job()


@router.post('/run-weekly', dependencies=[Depends(require_app_key)])
async def trigger_weekly_maintenance():
    """Run the Monday 03:00 weekly job now (due-only workspaces are skipped)."""
    return await run_weekly_maintenance_job()


@router.post('/run-monthly', dependencies=[Depends(require_app_key)])
async def trigger_monthly_maintenance():
    """Run the 1st-of-month 03:00 monthly job now (due-only, skipped when done)."""
    return await run_monthly_maintenance_job()
