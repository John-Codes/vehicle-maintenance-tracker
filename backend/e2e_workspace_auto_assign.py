"""E2E: workspace auto-provisioning and safe invite joining (basic path).

Real HTTP against the real backend and DB. Every new user is manager of their
own workspace; redeeming an invite adds a membership without losing the old one.
"""
from e2e_helpers import call, dev_token, expect_error, fresh_email, memberships_ws, switch


def main():
    # Basic path: each fresh user auto-becomes manager of their own workspace.
    _, alice = dev_token(fresh_email('auto'))
    _, bob = dev_token(fresh_email('auto'))
    own_alice = alice['workspace_id']
    assert alice['role'] == 'manager' and own_alice.startswith('ws-'), alice
    assert memberships_ws(alice) == {own_alice}, alice
    assert own_alice != bob['workspace_id'], 'workspaces must be unique'

    # Usual: signing in again keeps the same workspace and membership.
    _, again = dev_token(alice['email'])
    assert again['workspace_id'] == own_alice and memberships_ws(again) == {own_alice}

    # Usual: records are isolated between the two auto workspaces.
    token_a, _ = dev_token(alice['email'])
    record = call('POST', '/service-records', token=token_a)
    assert record['workspace_id'] == own_alice
    token_b, _ = dev_token(bob['email'])
    expect_error('GET', f"/service-records/{record['id']}", 404, token=token_b)

    # Usual: alice redeems a tech invite into carol's team workspace.
    _, carol = dev_token(fresh_email('owner'))
    token_c, _ = dev_token(carol['email'])
    team = carol['workspace_id']
    invite = call('POST', '/invites', {'role': 'tech'}, token=token_c)
    joined = call('POST', '/invites/redeem', {'code': invite['code']}, token=token_a)
    assert joined['workspace_id'] == team and joined['role'] == 'tech', joined
    assert memberships_ws(joined) == {own_alice, team}, 'own workspace must be kept'

    # Less common: signing in after joining still reports both memberships.
    _, signed = dev_token(alice['email'])
    assert memberships_ws(signed) == {own_alice, team}, signed

    # No data loss: switching back to the own workspace restores the record.
    back = switch(token_a, own_alice)
    assert back['role'] == 'manager' and back['workspace_id'] == own_alice, back
    got = call('GET', f"/service-records/{record['id']}", token=token_a)
    assert got['id'] == record['id']

    # Both directions: inside the team workspace the own record is hidden.
    switch(token_a, team)
    expect_error('GET', f"/service-records/{record['id']}", 404, token=token_a)

    # Odd: switching to a workspace the user never joined is rejected.
    expect_error('PUT', '/auth/workspace', 403, token=token_a, body={'workspace_id': 'ws-ghost'})

    # Tidy up the review DB.
    switch(token_a, own_alice)
    call('DELETE', f"/service-records/{record['id']}", token=token_a)


if __name__ == '__main__':
    main()