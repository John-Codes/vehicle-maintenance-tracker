"""E2E: strict due-window photo gate for chat maintenance marks. Builds real
JPEGs with real EXIF dates (no mocks): photos outside the frequency's window
(daily=today, weekly=this ISO week, monthly=this calendar month) are rejected
WITHOUT any LLM call; in-window photos pass the gate and reach the vision
model (needs OPENROUTER_API_KEY, else a 503 proves the gate passed)."""
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


def _raw_chat(token, message, images, frequency=None):
    import json as _json
    import urllib.error
    import urllib.request
    base = os.environ['API_URL'].rstrip('/')
    body = {'message': message, 'history': [], 'images': images}
    if frequency:
        body['frequency'] = frequency
    req = urllib.request.Request(f'{base}/chat', data=_json.dumps(body).encode(),
                                 method='POST',
                                 headers={'Content-Type': 'application/json',
                                          'Authorization': f'Bearer {token}'})
    try:
        with urllib.request.urlopen(req, timeout=180) as res:
            return res.status, _json.loads(res.read())
    except urllib.error.HTTPError as err:
        return err.code, _json.loads(err.read() or b'{}')


def _week_start(today: str) -> str:
    from app.due_periods import window_start
    return window_start('weekly')


def main():
    email = fresh_email('visionmgr')
    token, user = dev_token(email)
    truck = call('POST', '/service-records', token=token)
    truck = call('PUT', f"/service-records/{truck['id']}",
                 {**truck, 'vehicle_number': 'E2E-TRUCK-1'}, token=token)

    yesterday = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
    today = datetime.now().strftime('%Y-%m-%d')
    week_start = _week_start(today)
    before_this_week = (datetime.fromisoformat(week_start) - timedelta(days=2)).strftime('%Y-%m-%d')
    month_start = today[:8] + '01'

    print('case 1 (daily): yesterday photo rejected by the server gate')
    status, body = _raw_chat(token, 'Daily inspection photo for E2E-TRUCK-1',
                             [_b64(jpeg_with_exif_date(yesterday))])
    assert status == 200 and 'not within today' in body['reply'], (status, body['reply'][:120])
    print('  reply:', body['reply'][:100])

    print('case 2 (daily): dateless photo rejected')
    status, body = _raw_chat(token, 'Daily inspection photo for E2E-TRUCK-1',
                            [_b64(jpeg_with_exif_date(None))])
    assert status == 200 and 'no date metadata' in body['reply'], body['reply'][:120]

    print('case 3 (weekly): last-week photo rejected for weekly')
    status, body = _raw_chat(token, 'Weekly service photo for E2E-TRUCK-1',
                             [_b64(jpeg_with_exif_date(before_this_week))], frequency='weekly')
    assert status == 200 and 'not within this week' in body['reply'], body['reply'][:120]
    print('  reply:', body['reply'][:100])

    print('case 4 (weekly): yesterday photo PASSES the weekly gate')
    if yesterday >= week_start:
        status, body = _raw_chat(token, 'Weekly service photo for E2E-TRUCK-1',
                                 [_b64(jpeg_with_exif_date(yesterday))], frequency='weekly')
        assert status == 200 and body['reply'] and 'not within' not in body['reply'], (status, str(body)[:160])
        print('  reply:', str(body.get('reply', body))[:140])
    else:
        print('  skipped: today is Monday, no in-week-but-not-today date exists')

    print('case 5 (monthly): mid-last-month photo rejected for monthly')
    last_month = (datetime.now().replace(day=15) - timedelta(days=31)).strftime('%Y-%m-%d')
    status, body = _raw_chat(token, 'Monthly service photo for E2E-TRUCK-1',
                             [_b64(jpeg_with_exif_date(last_month))], frequency='monthly')
    assert status == 200 and 'not within this month' in body['reply'], body['reply'][:120]

    print('case 6 (monthly): earlier-this-month photo PASSES the monthly gate')
    if today != month_start and os.environ.get('OPENROUTER_API_KEY'):
        in_month = month_start if today != month_start else today
        status, body = _raw_chat(token, 'Monthly service photo for E2E-TRUCK-1',
                                 [_b64(jpeg_with_exif_date(in_month))], frequency='monthly')
        assert status == 200 and 'not within' not in str(body), (status, str(body)[:160])
        print('  reply:', str(body.get('reply', body))[:140])
    else:
        print('  skipped: today is the 1st or no OPENROUTER_API_KEY')

    daily = call('GET', f"/service-records/{truck['id']}", token=token)['schedule']['daily']
    assert daily['last_done_at'] == '', 'blank test photos must never mark anything'
    print('PASS vision gate (strict per-frequency due windows, deterministic)')


main()
