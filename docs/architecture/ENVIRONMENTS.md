# GoJobs — Environment Strategy

Status: **Proposed, not yet implemented.** Today there is exactly **one** Firebase project (`gojobs-187af`) serving all purposes — development, testing, and (presumably) production traffic all hit the same database, the same Storage bucket, and the same Auth user pool. This is itself a production blocker: there is currently no safe place to test a destructive or exploratory change without risking real data, and no way to verify a change against production-like data without touching production.

## Target: three isolated environments

| Environment | Firebase/GCP project | Purpose | Data | Who/what can access |
|---|---|---|---|---|
| **Development** | `gojobs-dev` | Local development, CI test runs, exploratory work | Synthetic/seed data only. Safe to destroy and recreate at any time. | Developers, CI runners |
| **Staging** | `gojobs-staging` | Pre-release verification; realistic simulation of production | Anonymized/synthetic data resembling production shape and volume. **Never** a copy of real production data. | Developers, QA, automated smoke tests, CI/CD deploy pipeline |
| **Production** | `gojobs-production` (the current `gojobs-187af` project, once secured — see Open Question below) | Real users, real data | Real user data, subject to backups/DR (`docs/operations/DISASTER_RECOVERY.md`) | End users via the app; restricted IAM for engineers; no direct developer-laptop access to the database |

## Isolation rules (non-negotiable)

- Each environment is a **separate Firebase project** with its own Auth user pool, Firestore database, Storage bucket, and FCM sender ID — not a namespace/prefix inside a shared project.
- Development credentials (service accounts, API keys) **must not** have any IAM grant on the staging or production projects, and vice versa. Verified via GCP IAM policy review, not assumed.
- The mobile app is built with **environment-specific Firebase configuration** (`google-services.json`/`GoogleService-Info.plist`/`firebase_options.dart` per environment via `flutterfire configure --project=<env>` per flavor/scheme) — a production build must never be compiled against `gojobs-dev` config, and a dev build must never ship with production config baked in.
- CI/CD pipeline stages map 1:1 to environments: PR checks run against `gojobs-dev` (or the Firebase Emulator Suite, preferred — no live project needed for most checks); merges to `develop`/staging branch deploy to `gojobs-staging`; production deploys require an explicit approval gate and target `gojobs-production` only.
- Staging must never point at production data. If production-shaped test data is needed in staging, it is synthetic/anonymized, generated deliberately — never copied wholesale from production.

## Flutter build flavors (Phase 1 design — not created yet)

Target: three build flavors/schemes (`dev`, `staging`, `production`) per platform, each with:
- Its own `applicationId`/`bundleId` suffix so all three can be installed side-by-side on one device:

| Environment | Android `applicationId` | iOS bundle ID | iOS scheme name |
|---|---|---|---|
| dev | `com.gojobs.app.dev` | `com.gojobs.app.dev` | `Runner-dev` |
| staging | `com.gojobs.app.staging` | `com.gojobs.app.staging` | `Runner-staging` |
| production | `com.gojobs.app` | `com.gojobs.app` | `Runner` (existing default scheme) |

  (Today's actual values — `com.example.gp1_mvp` on Android, `com.example.gp1Mvp` on iOS — are still the unmodified Flutter template defaults on all builds, since there's only one build type. Renaming to real, owned IDs is itself a production-readiness prerequisite independent of flavors, already tracked in `docs/operations/PRODUCTION_READINESS.md`.)
