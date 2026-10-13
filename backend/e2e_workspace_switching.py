"""E2E: workspace switching, per-workspace roles, and invite edge cases.

Less-common and odd scenarios on top of e2e_workspace_auto_assign. Switching
or being removed must never corrupt memberships or lose a user's own workspace.
"""
from e2e_helpers import (call, dev_token, expect_error, fresh_email,
                         memberships_ws, switch, team_invite)


def main():
    # Setup: alice owns a workspace; carol owns a team and invites alice as tech.
    _, alice = dev_token(fresh_email('switch'))
    own = alice['workspace_id']
    token_a, _ = dev_token(alice['email'])
    _, carol = dev_token(fresh_email('owner'))
    token_c, _ = dev_token(carol['email'])
    team = carol['workspace_id']
    invite = team_invite(token_c, 'tech')
    call('POST', '/invites/redeem', {'code': invite['code']}, token=token_a)

    # Less common: a second invite with a different role upserts, not duplicates.
    promote = team_invite(token_c, 'manager')
    joined = call('POST', '/invites/redeem', {'code': promote['code']}, token=token_a)
    assert joined['role'] == 'manager' and len(joined['memberships']) == 2, joined
    alice_id = joined['id']

    # Role independence: manager of own workspace; switching works both ways.
    assert switch(token_a, own)['role'] == 'manager'
    assert switch(token_a, team)['role'] == 'manager'

    # Less common: a team role change does not leak into the own workspace.
    call('PUT', f'/users/{alice_id}/role', {'role': 'tech'}, token=token_c)
    assert switch(token_a, own)['role'] == 'manager'
    assert switch(token_a, team)['role'] == 'tech'

    # Odd: the legacy shared key cannot switch workspaces.
    expect_error('PUT', '/auth/workspace', 403, body={'workspace_id': team})

    # Odd: a pending user (no memberships) cannot switch workspaces.
    token_p, _ = dev_token(fresh_email('pending'), 'tech', '')
    expect_error('PUT', '/auth/workspace', 403, token=token_p, body={'workspace_id': team})

    # Odd: invite codes are single-use and revoked codes stay dead.
    used = team_invite(token_c)
    call('POST', '/invites/redeem', {'code': used['code']}, token=token_a)
    expect_error('POST', '/invites/redeem', 409, token=token_a, body={'code': used['code']})
    revoked = team_invite(token_c)
    call('DELETE', f"/invites/{revoked['id']}", token=token_c)
    expect_error('POST', '/invites/redeem', 409, token=token_a, body={'code': revoked['code']})

    # Less common: removing the active membership falls back to the own workspace.
    call('DELETE', f'/users/{alice_id}', token=token_c)
    _, reverted = dev_token(alice['email'])
    assert reverted['workspace_id'] == own and reverted['role'] == 'manager', reverted
    expect_error('PUT', '/auth/workspace', 403, token=token_a, body={'workspace_id': team})

    # Odd: a user whose only membership is a team becomes pending when removed.
    token_s, solo = dev_token(fresh_email('solo'), 'tech', '')
    invite = team_invite(token_c, 'tech')
    solo_joined = call('POST', '/invites/redeem', {'code': invite['code']}, token=token_s)
    assert memberships_ws(solo_joined) == {team}, solo_joined
    call('DELETE', f"/users/{solo_joined['id']}", token=token_c)
    _, solo_after = dev_token(solo['email'])
    assert solo_after['workspace_id'] == '' and solo_after['role'] == 'tech', solo_after
    expect_error('GET', '/service-records', 403, token=token_s)


if __name__ == '__main__':
    main()