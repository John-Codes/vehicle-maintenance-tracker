"""Chat tools that mark inspections done. Every mark stamps WHO did it
(last_done_by) and HOW (last_done_via) so the responsible person is on record."""
from ..schemas import ServiceRecord


def _tool(name, description, params):
    return {'type': 'function', 'function': {'name': name, 'description': description, 'parameters': params}}


def _p(description):
    return {'type': 'string', 'description': description}


INSPECTION_TOOLS = [
    _tool('mark_inspection_done',
          'Mark one vehicle\'s inspection done for a frequency (daily/weekly/monthly). '
          'Sets last_done_at to today and records the signed-in user as responsible.',
          {'type': 'object',
           'properties': {'record_id': _p('Service record id to mark done'),
                          'frequency': _p('daily, weekly, or monthly')},
           'required': ['record_id']}),
    _tool('mark_all_inspections_done',
          'Mark EVERY vehicle\'s inspection done for a frequency in the workspace. '
          'DANGEROUS: only call after the user explicitly confirmed "yes" to your '
          'final are-you-sure question. Records the signed-in user as responsible.',
          {'type': 'object',
           'properties': {'frequency': _p('daily, weekly, or monthly')},
           'required': []}),
]
