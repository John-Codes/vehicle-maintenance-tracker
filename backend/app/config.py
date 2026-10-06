import os

MONGO_URI = os.getenv('MONGO_URI', '')
DB_NAME = os.getenv('DB_NAME', 'mystore')
COLLECTION = os.getenv('COLLECTION', 'items')
API_KEY = os.getenv('APP_API_KEY', 'change-me')
CORS_ORIGINS = [value.strip() for value in os.getenv('CORS_ALLOWED_ORIGINS', '*').split(',')]
