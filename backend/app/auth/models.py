from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class FirebaseExchange(BaseModel):
    id_token: str = Field(min_length=20, max_length=4000)


class DevTokenRequest(BaseModel):
    email: EmailStr
    name: str = ''
    role: str = Field(default='technician', pattern='^(admin|manager|technician)$')
    workspace_id: str = Field(default='', max_length=80)


class BootstrapAdminRequest(BaseModel):
    email: EmailStr


class Token(BaseModel):
    access_token: str
    token_type: str = 'bearer'
    user: Optional[dict] = None


class LegacyPrincipalOut(BaseModel):
    id: str = ''
    email: str = ''
    name: str = ''
    role: str = 'legacy'
    workspace_id: str = 'default'
