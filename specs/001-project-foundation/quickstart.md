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
git clone <repo-url> && cd inventory-order-client
melos bootstrap                 # installs/link all package dependencies
Copy-Item .env.example .env     # then edit if your backend runs elsewhere
```

## 2. Launch the local backend

```powershell
docker compose -f docker/docker-compose.yml up -d
# REST  -> http://localhost:8080
# WS    -> ws://localhost:8080/api/ws
```

Verify: `GET http://localhost:8080/api/inventory/products` returns 200.

## 3. Run the mobile client

```powershell
cd app; flutter run             # placeholder home + auth shell on emulator/device (Android 8+)
```

## 4. Run the web client

```powershell
cd web; jaspr serve             # open printed URL in Chrome/Firefox/Edge/Safari
```

## 5. Exercise the plumbing (Story 3 scenarios)

1. Register/log in through the auth shell → restart app → still logged in (secure storage).
2. Let the access token expire (or shorten TTL in backend config) → any request renews
   silently.
3. Stop the backend container → trigger an action → friendly categorized error with retry;
   start the container → retry succeeds.
4. With a second session, change an order → first session's screen updates within ~2s without
   manual refresh.

## 6. Quality gates

```powershell
melos run lint        # analyzer across all packages
melos run format      # format check
melos run test        # unit + widget + component tests; core coverage >= 75%
```

All must pass locally before opening a PR; CI enforces the same gates and blocks merges on
failure.

## 7. Release build sanity check

```powershell
cd app; flutter build apk --obfuscate --split-debug-info=build/symbols   # hardened mobile artifact
cd ../web; jaspr build --release                                         # minified web build
```
