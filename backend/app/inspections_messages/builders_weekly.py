"""The weekly maintenance reminder: vehicle-specific (weekly service is
per-vehicle work, unlike the daily inspection) and sent only when due."""
from ..due_periods import window_label
from ..messaging.models import Message, MessageRecipient


def _vehicle_line(names: list[str]) -> str:
    return ', '.join(names[:-1]) + f' and {names[-1]}' if len(names) > 1 else names[0]


def build_weekly_message(recipients: list[MessageRecipient],
                         due_names: list[str], total_due: int) -> Message:
    listed = _vehicle_line(due_names)
    if total_due > len(due_names):
        listed += f' (and {total_due - len(due_names)} more)'
    subject = f'Weekly maintenance due this week: {listed}'
    count_line = f'{total_due} vehicle' + ('s' if total_due != 1 else '') + ' due. '
    text = (f'{subject}. {count_line}Check the brakes and grease points, '
            'inspect the tires and battery, and go over safety items '
            'before the week\'s work. Open the app to tick it off, or send '
            f'{window_label("weekly")}\'s photos to the assistant in chat and '
            'it will mark the service done for you.')
    html = (f'<b>{subject}</b><br><br>{count_line}<br>Due now: <b>{listed}</b>.'
            '<br><br>Check the <b>brakes</b> and <b>grease points</b>, inspect '
            'the <b>tires</b> and <b>battery</b>, and go over safety items '
            'before the week\'s work. Open the app to tick it off, or send '
            'this week\'s <b>photos</b> to the assistant in <b>chat</b> and it '
            'will mark the service done for you.')
    return Message(subject=subject, text=text, html=html,
                   recipients=recipients, context={'type': 'weekly_maintenance'})


