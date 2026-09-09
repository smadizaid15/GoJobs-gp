# GoJobs — Target Architecture

Status: **Proposed, not yet implemented.** This is the architecture Phases 1-15 build toward. See `docs/ROADMAP.md` for the sequencing and `docs/architecture/EXISTING_SYSTEM.md` for the current state this replaces.

## Design principles

1. **The client is untrusted.** Nothing the Flutter app sends — role, uid, ownership claims, document IDs — is authoritative. The backend independently re-derives and verifies every authorization decision.
2. **Smallest viable production architecture, not a disposable MVP.** Every first-release component (auth, authz, validation, rate limiting, logging, monitoring, backups, CI/CD, rollback) is production-grade from day one, sized for current scale — not a placeholder to be replaced later.
3. **Modular monolith, not microservices.** One Node.js/TypeScript/Express service. Internal module boundaries (jobs, applications, users, notifications, admin) are kept clean enough to extract later if a real scaling/team boundary ever justifies it — but nothing is decomposed pre-emptively.
4. **Firestore stays.** The audit found no workload evidence (see `docs/database/DATABASE_DESIGN.md`) that justifies replacing Firestore with a relational database. Its query patterns (owner-scoped `where` clauses, simple filters) map cleanly onto what GoJobs actually needs.
5. **Managed infrastructure wherever practical.** Cloud Run over self-managed containers/VMs; Firebase-managed Auth/Storage/FCM over self-hosted equivalents; Google Secret Manager over hand-rolled secret handling.

## Diagram

```
                         ┌─────────────────────────────┐
                         │   Flutter Mobile Apps        │
                         │   (Android / iOS / Web)      │
                         │   — no authoritative logic —  │
                         └──────────────┬───────────────┘
                                        │ HTTPS
                                        ▼
                         ┌─────────────────────────────┐
                         │  Firebase Authentication      │
                         │  (issues ID tokens)           │
                         └──────────────┬───────────────┘
                                        │ ID token on every request
                                        ▼
                         ┌─────────────────────────────┐
                         │      Firebase App Check        │
                         │ (attests request comes from the │
                         │  real app, not a script/emulator)│
                         └──────────────┬───────────────┘
                                        │
                                        ▼
                 ┌──────────────────────────────────────────┐
                 │        API — Node.js + TypeScript + Express│
                 │        Cloud Run, stateless, /api/v1/...    │
                 │                                              │
                 │  Route → AuthN mw → AuthZ mw → Validation(Zod)│
                 │        → Controller → Service → Repository   │
                 └───────────────┬─────────────────┬────────────┘
                                 │                 │
                    ┌────────────▼──────┐   ┌──────▼─────────────┐
                    │  Business Logic     │   │  Background Jobs    │
                    │  (Services layer)   │   │  (notif fan-out,     │
                    │                      │   │   moderation, cleanup)│
                    └────────────┬─────────┘   └──────┬─────────────┘
                                 │                    │
                    ┌────────────▼──────┐   ┌─────────▼─────────────┐
                    │  Cloud Firestore    │   │  Cloud Storage          │
                    │  (Repository layer  │   │  (signed URLs / backend- │
                    │   only writes here) │   │   mediated uploads)      │
                    └────────────┬─────────┘  └─────────┬───────────────┘
                                 │                       │
                    ┌────────────▼───────────────────────▼────────────┐
                    │ Firestore/Storage Security Rules (deny-by-default,│
                    │ defense-in-depth behind the backend, rule-tested  │
                    │ via the Local Emulator Suite)                     │
                    └───────────────────────────────────────────────────┘

Supporting: GitHub + GitHub Actions (CI/CD) · Docker (API image) · Google Cloud Run (hosting)
· Google Cloud Logging/Monitoring · Firebase Crashlytics · Firebase Cloud Messaging
· Google Secret Manager · automated tests (unit/integration/security/e2e) · dependency & secret scanning
```

## Component-by-component target

### Mobile/Web client (Flutter)

