"""Prompt for AI-generated vehicle/equipment maintenance checklists.

RAG seam: build_generation_prompt takes `manual_context` (retrieved manual
chunks). Today it is always empty — generation uses the model's general
knowledge only. When manuals land, per-category retrieval plugs in here
without changing the endpoint contract.
"""

DISCLAIMER = ('General maintenance guidelines only, generated from general '
              'knowledge for reference purposes only. Always follow the '
              "manufacturer's manual and your shop's procedures.")

SCHEDULE_RULES = """
The schedule JSON must follow these rules exactly:
- Exactly three frequency groups: "daily", "weekly", "monthly".
- Each group: {"last_done_at": "", "components": [...]}.
- A component: {"id": "kebab-case-id", "title": "Human title", "steps": [...]}.
- The SAME component ids (with the same titles) appear in ALL THREE
  frequencies; the steps inside a component differ per frequency.
- A step: {"id": "unique-kebab-case-id", "title": "Item title",
  "done": false, "not_applicable": false, "value": "", "notes": "",
  "description": "What to check, in plain language"}.
- Every step id is unique across the whole schedule.
- Daily = walk-around/pre-operation checks; Weekly = inspections and levels;
  Monthly = scheduled service items. 4-8 components, 2-5 steps each.
"""


def build_generation_prompt(brand, model_name, year, manual_context=None):
    vehicle = f'{year} {brand} {model_name}'.strip()
    context = ''
    if manual_context:
        joined = '\n---\n'.join(manual_context[:10])
        context = (f'\nReference material from the vehicle manuals follows. '
                   f'Base the checklist on it where relevant:\n{joined}\n')
    return (
        'You create maintenance checklists for a fleet tracking app. '
        f'Build a general maintenance checklist for a {vehicle}. '
        f'{DISCLAIMER} '
        f'{SCHEDULE_RULES} '
        f'Name the vehicle/equipment type "{vehicle}" and pass it with the '
        'schedule to the create_service_type tool in ONE tool call. '
        'If the tool returns an error, fix the schedule JSON and call it '
        f'again.{context}'
    )
