# Vehicle Maintenance Tracker

A full-stack vehicle service record management app built with **Flutter** (frontend) and **FastAPI** (backend), backed by **MongoDB** via a REST API.

## Features

- **Service Records** — Create, edit, and delete vehicle inspection records
- **Inspection Checklist** — Customizable checklist items with done/pending status, values, and notes
- **Technician Profile** — Store technician name, phone, and email
- **PDF Export** — Styled PDF reports with branded colors, info tables, and checklist
- **XLSX Export** — Spreadsheet export with summary and checklist tabs
- **Dark Mode** — Toggle between light and dark themes
- **Swipe to Delete** — Swipe or tap to delete records with confirmation

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

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.10
- [Python 3.12+](https://www.python.org/downloads/)
- [Docker](https://docs.docker.com/get-docker/) (optional, for containerized deployment)

### Local Development

**1. Start the MongoDB storage service** (or point to an existing instance)

**2. Start the backend:**

```bash
cd backend
pip install -r requirements.txt
MONGO_STORE_URL=http://127.0.0.1:8002 APP_API_KEY=change-me uvicorn app.main:app --host 0.0.0.0 --port 8010
```

**3. Run the Flutter app:**

```bash
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://localhost:8010 --dart-define=API_KEY=change-me
```

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

All endpoints except `/health` require the `X-App-Key` header.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGO_URI` | *(empty)* | MongoDB Atlas connection string |
| `DB_NAME` | `mystore` | MongoDB database name |
| `COLLECTION` | `items` | MongoDB collection for all records |
| `APP_API_KEY` | `change-me` | API key for authentication |
| `CORS_ALLOWED_ORIGINS` | `*` | Comma-separated allowed origins |

## Branch Update Workflow

Every change follows this workflow. **Tests are always real end-to-end (real backend, real database, real HTTP) — never mocked or faked.**

1. **Branch** off `main` (branches are never deleted)
2. **Implement** — each file under 100 lines, one feature per folder, SRP, clear names (see `BRANCH_UPDATE_RULES.md`)
3. **Local end-to-end tests pass** (real API round-trips, real database writes, `flutter build` clean)
4. **Push branch, open a PR**
5. **Merge the PR** to `main`
6. **Build + push the Docker image(s), deploy to Render**
7. **Run the same tests against production** — a change is only "shipped" when prod passes the same end-to-end tests

## License

[MIT](LICENSE)
