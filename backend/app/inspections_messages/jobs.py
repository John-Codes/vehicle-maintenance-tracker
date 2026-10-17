"""Scheduled job entrypoints for daily inspection messages."""
import logging

from ..messaging.service import send_failure_alert
from .service import run_daily_inspection_for_all_workspaces

log = logging.getLogger('uvicorn.error')


async def run_daily_inspection_job() -> dict:
    """03:00 job: remind every workspace to do its daily inspection.
    If anything blows up, email the owner the full details."""
    try:
        summary = await run_daily_inspection_for_all_workspaces()
        log.info('daily inspection job finished: %s', summary)
        return summary
    except Exception as error:  # noqa: BLE001 - alert, then re-raise for the log
        log.exception('daily inspection job failed')
        from ..messaging.models import Message
        await send_failure_alert('daily-inspection-job', error,
                                 Message(subject='daily inspection job run', text=''))
        raise
