"""Channel registry: builds the configured channel list once."""
from ..config import AGENTMAIL_API_KEY, AGENTMAIL_INBOX_ID, MESSAGE_CHANNELS
from .channels.base import Channel
from .channels.email_agentmail import AgentMailChannel
from .channels.email_dummy import DummyEmailChannel

_cache: list[Channel] | None = None


def _build() -> list[Channel]:
    built: list[Channel] = []
    if 'email' in MESSAGE_CHANNELS:
        if AGENTMAIL_API_KEY and AGENTMAIL_INBOX_ID:
            built.append(AgentMailChannel())
        else:
            built.append(DummyEmailChannel())
    return built


def channels() -> list[Channel]:
    """Configured channel instances (cached; registry is static per process)."""
    global _cache
    if _cache is None:
        _cache = _build()
    return _cache
