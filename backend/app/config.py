import os

MONGO_URI = os.getenv('MONGO_URI', '')
DB_NAME = os.getenv('DB_NAME', 'mystore')
COLLECTION = os.getenv('COLLECTION', 'items')
API_KEY = os.getenv('APP_API_KEY', 'change-me')
OPENROUTER_API_KEY = os.getenv('OPENROUTER_API_KEY', '')
CHAT_MODEL = os.getenv('CHAT_MODEL', 'nvidia/nemotron-3.5-lightning:free')
# Vision model for photo inspections; empty disables the photo path.
# Free vision-capable default; set to google/gemini-2.5-flash once the
# OpenRouter account has credits (it rejects with 402 without them).
VISION_MODEL = os.getenv('VISION_MODEL', 'nvidia/nemotron-3.5-super-vl:free')
CORS_ORIGINS = [value.strip() for value in os.getenv('CORS_ALLOWED_ORIGINS', '*').split(',')]

MESSAGE_CHANNELS = [c.strip() for c in os.getenv('MESSAGE_CHANNELS', 'email').split(',') if c.strip()]
SCHEDULE_TZ = os.getenv('SCHEDULE_TZ', 'America/Chicago')
DAILY_INSPECTION_HOUR = int(os.getenv('DAILY_INSPECTION_HOUR', '3'))
DAILY_INSPECTION_MINUTE = int(os.getenv('DAILY_INSPECTION_MINUTE', '0'))
AGENTMAIL_API_KEY = os.getenv('AGENTMAIL_API_KEY', '')
AGENTMAIL_BASE_URL = os.getenv('AGENTMAIL_BASE_URL', 'https://api.agentmail.to/v0')
AGENTMAIL_INBOX_ID = os.getenv('AGENTMAIL_INBOX_ID', '')
EMAIL_REPLY_TO = os.getenv('EMAIL_REPLY_TO', '')
ALERT_EMAIL_TO = os.getenv('ALERT_EMAIL_TO', 'efexzium@gmail.com')
