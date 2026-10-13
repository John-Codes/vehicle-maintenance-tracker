"""No-op email channel used when email is not configured (local dev/test).
Reports a skip honestly so e2e can assert without external services."""
from ..models import Message
from .base import Channel


class DummyEmailChannel(Channel):
    name = 'email'

    async def send(self, message: Message) -> dict:
        return {'ok': True, 'dummy': True, 'delivered_to': len(message.recipients),
                'note': 'email not configured; message recorded but not sent'}
