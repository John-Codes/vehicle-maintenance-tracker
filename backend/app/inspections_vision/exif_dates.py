"""EXIF photo-date extraction. Pillow only - no external calls."""
from datetime import datetime
from io import BytesIO

from PIL import Image

# DateTimeOriginal lives in the EXIF IFD; DateTime is the base-IFD fallback.
_EXIF_IFD = 0x8769
_DATE_TIME_ORIGINAL = 36867
_DATE_TIME = 306


def photo_date(image_bytes: bytes) -> str | None:
    """The date the photo was TAKEN ('YYYY-MM-DD') or None when no EXIF date."""
    try:
        image = Image.open(BytesIO(image_bytes))
        raw = image.getexif().get(_DATE_TIME)
        exif_ifd = image.getexif().get_ifd(_EXIF_IFD)
        if exif_ifd.get(_DATE_TIME_ORIGINAL):
            raw = exif_ifd[_DATE_TIME_ORIGINAL]
    except Exception:
        return None
    if not raw:
        return None
    try:
        return datetime.strptime(str(raw).strip()[:10], '%Y:%m:%d').strftime('%Y-%m-%d')
    except ValueError:
        return None
