from .schemas import FrequencyList, MaintenanceSchedule

def empty_schedule():
    return MaintenanceSchedule(daily=FrequencyList(), weekly=FrequencyList(), monthly=FrequencyList())

def step_ids(schedule: MaintenanceSchedule):
    ids = []
    for frequency in (schedule.daily, schedule.weekly, schedule.monthly):
        for component in frequency.components:
            ids.extend(step.id for step in component.steps)
    return ids
