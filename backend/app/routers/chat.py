from pydantic import BaseModel, Field, field_validator

from fastapi import APIRouter, Depends

from ..auth.guards import require_workspace_user
from ..auth.session import Principal
from ..chat_context import SYSTEM_PROMPT, records_brief
from ..chat_history import save_exchange
from ..config import VISION_MODEL
from ..inspections_tools import INSPECTION_TOOLS
from ..inspections_vision import VISION_PROMPT_RULES, date_gate, image_parts
from ..llm import complete
from ..storage import store
from ..tools import TOOLS

router = APIRouter(prefix='/chat', dependencies=[Depends(require_workspace_user)])

ALL_TOOLS = TOOLS + INSPECTION_TOOLS


class HistoryMessage(BaseModel):
    role: str = Field(pattern='^(user|assistant)$')
    content: str = Field(min_length=1, max_length=20000)


class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=4000)
    history: list[HistoryMessage] = []
    images: list[str] = Field(default=[], max_length=3)

    @field_validator('message')
    @classmethod
    def not_blank(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError('message must not be blank')
        return value


def _record_scope(principal: Principal):
    return None if principal.is_legacy else principal.workspace_id


def _system_prompt(principal: Principal, records: list) -> str:
    who = principal.email or 'legacy shared-key user'
    return (f'{SYSTEM_PROMPT}\n\nSigned in as: {who} (marks are recorded under this name).\n\n'
            f'Records JSON:\n{records_brief(records)}')


@router.post('')
async def chat(request: ChatRequest, principal: Principal = Depends(require_workspace_user)):
    records = await store.list('service_record', _record_scope(principal))
    system_prompt = _system_prompt(principal, records)
    conversation = [
        {'role': item.role, 'content': item.content} for item in request.history[-20:]
    ]
    while conversation and conversation[0]['role'] == 'assistant':
        conversation.pop(0)

    if request.images:
        gate = date_gate(request.images)
        if not gate['ok']:
            return {'reply': gate['message']}
        system_prompt += VISION_PROMPT_RULES + f"\nServer date check: {gate['message']}"
        text = (f"{request.message}\n\n[Attached photos: {len(request.images)}. "
                f"Server verified the dates above; inspect the content yourself.]")
        conversation.append({'role': 'user', 'content': [{'type': 'text', 'text': text}, *image_parts(request.images)]})
        reply = await complete(system_prompt, conversation, tools=ALL_TOOLS,
                               principal=principal, model=VISION_MODEL or None)
    else:
        conversation.append({'role': 'user', 'content': request.message})
        reply = await complete(system_prompt, conversation, tools=ALL_TOOLS, principal=principal)

    await save_exchange(principal, request.message, reply)
    return {'reply': reply}
