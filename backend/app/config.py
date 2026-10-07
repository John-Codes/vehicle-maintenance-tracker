import os

MONGO_URI = os.getenv('MONGO_URI', '')
DB_NAME = os.getenv('DB_NAME', 'mystore')
COLLECTION = os.getenv('COLLECTION', 'items')
API_KEY = os.getenv('APP_API_KEY', 'change-me')
OPENROUTER_API_KEY = os.getenv('OPENROUTER_API_KEY', '')
CHAT_MODEL = os.getenv('CHAT_MODEL', 'nvidia/nemotron-3.5-lightning:free')
CORS_ORIGINS = [value.strip() for value in os.getenv('CORS_ALLOWED_ORIGINS', '*').split(',')]
