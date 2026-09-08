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
# Clone with the OpenAPI contracts submodule:
# git clone --recurse-submodules <repo-url>
dart pub global activate melos 6.3.0

# 2. Bootstrap the workspace
dart pub get
melos bootstrap

# 3. Create the Flutter compile-time environment file (never commit it)
Copy-Item .env.example app\config.env

# 4. Start the local OpenAPI-backed test backend (FR-017)
docker compose -f docker/docker-compose.yml up -d --build --wait

# 5a. Run the mobile client on an Android emulator (from /app)
#     Android reaches Docker on the host through 10.0.2.2.
cd app
flutter run -d emulator-5554 --dart-define-from-file=config.env `
	--dart-define=API_BASE_URL=http://10.0.2.2:8080 `
	--dart-define=WS_URL=ws://10.0.2.2:8080/api/ws/websocket

# 5b. Run the web client (from /web)
cd ..\web
Copy-Item env.example.json env.json
jaspr serve

# 5c. Run Android integration tests
cd ..\app
flutter test integration_test -d emulator-5554 `
	--dart-define-from-file=config.env `
	--dart-define=API_BASE_URL=http://10.0.2.2:8080 `
	--dart-define=WS_URL=ws://10.0.2.2:8080/api/ws/websocket
```

## Common tasks

```powershell
melos analyze       # analyzer across all packages (must be clean)
melos format        # formatting check
melos run test      # core/web Dart tests
melos run flutter_test # Flutter widget tests
```

## Quality gates

CI blocks merges on: analyzer findings, formatting diffs, failing tests, `core` coverage below
**75%**, non-Conventional-Commit messages, and any import of internal core modules (clients must
use `package:core/core.dart` only).

## Contracts

Clients are contract-driven: REST via [`contracts/api/openapi.yaml`](contracts/api/openapi.yaml),
real-time via [`contracts/ws/asyncapi-ws.md`](contracts/ws/asyncapi-ws.md). Never infer backend
behavior from backend source code.

