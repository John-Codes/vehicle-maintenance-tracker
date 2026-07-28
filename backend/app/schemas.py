from datetime import datetime, timezone
from typing import Optional
from pydantic import BaseModel, Field

class Technician(BaseModel):
    name: str = ''
    phone: str = ''
    email: str = ''

class CheckStep(BaseModel):
    id: str
    title: str = Field(min_length=1, max_length=120)
    done: bool = False
    value: str = ''
    notes: str = ''

class ServiceRecord(BaseModel):
    vehicle_number: str = ''
    miles: Optional[float] = Field(None, ge=0)
    hours: Optional[float] = Field(None, ge=0)
    date_started: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    service_type: str = ''
    worker_names: list[str] = []
    technician: Technician = Technician()
    steps: list[CheckStep] = []
    notes: str = ''
    next_steps: str = ''
