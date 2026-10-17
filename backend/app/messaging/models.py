"""Message models shared by jobs and channels."""
from pydantic import BaseModel, EmailStr


class MessageRecipient(BaseModel):
    email: EmailStr
    name: str = ''


class MessageAttachment(BaseModel):
    filename: str
    content_type: str = 'application/octet-stream'
    content_b64: str = ''


class Message(BaseModel):
    """Channel-agnostic message. Jobs build this; channels deliver it."""
    subject: str
    text: str
    html: str = ''
    recipients: list[MessageRecipient] = []
    attachments: list[MessageAttachment] = []
    context: dict = {}
