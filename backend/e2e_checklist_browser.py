"""Browser e2e for checklist done-history, due badges and autosave; needs Playwright + local stack."""
import json
import os
import uuid
import urllib.error
import urllib.request
from playwright.sync_api import sync_playwright, expect, TimeoutError as PlaywrightTimeout

VEH = 'BRW-' + uuid.uuid4().hex[:8]
NOTES = 'Autosave notes ' + uuid.uuid4().hex[:8]
REVIEW = os.environ.get('REVIEW_URL', 'http://127.0.0.1:8391')
API = os.environ.get('API_URL', 'http://127.0.0.1:8021').rstrip('/')
KEY = os.environ.get('APP_API_KEY', 'local-review-key')

def fill(page, name, value):
    field = page.get_by_role('textbox', name=name, exact=True)
    field.click()
    page.wait_for_timeout(200)
    field.press('Control+a')
    field.press_sequentially(value, delay=10)

def open_editor(page):
    page.locator('flt-semantics-placeholder').evaluate('(element) => element.click()')
    page.get_by_role('button', name=VEH, exact=False).click()

def dcheck():
    request = urllib.request.Request(API + '/service-records', headers={'X-App-Key': KEY})
    records = json.loads(urllib.request.urlopen(request, timeout=15).read())
    record = next(r for r in records if r.get('vehicle_number') == VEH)
    for component in record['schedule']['daily']['components']:
        for step in component['steps']:
            if step['id'] == 'd-check':
                return step
    raise AssertionError('d-check step missing')

def wait_step(page, done_at, history_len, message):
    for _ in range(25):
        page.wait_for_timeout(300)
        try:
            step = dcheck()
            stamped = step['done_at'] == '' if done_at == '' else bool(step['done_at'])
            if stamped and len(step['done_history']) == history_len:
                return step
        except (AssertionError, StopIteration, KeyError, urllib.error.URLError):
            pass
    raise AssertionError(message)

def run(page):
    page.goto(REVIEW)
    page.locator('flt-semantics-placeholder').evaluate('(element) => element.click()')
    page.get_by_role('button', name='New record').click()
    fill(page, 'Vehicle number', VEH)
    fill(page, 'Notes', NOTES)
    page.wait_for_timeout(1500)  # debounce: silent PUT must fire without Save
    page.reload()
    open_editor(page)
    notes = page.get_by_role('textbox', name='Notes', exact=True)
    notes.click()  # Flutter web syncs the DOM value only after focus
    expect(notes).to_have_value(NOTES)
    print('PASS autosave: typed notes persisted after reload without manual save', flush=True)
    page.get_by_role('button', name='Choose service type').click()
    page.get_by_role('button', name='Semi', exact=True).click()
    confirm = page.get_by_role('button', name='Use', exact=True)
    try:  # only shown when the record already has a checklist
        confirm.wait_for(timeout=1500)
        confirm.click()
    except PlaywrightTimeout:
        pass
    expect(page.get_by_role('button', name='Due', exact=False)).to_have_count(3)  # Daily/Weekly/Monthly all due
    page.get_by_role('button', name='Daily Last done', exact=False).click()
    expect(page.get_by_role('button', name='Mark Daily done', exact=True)).to_be_visible()
    boxes = page.get_by_role('checkbox')
    expect(boxes).to_have_count(7)  # 3 frequency rows + 4 collapsed components
    boxes.nth(1).click()  # Brakes component checkbox: GPS capture + immediate flush
    expect(page.get_by_role('group', name='1/1', exact=False)).to_have_count(1)
    event = wait_step(page, 'set', 1, 'GPS history not persisted after component toggle')['done_history'][0]
    assert abs(event['lat'] - 10.5) < 0.01 and abs(event['lng'] + 66.9) < 0.01, event
    page.get_by_role('group', name='Brakes', exact=False).click()
    page.get_by_role('group', name='Brake check', exact=False).click()
    expect(page.get_by_role('group', name='Done @', exact=False)).to_have_count(1)
    print('PASS checklist history: Done @ stamp + GPS lat/lng stored in done_history', flush=True)
    page.reload()
    open_editor(page)
    expect(page.get_by_role('button', name='Due', exact=False)).to_have_count(3)  # frequency row untouched
    page.get_by_role('button', name='Daily Last done', exact=False).click()
    page.get_by_role('group', name='Brakes', exact=False).click()
    page.get_by_role('group', name='Brake check', exact=False).click()
    expect(page.get_by_role('group', name='Done @', exact=False)).to_have_count(1)  # survived reload
    boxes = page.get_by_role('checkbox')
    expect(boxes).to_have_count(8)  # + the step tile checkbox
    boxes.nth(2).click()  # step tile checkbox inside Brakes
    expect(page.get_by_role('group', name='Done @', exact=False)).to_have_count(0)
    wait_step(page, '', 1, 'uncheck must clear done_at but keep history')
    print('PASS reload keeps done state; uncheck clears done_at, history stays append-only', flush=True)

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path='/usr/bin/google-chrome', headless=True, args=['--no-sandbox'])
    context = browser.new_context(viewport={'width': int(os.environ.get('BROWSER_WIDTH', '1280')), 'height': 1200},
                                  geolocation={'latitude': 10.5, 'longitude': -66.9}, permissions=['geolocation'])
    page = context.new_page()
    page.on('pageerror', lambda error: print('BROWSER ERROR:', error, flush=True))
    try:
        run(page)
    finally:
        print(page.locator('body').aria_snapshot(), flush=True)
        page.screenshot(path='/tmp/tracker-checklist-browser.png')
        browser.close()
