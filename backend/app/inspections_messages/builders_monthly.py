"""The monthly maintenance reminder: vehicle-specific, sent only when due."""
from ..messaging.models import Message, MessageRecipient


def _vehicle_line(names: list[str]) -> str:
    return ', '.join(names[:-1]) + f' and {names[-1]}' if len(names) > 1 else names[0]


def build_monthly_message(recipients: list[MessageRecipient],
                          due_names: list[str], total_due: int) -> Message:
    listed = _vehicle_line(due_names)
    if total_due > len(due_names):
        listed += f' (and {total_due - len(due_names)} more)'
    subject = f'Monthly maintenance due this month: {listed}'
    count_line = f'{total_due} vehicle' + ('s' if total_due != 1 else '') + ' due. '
    text = (f'{subject}. {count_line}Change or inspect the filters, '
            'check the belts and fluid levels, and go over the safety items '
            'on this month\'s list. Open the app to tick it off, or send this '
            'month\'s photos to the assistant in chat and it will mark the '
            'service done for you.')
    html = (f'<b>{subject}</b><br><br>{count_line}<br>Due now: <b>{listed}</b>.'
            '<br><br>Change or inspect the <b>filters</b>, check the '
            '<b>belts</b> and <b>fluid levels</b>, and go over the safety '
            'items on this month\'s list. Open the app to tick it off, or '
            'send this month\'s <b>photos</b> to the assistant in '
            '<b>chat</b> and it will mark the service done for you.')
    return Message(subject=subject, text=text, html=html,
                   recipients=recipients, context={'type': 'monthly_maintenance'})
