"""Back-compat shim: the daily builder moved to builders_daily.py; weekly and
monthly live in their own modules. Old import paths keep working."""
from .builders_daily import build_daily_inspection_message  # noqa: F401
