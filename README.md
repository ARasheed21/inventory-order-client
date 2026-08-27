# Inventory Order Client

Frontend monorepo for the **Inventory & Order Management System**: a shared Dart core, a
Flutter mobile customer app, and a Jaspr web admin/warehouse dashboard.

## Structure

| Package | Purpose |
|---|---|
| `core/` | Shared business logic: domain entities/repositories, data layer, design tokens, strings |
| `app/`  | Flutter mobile customer client (Android 8.0+ per FR-016) |
| `web/`  | Jaspr web dashboard (latest two versions of Chrome/Firefox/Edge/Safari) |

Governed by [.specify/memory/constitution.md](.specify/memory/constitution.md) — read it before
contributing.

## Quick start

```powershell
# 1. Install prerequisites: Flutter SDK (stable), Docker Desktop
dart pub global activate melos

# 2. Bootstrap the workspace
melos bootstrap

# 3. Create your environment file (never commit it)
Copy-Item .env.example .env

# 4. Start the local backend container (FR-017)
docker compose -f docker/docker-compose.yml up -d

# 5a. Run the mobile client (from /app)
flutter run --dart-define-from-file=config.env
#    (copy .env to app/config.env first — same schema)

# 5b. Run the web client (from /web)
cp web/env.example.json web/web/env.json   # adjust values as needed
jaspr serve
```

## Common tasks

```powershell
melos analyze       # analyzer across all packages (must be clean)
melos format        # formatting check
dart test           # core unit tests (run from core/)
flutter test        # widget tests (run from app/)
```

## Quality gates

CI blocks merges on: analyzer findings, formatting diffs, failing tests, `core` coverage below
**75%**, non-Conventional-Commit messages, and any import of internal core modules (clients must
use `package:core/core.dart` only).

## Contracts

Clients are contract-driven: REST via [`contracts/api/openapi.yaml`](contracts/api/openapi.yaml),
real-time via [`contracts/ws/asyncapi-ws.md`](contracts/ws/asyncapi-ws.md). Never infer backend
behavior from backend source code.

