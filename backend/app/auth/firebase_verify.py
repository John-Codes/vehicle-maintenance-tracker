import time

import httpx
from fastapi import HTTPException
from jose import JWTError, jwt

from .config import FIREBASE_PROJECT_ID

CERT_URL = ('https://www.googleapis.com/robot/v1/metadata/x509/'
            'securetoken@system.gserviceaccount.com')
_cert_cache = {'certs': {}, 'expires': 0.0}


async def _load_certs() -> dict:
    now = time.time()
    if now >= _cert_cache['expires'] or not _cert_cache['certs']:
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.get(CERT_URL)
            response.raise_for_status()
        cache_control = response.headers.get('cache-control', 'max-age=3600')
        max_age = next((int(part.split('=')[1]) for part in cache_control.split(',')
                        if 'max-age' in part), 3600)
        _cert_cache['certs'] = response.json()
        _cert_cache['expires'] = now + max_age
    return _cert_cache['certs']


async def verify_firebase_token(id_token: str) -> dict:
    """Verify a Firebase ID token and return {'uid', 'email', 'name'}."""
    if not FIREBASE_PROJECT_ID:
        raise HTTPException(503, 'Firebase auth is not configured')
    try:
        header = jwt.get_unverified_header(id_token)
        certs = await _load_certs()
        cert = certs.get(header.get('kid', ''))
        if cert is None:
            raise HTTPException(401, 'Unknown token signing key')
        claims = jwt.decode(
            id_token, cert, algorithms=['RS256'],
            audience=FIREBASE_PROJECT_ID,
            issuer=f'https://securetoken.google.com/{FIREBASE_PROJECT_ID}')
    except JWTError:
        raise HTTPException(401, 'Invalid Firebase token')
    if not claims.get('sub') or not claims.get('email'):
        raise HTTPException(401, 'Firebase token missing identity')
    return {'uid': claims['sub'], 'email': claims['email'].lower(),
            'name': claims.get('name', '')}
