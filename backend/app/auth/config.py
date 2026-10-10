import os

JWT_SECRET = os.getenv('JWT_SECRET', 'dev-only-insecure-secret')
TOKEN_HOURS = int(os.getenv('TOKEN_HOURS', '24'))
AUTH_MODE = os.getenv('AUTH_MODE', 'dev')
FIREBASE_PROJECT_ID = os.getenv('FIREBASE_PROJECT_ID', '')
DEFAULT_WORKSPACE = os.getenv('DEFAULT_WORKSPACE', 'default')
