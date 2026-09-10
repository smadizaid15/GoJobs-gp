# GoJobs — Migration Roadmap (Phase 0 → 19)

Status: proposed sequencing for turning the audited codebase (`docs/architecture/EXISTING_SYSTEM.md`) into the target architecture (`docs/architecture/TARGET_ARCHITECTURE.md`). Each phase is scoped to be independently reviewable and revertible — per the brief's explicit instruction, work proceeds in controlled phases with a stop-and-report at the end of each, not as one continuous rewrite. **Only Phase 0 is executed as of this document's creation.** Every later phase requires its own explicit go-ahead before work begins.

---

## PHASE 0 — Audit

- **Objective**: Understand the existing system without changing it; produce the baseline documentation set this roadmap is part of.
- **Prerequisites**: none.
- **Tasks**: repository-wide read-only investigation (Flutter app, absence of a backend, Firebase config, CI/CD, tests, dependencies, secrets); produce the 9 documents under `docs/`.
- **Files affected**: `docs/architecture/EXISTING_SYSTEM.md`, `docs/architecture/TARGET_ARCHITECTURE.md`, `docs/architecture/ENVIRONMENTS.md`, `docs/database/DATABASE_DESIGN.md`, `docs/security/SECURITY_AUDIT.md`, `docs/security/OWASP_CHECKLIST.md`, `docs/product/FEATURE_MATRIX.md`, `docs/operations/PRODUCTION_READINESS.md`, `docs/ROADMAP.md` (this file) — no application code touched.
- **Tests**: N/A (documentation only).
- **Security requirements**: none introduced; findings documented for later phases to act on.
- **Acceptance criteria**: all 9 documents exist, are internally consistent, and every claim is backed by a specific file:line citation or explicitly marked as unverifiable from source.
- **Rollback**: trivial — delete `docs/` if the audit needs to be redone; no other part of the system is affected.
- **Dependencies on previous phases**: none — this is the starting point.

---

## PHASE 1 — Foundation

- **Objective**: Lay groundwork that every later phase depends on, without yet touching security-sensitive logic: fix the cheap, high-value production blockers found in Phase 0 that don't require the backend to exist first, and establish base tooling.
- **Prerequisites**: Phase 0 complete and reviewed.

### Status as of 2026-09-09

**Done and pushed (Phase 0 commit `1f2d2c2c`, plus a separately-approved production rules deploy):**
- H-1 closed: `lib/config/api_config.dart` holds no real key; `ai_service.dart` fails clearly on a missing key before any network call.
- `applications` field-shape unification (was 3 incompatible shapes; job-seeker and student apply flows now write the same `userId`/lowercase-`status`/always-present-`companyId` shape the rules expect).
- `freelancer_requests` ownership-field immutability + status-enum fix (the C-9 pattern, previously missed for this collection).
- `/student/upload-cv` routing fix — `state.extra` now actually reaches the screen, so applications record a real `companyId` instead of a fallback.
- `firestore.rules` (corrected version, including all of the above) deployed to production `gojobs-187af`, verified.
- 131-case emulator regression suite committed, passing.
- Full Phase 0 documentation set committed.