- Keeps the existing Flutter codebase as its foundation (per the brief: audit, don't discard). Consolidated toward a feature-oriented `lib/` structure (`core/`, `features/{auth,jobs,applications,profile}/{data,domain,presentation}`), adapted incrementally rather than rewritten wholesale — see Phase 7 in `ROADMAP.md`.
- All security-sensitive writes (job create/delete, application status changes, profile role fields) move from direct Firestore calls to calls against the new `/api/v1/...` backend. Read-heavy, non-sensitive operations (browsing active jobs, own-profile reads) may continue to read Firestore directly via the client SDK, gated by rewritten deny-by-default Security Rules — this keeps the architecture from forcing every single read through the API unnecessarily.
- The Groq AI key moves out of the client entirely (`lib/config/api_config.dart` is deleted); AI features call a new backend endpoint that holds the key server-side (Secret Manager).
- File uploads (CVs, profile pics, portfolio images) move to backend-issued signed URLs or backend-mediated upload endpoints, with server-side size/MIME/extension enforcement — the client no longer writes directly to arbitrary Storage paths.
- Never embeds: database credentials, service-account keys, admin credentials, or any third-party API secret.

### Authentication

- Firebase Authentication remains the identity provider (email/password today; the audit found no compelling reason to replace it — see `EXISTING_SYSTEM.md` §5).
- Every backend request carries a Firebase ID token (`Authorization: Bearer <token>`); a dedicated Express middleware verifies it server-side via the Firebase Admin SDK on every request to a protected route. No backend route trusts a client-supplied uid, role, or email — those are read from the verified token/custom claims only.
- Firebase App Check is added at the client and enforced at the API edge to reject traffic that isn't the genuine app (mitigates scripted abuse independent of valid-but-stolen tokens).

### Authorization

- Role (`JOB_SEEKER` / `EMPLOYER` / `ADMIN`) is stored as a Firebase custom claim (set only by trusted backend/admin code, never client-writable) plus mirrored on the `users/{uid}` Firestore doc for query convenience — the custom claim, not the Firestore field, is the authoritative source the backend checks.
- Every mutating endpoint re-derives ownership server-side before acting: job mutations check `job.companyId === request.auth.uid`; application status changes check `application.companyId === request.auth.uid`; profile updates check `uid === request.auth.uid` and apply a field allowlist that excludes `role`/`userType`.
- Firestore/Storage Security Rules are rewritten from (effectively) nothing to **deny-by-default**, mirroring the same ownership checks as defense-in-depth for the reads/writes the client SDK still performs directly, and are unit-tested via the Firebase Local Emulator Suite in CI.

### API design

- `/api/v1/...`, versioned from day one. Consistent JSON error shape (`{success:false, error:{code, message, requestId}}`), never leaking stack traces, internal paths, or Firestore internals in responses.
- Layered request flow (Route → AuthN → AuthZ → Validation → Controller → Service → Repository → Firestore) — controllers stay thin, business rules live in services, all Firestore access is confined to repositories (no Firestore calls scattered through controllers, unlike today's inline-in-screens pattern).
- Zod schemas validate body/query/path/headers on every endpoint before business logic runs; explicit max-lengths on all free-text fields (titles, descriptions, locations, search terms).

### Background jobs

- Notification fan-out, FCM token cleanup, and any future moderation/cleanup tasks run as scheduled/async work (Cloud Run jobs or Cloud Scheduler-triggered endpoints), not inline in the request/response cycle. No message queue is introduced pre-emptively — current volume doesn't justify one; the architecture keeps this swappable later.

### Storage

- Cloud Storage remains (large binary files never belong in Firestore). All upload paths are backend-mediated or signed-URL-based, with server-side size caps, MIME/extension validation independent of client claims, and safe (randomized) filenames. Storage Security Rules deny direct client writes outside a user's own signed-URL grant.

### Notifications

- FCM remains for push. Token registration is fixed to actually persist (today's `saveTokenToFirestore()` is a non-functional stub); fan-out moves to a backend/background job that handles invalid-token cleanup, retries, and per-user notification preferences — not triggered synchronously inside unrelated request handlers.

### Observability

- Backend: Google Cloud Logging (structured JSON logs — timestamp, requestId, endpoint, method, status, duration, userId where relevant, error code; never passwords/tokens/keys) and Google Cloud Monitoring (latency, error-rate, uptime dashboards + alert thresholds).
- Mobile: Firebase Crashlytics (currently entirely absent).
- Health endpoints: `GET /health` (process alive), `GET /ready` (dependencies reachable) — no sensitive diagnostic detail in public responses.

### AI architecture (provider-agnostic by design)

**Do not commit to a specific AI provider.** The audit found the current implementation calls Groq directly from the Flutter client with a hardcoded API key (`SECURITY_AUDIT.md` H-1) — that must be fixed regardless of which provider ends up backing it long-term, and the fix should not accidentally lock the product into Groq specifically. Target design:

```
Flutter client
   │  POST /api/v1/ai/chat, /api/v1/ai/match-score, /api/v1/ai/job-description, /api/v1/ai/interview-prep
   ▼
Backend AI routes (auth + rate limiting, per-user/IP quotas — this is the app's own
abuse surface: every call costs the backend money at a third-party provider)
   ▼
AIProvider interface (backend-internal abstraction)
   │
   ├─ GroqProvider        (hosted, OpenAI-compatible chat-completions API — today's default)
   ├─ OpenAIProvider       (hosted, same interface shape, swap via config)
   ├─ SelfHostedProvider   (e.g. an Ollama/vLLM endpoint the team runs, same interface)
   └─ GoJobsFineTunedProvider (future — a model fine-tuned on GoJobs' own job/application
                                data, served however the team chooses once it exists)
```

- **`AIProvider` interface** (backend TypeScript): a single method shape every implementation conforms to, roughly `generate({prompt, maxTokens, temperature}): Promise<string>` plus whatever structured-output variant the match-score/interview-prep features need. Which concrete provider is active is a **runtime config value** (environment variable / Secret Manager entry), not a code branch scattered through the app — swapping providers means changing config, not shipping a new client build.
- **The Flutter client never holds a provider API key of any kind, for any provider, ever.** It only ever calls the GoJobs backend's own `/api/v1/ai/*` endpoints with its normal Firebase ID token. This is true today (Groq) and must remain true if/when the provider changes or a self-hosted/fine-tuned model is introduced later — the abstraction exists specifically so that transition never requires touching client code or, worse, embedding a new key in the client again.
- **Rate limiting lives at the backend AI routes**, not per-provider — since every provider call has a real cost, this is one of the "sensitive endpoints" the brief calls out for abuse protection (brief §18), independent of which provider is behind it.
- **Self-hosted/fine-tuned readiness**: the interface is deliberately provider-shape-agnostic (a plain prompt/response contract) rather than modeling Groq's or OpenAI's specific request schema as the "native" shape — this is what makes swapping in a self-hosted open-source model or a future GoJobs-specific fine-tuned model a config change and a new `AIProvider` implementation, not a rewrite of the four AI features' business logic.
- **No provider decision is being made now.** Groq remains the default until there's a concrete reason to change (cost, quality, latency, or a fine-tuned model becoming available) — this section only ensures that whenever that decision happens, it's a backend config/implementation change, never a client-side one.

### Deployment

- API: Docker image → Google Cloud Run, stateless (no local-disk state, no single-instance assumptions), horizontally scalable by construction. Non-root container user, minimal base image, deterministic dependency install, graceful shutdown handling.
- CI/CD: GitHub Actions — PR checks (lint, unit+integration tests, security checks, build) → staging deploy + automated smoke tests → manual-approval production deploy + smoke tests + monitoring. Every production deploy is reversible (Cloud Run revision rollback).

## What this target deliberately avoids

Per the brief's explicit anti-over-engineering guidance, and because nothing in the audit's findings justifies it at current scale:

- No microservices — one Express service with clean internal module boundaries.
- No Kubernetes/service mesh — Cloud Run is sufficient for a stateless HTTP API at this scale.
- No message queue/Kafka — background jobs use Cloud Run jobs/Cloud Scheduler; revisit only if async volume grows enough to need it.
- No Redis/cache layer — add only if load testing (Phase 16) demonstrates a real need.
- No dedicated search engine (Elasticsearch/Algolia) — Firestore queries are evaluated first; an abstraction is left in place so one can be introduced later if search requirements outgrow it (see `DATABASE_DESIGN.md`).
- No relational database migration — Firestore's access patterns fit GoJobs' actual query shapes.
