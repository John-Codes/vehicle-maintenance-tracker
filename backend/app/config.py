import os

STORE_URL = os.getenv('MONGO_STORE_URL', 'http://127.0.0.1:8002').rstrip('/')
API_KEY = os.getenv('APP_API_KEY', 'change-me')
CORS_ORIGINS = [value.strip() for value in os.getenv('CORS_ALLOWED_ORIGINS', '*').split(',')]