- Its own Firebase config file, generated via FlutterFire CLI per project (`flutterfire configure --project=gojobs-dev`, etc.) — not run yet, since it requires the dev/staging projects to exist first (Phase 2, explicitly out of scope for this pass).
- Its own app icon/name badge (visually distinguishing dev/staging builds from production on a tester's home screen) — reduces the risk of a tester accidentally testing against the wrong backend.
- Android: implemented via `flavorDimensions`/`productFlavors` in `android/app/build.gradle.kts` (none exist today — confirmed, only the stock `main`/`debug`/`profile` source sets are present). iOS: implemented via additional Xcode schemes + per-scheme `.xcconfig` files (only the default `Runner` scheme exists today — confirmed).
- Flutter-side environment selection: a compile-time constant (`--dart-define=ENVIRONMENT=dev|staging|production`) read by a small `lib/config/environment.dart` (not created yet) that selects the matching `DefaultFirebaseOptions`-equivalent at startup, replacing today's single, unconditional `DefaultFirebaseOptions.currentPlatform` (`lib/firebase_options.dart`), which currently always points at `gojobs-187af` regardless of build type — there is no other mechanism today that could point a build at the wrong project, because there is only one project.

## Backend environment variables (Phase 1 design — no backend exists yet)

Once `services/api/` exists (see `TARGET_ARCHITECTURE.md`'s backend folder structure), each environment's Cloud Run service gets its own variable set, never shared across environments:

| Variable | Purpose | Source |
|---|---|---|
| `NODE_ENV` | `development` \| `staging` \| `production` | Set per Cloud Run service |
| `FIREBASE_PROJECT_ID` | Which Firebase project the Admin SDK targets | Set per Cloud Run service — `gojobs-dev` / `gojobs-staging` / `gojobs-187af` |
| `GOOGLE_APPLICATION_CREDENTIALS` (or Cloud Run's built-in service-account identity) | Admin SDK auth | Cloud Run's attached service account, scoped by IAM to only that environment's project — never a downloaded key file |
| `AI_PROVIDER` | Which `AIProvider` implementation is active (`groq` \| `openai` \| `self-hosted`, per `TARGET_ARCHITECTURE.md`) | Set per environment; provider API key itself comes from Secret Manager, not an env var |
| `LOG_LEVEL` | Verbosity | Set per environment (more verbose in dev/staging) |
| `CORS_ALLOWED_ORIGINS` | Which web origins may call the API (relevant since the Flutter web build exists) | Set per environment — dev/staging allow localhost + preview URLs, production allows only the real domain |

**Secrets handling**: no secret (AI provider key, any future third-party credential) is ever an environment variable in plaintext — all secrets are read from Google Secret Manager at container startup, one Secret Manager entry per secret per environment (e.g. `groq-api-key-dev`, `groq-api-key-production`, never shared). This is a direct, structural continuation of the H-1 remediation: the reason a hardcoded client key was possible at all was the absence of any secret-management layer — Secret Manager is that layer for the backend, permanently, not a one-time fix.

## Preventing accidental production access from dev builds

This is the specific failure mode being designed against, not a generic aspiration:

1. **No shared credentials across environments.** Each environment's Firebase config (client-side) and service-account identity (backend-side) are project-scoped by construction — a dev build's `firebase_options.dart`-equivalent literally cannot authenticate against the production project's Auth/Firestore/Storage, because Firebase client SDKs bind to the project embedded in their config at compile time, not at runtime.
2. **IAM, not convention, enforces the backend side.** The dev/staging Cloud Run services' service accounts are granted roles only on their own GCP project — verified via IAM policy review (not assumed), per the Isolation rules above.
3. **Visual distinction on-device** (flavor-specific icon/name badge) catches the human error case — a tester or developer glancing at their home screen can tell which build they're running before they act on what they see in it.
4. **CI/CD pipeline stages are hard-mapped to environments** (see the table below) — there is no manual "which project do I deploy to" step where a mistake could happen; the trigger (PR vs. merge to `develop` vs. merge to `main`) determines the target unambiguously.
5. **Production requires an explicit manual approval gate** (already true of the interim rules deploys performed so far in this engagement, each individually approved) — this continues as a hard requirement once real CI/CD exists (see `docs/operations/CI_CD.md`), not just a habit during manual operation.

## CI/CD → environment mapping

| Trigger | Target environment | Gate |
|---|---|---|
| Pull request | `gojobs-dev` / Firebase Emulator Suite | Lint, unit tests, integration tests, security checks, build verification |
| Merge to `develop`/staging branch | `gojobs-staging` | All PR checks + automated staging smoke tests |
| Merge/promote to `main` (production release) | `gojobs-production` | Staging verified + explicit manual approval + smoke tests post-deploy + monitoring watch |

## Decision (resolved 2026-09-08)

**Option 1 — promote in place.** `gojobs-187af` becomes `gojobs-production`, confirmed by the project owner. Fresh `gojobs-dev` and `gojobs-staging` projects are created alongside it; no data migration out of `gojobs-187af` is needed.

**Consequence for Phase 2/4 sequencing**: since `gojobs-187af` is being promoted rather than replaced, its live Firestore/Storage rules must be confirmed and hardened *before* it carries any traffic the team is relying on as "production" — this makes the rules-confirmation step (`SECURITY_AUDIT.md` C-3) a prerequisite for Phase 2 sign-off, not just a Phase 4 task. Until those rules are confirmed adequate (or tightened), treat `gojobs-187af` as exposed per the C-1/C-2/C-3 findings — do not treat "we chose to keep it as production" as evidence the current data is already safe.
