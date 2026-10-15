"""Strict same-day gate for photo inspections. The server checks the EXIF
date BEFORE any model call: not today (or no date) = rejected, no exceptions.
Photos are used for the check and then discarded - never stored."""
import base64

from ..config import SCHEDULE_TZ
from ..inspections_tools.service import today_date
from .exif_dates import photo_date

MAX_PHOTOS = 3
MAX_PHOTO_BYTES = 8_000_000

VISION_PROMPT_RULES = (
    '\n\nPHOTO INSPECTION RULES (this turn has photo attachments):\n'
    '- The server already verified each photo was TAKEN TODAY via its EXIF date. '
    'You can trust that.\n'
    '- Look at the photos: they must genuinely show vehicle/equipment inspection '
    'evidence (tires, lights, fluids, gauges, safety items, or the vehicle itself '
    'at the work site). Staged, blank, or unrelated photos must be REFUSED.\n'
    '- If the photos are genuine AND the user asks to mark the inspection done, '
    'call mark_inspection_done for the correct record (frequency defaults to daily).\n'
    '- If refused, say plainly why and remind them they can also tick the checklist '
    'in the app.\n'
)


def _decode(image_b64: str) -> bytes:
    return base64.b64decode(image_b64, validate=True)


def date_gate(images_b64: list[str]) -> dict:
    """Strict gate: every photo must carry an EXIF date equal to today.
    Returns {'ok': bool, 'message': str, 'dates': [...]} - no LLM involved."""
    if not images_b64:
        return {'ok': False, 'message': 'No photos attached.', 'dates': []}
    if len(images_b64) > MAX_PHOTOS:
        return {'ok': False, 'message': f'Attach at most {MAX_PHOTOS} photos per message.', 'dates': []}
    today = today_date()
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
        elif taken != today:
            problems.append(f'photo {index} was taken {taken}, not today')
    if problems:
        return {'ok': False,
                'message': ('Rejected - strict same-day rule: ' + '; '.join(problems)
                            + '. Retake the photo with the camera so it is dated today, '
                              'or tick the checklist in the app instead.'),
                'dates': dates}
    return {'ok': True, 'message': f'All photos verified as taken today ({today}, {SCHEDULE_TZ}).',
            'dates': dates}


def image_parts(images_b64: list[str]) -> list[dict]:
    """OpenRouter multimodal content parts. The bytes are discarded after the call."""
    return [{'type': 'image_url',
             'image_url': {'url': f'data:image/jpeg;base64,{encoded}'}}
            for encoded in images_b64]
