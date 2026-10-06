#!/bin/sh
# Local review stack: Docker MongoDB + API + web app. Never touches the prod DB.
set -e
cd "$(dirname "$0")/.."
API_PORT=8011
WEB_PORT=8091
LOG_DIR="${TMPDIR:-/tmp}/tracker-logs"
mkdir -p "$LOG_DIR"
KEY=$(grep '^APP_API_KEY=' backend/.env | cut -d= -f2-)
IP=$(hostname -I | awk '{print $1}'); [ -n "$IP" ] || IP=127.0.0.1

echo "== local test MongoDB =="
if ! docker ps --format '{{.Names}}' | grep -q '^tracker-test-mongo$'; then
  docker rm -f tracker-test-mongo >/dev/null 2>&1 || true
  docker run -d --name tracker-test-mongo -p 27017:27017 mongo:7 >/dev/null
  echo "started fresh tracker-test-mongo"
else
  echo "reusing running tracker-test-mongo"
fi

echo "== backend venv =="
if [ ! -x backend/.venv/bin/python ]; then
  python3 -m venv backend/.venv
  backend/.venv/bin/pip install -q -r backend/requirements.txt
fi

echo "== backend on :$API_PORT (local DB only) =="
pkill -f "uvicorn app.main:app" 2>/dev/null || true
sleep 1
( cd backend && MONGO_URI=mongodb://127.0.0.1:27017 DB_NAME=tracker_local COLLECTION=items \
  APP_API_KEY="$KEY" CORS_ALLOWED_ORIGINS='*' \
  exec ../backend/.venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port $API_PORT ) > "$LOG_DIR/local-api.log" 2>&1 &
for i in $(seq 1 30); do curl -sf http://127.0.0.1:$API_PORT/health >/dev/null && break; sleep 2; done
curl -sf http://127.0.0.1:$API_PORT/health >/dev/null || { echo "backend failed:"; tail -20 "$LOG_DIR/local-api.log"; exit 1; }

echo "== e2e against local DB =="
API_URL=http://127.0.0.1:$API_PORT APP_API_KEY="$KEY" backend/.venv/bin/python backend/e2e_schedule.py

echo "== building web (API http://$IP:$API_PORT) =="
flutter build web --release --dart-define=API_URL=http://$IP:$API_PORT --dart-define=API_KEY="$KEY" >/dev/null

echo "== serving web on :$WEB_PORT =="
pkill -f "http.server $WEB_PORT" 2>/dev/null || true
sleep 1
setsid python3 -m http.server $WEB_PORT --directory build/web > "$LOG_DIR/web.log" 2>&1 < /dev/null &
for i in $(seq 1 15); do curl -sf http://127.0.0.1:$WEB_PORT/ >/dev/null && break; sleep 1; done
curl -sf http://127.0.0.1:$WEB_PORT/ >/dev/null || { echo "web server failed"; cat "$LOG_DIR/web.log"; exit 1; }
echo ""
echo "REVIEW LINK: http://$IP:$WEB_PORT  (API http://$IP:$API_PORT -> local Docker DB only, prod untouched)"