**Not yet done** (remainder of this phase, requires separate approval before implementation — see the Decisions list in the Phase 1 design-pass report):
- Fix Android release signing (`android/app/build.gradle.kts`) — real keystore, secrets-managed, not the debug fallback.
- Fix default `applicationId`/bundle ID on Android and iOS (target values now specified in `docs/architecture/ENVIRONMENTS.md`'s flavor table).
- Add missing iOS `Info.plist` usage-description keys for camera/photo library.
- Correct the README's inaccurate gitignore claim.
- Delete confirmed-dead code: `lib/services/api_service.dart`, empty `lib/services/chat_service.dart`, dead `StorageService` methods, empty `lib/widgets/*` stubs (still deferred to Phase 7 to avoid churn).
- **Deploy `storage.rules`** (the corrected version with `company_logos`/`job_images`/`portfolio_images` coverage is written locally and tested but was never deployed this session — only `firestore.rules` was, per the explicit scoping of that approval). Storage is still running the 2026-09-08 interim version, which is missing those three prefixes.

**Done, on branch `feature/phase1-engineering-foundation`, not yet merged or pushed (2026-09-09 engineering-foundation implementation batch):**
- Toolchain pinned: `.fvmrc` (Flutter `3.44.2`), `.nvmrc` (Node `24.21.0`), explicit `compileSdk`/`targetSdk`/`minSdk` (36/36/24) in `android/app/build.gradle.kts`.
- `flutter analyze` and `flutter test` restored as real CI gates (see below) — the pre-existing failing smoke test blocker is resolved, not skipped.
- `test/widget_test.dart` replaced with `test/theme_provider_test.dart` — see "CI/CD and test-suite changes" below for why the original template test could not simply be patched.
- `.github/workflows/main.yml` (the unconditional Docker Hub publish workflow) removed — it could bake `API_CONFIG_DART` into a published image on every push to `main`, which is unacceptable as a "production pipeline" and was never gated by any test. No replacement deploy workflow has been created; deploys remain manual and explicitly approved, same as every rules deploy so far in this engagement.
- `.github/workflows/non-functional.yml` renamed to `ci.yml` and converted into the Phase 1 CI foundation from `docs/operations/CI_CD.md`: exact-pinned Flutter `3.44.2`, `dart format` check, `flutter analyze`, `flutter test`, `flutter build apk --debug`, plus the 133-case Firebase emulator security-rules suite on Node `24.21.0`. Still verification-only — no deploy, no publish, no secrets consumed.

### Phase 1 foundation design pass (2026-09-09) — documentation only, nothing implemented

Produced this session, per explicit scope ("foundation only," no feature migration, no scaffolding created yet):
- `docs/architecture/TARGET_ARCHITECTURE.md` — expanded to explicitly cover every live product domain (auth, users/profiles, jobs, applications, companies, messaging/chat, notifications, student/internships, freelancer marketplace, courses/workshops, search/filtering, saved jobs, AI integration layer), a proposed backend folder structure, and a tightened AI provider abstraction section.
- `docs/architecture/ENVIRONMENTS.md` — expanded with concrete Android/iOS flavor identifiers, backend environment variables, secrets handling, and an explicit "preventing accidental production access" design.
- `docs/architecture/DEVELOPMENT_WORKFLOW.md` (new) — branch strategy (`main`/`develop`/`feature`/`fix`/`hotfix`) and a full toolchain audit + pinning proposal.
- `docs/operations/CI_CD.md` (new) — current CI/CD audit (re-confirmed: no test/lint gate, floating Flutter version, a deleted `test-and-build` job) and the proposed minimal Phase 1 CI foundation.

None of the above creates a `develop` branch, a `.fvmrc`, a `services/api/` directory, GitHub branch protection, or any new Firebase project — all of that is proposed and awaits explicit approval, tracked as decisions in the design-pass report.

- **Files affected**: `lib/config/api_config.dart` (done), `lib/services/ai_service.dart` (done), `firestore.rules` (done, deployed), `firebase-emulator-tests/` (done), plus this design pass's four documentation files. Still to touch: `android/app/build.gradle.kts`, `ios/Runner/Info.plist`, `ios/Runner.xcodeproj/project.pbxproj`, `README.md`, new `.fvmrc`/`.nvmrc`, `.github/workflows/*.yml`, `lib/services/api_service.dart` (delete).
- **Tests**: `flutter analyze` clean on everything touched so far; 131/131 emulator suite; full-project `flutter analyze`/`flutter test` still show the pre-existing baseline (52 lint issues, 1 failing smoke test) since those are explicitly deferred, not silently ignored.
- **Security requirements**: H-1 closed. `firestore.rules` deployed; `storage.rules` deploy still pending (see above).
- **Acceptance criteria**: a release build can be produced that Play Console/App Store Connect would accept on technical grounds — not yet met (signing/bundle ID/permissions still open).
- **Rollback**: each remaining task is independently revertible via git; signing/bundle-ID changes are the highest-care items — coordinate before changing if any build has already been distributed.
- **Dependencies on previous phases**: Phase 0 findings drive every task here directly.

---

## PHASE 2 — Environments

- **Objective**: Establish isolated dev/staging/production Firebase+GCP projects per `docs/architecture/ENVIRONMENTS.md`.
- **Prerequisites**: Phase 1 complete. **Resolved 2026-09-08**: `gojobs-187af` is promoted in place to `gojobs-production` (owner decision, recorded in `ENVIRONMENTS.md`) — this phase only needs to create the new `gojobs-dev`/`gojobs-staging` projects, not migrate data out of the existing one. Because the existing project carries this decision forward as "production," confirming and hardening its live Firestore/Storage rules (`SECURITY_AUDIT.md` C-3) is a hard prerequisite for calling this phase done, not deferrable to Phase 4.
- **Tasks**: create `gojobs-dev`/`gojobs-staging` Firebase projects; confirm and, if needed, immediately tighten the live rules on `gojobs-187af`/`gojobs-production` ahead of the full Phase 4 rewrite; configure Flutter build flavors (`dev`/`staging`/`production`) with per-environment `flutterfire configure` output; set up IAM so dev/staging service accounts have zero access to production; wire environment-specific secrets into GitHub Actions.
- **Files affected**: new `android/app/src/{dev,staging,production}/` flavor dirs, new iOS schemes, `lib/firebase_options_{dev,staging,production}.dart` (or an environment-selecting equivalent), `.firebaserc`, CI workflow updates.
- **Tests**: a dev-flavor build boots against `gojobs-dev` and a staging-flavor build boots against `gojobs-staging`, verified by checking which project each build's Firestore reads/writes land in.
- **Security requirements**: confirmed IAM isolation between projects (a dev service account key must not decrypt/access anything in staging or production).
- **Acceptance criteria**: three installable app variants exist side-by-side on one test device, each unambiguously connected to its own backend project (distinct icon/name badge per flavor).
- **Rollback**: new projects can be deleted without affecting the existing single-project setup if this phase needs to be abandoned; flavor config changes are additive, not destructive, to the existing default build.
- **Dependencies**: Phase 1 (stable client to branch flavors from).

---

## PHASE 3 — Authentication

- **Objective**: Introduce server-side verification of Firebase ID tokens — the first piece of the backend, and the prerequisite for every authorization fix in Phase 4.
- **Prerequisites**: Phase 2 (need a dev environment to build the backend against safely).
- **Tasks**: scaffold the Node.js/TypeScript/Express project (`services/api/` per target structure); add Firebase Admin SDK; write the ID-token-verification middleware; add `GET /health`/`GET /ready` endpoints; containerize with a minimal Dockerfile; deploy a skeleton to Cloud Run (dev environment only at this stage).
- **Files affected**: new `services/api/` tree (`src/middleware/auth.ts`, `src/server.ts`, `package.json`, `tsconfig.json`, `Dockerfile`), CI workflow additions for the new service.
- **Tests**: unit tests for the auth middleware (valid token → passes with decoded claims attached; missing/expired/malformed/tampered token → 401); integration test hitting `/health` unauthenticated and a protected test route with/without a valid token.
- **Security requirements**: tokens verified via Admin SDK (not manually decoded/trusted); no route yet does anything with the verified identity beyond exposing it to later middleware — this phase only proves "who is this," not "what may they do" (that's Phase 4).
- **Acceptance criteria**: a request with a valid ID token from a real dev-environment user reaches a protected test endpoint; a request with no token, an expired token, or a token from a different Firebase project is rejected with a consistent error shape.
- **Rollback**: the backend doesn't yet handle any real traffic — deploy can be torn down without affecting the (still fully client-direct) mobile app, which hasn't been repointed at it yet.
- **Dependencies**: Phase 2 (dev environment to target).

---

## PHASE 4 — Authorization

- **Objective**: Close SECURITY_AUDIT.md C-1, C-2, C-3, M-2, M-3 — server-side ownership/role checks, plus the Firestore/Storage rules rewrite as defense-in-depth.
- **Prerequisites**: Phase 3 (need verified identity to authorize against).
- **Tasks**: implement authorization middleware/helpers (ownership check for jobs/applications, role check via custom claims); write and deploy `firestore.rules`/`storage.rules` (deny-by-default, per the model in `DATABASE_DESIGN.md`); set up the Firebase Local Emulator Suite; write automated rule tests (positive + negative cases for every collection); confirm the live rules on `gojobs-187af`/production project (the Open Question from `ENVIRONMENTS.md`) and tighten immediately if found permissive, independent of the rest of this phase's timeline.
- **Files affected**: `firestore.rules`, `storage.rules`, `firestore.indexes.json` (new, all repo root or `infrastructure/firebase/`), new `services/api/src/middleware/authz.ts`, new rule-test suite (`firebase-emulator-tests/` or similar), CI workflow to run emulator-based rule tests on every PR.
- **Tests**: rule emulator tests — for every collection, assert an owner can read/write their own data and a different authenticated user is denied; assert an unauthenticated request is denied everywhere rules require auth; backend unit tests for ownership-check helper functions.
- **Security requirements**: this phase directly closes C-1/C-2/C-3/M-2/M-3 from `SECURITY_AUDIT.md` — treat it as the highest-priority phase after Foundation/Environments/Auth are in place.
- **Acceptance criteria**: emulator rule tests pass in CI; a manual test confirms a non-owner's attempt to delete another company's job or change another company's application status is rejected (both via the new backend and, redundantly, via rules if the client SDK path is still reachable at all at this point).
- **Rollback**: rules deploys are versioned and can be redeployed to a previous version via `firebase deploy --only firestore:rules` if a rule proves too restrictive and breaks legitimate traffic — test in staging first, always.
- **Dependencies**: Phase 3.

---

## PHASE 5 — Database

- **Objective**: Formalize the Firestore schema or so it's no longer purely implicit in client code, add missing indexes, and begin migrating writes behind the backend.
- **Prerequisites**: Phase 4 (rules must exist before loosening what the client can do directly).
- **Tasks**: commit `firestore.indexes.json` covering the composite queries identified in `DATABASE_DESIGN.md`; add pagination (`.limit()` + cursors) to unbounded list queries (`getActiveJobs`, applicant lists); decide and document the retention/archival policy left open in `DATABASE_DESIGN.md`; add the `updateJob` capability that's currently missing entirely.
- **Files affected**: `firestore.indexes.json`, `services/api/src/repositories/*.ts` (new repository layer), `lib/services/job_service.dart` (pagination support).
- **Tests**: integration tests confirming paginated queries return bounded result sets; index-backed composite queries succeed without runtime "missing index" errors in a clean environment (proves the index file is complete, not relying on Console auto-creation).
- **Security requirements**: none new beyond Phase 4's rules remaining in force.
- **Acceptance criteria**: a fresh `gojobs-staging` project, seeded only from `firestore.indexes.json` + rules files (no manual Console clicking), serves every query the app makes without index errors.
- **Rollback**: index additions are non-destructive; pagination changes are UI-visible but reversible.
- **Dependencies**: Phase 4.

---

## PHASE 6 — Backend

- **Objective**: Build out the real API surface — the central, largest phase, since no backend exists today (per `EXISTING_SYSTEM.md` §2).
- **Prerequisites**: Phases 3-5 (auth, authz, database groundwork all in place).
- **Tasks**: implement `/api/v1/jobs` (create/read/update/delete — including the currently-missing edit capability), `/api/v1/applications` (create/read/status-update), `/api/v1/users` (profile read/update with field allowlisting), `/api/v1/ai/*` (Groq proxy, key held server-side via Secret Manager), Zod validation schemas for every endpoint, consistent error-response middleware, request-ID + structured logging middleware, rate limiting on sensitive endpoints (login-adjacent, job creation, applications, AI calls).
- **Files affected**: full `services/api/src/{routes,controllers,services,repositories,validators}/` tree.
- **Tests**: unit tests per service/validator; integration tests per endpoint (happy path + auth failure + authz failure + validation failure); security tests specifically targeting IDOR on the two Phase-0-identified vulnerable endpoints (confirm a non-owner truly cannot act, now via the real API, not just via rules).
- **Security requirements**: every mutating endpoint enforces ownership + role server-side; every input validated; no stack traces/internals in error responses; rate limits on abuse-prone endpoints; Groq key never leaves the server process.
- **Acceptance criteria**: C-1 and C-2 from `SECURITY_AUDIT.md` are fully closed via the real API (not just theoretically via rules); AI features work end-to-end without the client ever seeing the Groq key.
- **Rollback**: Cloud Run revision-based rollback; the mobile app isn't fully repointed yet (Phase 7), so a bad backend deploy doesn't immediately break the shipped app if the app still has a client-direct fallback during transition — sequence carefully, ideally behind a feature flag (Phase 7/brief §44).
- **Dependencies**: Phases 3, 4, 5.

---

## PHASE 7 — Mobile

- **Objective**: Repoint the Flutter app's security-sensitive writes at the new backend; begin the screen-consolidation and shared-widget work identified in `EXISTING_SYSTEM.md`/`FEATURE_MATRIX.md`.
- **Prerequisites**: Phase 6 (backend endpoints must exist to repoint to).
- **Tasks**: replace direct Firestore writes in `job_service.dart`/`application_service.dart`/`user_service.dart` with backend HTTP calls (via a new networking layer with timeouts, retries-only-for-idempotent-operations, request IDs); implement the real `lib/widgets/` component library (cards, tiles, dialogs, buttons, loading/empty-state widgets); consolidate the job_seeker/freelancer/student screen trees to use shared widgets and reduce duplication; add router-level auth/role guards (SECURITY_AUDIT.md M-1).
- **Files affected**: `lib/services/*.dart` (networking layer + backend calls replacing direct Firestore writes for sensitive ops), `lib/widgets/*` (implemented), `lib/screens/{job_seeker,freelancer,student}/*` (consolidated where duplication was found), `lib/router/app_router.dart` (guards added).
- **Tests**: widget tests for the new shared components; integration tests confirming a job-seeker account can no longer successfully call the raw Firestore write paths that C-1/C-2 exploited (they now hit rules-denied writes if attempted, and the UI no longer offers them); manual QA pass across all four role flows to confirm no regression from consolidation.
- **Security requirements**: client no longer performs the specific writes identified as C-1/C-2/H-2 directly — those now go exclusively through the authorizing backend.
- **Acceptance criteria**: every flow in `FEATURE_MATRIX.md` marked "Rewrite" due to an insecure write now goes through the backend; screen count in `job_seeker/freelancer/student` measurably reduced via shared-widget adoption without losing any behavior in `FEATURE_MATRIX.md`'s Keep rows.
- **Rollback**: feature-flag the cutover per endpoint (brief §44) so a broken backend integration can fall back or be disabled without an emergency app-store release.
- **Dependencies**: Phase 6.

---

## PHASE 8 — Storage

- **Objective**: Close SECURITY_AUDIT.md H-2 — move uploads behind backend-issued signed URLs or backend-mediated upload endpoints with real size/MIME/path enforcement.
- **Prerequisites**: Phase 6 (backend must exist to issue signed URLs).
- **Tasks**: implement a backend upload-authorization endpoint (verifies uid, issues a scoped signed URL or proxies the upload); enforce file-size caps and MIME/extension validation server-side (not just client `FilePicker` restriction); randomize/safe-guard filenames; update `storage.rules` to only allow writes matching the backend-issued grant.
- **Files affected**: `services/api/src/routes/uploads.ts`, `lib/services/storage_service.dart` (calls the new authorization endpoint before uploading), `storage.rules`.
- **Tests**: integration tests confirming an oversized or wrong-MIME upload is rejected server-side even if a client bypasses the picker UI; confirm a user cannot upload into another user's storage path.
- **Security requirements**: closes H-2 fully.
- **Acceptance criteria**: a scripted upload attempt (bypassing the Flutter UI entirely, simulating a modified client) against another user's CV path, or with an oversized file, is rejected.
- **Rollback**: Storage rules are versioned/redeployable like Firestore rules; upload endpoint can be feature-flagged.
- **Dependencies**: Phase 6.

---

## PHASE 9 — Notifications

- **Objective**: Fix the non-functional FCM token persistence stub and move notification fan-out to a proper backend/background job; consolidate the 4× duplicated chat implementation.
- **Prerequisites**: Phase 6.
- **Tasks**: implement real token persistence (`users/{uid}.fcmTokens` or equivalent, with invalid-token cleanup); implement backend-triggered fan-out for application-status-change and new-message events; consolidate chat into one implementation using `message_service.dart`'s existing shape (add the missing `chatId`/`receiverId` model fields) instead of 4 separate inline reimplementations.
- **Files affected**: `lib/services/notification_service.dart`, `services/api/src/services/notifications.ts` (new), `lib/models/message_model.dart` (add fields), `lib/services/message_service.dart` (wired up for real), the 4 chat screens (refactored to use the shared service).
- **Tests**: integration test confirming a status change triggers a push notification to a valid registered token, and gracefully handles/cleans up an invalid token; chat consolidation covered by widget/integration tests replacing the previous zero coverage on this feature.
- **Security requirements**: notification payloads don't leak data the recipient shouldn't see; token registration is uid-scoped, not client-supplied-uid-scoped.
- **Acceptance criteria**: an applicant reliably receives a push notification when their application status changes; chat works identically across all four roles from one shared implementation.
- **Rollback**: additive — old inline chat code can stay dormant behind a flag until the consolidated version is verified in staging.
- **Dependencies**: Phase 6.

---

## PHASE 10 — Admin

- **Objective**: Build the admin role and platform from scratch (none exists today).
- **Prerequisites**: Phases 4, 6 (authorization model and backend must exist first — admin is the highest-privilege role and must not be bolted on before the authz foundation is solid).
- **Tasks**: define the `ADMIN` custom claim (settable only via a trusted server-side process, e.g. a one-time bootstrap script or a super-admin-only endpoint — never client-writable); build minimal admin endpoints (user suspend/verify, job moderation, application dispute review); build a minimal admin web app or Flutter admin flavor (per target repo structure's `apps/admin`); wire every sensitive admin action to the audit log (Phase 10 also depends conceptually on logging groundwork from Phase 6/15).
- **Files affected**: new `apps/admin/` (or equivalent), `services/api/src/routes/admin.ts`, `services/api/src/middleware/requireAdmin.ts`, audit-log schema/collection.
- **Tests**: security tests specifically confirming a non-admin token cannot reach any `/api/v1/admin/*` route, and that admin actions are recorded in the audit log.
- **Security requirements**: admin auth is the most tightly scoped role check in the system; every admin action is audit-logged and the audit log is not editable by ordinary users (brief §41).
- **Acceptance criteria**: a designated admin account can suspend a user/verify a company/moderate a job; the action appears in an audit trail; no non-admin account can reach these endpoints under any tested condition.
- **Rollback**: admin surface is new/additive — can be disabled entirely without affecting the rest of the app.
- **Dependencies**: Phases 4, 6.

---

## PHASE 11 — Testing

- **Objective**: Build the test suite that currently doesn't exist (`EXISTING_SYSTEM.md` §11) — unit, integration, security, widget, and e2e layers.
- **Prerequisites**: ideally interleaved with Phases 3-10 rather than deferred entirely to the end (each phase above already lists its own tests) — this phase is where coverage is backfilled/completed and e2e flows are added once enough of the system exists to test end-to-end.
- **Tasks**: backend unit tests for all services/validators/authz policies; Flutter widget tests for the newly-built shared component library and consolidated screens; e2e tests for the two flows named in the brief (job seeker: register→login→profile→search→apply; employer: login→post job→receive application→review→accept/reject; notification: status change→push→open→see update).
- **Files affected**: `services/api/test/`, `test/` (Flutter), new `e2e/` directory.
- **Tests**: this phase *is* the tests.
- **Security requirements**: security-test layer specifically re-verifies every `SECURITY_AUDIT.md` finding is closed (IDOR attempts, role manipulation, expired/invalid/tampered tokens, malformed input, rate-limit enforcement) as regression tests, not just a one-time manual check.
- **Acceptance criteria**: CI blocks merge on test failure; the two named e2e flows pass reliably in the staging environment.
- **Rollback**: N/A — tests are additive infrastructure.
- **Dependencies**: Phases 3-10 (tests need something real to test).

---

## PHASE 12 — Security

- **Objective**: A dedicated hardening pass — re-run `OWASP_CHECKLIST.md` against the now-real backend/mobile app, add Firebase App Check, close remaining Medium/Low findings from `SECURITY_AUDIT.md`.
- **Prerequisites**: Phases 4, 6, 8, 11 (need the backend, storage, and test harness in place to verify against).
- **Tasks**: enable Firebase App Check (client + API-edge enforcement); close M-1 (router guards — likely already done in Phase 7, verify), M-3 (field allowlist — likely already done in Phase 4/6, verify); remove/gate remaining `debugPrint`/`print` findings (L-1, L-2); run static analysis + dependency + secret scanning as part of this phase's own verification, ahead of Phase 13 making it a permanent CI gate.
- **Files affected**: client App Check integration, `services/api/src/middleware/appCheck.ts`, cleanup of remaining logging findings.
- **Tests**: security test suite from Phase 11 re-run and expanded; a manual/light penetration-style pass against staging (brief §48 — "where feasible," not necessarily a full professional pentest for a first release, but a deliberate adversarial pass by the team).
- **Security requirements**: re-mark every row in `OWASP_CHECKLIST.md` based on actual verification, not plan intent.
- **Acceptance criteria**: `OWASP_CHECKLIST.md` updated with real ✅/⚠️/❌ status; no Critical or High findings remain open from `SECURITY_AUDIT.md`.
- **Rollback**: App Check can be set to "monitor" mode before "enforce" mode to avoid accidentally locking out legitimate traffic — roll forward gradually.
- **Dependencies**: Phases 4, 6, 8, 11.

---

## PHASE 13 — CI/CD

- **Objective**: Replace the current minimal/mislabeled pipelines with the brief's PR → staging → production flow.
- **Prerequisites**: Phases 2 (environments to deploy to), 11 (tests to gate on).
- **Tasks**: PR workflow (install, format, lint incl. `avoid_print` enforcement, unit+integration tests, security checks incl. dependency/secret scanning, build verification) for both the Flutter app and the new backend; staging workflow (deploy on merge, run smoke tests); production workflow (manual approval gate after staging verification, deploy, smoke tests, monitoring watch).
- **Files affected**: rewrite `.github/workflows/main.yml` and `.github/workflows/non-functional.yml`, add new workflows for the backend and per-environment deploys.
- **Tests**: the pipelines' own correctness is verified by intentionally introducing a failing test/lint violation on a branch and confirming the PR check blocks merge.
- **Security requirements**: real dependency-vulnerability scanning (not just `flutter pub outdated`) and secret scanning added as blocking checks.
- **Acceptance criteria**: a PR with a failing test cannot merge; a merge to the staging branch auto-deploys and smoke-tests; a production deploy requires explicit human approval and is reversible.
- **Rollback**: Cloud Run revision rollback + Docker Hub/Artifact Registry tag history for the web/API images; document the exact rollback command sequence in `docs/operations/`.
- **Dependencies**: Phases 2, 11.

---

## PHASE 14 — Infrastructure

- **Objective**: Production-grade containerization and deployment for the new API (the web/Flutter side already has a Docker path from the existing repo, to be hardened alongside).
- **Prerequisites**: Phase 6 (backend to containerize), Phase 13 (pipeline to deploy it through).
- **Tasks**: production Dockerfile for `services/api/` — non-root user, minimal base image, deterministic install (lockfile-pinned), health-check directive, graceful shutdown handling; Cloud Run service configuration (min/max instances, concurrency, memory/CPU limits, environment-specific service accounts).
- **Files affected**: `services/api/Dockerfile`, `infrastructure/gcp/` (Cloud Run config, whether as scripts or light IaC).
- **Tests**: container starts, passes its own health check, and shuts down gracefully on SIGTERM within a defined timeout (verified locally and in CI).
- **Security requirements**: non-root container user; no secrets baked into the image (all via Secret Manager/env at runtime); minimal attack surface (no unnecessary packages in the final image).
- **Acceptance criteria**: the API runs correctly as multiple concurrent Cloud Run instances with no shared local state (proves the "stateless, horizontally scalable" requirement, not just claims it).
- **Rollback**: Cloud Run's built-in revision management.
- **Dependencies**: Phases 6, 13.

---

## PHASE 15 — Observability

- **Objective**: Add the logging/monitoring/crash-reporting/alerting that currently doesn't exist anywhere (`EXISTING_SYSTEM.md` §14).
- **Prerequisites**: Phase 14 (something deployed to observe).
- **Tasks**: structured JSON logging middleware on the backend (timestamp, requestId, endpoint, method, status, duration, userId where relevant, error code — never secrets/PII beyond what's necessary); wire Google Cloud Logging/Monitoring dashboards and alert thresholds (error rate, latency, uptime); add Firebase Crashlytics to the Flutter app (currently entirely absent).
- **Files affected**: `services/api/src/middleware/logging.ts`, `lib/main.dart` (Crashlytics init), new dashboard/alert config (Console-managed or light IaC), `docs/operations/` additions documenting the dashboards and alert thresholds chosen.
- **Tests**: a deliberately-triggered error in staging appears in Cloud Logging with the expected structured fields and fires the configured alert.
- **Security requirements**: logging redaction confirmed — no passwords/tokens/keys ever appear in a log line (test this explicitly, don't just assume the code never logs them).
- **Acceptance criteria**: an on-call engineer could diagnose a production incident from dashboards + logs alone, without SSHing into anything (there's nothing to SSH into — Cloud Run is stateless by design).
- **Rollback**: N/A — additive.
- **Dependencies**: Phase 14.

---

## PHASE 16 — Load Testing

- **Objective**: Measure, not assume, scalability — per the brief's explicit instruction.
- **Prerequisites**: Phases 6, 14, 15 (need a real deployed, observable backend to load-test).
- **Tasks**: define realistic workloads (auth, job browsing/search, job creation, applications, employer dashboards, notifications) against `gojobs-staging`; run progressively (100 → 1,000 → 10,000 concurrent users, as far as practical/affordable); measure latency, error rate, Firestore read/write contention, Cloud Run CPU/memory scaling behavior, and cost.
- **Files affected**: new `load-tests/` directory (e.g. k6 or Artillery scripts), a results report under `docs/operations/`.
- **Tests**: the load test *is* the test; results feed pass/fail thresholds (e.g. p95 latency under Xms at 1,000 concurrent users) agreed before running, not judged after the fact.
- **Security requirements**: rate limiting (Phase 6) is verified to actually engage under load, not just exist in code.
- **Acceptance criteria**: documented, reproducible load-test results with clear pass/fail against pre-agreed thresholds; any bottleneck found (e.g. an unindexed query, a Cloud Run cold-start issue) is filed as a concrete follow-up, not silently ignored.
- **Rollback**: N/A — testing against staging only, no production impact.
- **Dependencies**: Phases 6, 14, 15.

---

## PHASE 17 — Beta

- **Objective**: Real users (a limited group) exercising the staging/pre-production build before full public launch.
- **Prerequisites**: Phases 11, 12, 16 (tested, secured, load-verified).
- **Tasks**: TestFlight (iOS) / Play Console closed testing track (Android) setup; recruit a beta cohort; monitor via the Phase 15 observability stack; triage feedback and bugs.
- **Files affected**: App Store Connect / Play Console configuration (outside the repo), any hotfixes discovered during beta.
- **Tests**: real-world usage is the test at this stage; any bug found gets a regression test added per Phase 11's ongoing practice.
- **Security requirements**: monitor for any authorization anomaly during beta (unexpected 403s, rule-denial spikes) as an early signal the Phase 4 model has a gap the audit/tests missed.
- **Acceptance criteria**: beta cohort completes the core job-seeker and employer flows without a Critical/High-severity bug found; feedback incorporated or explicitly deferred with reasoning.
- **Rollback**: beta builds are isolated from production by construction (staging environment) — no production impact regardless of beta findings.
- **Dependencies**: Phases 11, 12, 16.

---

## PHASE 18 — Production Launch

- **Objective**: Public release.
- **Prerequisites**: Phase 17 (beta signed off), production environment fully configured per `ENVIRONMENTS.md`/`PRODUCTION_READINESS.md` (backups, IAM, App Check enforced, budget alerts).
- **Tasks**: App Store / Play Store submission (per the checklist in `PRODUCTION_READINESS.md`); production deploy via the Phase 13 pipeline with its manual-approval gate; post-launch smoke tests; active monitoring window immediately following release.
- **Files affected**: none new beyond what prior phases already built — this phase is execution, not development.
- **Tests**: production smoke test suite (subset of Phase 11's e2e tests, safe to run against real production without side effects — e.g. health checks, read-only flows).
- **Security requirements**: final confirmation of `OWASP_CHECKLIST.md` status; production Firestore/Storage rules confirmed deployed and matching the reviewed `firestore.rules`/`storage.rules` source (no undocumented Console drift).
- **Acceptance criteria**: app is live in both stores; production traffic flowing; dashboards green; rollback plan rehearsed (not just written) before this phase begins.
- **Rollback**: documented, tested rollback procedure (Cloud Run revision + mobile store staged-rollout halt) — this is the phase where "reversible" (a hard requirement per the brief) gets exercised for real if needed.
- **Dependencies**: Phase 17 and, transitively, everything before it.

---

## PHASE 19 — Post-launch Operations

- **Objective**: Steady-state operation — the roadmap doesn't end at launch.
- **Prerequisites**: Phase 18.
- **Tasks**: ongoing dependency/security updates, on-call/incident-response process (documented, not just implied), scheduled backup-restoration drills (`docs/operations/DISASTER_RECOVERY.md` — "restoration must eventually be tested," not assumed to work), feature-flag-driven gradual rollouts for new features (brief §44), periodic re-audit against `OWASP_CHECKLIST.md`.
- **Files affected**: ongoing, feature-by-feature.
- **Tests**: ongoing, per the established Phase 11/13 practice — no new feature ships without tests going forward.
- **Security requirements**: periodic dependency/secret scanning already running in CI (Phase 13) continues; schedule a recurring (e.g. quarterly) manual security review.
- **Acceptance criteria**: N/A — this phase is indefinite by design.
- **Rollback**: N/A — this phase defines the ongoing operational posture, not a single change.
- **Dependencies**: Phase 18.

---

## Sequencing notes

- Phases 3-6 (Auth → Authz → Database → Backend) are the critical path — nothing else in the roadmap can proceed safely until the backend exists and the two Critical IDOR findings (C-1, C-2) are closed. This is intentionally front-loaded.
- Phase 1's cheap fixes (signing, bundle ID, iOS permissions, removing the client-embedded AI key) do **not** depend on the backend and can start immediately/in parallel with Phase 2-3 planning.
- Localization (mentioned in `FEATURE_MATRIX.md` as a from-scratch item) is deliberately not a numbered phase of its own above — it should be sequenced **before** the large screen-consolidation work inside Phase 7, so UI strings aren't touched twice (once for consolidation, once for i18n extraction). Treat it as a sub-task the Phase 7 go-ahead conversation should explicitly schedule.
- Every phase above ends with the same discipline the brief specifies for all of them (§54): run tests, run static analysis, run formatting, verify builds, review changed files, update documentation, report what changed, report remaining risks, report the exact next step — and **stop** for explicit approval before starting the next phase.
