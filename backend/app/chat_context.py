import json

FREQUENCIES = ('daily', 'weekly', 'monthly')
MAX_RECORDS = 50
MAX_CHARS = 50000

SYSTEM_PROMPT = (
    "You are the Vehicle Maintenance Tracker assistant. Answer the user's "
    'questions about their vehicle service records using ONLY the records '
    'provided below. Be concise and factual. If the records do not contain the '
    'answer, say so plainly. Dates are ISO strings. Checklist progress is '
    'done/total per frequency, counting not_applicable items as done.\n\n'
    'You have tools to work with the data directly: search_records, list_records, '
    'get_record, create_record, update_record, delete_record, list_service_types, '
    'get_service_type, create_service_type, update_service_type, delete_service_type. '
    'Call a tool when the brief is missing details, when the user asks to search, '
    'create, update, or delete records or service types, or to confirm a change '
    'actually happened. Ask the user for any required details they have not supplied '
    'before creating or updating.'
)


def records_brief(records: list) -> str:
    summary = {
        'total_records': len(records),
        'showing_newest': min(MAX_RECORDS, len(records)),
        'records': [record_line(record) for record in records[:MAX_RECORDS]],
    }
    return json.dumps(summary, default=str)[:MAX_CHARS]


def record_line(record: dict) -> dict:
    schedule = record.get('schedule') or {}
    progress = {}
    for frequency in FREQUENCIES:
        components = (schedule.get(frequency) or {}).get('components') or []
        steps = [step for component in components for step in (component.get('steps') or [])]
        done = sum(1 for step in steps if step.get('done') or step.get('not_applicable'))
        progress[frequency] = f'{done}/{len(steps)}'
    technician = record.get('technician') or {}
    return {
        'vehicle_number': record.get('vehicle_number', ''),
        'vin': record.get('vin', ''),
        'license_plate': record.get('license_plate', ''),
        'service_type': record.get('service_type', ''),
        'date_started': (record.get('date_started') or '')[:10],
        'miles': record.get('miles'),
        'hours': record.get('hours'),
        'technician': technician.get('name', ''),
        'worker_names': record.get('worker_names') or [],
        'checklist_progress': progress,
        'notes': (record.get('notes') or '')[:500],
        'next_steps': (record.get('next_steps') or '')[:500],
    }