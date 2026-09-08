# Quickstart: Project Foundation

**Branch**: `001-project-foundation`

Validate the foundation end-to-end: workspace setup, both clients running against a local
backend, quality gates passing.

## Prerequisites

- Dart/Flutter SDK (stable) and Jaspr CLI
- Docker (for the local backend container)
- A GitHub account with access to repo secrets for pipeline verification (optional)

## 1. Workspace setup (< 15 minutes total, SC-001)

```powershell
git clone --recurse-submodules <repo-url>
cd inventory-order-client
dart pub global activate melos 6.3.0
dart pub get
melos bootstrap
Copy-Item .env.example app\config.env
```

## 2. Launch the local backend

```powershell
docker compose -f docker/docker-compose.yml up -d --build --wait
# REST auth/health -> http://localhost:8080
# WebSocket behavior requires the real backend; it is not part of this mock.
```

The service is a local mock that loads `contracts/api/openapi.yaml` at startup and
implements the authentication operations required by the integration tests.

Verify: `GET http://localhost:8080/actuator/health` returns `{"status":"UP"}`.

## 3. Run the mobile client

```powershell
cd app
flutter run -d emulator-5554 --dart-define-from-file=config.env `
   --dart-define=API_BASE_URL=http://10.0.2.2:8080 `
   --dart-define=WS_URL=ws://10.0.2.2:8080/api/ws/websocket
```

For a physical Android device, replace `10.0.2.2` with the host machine's LAN IP.

## 4. Run the web client

```powershell
cd ..\web
Copy-Item env.example.json env.json
jaspr serve                     # open the printed URL in a browser
```

## 5. Run the Android integration suite

```powershell
cd ..\app
flutter test integration_test/auth_flow_test.dart integration_test/error_recovery_test.dart `
   -d emulator-5554 `
   --dart-define-from-file=config.env `
   --dart-define=API_BASE_URL=http://10.0.2.2:8080 `
   --dart-define=WS_URL=ws://10.0.2.2:8080/api/ws/websocket
```

Expected result: all four integration tests pass.

## 6. Exercise the plumbing (Story 3 scenarios)

1. Register/log in through the auth shell → restart app → still logged in (secure storage).
2. Let the access token expire (or shorten TTL in backend config) → any request renews
   silently.
3. Stop the backend container → trigger an action → friendly categorized error with retry;
   start the container → retry succeeds.
4. With a second session, change an order → first session's screen updates within ~2s without
   manual refresh.

## 7. Quality gates

```powershell
melos analyze        # analyzer across all packages
melos format         # format check
melos run test       # core/web Dart tests
melos run flutter_test # Flutter widget tests
```

All must pass locally before opening a PR; CI enforces the same gates and blocks merges on
failure.

## 8. Release build sanity check

```powershell
cd app; flutter build apk --obfuscate --split-debug-info=build/symbols   # hardened mobile artifact
cd ../web; jaspr build -O 2                                               # optimized web build
```

