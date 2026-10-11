from typing import Optional

from pydantic import BaseModel, Field


class TelemetryIn(BaseModel):
    """One mileage/hours reading for a vehicle, from manual entry, GPS,
    or an OBD adapter."""
    vehicle_number: str = Field(min_length=1, max_length=120)
    odometer_mi: float = Field(ge=0, le=10_000_000)
    engine_hours: Optional[float] = Field(default=None, ge=0, le=1_000_000)
    source: str = Field(default='manual', pattern='^(manual|gps|obd)$')
    notes: str = Field(default='', max_length=2000)
