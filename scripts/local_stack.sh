#!/bin/sh
# Local review stack: Docker MongoDB + API + web app. Never touches the prod DB.
set -e
cd "$(dirname "$0")/.."
API_PORT=${API_PORT:-8021}
WEB_PORT=${WEB_PORT:-8092}
LOG_DIR="${TMPDIR:-/tmp}/chat-gpt-tracker-logs"
MONGO_PORT=${MONGO_PORT:-27027}
MONGO_CONTAINER=${MONGO_CONTAINER:-chat-gpt-tracker-mongo}
mkdir -p "$LOG_DIR"
KEY=${APP_API_KEY:-local-review-key}
IP=$(hostname -I | awk '{print $1}'); [ -n "$IP" ] || IP=127.0.0.1

echo "== local test MongoDB =="
if ! docker ps --format '{{.Names}}' | grep -qx "$MONGO_CONTAINER"; then
  docker run -d --name "$MONGO_CONTAINER" -p "127.0.0.1:$MONGO_PORT:27017" mongo:7 >/dev/null
  echo "started fresh isolated test MongoDB"
else
  echo "reusing running isolated test MongoDB"
fi

echo "== backend venv =="
if [ ! -x backend/.venv/bin/python ]; then
  python3 -m venv backend/.venv
  backend/.venv/bin/pip install -q -r backend/requirements.txt
fi

echo "== backend on :$API_PORT (local DB only) =="
if curl -sf http://127.0.0.1:$API_PORT/health >/dev/null; then
  echo "API port already occupied; choose a different API_PORT"; exit 1
fi
( cd backend && MONGO_URI=mongodb://127.0.0.1:$MONGO_PORT DB_NAME=chat_gpt_tracker_local COLLECTION=items \
  APP_API_KEY="$KEY" CORS_ALLOWED_ORIGINS='*' \
  AUTH_MODE="${AUTH_MODE:-dev}" JWT_SECRET="${JWT_SECRET:-local-jwt-secret}" \
  FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID:-fleet-tracker-9242a}" \
  OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-}" CHAT_MODEL="${CHAT_MODEL:-nvidia/nemotron-3.5-lightning:free}" \
  exec setsid ../backend/.venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port $API_PORT ) > "$LOG_DIR/local-api.log" 2>&1 < /dev/null &
echo $! > "$LOG_DIR/api.pid"
for i in $(seq 1 30); do curl -sf http://127.0.0.1:$API_PORT/health >/dev/null && break; sleep 2; done
curl -sf http://127.0.0.1:$API_PORT/health >/dev/null || { echo "backend failed:"; tail -20 "$LOG_DIR/local-api.log"; exit 1; }

echo "== e2e against local DB =="
API_URL=http://127.0.0.1:$API_PORT APP_API_KEY="$KEY" OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-}" backend/.venv/bin/python backend/e2e_schedule.py
API_URL=http://127.0.0.1:$API_PORT APP_API_KEY="$KEY" backend/.venv/bin/python backend/e2e_auth.py

echo "== building web (API http://$IP:$API_PORT) =="
flutter build web --release --dart-define=API_URL=http://$IP:$API_PORT --dart-define=API_KEY="$KEY" >/dev/null

echo "== serving web on :$WEB_PORT =="
if curl -sf http://127.0.0.1:$WEB_PORT/ >/dev/null; then
  echo "Web port already occupied; choose a different WEB_PORT"; exit 1
fi
setsid python3 -m http.server $WEB_PORT --directory build/web > "$LOG_DIR/web.log" 2>&1 < /dev/null &
for i in $(seq 1 15); do curl -sf http://127.0.0.1:$WEB_PORT/ >/dev/null && break; sleep 1; done
curl -sf http://127.0.0.1:$WEB_PORT/ >/dev/null || { echo "web server failed"; cat "$LOG_DIR/web.log"; exit 1; }
echo ""
echo "REVIEW LINK: http://$IP:$WEB_PORT  (API http://$IP:$API_PORT -> local Docker DB only, prod untouched)"
