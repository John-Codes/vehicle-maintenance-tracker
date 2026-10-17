import asyncio
import json
import os

from fastapi import APIRouter, Header, HTTPException
from pydantic import BaseModel, Field

from ..config import API_KEY
from ..llm import complete
from ..service_types.ai_type_prompt import DISCLAIMER, build_generation_prompt
from ..service_types import store as type_store

router = APIRouter(prefix='/service-types', tags=['AI type generation'])


class AiTypeRequest(BaseModel):
    brand: str = Field(min_length=1, max_length=60)
    model: str = Field(min_length=1, max_length=60)
    year: int = Field(ge=1900, le=2100)


# The AI model that drafts checklists. Defaults to a free Nemotron on
# OpenRouter; override per environment with AI_TYPE_MODEL.
AI_TYPE_MODEL = os.getenv('AI_TYPE_MODEL', 'nvidia/nemotron-3-ultra-550b-a55b:free')
# When the primary model is overloaded/empty (free tier), fall back to the
# lighter chat-tier model so generation still works during outages.
AI_TYPE_FALLBACK_MODEL = os.getenv('AI_TYPE_FALLBACK_MODEL', 'nvidia/nemotron-3.5-lightning:free')


@router.post('/ai-generate')
async def ai_generate(request: AiTypeRequest, x_app_key: str = Header(default='')):
    """Generate a maintenance checklist via an LLM function call. The model
    runs with ONLY the create_service_type tool, so it cannot touch records
    or other types; invalid JSON is repaired in the same conversation."""
    if x_app_key != API_KEY:
        raise HTTPException(401, 'Master app key required')
    vehicle = f'{request.year} {request.brand} {request.model}'.strip()
    prompt = build_generation_prompt(request.brand, request.model, request.year)
    created = None
    reply = ''
    # Hard total deadline so an overloaded free tier fails fast instead of
    # piling attempts: try the primary model, then the lighter fallback.
    deadline = asyncio.get_event_loop().time() + 480
    for model, timeout in ((AI_TYPE_MODEL, 120), (AI_TYPE_FALLBACK_MODEL, 180)):
        for attempt in range(3):
            if asyncio.get_event_loop().time() >= deadline:
                break
            try:
                reply = await complete(prompt, [
                    {'role': 'user', 'content': f'Create the maintenance type for the {vehicle} now.'}],
                    tools=[_create_type_tool()], model=model,
                    stop_after_tool='create_service_type', timeout=timeout,
                    deadline=deadline)
                created = json.loads(reply)
                break
            except (HTTPException, json.JSONDecodeError):
                created = await _find_created_type(vehicle)
                if created is not None:
                    break
                if attempt < 2:
                    await asyncio.sleep(10)
        if created is not None or asyncio.get_event_loop().time() >= deadline:
            break
    if created is None:
        raise HTTPException(502, 'The AI could not create the type. Its reply: ' + reply[:300])
    return {'type': created, 'disclaimer': DISCLAIMER}


def _create_type_tool():
    """One-tool whitelist: the AI can only create a type, nothing else."""
    return {
        'type': 'function',
        'function': {
            'name': 'create_service_type',
            'description': 'Create a service type with a schedule.',
            'parameters': {
                'type': 'object',
                'properties': {
                    'name': {'type': 'string', 'description': 'Type name'},
                    'schedule': {'type': 'object',
                                 'description': 'Full daily/weekly/monthly schedule of components with steps'},
                },
                'required': ['name', 'schedule'],
            },
        },
    }


async def _find_created_type(vehicle):
    """The prompt mandates the type name; look it up, then fall back to
    the most recently created type containing the vehicle words."""
    docs = type_store.collection.find({'deleted': False})
    latest = None
    async for doc in docs:
        public = type_store.public(doc)
        if public['name'].casefold() == vehicle.casefold():
            return public
        if all(word in public['name'].casefold() for word in vehicle.casefold().split()):
            latest = public
    return latest
