"""Base contract every messaging channel implements."""


class Channel:
    """A delivery channel (email, sms, push, call, ...). Subclasses set
    `name` and implement `send`."""

    name = 'channel'

    async def send(self, message) -> dict:
        """Deliver `message`. Returns {'ok': bool, ...} metadata; may raise
        on failure (caller alerts)."""
        raise NotImplementedError
