# Environment Configuration Contract

**Branch**: `001-project-foundation` | **Date**: 2026-08-25

Environment-specific values are provided via `.env` files excluded from version control
(FR-014). `.env.example` is committed as the authoritative schema; real files are created per
environment and injected via pipeline secrets.

## Variables

| Variable | Required | Example | Used by |
|---|---|---|---|
| `API_BASE_URL` | yes | `http://localhost:8080` | REST client (both clients) |
| `WS_URL` | yes | `ws://localhost:8080/api/ws` | Real-time channel (both clients) |
| `SENTRY_DSN` | release: yes, dev: no | `https://key@sentry.io/project` | Crash reporting binding |
| `CERT_PINS` | release: yes, dev: no | Comma-separated SHA-256 SPKI pins | Release certificate pinning (mobile + web) |
| `APP_ENV` | yes | `dev` \| `staging` | Logging verbosity, cert-pinning bypass in dev |

## Rules

1. No environment value may be hard-coded in source; missing required values MUST abort
   startup with a clear message naming the variable.
2. `.env.example` MUST always reflect the full current schema; CI fails if a consumed variable
   is absent from it.
3. Secrets (Sentry DSN, any future keys) are stored only in GitHub Secrets / local untracked
   files — never committed.
4. Web builds receive values at build time (compile-time substitution); mobile reads at
   runtime via bundled asset/env loading.
