from pydantic import BaseModel, Field, field_validator
from ..schemas import MaintenanceSchedule

class ServiceType(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    schedule: MaintenanceSchedule

    @field_validator('name')
    @classmethod
    def clean_name(cls, value):
        value = value.strip()
        if not value:
            raise ValueError('Name is required')
        return value

    @field_validator('schedule')
    @classmethod
    def validate_children(cls, schedule):
        groups = [schedule.daily, schedule.weekly, schedule.monthly]
        component_ids = [[c.id for c in group.components] for group in groups]
        if any(len(ids) != len(set(ids)) for ids in component_ids):
            raise ValueError('Component IDs must be unique within a frequency')
        if any(set(ids) != set(component_ids[0]) for ids in component_ids):
            raise ValueError('Components must appear in all three frequencies')
        steps = [s for g in groups for c in g.components for s in c.steps]
        if len({s.id for s in steps}) != len(steps):
            raise ValueError('Step IDs must be unique across the schedule')
        if any(not c.id.strip() or not c.title.strip() for g in groups for c in g.components):
            raise ValueError('Components require an ID and title')
        if any(not s.id.strip() or not s.title.strip() for s in steps):
            raise ValueError('Items require an ID and title')
        return schedule
