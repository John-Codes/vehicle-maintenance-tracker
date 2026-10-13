"""Builders for the generic daily inspection reminder. Deliberately
vehicle-agnostic: vehicles are assigned daily, so no vehicle/driver names."""
from ..messaging.models import Message, MessageRecipient


def build_daily_inspection_message(recipients: list[MessageRecipient]) -> Message:
    return Message(
        subject='Daily inspection reminder',
        text=('Daily inspection reminder: Check the tires, check the lights, '
              'check the fluids, and go over safety items before using the '
              'equipment. Did you do your daily inspection today?'),
        html=('Daily inspection reminder: Check the <b>tires</b>, check the '
              '<b>lights</b>, check the <b>fluids</b>, and go over <b>safety '
              'items</b> before using the equipment. Did you do your daily '
              'inspection today?'),
        recipients=recipients,
        context={'type': 'daily_inspection'},
    )
