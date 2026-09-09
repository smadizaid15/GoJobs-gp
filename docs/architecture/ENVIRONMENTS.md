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

## Flutter build flavors

Target: three build flavors/schemes (`dev`, `staging`, `production`) per platform, each with:
- Its own `applicationId`/`bundleId` suffix (e.g. `com.gojobs.app.dev`, `com.gojobs.app.staging`, `com.gojobs.app`) so all three can be installed side-by-side on one device.
- Its own Firebase config file, generated via FlutterFire CLI per project.
- Its own app icon/name badge (visually distinguishing dev/staging builds from production on a tester's home screen) — reduces the risk of a tester accidentally testing against the wrong backend.

This replaces today's single, unconditional `DefaultFirebaseOptions.currentPlatform` (`lib/firebase_options.dart`), which currently always points at `gojobs-187af` regardless of build type.

## CI/CD → environment mapping

| Trigger | Target environment | Gate |
|---|---|---|
| Pull request | `gojobs-dev` / Firebase Emulator Suite | Lint, unit tests, integration tests, security checks, build verification |
| Merge to `develop`/staging branch | `gojobs-staging` | All PR checks + automated staging smoke tests |
| Merge/promote to `main` (production release) | `gojobs-production` | Staging verified + explicit manual approval + smoke tests post-deploy + monitoring watch |

## Decision (resolved 2026-09-08)

**Option 1 — promote in place.** `gojobs-187af` becomes `gojobs-production`, confirmed by the project owner. Fresh `gojobs-dev` and `gojobs-staging` projects are created alongside it; no data migration out of `gojobs-187af` is needed.

**Consequence for Phase 2/4 sequencing**: since `gojobs-187af` is being promoted rather than replaced, its live Firestore/Storage rules must be confirmed and hardened *before* it carries any traffic the team is relying on as "production" — this makes the rules-confirmation step (`SECURITY_AUDIT.md` C-3) a prerequisite for Phase 2 sign-off, not just a Phase 4 task. Until those rules are confirmed adequate (or tightened), treat `gojobs-187af` as exposed per the C-1/C-2/C-3 findings — do not treat "we chose to keep it as production" as evidence the current data is already safe.
