"""Background scheduler for recurring jobs (runs at SCHEDULE_TZ time)."""
import logging

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger

from .config import (DAILY_INSPECTION_HOUR, DAILY_INSPECTION_MINUTE,
                     MONTHLY_REMINDER_DAY, MONTHLY_REMINDER_HOUR,
                     SCHEDULE_TZ, WEEKLY_REMINDER_DAY, WEEKLY_REMINDER_HOUR)
from .inspections_messages.jobs import (run_daily_inspection_job,
                                        run_monthly_maintenance_job,
                                        run_weekly_maintenance_job)

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
    _scheduler.add_job(run_weekly_maintenance_job, CronTrigger(
        day_of_week=WEEKLY_REMINDER_DAY, hour=WEEKLY_REMINDER_HOUR),
        id='weekly-maintenance-job', name='Weekly maintenance reminder emails',
        misfire_grace_time=3600)
    _scheduler.add_job(run_monthly_maintenance_job, CronTrigger(
        day=MONTHLY_REMINDER_DAY, hour=MONTHLY_REMINDER_HOUR),
        id='monthly-maintenance-job', name='Monthly maintenance reminder emails',
        misfire_grace_time=3600)
    _scheduler.start()
    log.info('scheduler started (tz=%s, daily %02d:%02d, weekly %s %02d:00, '
             'monthly day %d %02d:00)', SCHEDULE_TZ, DAILY_INSPECTION_HOUR,
             DAILY_INSPECTION_MINUTE, WEEKLY_REMINDER_DAY, WEEKLY_REMINDER_HOUR,
             MONTHLY_REMINDER_DAY, MONTHLY_REMINDER_HOUR)
    return _scheduler


def stop_scheduler() -> None:
    """Shut the scheduler down cleanly."""
    global _scheduler
    if _scheduler is not None:
        _scheduler.shutdown(wait=False)
        _scheduler = None
        log.info('scheduler stopped')
