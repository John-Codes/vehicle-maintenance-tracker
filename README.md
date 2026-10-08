# Vehicle Maintenance Tracker

A full-stack vehicle service record management app built with **Flutter** (frontend) and **FastAPI** (backend), backed by **MongoDB** via a REST API.

## Features

- **Service Records** — Create, edit, and delete vehicle inspection records
- **Inspection Checklist** — Customizable checklist items with done/pending status, values, and notes
- **Checklist Done History** — Every done toggle stores a `done_at` timestamp and a quiet, append-only `done_history` log in the DB (time + GPS when the browser grants location); the UI only shows the last-done stamp
- **Due Badges** — Daily/Weekly/Monthly rows stay collapsed and show a red "Due" badge until done in the current period; unchecked items are marked red inside the expanded list
- **Autosave** — Record editor fields save silently after 1s of inactivity; checklist done events flush immediately; a local draft (shared preferences) is restored and sent to the backend when the editor reopens
- **Technician Profile** — Store technician name, phone, and email
- **PDF Export** — Styled PDF reports with branded colors, info tables, and checklist
- **XLSX Export** — Spreadsheet export with summary and checklist tabs
- **Dark Mode** — Toggle between light and dark themes
- **Swipe to Delete** — Swipe or tap to delete records with confirmation
- **AI Chat** — Chat tab that answers questions about your service records (OpenRouter, server-side key)

## Architecture

```
Flutter Web (port 3000)
  → FastAPI Backend (port 8010)
    → MongoDB Fast API (external REST service)
      → MongoDB Atlas
```

| Layer | Tech | Location |
|-------|------|----------|
| Frontend | Flutter / Dart | `lib/` |
| Backend API | FastAPI / Python | `backend/` |
| MongoDB Storage | FastAPI + Motor | External service |

## Maintenance schedule contract

Every service record stores a `schedule`. There is no flat `steps` list. Flutter enforces this with `MaintenanceSchedule` in `lib/features/maintenance_lists/maintenance_schedule.dart`. The backend schema requires the same three keys and rejects a record that omits one.

```json
{
  "schedule": {
    "daily": {
      "last_done_at": "",
      "components": [
        {
          "id": "engine",
          "title": "Engine",
          "steps": [
            {"id": "d-oil", "title": "Oil level", "done": false, "not_applicable": false, "done_at": "", "done_history": [], "value": "", "notes": "", "description": ""}
          ]
        }
      ]
    },
    "weekly": {"last_done_at": "", "components": []},
    "monthly": {"last_done_at": "", "components": []}
  }
}
```

