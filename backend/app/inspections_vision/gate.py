"""Strict photo gate for chat maintenance marks. The server checks the EXIF
date BEFORE any model call: outside the frequency's due window (daily=today,
weekly=this ISO week, monthly=this calendar month) = rejected, no exceptions.
Photos are used for the check and then discarded - never stored."""
import base64

from ..due_periods import is_date_in_window, window_label
from .exif_dates import photo_date

MAX_PHOTOS = 3
MAX_PHOTO_BYTES = 8_000_000

VISION_PROMPT_RULES = (
    '\n\nPHOTO INSPECTION RULES (this turn has photo attachments):\n'
    '- The server already verified each photo was TAKEN WITHIN the due window '
    'of the frequency the user stated (daily = today, weekly = this week, '
    'monthly = this month). You can trust that.\n'
    '- Look at the photos: they must genuinely show vehicle/equipment '
    'maintenance evidence (tires, lights, fluids, brakes, filters, belts, '
    'gauges, or the vehicle itself at the work site). Staged, blank, or '
    'unrelated photos must be REFUSED.\n'
    '- If the photos are genuine AND the user asks to mark the maintenance '
    'done, call mark_inspection_done for the correct record with the stated '
    'frequency (default daily).\n'
    '- If refused, say plainly why and remind them they can also tick the '
    'checklist in the app.\n'
)


def _decode(image_b64: str) -> bytes:
    return base64.b64decode(image_b64, validate=True)


def date_gate(images_b64: list[str], frequency: str = 'daily') -> dict:
    """Strict gate: every photo must carry an EXIF date inside the frequency's
    current due window. Returns {'ok', 'message', 'dates'} - no LLM involved."""
    if not images_b64:
        return {'ok': False, 'message': 'No photos attached.', 'dates': []}
    if len(images_b64) > MAX_PHOTOS:
        return {'ok': False, 'message': f'Attach at most {MAX_PHOTOS} photos per message.', 'dates': []}
    dates, problems = [], []
    for index, encoded in enumerate(images_b64, start=1):
        try:
            raw = _decode(encoded)
        except Exception:
            return {'ok': False, 'message': f'Photo {index} is not valid image data.', 'dates': []}
        if len(raw) > MAX_PHOTO_BYTES:
            return {'ok': False, 'message': f'Photo {index} is too large (max 8 MB).', 'dates': []}
        taken = photo_date(raw)
        dates.append(taken)
        if taken is None:
            problems.append(f'photo {index} has no date metadata')
        elif not is_date_in_window(frequency, taken):
            problems.append(f'photo {index} was taken {taken}, not within {window_label(frequency)}')
    if problems:
        return {'ok': False,
                'message': ('Rejected - strict due-window rule for {freq}: '.format(freq=frequency)
                            + '; '.join(problems)
                            + '. Retake the photo with the camera so it is dated '
                              f'within {window_label(frequency)}, or tick the '
                              'checklist in the app instead.'),
                'dates': dates}
    return {'ok': True,
            'message': (f'All photos verified as taken within {window_label(frequency)} '
                        f'({frequency} frequency).'),
            'dates': dates}


def image_parts(images_b64: list[str]) -> list[dict]:
    """OpenRouter multimodal content parts. The bytes are discarded after the call."""
    return [{'type': 'image_url',
             'image_url': {'url': f'data:image/jpeg;base64,{encoded}'}}
            for encoded in images_b64]
