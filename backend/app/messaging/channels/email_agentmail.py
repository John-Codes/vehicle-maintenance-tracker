"""Email channel via AgentMail (https://agentmail.to). Used in prod; needs
AGENTMAIL_API_KEY + EMAIL_FROM or it refuses to send (caller alerts)."""
import httpx

from ...config import AGENTMAIL_API_KEY, AGENTMAIL_BASE_URL, EMAIL_FROM
from ..models import Message
from .base import Channel


class AgentMailChannel(Channel):
    name = 'email'

    async def send(self, message: Message) -> dict:
        if not AGENTMAIL_API_KEY or not EMAIL_FROM:
            raise RuntimeError(f'email channel not configured: AGENTMAIL_API_KEY={bool(AGENTMAIL_API_KEY)} '
                               f'EMAIL_FROM={EMAIL_FROM!r} (message subject: {message.subject!r})')
        payload = {'from': EMAIL_FROM,
                   'to': [r.email for r in message.recipients],
                   'subject': message.subject,
                   'body': message.text}
        headers = {'Authorization': f'Bearer {AGENTMAIL_API_KEY}'}
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(f'{AGENTMAIL_BASE_URL}/messages/outgoing',
                                         json=payload, headers=headers)
        if response.status_code not in (200, 201, 202):
            raise RuntimeError(f'AgentMail rejected send ({response.status_code}): {response.text[:300]}')
        return {'ok': True, 'delivered_to': len(message.recipients)}
