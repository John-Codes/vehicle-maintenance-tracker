"""E2E: daily inspection job sends a generic reminder to all workspace users.
Creates real users over real HTTP, then runs the real job against the same
local test DB. No mocks."""
import asyncio
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from e2e_helpers import dev_token, fresh_email  # noqa: E402


def create_workspace_with_two_users():
    manager_email = fresh_email('insp-mgr')
    _, manager = dev_token(manager_email)
    workspace_id = manager['workspace_id']
    assert workspace_id, 'manager should own a workspace'
    _, tech = dev_token(fresh_email('insp-tech'), workspace_id=workspace_id)
    assert tech['workspace_id'] == workspace_id
    return workspace_id, {manager_email, tech['email']}


def main():
    workspace_id, expected_emails = create_workspace_with_two_users()

    from app.inspections_messages.builders import build_daily_inspection_message
    from app.inspections_messages.service import run_daily_inspection_for_all_workspaces
    from app.messaging.models import MessageRecipient

    summary = asyncio.run(run_daily_inspection_for_all_workspaces())
    assert summary['workspaces_checked'] >= 1, summary
    assert summary['users_considered'] >= 2, summary
    results = summary['results']
    assert workspace_id in results, f'workspace {workspace_id} missing: {results}'
    workspace_result = results[workspace_id]
    assert workspace_result['email']['ok'] is True, workspace_result
    assert workspace_result['email']['delivered_to'] == 2, workspace_result

    message = build_daily_inspection_message(
        [MessageRecipient(email=email) for email in expected_emails])
    assert 'inspection' in message.text.lower()
    assert 'tires' in message.text.lower() and 'lights' in message.text.lower()
    assert message.context['type'] == 'daily_inspection'
    print('PASS daily inspection job: generic reminder sent to all workspace users')


main()
