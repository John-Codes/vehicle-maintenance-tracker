"""Background scheduler for recurring jobs (runs at SCHEDULE_TZ time)."""
import logging

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger

from .config import DAILY_INSPECTION_HOUR, DAILY_INSPECTION_MINUTE, SCHEDULE_TZ
from .inspections_messages.jobs import run_daily_inspection_job

log = logging.getLogger('uvicorn.error')
_scheduler: AsyncIOScheduler | None = None


def start_scheduler() -> AsyncIOScheduler:
    """Start the background scheduler with all recurring jobs."""
    global _scheduler
    if _scheduler is not None:
        return _scheduler
    _scheduler = AsyncIOScheduler(timezone=SCHEDULE_TZ)
    _scheduler.add_job(run_daily_inspection_job, CronTrigger(
        hour=DAILY_INSPECTION_HOUR, minute=DAILY_INSPECTION_MINUTE),
        id='daily-inspection-job', name='Daily inspection reminder emails',
        misfire_grace_time=3600)
    _scheduler.start()
    log.info('scheduler started (tz=%s, daily inspection at %02d:%02d)',
             SCHEDULE_TZ, DAILY_INSPECTION_HOUR, DAILY_INSPECTION_MINUTE)
    return _scheduler


def stop_scheduler() -> None:
    """Shut the scheduler down cleanly."""
    global _scheduler
    if _scheduler is not None:
        _scheduler.shutdown(wait=False)
        _scheduler = None
        log.info('scheduler stopped')
