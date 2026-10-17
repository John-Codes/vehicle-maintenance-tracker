"""Scheduled job entrypoints for maintenance reminder messages."""
import logging

from ..messaging.models import Message
from ..messaging.service import send_failure_alert
from .service import run_daily_inspection_for_all_workspaces
from .service_due import run_monthly_for_all_workspaces, run_weekly_for_all_workspaces

log = logging.getLogger('uvicorn.error')


async def _guarded(job_name: str, subject: str, run) -> dict:
    try:
        summary = await run()
        log.info('%s finished: %s', job_name, summary)
        return summary
    except Exception as error:  # noqa: BLE001 - alert, then re-raise for the log
        log.exception('%s failed', job_name)
        await send_failure_alert(job_name, error, Message(subject=subject, text=''))
        raise


async def run_daily_inspection_job() -> dict:
    """03:00 job: remind every workspace to do its daily inspection."""
    return await _guarded('daily-inspection-job', 'daily inspection job run',
                          run_daily_inspection_for_all_workspaces)


async def run_weekly_maintenance_job() -> dict:
    """Monday 03:00 job: nudge workspaces with weekly service DUE this week."""
    return await _guarded('weekly-maintenance-job', 'weekly maintenance job run',
                          run_weekly_for_all_workspaces)


async def run_monthly_maintenance_job() -> dict:
    """1st of month 03:00 job: nudge workspaces with monthly service DUE."""
    return await _guarded('monthly-maintenance-job', 'monthly maintenance job run',
                          run_monthly_for_all_workspaces)
