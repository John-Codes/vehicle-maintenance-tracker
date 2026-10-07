from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .config import CORS_ORIGINS
from .routers import chat, profile, records
from .storage import store
from .service_types import router as service_types, store as type_store

@asynccontextmanager
async def lifespan(app):
    await type_store.initialize()
    yield
    await store.close()

app = FastAPI(title='Vehicle Service Tracker API', lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=CORS_ORIGINS, allow_credentials=False, allow_methods=['*'], allow_headers=['*'])
app.include_router(profile.router)
app.include_router(records.router)
app.include_router(chat.router)
app.include_router(service_types.router)

@app.get('/health')
async def health(): return {'ok': True}
