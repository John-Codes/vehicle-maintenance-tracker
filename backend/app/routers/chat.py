from pydantic import BaseModel, Field, field_validator

from fastapi import APIRouter, Depends

from ..auth import require_key
from ..chat_context import SYSTEM_PROMPT, records_brief
from ..llm import complete
from ..tools import TOOLS
from ..storage import store

router = APIRouter(prefix='/chat', dependencies=[Depends(require_key)])


class HistoryMessage(BaseModel):
    role: str = Field(pattern='^(user|assistant)$')
    content: str = Field(min_length=1, max_length=20000)


class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=4000)
    history: list[HistoryMessage] = []

    @field_validator('message')
    @classmethod
    def not_blank(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError('message must not be blank')
        return value


@router.post('')
async def chat(request: ChatRequest):
    records = await store.list('service_record')
    system_prompt = f'{SYSTEM_PROMPT}\n\nRecords JSON:\n{records_brief(records)}'
    conversation = [
        {'role': item.role, 'content': item.content} for item in request.history[-20:]
    ]
    while conversation and conversation[0]['role'] == 'assistant':
        conversation.pop(0)
    conversation.append({'role': 'user', 'content': request.message})
    reply = await complete(system_prompt, conversation, tools=TOOLS)
    return {'reply': reply}