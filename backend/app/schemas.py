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
    not_applicable: bool = False
    value: str = ''
    notes: str = ''
    description: str = ''

class ComponentList(BaseModel):
    id: str
    title: str = Field(min_length=1, max_length=120)
    steps: list[CheckStep] = []

class FrequencyList(BaseModel):
    last_done_at: str = ''
    components: list[ComponentList] = []

class MaintenanceSchedule(BaseModel):
    daily: FrequencyList
    weekly: FrequencyList
    monthly: FrequencyList

class ServiceRecord(BaseModel):
    vehicle_number: str = ''
    miles: Optional[float] = Field(None, ge=0)
    hours: Optional[float] = Field(None, ge=0)
    date_started: str = ''
    service_type: str = ''
    worker_names: list[str] = []
    technician: Technician = Technician()
    schedule: MaintenanceSchedule
    notes: str = ''
    next_steps: str = ''
    vin: str = ''
    license_plate: str = ''