- `daily`, `weekly`, and `monthly` are required.
- `last_done_at` is `YYYY-MM-DD` or `""`. Empty means never.
- Each frequency holds component lists. A service type repeats the same component ids in all three frequencies.
- A component holds leaf steps only. A step has `id`, `title`, `done`, `not_applicable`, `done_at`, `done_history`, `value`, `notes`, and `description`.
- `done_at` is the ISO timestamp of the last done toggle; `done_history` is an append-only log of `{at, lat, lng, accuracy}` entries (GPS may be null when the browser denies location). Service types never store either field.
- Step ids are unique across the whole schedule.
- The inspection UI shows Daily, Weekly, and Monthly collapsed, each with last done or Never plus a red "Due" badge when not done in the current period.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.10
- [Python 3.12+](https://www.python.org/downloads/)
- [Docker](https://docs.docker.com/get-docker/) (optional, for containerized deployment)

### Local Development

**1. Start the local test database** (Docker — never test against the prod DB):

```bash
docker run -d --name tracker-test-mongo -p 27017:27017 mongo:7
```

**2. Start the backend** (pointed at the local test DB):

```bash
cd backend
pip install -r requirements.txt
MONGO_URI=mongodb://127.0.0.1:27017 DB_NAME=tracker_local APP_API_KEY=change-me uvicorn app.main:app --host 0.0.0.0 --port 8010
```

**3. Run the Flutter app:**

```bash
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://localhost:8010 --dart-define=API_KEY=change-me
```

### Local review stack (one command)

```bash
sh scripts/local_stack.sh
```

Starts the Docker MongoDB, starts the backend pointed at it, runs the e2e suite against that local DB, builds and serves the web app, and prints the review link. Prod database is never touched.

### Docker

**Build and run the backend:**

```bash
cd backend
docker build -t vehicle-tracker-api .
docker run -p 8010:8010 \
  -e MONGO_STORE_URL=http://host.docker.internal:8002 \
  -e APP_API_KEY=change-me \
  vehicle-tracker-api
```

**Or use Docker Compose (full stack):**

```bash
docker compose up
```

### Deploy to Render

1. Push backend Docker image to Docker Hub
2. Deploy backend as a Render Web Service using `render.yaml`
3. Build Flutter web: `flutter build web --dart-define=API_URL=https://your-backend.onrender.com --dart-define=API_KEY=your-key`
4. Deploy `build/web/` as a Render Static Site

## Project Structure

```
lib/
├── main.dart
├── app/app.dart                          # MaterialApp + theme + navigation
├── core/
│   ├── app_config.dart                   # API URL/key configuration
│   └── api_client.dart                   # HTTP client with retry logic
└── features/
    ├── records/
    │   ├── records_page.dart             # Records list with swipe-to-delete
    │   ├── records_repository.dart       # CRUD operations
    │   ├── service_record.dart           # ServiceRecord model
    │   └── check_step.dart               # CheckStep model
    ├── editor/
    │   ├── record_editor_page.dart       # Record editor form
    │   └── step_tile.dart                # Editable checklist tile
    ├── profile/
    │   ├── settings_page.dart            # Technician settings + dark mode
    │   ├── profile_repository.dart       # Profile CRUD
    │   └── technician.dart               # Technician model
    └── exports/
        ├── export_service.dart           # PDF + XLSX export entry point
        └── vehicle_service_record_pdf.dart # Styled PDF generator

backend/
├── app/
│   ├── main.py                           # FastAPI app + CORS
│   ├── config.py                         # Environment config
│   ├── storage.py                        # HTTP client for MongoDB API
│   ├── schemas.py                        # Pydantic models
│   ├── auth.py                           # API key auth
│   ├── defaults.py                       # Default checklist steps
│   └── routers/
│       ├── profile.py                    # Profile endpoints
│       └── records.py                    # Service record endpoints
├── Dockerfile
├── requirements.txt
└── .env.example
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check |
| `GET` | `/profile` | Get technician profile |
| `PUT` | `/profile` | Update technician profile |
| `GET` | `/service-records` | List all service records |
| `POST` | `/service-records` | Create a new service record |
| `GET` | `/service-records/{id}` | Get a service record |
| `PUT` | `/service-records/{id}` | Update a service record |
| `DELETE` | `/service-records/{id}` | Delete a service record |
| `POST` | `/chat` | Ask the AI assistant about service records |

All endpoints except `/health` require the `X-App-Key` header.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGO_URI` | *(empty)* | MongoDB Atlas connection string |
| `DB_NAME` | `mystore` | MongoDB database name |
| `COLLECTION` | `items` | MongoDB collection for all records |
| `APP_API_KEY` | `change-me` | API key for authentication |
| `OPENROUTER_API_KEY` | *(empty)* | OpenRouter key for AI chat (server-side only; unset → `/chat` returns 503) |
| `CHAT_MODEL` | `nvidia/nemotron-3.5-lightning:free` | OpenRouter model id used by `/chat` |
| `CORS_ALLOWED_ORIGINS` | `*` | Comma-separated allowed origins |

## Branch Update Workflow

Every change follows this workflow. **Tests are always real end-to-end (real backend, real database, real HTTP) — never mocked or faked. Test data never touches the production database.**

1. **Branch** off `main` (branches are never deleted)
2. **Implement** — each file under 100 lines, one feature per folder, SRP, clear names (see `BRANCH_UPDATE_RULES.md`)
3. **Local review** — `sh scripts/local_stack.sh` runs the e2e suite against the local Docker MongoDB, then serves a review link (local DB only)
4. **Push branch, open a PR**
5. **PR CI** — `pr-checks` workflow runs analyze, unit tests, and the same e2e against a throwaway dev MongoDB container
6. **All tests pass → PR auto-merges** to `main` (required status check, auto-merge enabled)
7. **Ship** — `deploy` workflow re-runs e2e on a fresh dev DB, then builds and pushes the Docker images (web image gets prod API config from GitHub secrets) and deploys both services to Render
8. **Prod e2e** — the same e2e tests run against production; the change is only "shipped" when prod passes

## CI/CD

Public repo — all credentials live in GitHub encrypted secrets, never in code:

| Secret | Used for |
|--------|----------|
| `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN` | Push images to Docker Hub |
| `RENDER_API_KEY` | Trigger and watch Render deploys |
| `PROD_API_URL` / `PROD_API_KEY` | Bake prod API config into the web image; run prod e2e |
| `OPENROUTER_API_KEY` | Enables the real LLM round-trip in the chat e2e; CI skips it when unset |

Local review and CI always point at a local/throwaway MongoDB. Production points at the prod MongoDB via Render's configured `MONGO_URI` — the pipeline never supplies a DB connection at deploy time.

## License

[MIT](LICENSE)

## Manage service types

Open **Settings → Manage service types** to add, edit, or delete a service type.
Each type saves its name and complete Daily/Weekly/Monthly template, including
components and their child items (title, instructions, readings, and notes).
Components are shared across the three frequencies; items belong to one frequency.
Use **Add todo** inside a component to open a bounded editor for the title,
instructions, readings, and notes. Each saved todo has explicit Edit and Delete
buttons; long titles stay on one line in the list.
Choose a saved type in the record editor to copy its checklist. Completion flags
and last-done dates start fresh. Existing records retain their saved names and
checklists when a type is renamed or deleted.

`/service-types` supports GET and POST; `/service-types/{id}` supports GET, PUT,
and DELETE. These new endpoints do not require authentication. Existing endpoint
behavior is unchanged. Types are stored in the `service_types` MongoDB collection.
The five built-in templates initialize on backend startup; deleted defaults stay
deleted. Names must be nonblank and unique without regard to case.

The isolated review stack defaults to API port 8021, web port 8092, and MongoDB
port 27027 with container `chat-gpt-tracker-mongo`. Override `API_PORT`, `WEB_PORT`,
`MONGO_PORT`, or `MONGO_CONTAINER` if needed. It does not stop other agents' servers.
Run `sh scripts/local_stack.sh`; its e2e suite includes full child-item persistence,
service-type CRUD, invalid input, and historical-record preservation against the
local database. Logs are in `/tmp/chat-gpt-tracker-logs`.

Browser regression: install Playwright in the backend venv, then run
`backend/.venv/bin/python backend/e2e_service_types_browser.py` with the local
review stack running. Set `BROWSER_WIDTH=390` to check the phone layout.
The test uses real Chrome, HTTP, and MongoDB to add multiple todos, edit them,
reload their saved fields, add another todo, and delete its test service type.

## AI Chat

The **Chat** tab (between Records and Settings) is a Markdown-capable AI
assistant backed by the backend `POST /chat` endpoint. The server loads the
latest service records from MongoDB, compresses them into a JSON brief (up to
the newest 50 records; checklist progress, notes, and next steps included) and
sends it as system context to **OpenRouter** — the key lives only on the server.

The assistant can also call backend tools to work with the data: search, list,
get, create, update, and delete service records, and list, get, create, update,
and delete service types. It decides when to call a tool and follows up with the
real results, so queries like "find the record about quokka" or "add a service
type named Oil Change" work against the live database.

Client behavior:

- Conversation history stays in the browser and is sent on each request (last 20 messages).
- Enter sends, Shift+Enter makes a newline.
- Assistant replies render as Markdown; a copy button is on each assistant bubble.
- Tracker theme applies (dark mode, bigger-text setting respected).

Endpoint behavior:

- Requires `X-App-Key` like all other endpoints (401 without it).
- `message` is required (422 if blank); `history` is an optional list of `{role, content}`.
- Without a server-side `OPENROUTER_API_KEY`, `/chat` returns 503 `Chat is not configured`.
- With a key, a real OpenRouter completion is returned as `{reply: "..."}` (502 on upstream failure).
