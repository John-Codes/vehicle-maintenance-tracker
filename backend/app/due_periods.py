"""Due windows per maintenance frequency - the backend twin of the UI's
due_status.dart rules. Single source of truth for reminders AND the strict
photo gate: daily = today, weekly = this ISO week, monthly = this calendar
month (all in SCHEDULE_TZ, the workspace 'maintenance day' timezone)."""
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

from .config import SCHEDULE_TZ

FREQUENCIES = ('daily', 'weekly', 'monthly')


def _now() -> datetime:
    return datetime.now(ZoneInfo(SCHEDULE_TZ))


def today_date() -> str:
    return _now().strftime('%Y-%m-%d')


def window_start(frequency: str) -> str:
    """The inclusive date the current due window opened."""
    now = _now()
    if frequency == 'daily':
        return now.strftime('%Y-%m-%d')
    if frequency == 'weekly':
        # ISO weeks start Monday.
        return (now - timedelta(days=now.weekday())).strftime('%Y-%m-%d')
    if frequency == 'monthly':
        return now.strftime('%Y-%m-01')
    raise ValueError(f'frequency must be one of {FREQUENCIES}, got {frequency!r}')


def window_label(frequency: str) -> str:
    return {'daily': 'today', 'weekly': 'this week (Mon-Sun)',
            'monthly': 'this month'}[frequency]


def is_date_in_window(frequency: str, iso_date: str) -> bool:
    """True when the date falls inside the frequency's current window."""
    return (iso_date or '')[:10] >= window_start(frequency)


def is_record_due(record: dict, frequency: str) -> bool:
    """A record is due when its last_done_at predates the window start.
    Never done = always due (mirrors the UI's isFrequencyDue)."""
    last_done = ((record.get('schedule') or {}).get(frequency) or {}).get('last_done_at') or ''
    return not is_date_in_window(frequency, last_done[:10])


def due_vehicle_numbers(records: list, frequency: str, cap: int = 10) -> tuple[list, int]:
    """Vehicle names of records due for the frequency, capped for emails.
    Returns (names, total_due)."""
    due = [record for record in records if is_record_due(record, frequency)]
    names = [record.get('vehicle_number') or 'unnamed vehicle' for record in due]
    return names[:cap], len(due)
