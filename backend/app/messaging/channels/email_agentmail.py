"""Email channel via AgentMail (https://agentmail.to). Used in prod; needs
AGENTMAIL_API_KEY + AGENTMAIL_INBOX_ID or it refuses to send (caller alerts)."""
import httpx

from ...config import AGENTMAIL_API_KEY, AGENTMAIL_BASE_URL, AGENTMAIL_INBOX_ID
from ..models import Message
from .base import Channel


class AgentMailChannel(Channel):
    name = 'email'

    async def send(self, message: Message) -> dict:
        if not AGENTMAIL_API_KEY or not AGENTMAIL_INBOX_ID:
            raise RuntimeError(f'email channel not configured: AGENTMAIL_API_KEY={bool(AGENTMAIL_API_KEY)} '
                               f'AGENTMAIL_INBOX_ID={AGENTMAIL_INBOX_ID!r} (message subject: {message.subject!r})')
        payload = {'to': [str(r.email) for r in message.recipients],
                   'subject': message.subject,
                   'text': message.text}
        if message.html:
            payload['html'] = message.html
        headers = {'Authorization': f'Bearer {AGENTMAIL_API_KEY}'}
        url = f'{AGENTMAIL_BASE_URL}/inboxes/{AGENTMAIL_INBOX_ID}/messages/send'
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(url, json=payload, headers=headers)
        if response.status_code not in (200, 201, 202):
            raise RuntimeError(f'AgentMail rejected send ({response.status_code}): {response.text[:300]}')
        return {'ok': True, 'delivered_to': len(message.recipients)}
