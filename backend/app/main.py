from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .auth.routers import auth, auth_dev
from .config import CORS_ORIGINS
from .invites import router as invites
from .inspections_messages.router import router as inspections_messages
from .chat_history import router as chat_history
from .routers import chat, profile, records, users
from .scheduler import start_scheduler, stop_scheduler
from .storage import store
from .service_types import router as service_types, store as type_store

@asynccontextmanager
async def lifespan(app):
    await type_store.initialize()
    start_scheduler()
    yield
    stop_scheduler()
    await store.close()

app = FastAPI(title='Vehicle Service Tracker API', lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=CORS_ORIGINS, allow_credentials=False, allow_methods=['*'], allow_headers=['*'])
app.include_router(profile.router)
app.include_router(records.router)
app.include_router(chat.router)
app.include_router(service_types.router)
app.include_router(auth.router)
app.include_router(auth_dev.router)
app.include_router(users.router)
app.include_router(chat_history)
app.include_router(invites)
app.include_router(inspections_messages)

@app.get('/health')
async def health(): return {'ok': True}
