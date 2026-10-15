"""E2E: strict same-day photo gate for chat inspections. Builds real JPEGs
with real EXIF dates (no mocks): yesterday's photo and a dateless photo must
be rejected WITHOUT any LLM call; a photo dated today passes the gate and
reaches the vision model (needs OPENROUTER_API_KEY)."""
import base64
import io
import os
import sys
from datetime import datetime, timedelta

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image  # noqa: E402

from e2e_helpers import call, dev_token, fresh_email  # noqa: E402


def jpeg_with_exif_date(date_taken: str | None) -> bytes:
    """A real JPEG; embeds the EXIF date when given, omits it when None."""
    image = Image.new('RGB', (64, 64), color=(40, 40, 45))
    data = io.BytesIO()
    if date_taken:
        exif = Image.Exif()
        exif.get_ifd(0x8769)[36867] = f'{date_taken.replace("-", ":")} 12:00:00'
        image.save(data, 'jpeg', exif=exif)
    else:
        image.save(data, 'jpeg')
    return data.getvalue()


def _b64(raw: bytes) -> str:
    return base64.b64encode(raw).decode()


def main():
    email = fresh_email('visionmgr')
    token, user = dev_token(email)
    truck = call('POST', '/service-records', token=token)
    truck = call('PUT', f"/service-records/{truck['id']}",
                 {**truck, 'vehicle_number': 'E2E-TRUCK-1'}, token=token)

    yesterday = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
    today = datetime.now().strftime('%Y-%m-%d')

    print('case 1: yesterday photo rejected by the server gate (no LLM call)')
    reply = call('POST', '/chat', {'message': 'Daily inspection photo for E2E-TRUCK-1',
                                  'history': [], 'images': [_b64(jpeg_with_exif_date(yesterday))]},
                token=token)['reply']
    print('  reply:', reply[:120])
    daily = call('GET', f"/service-records/{truck['id']}", token=token)['schedule']['daily']
    assert daily['last_done_at'] == '', daily
    assert 'Rejected' in reply or 'not today' in reply, reply

    print('case 2: dateless photo rejected')
    reply = call('POST', '/chat', {'message': 'Daily inspection photo for E2E-TRUCK-1',
                                  'history': [], 'images': [_b64(jpeg_with_exif_date(None))]},
                token=token)['reply']
    print('  reply:', reply[:120])
    assert 'no date metadata' in reply, reply
    assert call('GET', f"/service-records/{truck['id']}", token=token)['schedule']['daily']['last_done_at'] == ''

    if not os.environ.get('OPENROUTER_API_KEY'):
        print('case 3 skipped: no OPENROUTER_API_KEY (gate already proven above)')
        print('PASS vision gate (strict same-day, deterministic)')
        return

    print('case 3: today-dated photo passes the gate and reaches the vision model')
    status, payload = _raw_chat(token, 'Daily inspection photo for E2E-TRUCK-1',
                                [_b64(jpeg_with_exif_date(today))])
    assert status == 200 and payload['reply'], (status, payload)
    print('  reply:', payload['reply'][:160])
    print('PASS vision gate (strict same-day, deterministic)')


def _raw_chat(token, message, images):
    import json as _json
    import urllib.request
    base = os.environ['API_URL'].rstrip('/')
    body = _json.dumps({'message': message, 'history': [], 'images': images}).encode()
    req = urllib.request.Request(f'{base}/chat', data=body, method='POST',
                                 headers={'Content-Type': 'application/json',
                                          'Authorization': f'Bearer {token}'})
    try:
        with urllib.request.urlopen(req, timeout=180) as res:
            return res.status, _json.loads(res.read())
    except urllib.error.HTTPError as err:
        return err.code, err.read().decode()


main()
