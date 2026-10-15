import asyncio
import json

import httpx
from fastapi import HTTPException

from .config import CHAT_MODEL, OPENROUTER_API_KEY
from .inspections_tools import run_inspection_tool
from .tools import run_tool

OPENROUTER_URL = 'https://openrouter.ai/api/v1/chat/completions'
MAX_TOOL_ROUNDS = 6


async def complete(system_prompt: str, messages: list, tools=None, principal=None, model=None) -> str:
    if not OPENROUTER_API_KEY:
        raise HTTPException(503, 'Chat is not configured: set OPENROUTER_API_KEY')
    conversation = [{'role': 'system', 'content': system_prompt}, *messages]
    for _ in range(MAX_TOOL_ROUNDS):
        pack = await _call(conversation, tools, model)
        tool_calls = pack.get('tool_calls') or []
        if not tool_calls:
            content = (pack.get('content') or '').strip()
            if content:
                return content
            raise HTTPException(502, 'LLM returned an empty reply')
        conversation.append({'role': 'assistant', 'content': pack.get('content') or '', 'tool_calls': tool_calls})
        for call in tool_calls:
            function = call.get('function', {})
            raw_args = function.get('arguments') or '{}'
            try:
                args = json.loads(raw_args)
            except json.JSONDecodeError:
                args = {}
            result = await _run_any_tool(function.get('name', ''), args if isinstance(args, dict) else {}, principal)
            conversation.append({'role': 'tool', 'tool_call_id': call.get('id', ''), 'content': result})
    raise HTTPException(502, 'LLM did not finish after multiple tool rounds')


async def _run_any_tool(name: str, args: dict, principal) -> str:
    """Inspection tools first, then the base record tools. Errors become
    tool-result text so the assistant can explain instead of crashing."""
    try:
        result = await run_inspection_tool(name, args, principal)
        if result is not None:
            return json.dumps(result, default=str)
        return await run_tool(name, args, principal)
    except HTTPException as error:
        return json.dumps({'error': error.detail})
    except Exception as error:  # noqa: BLE001 - surface to the assistant
        return json.dumps({'error': str(error).splitlines()[0][:200]})


async def _call(conversation, tools, model) -> dict:
    payload = {'model': model or CHAT_MODEL, 'messages': conversation}
    if tools:
        payload['tools'] = tools
    headers = {'Authorization': f'Bearer {OPENROUTER_API_KEY}'}
    last_error = 'unknown error'
    for attempt in range(2):
        try:
            async with httpx.AsyncClient(timeout=90) as client:
                response = await client.post(OPENROUTER_URL, json=payload, headers=headers)
        except httpx.HTTPError as error:
            last_error = str(error)
        else:
            if response.status_code == 200:
                return response.json().get('choices', [{}])[0].get('message', {})
            if response.status_code < 500 and response.status_code != 429:
                raise HTTPException(502, f'LLM rejected request ({response.status_code}): {response.text[:200]}')
            last_error = f'HTTP {response.status_code}'
        if attempt == 0:
            await asyncio.sleep(2)
    raise HTTPException(502, f'LLM request failed: {last_error}')