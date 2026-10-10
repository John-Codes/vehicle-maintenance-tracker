from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class FirebaseExchange(BaseModel):
    id_token: str = Field(min_length=20, max_length=4000)


class DevTokenRequest(BaseModel):
    email: EmailStr
    name: str = ''
    role: Optional[str] = Field(default=None, pattern='^(manager|tech)$')
    workspace_id: Optional[str] = Field(default=None, max_length=80)


class RoleChange(BaseModel):
    role: str = Field(pattern='^(manager|tech)$')


class InviteCreate(BaseModel):
    role: str = Field(default='tech', pattern='^(manager|tech)$')
    label: str = Field(default='', max_length=120)


class InviteRedeem(BaseModel):
    code: str = Field(min_length=4, max_length=64)


class LegacyPrincipalOut(BaseModel):
    id: str = ''
    email: str = ''
    name: str = ''
    role: str = 'legacy'
    workspace_id: str = 'default'
