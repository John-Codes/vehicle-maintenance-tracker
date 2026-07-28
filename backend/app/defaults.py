from .schemas import CheckStep

DEFAULT_TITLES = ['Brakes', 'AC fans', 'Air reservoir', 'Strobe light', 'Lights', 'DOT tires', 'DEF', 'Engine air filter', 'Parts needed']

def clean_steps(steps):
    seen = set()
    result = []
    for raw in steps:
        step = CheckStep.model_validate(raw)
        if step.id in seen: raise ValueError('Step IDs must be unique')
        seen.add(step.id)
        result.append(CheckStep(id=step.id, title=step.title))
    return result

def default_steps():
    return [CheckStep(id=title.lower().replace(' ', '_'), title=title) for title in DEFAULT_TITLES]
