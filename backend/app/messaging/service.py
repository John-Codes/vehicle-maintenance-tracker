import logging

from ..config import AGENTMAIL_INBOX_ID, ALERT_EMAIL_TO
from .models import Message, MessageRecipient
from .registry import channels

log = logging.getLogger('uvicorn.error')


async def send_message(message: Message) -> dict:
    """Send a message via every configured channel. Never raises; failures
    trigger an alert email to ALERT_EMAIL_TO so nothing dies silently."""
    results = {}
    for channel in channels():
        try:
            results[channel.name] = await channel.send(message)
        except Exception as error:  # noqa: BLE001 - alert on any failure
            log.exception('Channel %s failed', channel.name)
            results[channel.name] = {'ok': False, 'error': str(error)}
            await send_failure_alert(channel.name, error, message)
    return results


async def send_failure_alert(channel_name: str, error: Exception, message: Message) -> dict:
    """Email the owner with full details when anything takes a shit."""
    detail = (f'channel={channel_name}\nerror={type(error).__name__}: {error}\n'
              f'subject={message.subject}\nrecipients={len(message.recipients)}')
    alert = Message(subject=f'[Tracker Alert] {channel_name} message failed',
                    text=f'A message failed to send.\n\n{detail}\n',
                    recipients=[MessageRecipient(email=ALERT_EMAIL_TO, name='Owner')],
                    context={'type': 'alert'})
    if not AGENTMAIL_INBOX_ID:
        log.error('ALERT NOT SENT (no AGENTMAIL_INBOX_ID): %s | %s', alert.subject, detail)
        return {'ok': False, 'error': 'no AGENTMAIL_INBOX_ID configured; alert logged only'}
    try:
        from .channels.email_agentmail import AgentMailChannel
        return await AgentMailChannel().send(alert)
    except Exception as alert_error:  # noqa: BLE001
        log.exception('Failure alert itself failed')
        return {'ok': False, 'error': str(alert_error)}
