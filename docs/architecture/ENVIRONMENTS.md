# GoJobs — Environment Strategy

Status: **Phase 1B (environment isolation) — Firestore + Auth fully provisioned and live-verified, Storage still blocked, 2026-09-11, branch `feature/phase1-environment-isolation`.** `gojobs-dev` and `gojobs-staging` exist as real Firebase projects alongside production `gojobs-187af`. Permanent Android/iOS identifiers are approved (`com.gojobs.app[.dev|.staging]`) and Firebase apps are registered under all three projects. Android product flavors (`dev`/`staging`/`prod`) build correctly; Flutter's native `appFlavor` is the sole environment selector. **Both `gojobs-dev` and `gojobs-staging` now have: a provisioned Firestore database (`me-central2`, matching production, 8/8 indexes `READY`); the repository's real `firestore.rules`/`firestore.indexes.json` deployed and byte-verified against the source files; enabled Email/Password Auth with empty, independent, live-verified user pools.** A one-time controlled smoke test against both real projects confirmed account creation, sign-in, an authorized write, and a denied unauthorized write, then fully cleaned up. **Storage remains unavailable in both**, blocked on a Blaze/billing decision not authorized in this engagement. iOS remains prepared-but-unwired — see "iOS status" below. **Phase 1B is not yet complete** — Storage and iOS Xcode wiring remain open.

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

## `.firebaserc` (implemented 2026-09-10)

```json
{
  "projects": {
    "dev": "gojobs-dev",
    "staging": "gojobs-staging",
    "prod": "gojobs-187af"
  },
  "targets": {},
  "etags": {}
}
```
Deliberately **no `"default"` alias.** Firebase CLI commands that accept `--project` (`firebase deploy --project staging`, `firebase emulators:exec --project dev ...`, etc.) require picking one of these three explicitly; running a command with no project flag and no prior `firebase use` in the session fails rather than silently targeting whichever project happened to be last-used. Every deploy performed manually so far in this engagement has already followed this discipline (explicit project confirmation before every rules deploy); this file makes it the structural default rather than a habit.

## Approved permanent identifiers (2026-09-11)

| Environment | Android `applicationId` | iOS bundle ID |
|---|---|---|
| dev | `com.gojobs.app.dev` | `com.gojobs.app.dev` |
| staging | `com.gojobs.app.staging` | `com.gojobs.app.staging` |
| production | `com.gojobs.app` | `com.gojobs.app` |

The legacy `com.example.gp1_mvp` (Android) / `com.example.gp1Mvp` (iOS) Firebase app registrations in `gojobs-187af` are **not renamed or deleted** — they remain for migration/history safety. New Firebase app records were registered under `com.gojobs.app` alongside them.

## Firebase app registration inventory (as of 2026-09-11)

**`gojobs-187af` (production)** — 6 apps total:
| Nickname | Platform | Package/Bundle ID | Status |
|---|---|---|---|
| gp1_mvp (android) | Android | `com.example.gp1_mvp` | Legacy — untouched |
| gp1_mvp (ios) | iOS | `com.example.gp1Mvp` | Legacy — untouched |
| gp1_mvp (windows) | Web | — | Legacy — untouched |
| gp1_mvp (web) | Web | — | Legacy — untouched |
| GoJobs (production, Android) | Android | `com.gojobs.app` | **New, this batch** |
| GoJobs (production, iOS) | iOS | `com.gojobs.app` | **New, this batch** |

**`gojobs-dev`** — 2 apps (both new this batch): `GoJobs Dev (Android)` → `com.gojobs.app.dev`, `GoJobs Dev (iOS)` → `com.gojobs.app.dev`.

**`gojobs-staging`** — 2 apps (both new this batch): `GoJobs Staging (Android)` → `com.gojobs.app.staging`, `GoJobs Staging (iOS)` → `com.gojobs.app.staging`.

No web app was registered for dev/staging this batch (out of scope — only Android/iOS were requested). No service account was created or downloaded for Flutter; only client-side app configuration (project ID/app ID/API key — not secrets, per standard Firebase/FlutterFire practice) was generated.

## Flutter build flavors (implemented 2026-09-11)

`android/app/build.gradle.kts`: `flavorDimensions += "environment"`, three `productFlavors` (`dev`/`staging`/`prod`), each with `applicationIdSuffix` (`.dev`/`.staging`/none) off the base `applicationId = "com.gojobs.app"`, and a `resValue("string", "app_name", ...)` feeding `AndroidManifest.xml`'s `android:label="@string/app_name"` (previously a hardcoded `"gp1_mvp"`). Verified by building and inspecting each APK with `aapt dump badging`:

| Flavor | Built applicationId | Built app label |
|---|---|---|
| dev | `com.gojobs.app.dev` | `GoJobs Dev` |
| staging | `com.gojobs.app.staging` | `GoJobs Staging` |
| prod | `com.gojobs.app` | `GoJobs` |

`android:namespace` (Kotlin package for generated `R`/`BuildConfig`, independent of `applicationId` since AGP 7+) changed from `com.example.gp1_mvp` to the canonical `com.gojobs.app`. This required moving `MainActivity.kt` from `android/app/src/main/kotlin/com/example/gp1_mvp/` to `.../com/gojobs/app/` and updating its `package` declaration to match — done deliberately, verified by all three flavors building successfully afterward.

Each flavor has its own `android/app/src/<flavor>/google-services.json`, generated from its actual registered Firebase app (`firebase apps:sdkconfig`) — never hand-copied from another environment. Verified by inspecting each built APK's compiled resources (`aapt dump --values resources`) for the embedded `google_app_id`: dev → `1:17773055683:android:f651c0657b9f0838b9dc76`, staging → `1:1047239227213:android:8d09899232529d9fd52904`, prod → `1:944928167403:android:e4c953e9b51fcab7cc75ae` — each matching its own project, never another's.

All three flavors can coexist on one device (distinct `applicationId`s are exactly what makes that possible — Android treats them as entirely separate apps).

## Legacy Firebase configuration artifacts — audited and cleaned up (2026-09-11)

A dedicated hygiene pass audited every Firebase client configuration artifact in the repo for one specific question: **could an obsolete/default file let an incorrectly configured build connect to the wrong Firebase project, especially production?** (Not whether client API keys are secrets — they aren't, by Firebase's own model.)

**Full inventory found** (repository-wide search, not limited to the obvious locations):
- Android: `android/app/src/{dev,staging,prod}/google-services.json` (current, per-flavor — kept) + a legacy root `android/app/google-services.json` (removed, see below).
- iOS: `ios/Runner/Firebase/{dev,staging,prod}/GoogleService-Info.plist` (current, prepared but not yet Xcode-wired — kept). **No legacy root `ios/Runner/GoogleService-Info.plist` was found** — confirmed via a repo-wide `GoogleService-Info.plist` search; only the three environment-scoped copies exist.
- Dart: `lib/firebase_options_{dev,staging,prod}.dart` (current, imported by `lib/config/app_environment.dart` — kept) + a legacy `lib/firebase_options.dart` (removed, see below).
- Web: `web/firebase-messaging-sw.js` hardcoded production — **removed 2026-09-11** (see "Web platform status" below for the full reference audit and reasoning).
- `firebase.json`'s `"flutter"` key — **removed 2026-09-11**. It held exactly two entries, both stale: `platforms.android.default` pointed at the now-removed `android/app/google-services.json`, keyed to the legacy `com.example.gp1_mvp` Android app registration (`1:944928167403:android:445fcf1e636646e9cc75ae` — not the current `com.gojobs.app` registration); `platforms.dart["lib/firebase_options.dart"]` pointed at the now-removed Dart file, mapping all five platforms (android/ios/macos/web/windows) to that same single, pre-environment-architecture project. FlutterFire's bookkeeping schema has no native concept of "one project, three environments" — there was no way to edit this key into something that accurately represents the current per-environment architecture without inventing a new, ad hoc representation (out of scope for this cleanup). Since every entry in it pointed at deleted files under the superseded single-project model, it was removed entirely rather than left stale. **Untouched, verified**: `"auth"`, `"firestore"` (rules/indexes paths), `"storage"` (rules path), and `"emulators"` (ports, `singleProjectMode`) — all four remaining top-level keys are byte-identical to before this edit. This is a local JSON edit only; no `flutterfire configure` command was run, no external Firebase resource was touched.

### Android legacy root config — removed 2026-09-11

`android/app/google-services.json` (project `gojobs-187af`, client registered only under the legacy `com.example.gp1_mvp` package name — the pre-Phase-1B, unflavored production config) was determined to be **provably unreachable** by any buildable variant and removed:

- The Google Services Gradle plugin's file-resolution order checks `src/<flavor>/google-services.json` (which exists for all three flavors) **before** ever falling back to the module-root file. Since `flavorDimensions` is defined, Gradle has no "flavorless" variant to build in the first place — every `assemble*` task Flutter can invoke resolves to `assembleDevDebug`/`assembleStagingDebug`/`assembleProdDebug` (or their Release/Profile equivalents), all of which resolve their config via the flavor-specific file, never the root.
- Even in a hypothetical fallback scenario, the root file's only client entry is scoped to `com.example.gp1_mvp` — an applicationId nothing in the current flavor configuration produces (`com.gojobs.app[.dev|.staging]`) — so it couldn't silently supply valid config for any of today's three flavors even if somehow consulted.
- No build script, Gradle config, or CI step references the file by path (verified via repo-wide grep) — its presence was purely FlutterFire CLI's original, now-superseded default output location.
- **Verified empirically, not just reasoned about**: after removal, `flutter analyze` (0 issues) and all three flavor builds were re-run from scratch. Each still embeds its own correct `google_app_id` — dev → `1:17773055683:android:f651c0657b9f0838b9dc76`, staging → `1:1047239227213:android:8d09899232529d9fd52904`, prod → `1:944928167403:android:e4c953e9b51fcab7cc75ae` — identical to before removal. Zero regression.

### Legacy Dart Firebase options — removed 2026-09-11

`lib/firebase_options.dart` (the original, pre-Phase-1B, unflavored `DefaultFirebaseOptions` class — full production config for web/android/ios/macos/windows, Android/iOS registered under the legacy `com.example.gp1_mvp`/`com.example.gp1Mvp` identifiers) was confirmed dead code and removed:

- Repository-wide grep for `import.*firebase_options` and for the class name `DefaultFirebaseOptions` (not the `Dev`/`Staging`/`Prod` variants) found **zero references** anywhere in `lib/`, `test/`, or tooling — only `lib/config/app_environment.dart` importing the three current per-environment files.
- The one soft reference found was a **comment**, not code: `lib/firebase_options_prod.dart` pointed future readers at the legacy file's `web`/`windows` members "if a prod-environment web build is needed." Since web is not environment-isolated today and is being recorded as unsupported/deferred (see below), that comment was updated to point at this document instead of a deleted file, rather than leaving a dangling reference.
- Removing it closes exactly the risk this hygiene pass is about: an unused, importable, full-production Firebase config sitting in the codebase for future code to reach for by accident.
- The underlying legacy Firebase app registrations (`com.example.gp1_mvp` Android, `com.example.gp1Mvp` iOS/macOS, the original web/windows apps) still exist in `gojobs-187af` and were **not** renamed or deleted — only the unused local Dart file referencing them was removed. Their values remain recoverable via `firebase apps:sdkconfig` or the Firebase Console if ever needed.
- **Verified**: `flutter analyze` (0 issues) and `flutter test` (20/20) both pass after removal — nothing broke.

## iOS environment configuration (prepared 2026-09-11 — macOS/Xcode verification still required)

**Done, safely, from Windows:**
- `ios/Flutter/Dev.xcconfig`, `Staging.xcconfig`, `Prod.xcconfig` — each `#include "Generated.xcconfig"` plus `PRODUCT_BUNDLE_IDENTIFIER` and `PRODUCT_NAME` for its environment. Plain text files; safe to author without Xcode.
- `ios/Runner/Firebase/{dev,staging,prod}/GoogleService-Info.plist` — real, generated per environment (`firebase apps:sdkconfig`), matching the same three iOS app registrations above. Placed in clearly-separated folders, **not yet added to the Xcode project** (see below).
- `ios/Runner/Info.plist`: `CFBundleDisplayName` and `CFBundleName` changed from hardcoded `"Gp1 Mvp"`/`"gp1_mvp"` to `$(PRODUCT_NAME)`, so the xcconfig files above can actually control the displayed app name once wired in. **Side effect on the current, still-unflavored build**: since every existing Xcode build configuration already resolves `PRODUCT_NAME` to `$(TARGET_NAME)` (= `Runner`), the app's displayed name changes from "Gp1 Mvp" to "Runner" until real schemes exist — flagging this explicitly rather than letting it pass silently.
- `ios/Runner.xcodeproj/project.pbxproj` was **not** hand-edited — creating real Xcode schemes/targets/build configurations requires duplicating build settings in a format Xcode itself manages; doing that blind, from Windows, with no way to open the project and verify it still parses, is exactly the kind of unverifiable change this phase should not make.

**Remains for macOS/Xcode** (explicitly not done, not claimed done):
1. Create three schemes (e.g. `Runner-dev`/`Runner-staging`/`Runner-prod`, or duplicate the `Runner` target three times) with their own build configurations.
2. Have each scheme's configurations `#include` the matching `.xcconfig` file above.
3. Add each environment's `GoogleService-Info.plist` to its scheme's target and Copy Bundle Resources build phase (Xcode does not support flavor-suffixed resource directories the way Android Gradle does — this needs either per-target file membership or a build-phase script).
4. Build and run each scheme at least once to confirm it compiles, launches, and initializes the correct Firebase project.
5. Signing/provisioning/`DEVELOPMENT_TEAM` — explicitly **not** touched this batch, and not to be touched without separate approval per instruction.

### iOS legacy-config safety audit (2026-09-11, static/source analysis only — no macOS/Xcode available to build and confirm empirically)

- **No legacy root `GoogleService-Info.plist` exists** anywhere in the repo — confirmed by a repo-wide search; only the three environment-scoped copies under `ios/Runner/Firebase/`. There is nothing for an unflavored native build to accidentally pick up via Firebase's own auto-discovery convention.
- **`project.pbxproj` has zero `GoogleService-Info.plist` references** in any build phase (grep confirmed) — no plist is currently copied into the app bundle by any scheme, flavored or not.
- **`AppDelegate.swift` contains no native `FirebaseApp.configure()` call** — the only Firebase initialization path is the Dart-side `Firebase.initializeApp(options: AppEnvironmentConfig.firebaseOptions)` in `main.dart`. There is no separate native init that could race or diverge from it.
- **The active default build configuration still uses the legacy bundle ID**: `project.pbxproj`'s `PRODUCT_BUNDLE_IDENTIFIER = com.example.gp1Mvp` (Debug/Release/Profile, untouched — no scheme wiring was done). `ios/Flutter/Debug.xcconfig` and `Release.xcconfig` (the xcconfigs actually referenced by the default `Runner` scheme) only `#include "Generated.xcconfig"` — the new `Dev.xcconfig`/`Staging.xcconfig`/`Prod.xcconfig` are **not** included anywhere yet (confirmed via grep), exactly as documented above.
- **What this means for "could an unflavored iOS build connect to production?"**: no. `AppEnvironmentConfig.current` (`lib/config/app_environment.dart`) calls `parseFlavor(appFlavor)`, which **throws a `StateError` immediately** when no `--flavor` was passed (`appFlavor == null`) — before `Firebase.initializeApp` is ever called, on any platform including iOS. An ordinary/default iOS build today fails loudly at startup; it does not silently connect anywhere, legacy or production. This was verified by static/source analysis (tracing the exact call path), not by an actual iOS build — no macOS/Xcode environment is available here to confirm empirically, and none was attempted, per instruction.

**Constraint, documented explicitly per instruction**: **DO NOT run the iOS app against live Firebase until Phase 1B-iOS wiring (the "Remains for macOS/Xcode" list above) is completed.** Not because a legacy plist would be silently consumed today (none exists, and the fail-loud design prevents it even without one) — but because no iOS build has ever actually been compiled, launched, or verified this entire phase (no macOS/Xcode access), and the per-environment plists are not yet wired into any scheme's bundle. Until schemes exist and at least one real build/run has been verified, iOS environment isolation is **not validated**, only prepared.

## Flutter-side environment selection (implemented 2026-09-10, refactored 2026-09-11)

`lib/config/app_environment.dart` is the single source of truth for "which environment is this build, and which Firebase project does it talk to":
- **The native `--flavor` is the sole environment selector.** `AppEnvironmentConfig.current` resolves from Flutter's own `appFlavor` (`package:flutter/services.dart`, backed by `FLUTTER_APP_FLAVOR`, set directly by the Flutter CLI when `--flavor` is passed — no separate dart-define plumbing needed or possible). **No default case exists** — a missing (`null`, from a bare `flutter run`/`flutter build`) or unrecognized flavor throws a `StateError` immediately rather than silently resolving to production.
- **`--dart-define=ENVIRONMENT=...` is fully removed.** An earlier version of this module used both `--flavor` and a separate `--dart-define=ENVIRONMENT=...`, cross-checked at runtime via `package_info_plus` to catch the two disagreeing. That cross-check (and the dependency) is gone: with only one selector left, there is no second, independently-settable value left to disagree with it, so the whole class of "flavor/environment mismatch" bug this was guarding against can no longer occur by construction.
- `lib/main.dart`'s `Firebase.initializeApp(...)` calls `AppEnvironmentConfig.firebaseOptions` — the one, centralized wiring point; no screen or service branches on environment directly.
- All three environments return real, distinct, generated `FirebaseOptions` (`lib/firebase_options_dev.dart`, `firebase_options_staging.dart`, `firebase_options_prod.dart` — each generated from that environment's actual registered app, never copied from another).
- The non-prod `Banner` ribbon (green "DEV"/orange "STAGING", none for `prod`) is unchanged.

Protected by two test files:
- `test/app_environment_test.dart` (11 cases) — flavor parsing (including the `null`/missing case), per-environment project-id mapping, distinctness, and that every environment's real `FirebaseOptions.projectId` matches only its own project.
- `test/environment_config_consistency_test.dart` (6 cases) — a *structural* "one environment identity" check spanning native config → Dart mapping: reads the actual committed `android/app/src/<flavor>/google-services.json` and `ios/Runner/Firebase/<env>/GoogleService-Info.plist` files and asserts each one's `project_id`/`PROJECT_ID` matches `AppEnvironmentConfig.projectIdFor(...)` for that environment — catching drift if a config file is ever regenerated against the wrong project, independent of any runtime check.

**Commands developers use today (dev-first — see "Development becomes dev-first" below):**
```
flutter run --flavor dev            # normal local development
flutter run --flavor staging        # pre-release verification
flutter run --flavor prod           # PRODUCTION — not for routine use
flutter build apk --debug --flavor dev   # what CI runs
```
A bare `flutter run`/`flutter build` with no `--flavor` fails clearly (a thrown `StateError`, not a silent prod connection) — this remains an intentional, deliberate behavior change from before Phase 1B, where the app had no environment concept at all and always pointed at `gojobs-187af`.

## Development becomes dev-first

Routine local development, from this point forward, uses the `dev` flavor against `gojobs-dev` — never production. The `prod` commands above are for the specific, deliberate cases that actually need production (verifying a production-only issue, a release build) and should never be reached for in the ordinary course of feature work. CI (`ci.yml`) builds only the `dev` flavor and never touches `gojobs-187af` or any production credential.

## Firebase service readiness audit (2026-09-11)

Registering a Firebase project and an Android/iOS app does not by itself mean the project can run GoJobs — each Firebase *product* the app actually uses has its own provisioning state. Audited directly against each project (Cloud Billing API, Identity Toolkit Admin API, Service Usage API, Firestore Admin API, Cloud Storage JSON API — all read-only), not inferred from a successful APK compile.

**Firebase products actually used by executable code** (confirmed via `pubspec.yaml` + `import` audit of `lib/`): `firebase_core`, `firebase_auth` (email/password only — `createUserWithEmailAndPassword`/`signInWithEmailAndPassword`, no OAuth/phone/anonymous provider anywhere in code), `cloud_firestore`, `firebase_storage`, `firebase_messaging`. No other Firebase product (Functions, Analytics, Crashlytics, Remote Config, App Check) is imported anywhere.

| Service | `gojobs-dev` | `gojobs-staging` | `gojobs-187af` (reference) |
|---|---|---|---|
| Firestore | ✅ Provisioned + rules/indexes deployed + live-verified — `(default)` database, `FIRESTORE_NATIVE`, `STANDARD`, `me-central2`, rules byte-match source, 8/8 indexes `READY` | ✅ Same | ✅ `(default)` database, `FIRESTORE_NATIVE`, `STANDARD` edition, location `me-central2` |
| Auth | ✅ Enabled + live-verified — Email/Password, 0 users (empty, independent, smoke-tested and cleaned up) | ✅ Same | ✅ Email/Password enabled, 5 users (real production data, untouched, never copied) |
| Storage | ✅ Provisioned + rules deployed + live-verified — default bucket `gojobs-dev.firebasestorage.app`, `US-EAST1`, `STANDARD` class, rules byte-match source | ✅ Same — `gojobs-staging.firebasestorage.app` | ✅ Bucket `gojobs-187af.firebasestorage.app`, region `US-EAST1`, `REGIONAL` class — unchanged, not touched |
| FCM | ✅ `fcm.googleapis.com` enabled; Android ready (sender ID = project number, already in `google-services.json`) — iOS blocked on APNs (see below) | ✅ Same as dev | ✅ Android ready; iOS APNs status not audited (out of scope — production push already shipping) |
| Billing plan | Blaze — linked to `GoJobs Non-Production` (`billingAccounts/0195FD-A6E292-E6AF4C`), `billingEnabled: true`, independently verified via fresh reads | Blaze — same account | Unchanged — still linked to the old closed account (`019A19-...-70B1DE`), `billingEnabled: false`, re-verified unchanged after every dev/staging billing operation this pass |

### Firestore — provisioned 2026-09-11

Created and independently verified via `firebase firestore:databases:get`: both `gojobs-dev` and `gojobs-staging` now have a `(default)` database, `FIRESTORE_NATIVE` mode, `STANDARD` edition, location `me-central2` — exact production parity, as approved. The underlying `firestore.googleapis.com` API had to be explicitly enabled first (a free, standard prerequisite; the CLI's own database-create command doesn't do this automatically) before `firebase firestore:databases:create "(default)" --location me-central2 --project <dev|staging>` would succeed. Production's Firestore (`me-central2`, unchanged) was independently re-verified untouched afterward.

### Auth — enabled 2026-09-11, via `firebase.json`'s config-as-code path

The first API route tried (`identitytoolkit.googleapis.com/v2/projects/{project}/identityPlatform:initializeAuth`) returned `BILLING_NOT_ENABLED` — but this is the endpoint for upgrading to the paid, enterprise-tier **Identity Platform** superset product, not for enabling plain Firebase Authentication, which has never required Blaze for email/password (only phone/SMS auth gained a Blaze requirement, in Sept 2024 — irrelevant here, GoJobs doesn't use phone auth). The correct, billing-free path is Firebase's own config-as-code mechanism: a `firebase.json` `"auth"` key deployed via `firebase deploy --only auth --project <alias>`. Added:
```json
"auth": {"providers": {"emailPassword": true}}
```
Deployed to `dev` and `staging` only (never `prod` — the deploy command was never run with `--project prod` or against the default project). Each deploy auto-created a "Default Web App" registration in that project (Identity Toolkit requires at least one registered app to attach its config to; neither project had a web app yet) — a side effect of the mechanism, not a deliberate additional registration, noted here for completeness. Independently verified via a read-only API read (not just trusting the deploy's own success message): `signIn.email = {enabled: true, passwordRequired: true}` in both projects. User-pool independence verified via `accounts:query`: **0 users in both `gojobs-dev` and `gojobs-staging`**, versus **5 in `gojobs-187af`** (production, untouched, never copied) — confirming genuinely separate, empty pools.

### Storage — provisioned 2026-09-11

Once `GoJobs Non-Production` billing was linked (see below), Storage was provisioned for both projects and independently verified at every step (fresh reads, never inferred from a write response or CLI exit code):

1. **`firebasestorage.googleapis.com` enabled** on `gojobs-dev` and `gojobs-staging` (Service Usage API) — a free, reversible prerequisite. Verified `state: "ENABLED"` via a fresh `GET` on each project before proceeding.
2. **Default bucket created** via the Firebase Storage control-plane API (`POST .../v1beta/projects/{project}/defaultBucket`, `{"location":"US-EAST1"}`) — the Firebase CLI (15.29.0) has no `storage:buckets:create` command, so this went through the REST API directly, using the endpoint discovered from the service's own `$discovery/rest` document rather than guessed. Result: `gojobs-dev.firebasestorage.app` and `gojobs-staging.firebasestorage.app`, both `US-EAST1`, `STANDARD` storage class. Independently re-verified via a fresh `GET .../defaultBucket` on each.
3. **`storage.rules` re-audited before deploy**: confirmed zero environment-specific literals — every rule operates only on `request.auth`/path segments, no hardcoded project ID or bucket name — so the same file is safe to deploy verbatim to any environment.
4. **Deployed** via `firebase deploy --only storage --project <dev|staging>`. **Independently verified, not trusted from CLI exit code**: fetched the live release (`projects/<id>/releases/firebase.storage/<bucket>`) and its ruleset content via the Security Rules API, SHA-256-compared against the local `storage.rules` file — **exact byte-for-byte match in both projects** (5,165 bytes, hash `78f86742f5588c6eb1b5691613a2ce85c42418b62f46a541fdb593470556f278`).
5. **Live Storage smoke test** against both real (non-emulator) projects — see the results table below.

Production (`gojobs-187af.firebasestorage.app`, `REGIONAL`, `US-EAST1`) was re-read at multiple points during this work and is unchanged throughout — same bucket, same storage class, same rules ruleset name/timestamps (last updated 2026-09-09, before this session).

### Storage live smoke verification — 2026-09-11

Same methodology as the Firestore smoke test (unique temp Email/Password account per environment, tiny in-memory test file, full cleanup with independent post-cleanup verification via the Admin-level Identity Toolkit and Storage JSON APIs — not just trusting the client SDK's own success):

| Step | dev | staging |
|---|---|---|
| Temp account created, signed in | ✅ | ✅ |
| Authorized upload (`cvs/{own uid}/smoke_test.txt`) | ✅ allowed | ✅ allowed |
| Read-back of own uploaded file (content matches) | ✅ | ✅ |
| Unauthorized cross-user write (`cvs/{other uid}/hacked.txt`) | ✅ denied, `storage/unauthorized` | ✅ denied, `storage/unauthorized` |
| Storage object deleted, verified gone (`storage/object-not-found`) | ✅ | ✅ |
| Auth account deleted, independently verified via Identity Toolkit `accounts:lookup` (empty result) | ✅ | ✅ |

Two entirely separate temporary identities were used (dev's was never reused for staging). Production received zero Storage operations — the smoke test was never pointed at `gojobs-187af`.

### Non-production billing — linked and budgeted, 2026-09-11

**Account**: `GoJobs Non-Production` (`billingAccounts/0195FD-A6E292-E6AF4C`) was created manually via the Cloud Console self-serve signup flow (the only available path — see the preflight finding below, still accurate as history). Verified **before** linking anything: `open: true`, distinct account ID from the old closed account (`019A19-...-70B1DE`).

```
GoJobs Non-Production   (billingAccounts/0195FD-A6E292-E6AF4C, open)
├── gojobs-dev        — linked 2026-09-11, billingEnabled: true
└── gojobs-staging    — linked 2026-09-11, billingEnabled: true
```
`gojobs-187af` was never linked to this account and remains on the old closed one, `billingEnabled: false` — re-verified via a fresh read after every billing operation performed this pass, including as the very last step of this session's work.

**Preflight finding** (historical, still true): a genuinely new, independent billing account (its own payment method, not a subaccount) requires the Cloud Console's self-serve signup flow — the Cloud Billing API's `billingAccounts.create` only creates **subaccounts** under an already-payment-equipped parent. Confirmed by documentation and an empirical probe.

**Linking**: `PUT .../v1/projects/<dev|staging>/billingInfo` with `{"billingAccountName": "billingAccounts/0195FD-A6E292-E6AF4C"}`. Independently verified via a **fresh `GET`** afterward (not the `PUT` response) — `billingEnabled: true` on both, `billingAccountName` matching exactly. Cross-corroborated via `firebase projects:list --json` labels (no anomalies; `gojobs-187af` still carries `firebase/storage-default-bucket: created`, unaffected).

**Budget created**: scoped to the entire `GoJobs Non-Production` account (empty `budgetFilter` — matches the whole account, which structurally excludes production since it's on a different account entirely), **$20/month**, thresholds at **exactly 5% / 25% / 50% / 100%** ($1 / $5 / $10 / $20) — all four landed exactly as requested, no substitution needed. Default notification recipients (billing account admins, via email) — no Pub/Sub topic configured, so **no automated action** is wired to these alerts (they inform, they don't disable billing, stop resources, or change plans). Independently verified via a fresh `GET` on the created budget resource, not the creation response. Creating the budget required enabling `billingbudgets.googleapis.com` on `gojobs-dev` (as the quota-project header) — first attempt used an unrelated Google-managed quota project ID that this account has no permission on, corrected to `gojobs-dev` explicitly.

**Non-billing usage safeguards** (status, 2026-09-11):
- Storage security rules (deployed, see above) already prevent unbounded reads/writes to arbitrary paths — ownership-scoped, limits *who* can write.
- Per-file size limits and MIME-type enforcement (`request.resource.size`/`request.resource.contentType` in `storage.rules`): **still not implemented anywhere** (client, rules, or backend) for any of the six live upload paths. See "Storage upload-path audit" below for the full per-path findings and proposed limits — proposed only, not implemented this pass.
- Cloud Storage lifecycle auto-deletion on dev/staging buckets: assessed, not created — see "Storage lifecycle assessment" below.

### Storage upload-path audit (abuse/cost-hardening) — 2026-09-11

**Exact inventory (corrected 2026-09-11 — an earlier verbal report miscounted this as "six live paths")**: `storage.rules` defines seven path prefixes total. Exactly **five are live** (have a real call-site in the app): `cvs/`, `user_resumes/`, `company_logos/`, `job_images/`, `portfolio_images/`. Exactly **two are dead code**, kept harmless: `profiles/`, `portfolios/` (only referenced by `storage_service.dart`'s unused methods — zero call-sites anywhere in the app). 5 live + 2 dead = 7 prefixes, matching `storage.rules`' 7 `match` blocks exactly.

Every live Storage upload call-site was re-read directly (not inferred from `storage.rules`' own comments) to check for existing size/MIME enforcement, since `storage.rules` itself contains no `request.resource.size` or `request.resource.contentType` check on any path — write rules are ownership-only. Chat screens (`student`/`job_seeker`/`freelancer`/`company` messages) were also checked and confirmed to **not** touch Firebase Storage at all (grep for `FirebaseStorage`/`ImagePicker`/`FilePicker` across all four returned nothing — text-only chat, no hidden upload path).

| Path | Call site | Client-side restriction today | Server-side (rules) restriction today | Proposed limit (not implemented) |
|---|---|---|---|---|
| `cvs/{uid}/{file}` | `jobseeker_upload_cv_screen.dart` | Extension allowlist (`pdf`,`doc`,`docx`) via `FilePicker`, trivially bypassed by any direct SDK/REST call | None | Size cap ~5 MB; `request.resource.contentType.matches('application/pdf\|application/msword\|application/vnd\\.openxmlformats-officedocument\\.wordprocessingml\\.document')` in `storage.rules` |
| `user_resumes/{uid}/{file}` | `jobseeker_resume_screen.dart` | Same as above | None | Same as above |
| `company_logos/{uid}.jpg` | `company_edit_profile_screen.dart` | `imageQuality: 70` (compression only, no dimension cap); `contentType` set to `image/jpeg` in upload metadata but client-declared, not verified against actual bytes | None | Size cap ~2 MB; `request.resource.contentType.matches('image/jpeg\|image/png')` |
| `job_images/{uid}/{file}` | `company_add_job_screen.dart` | `pickMultiImage(imageQuality: 70)`, **no cap on number of images selected per post** | None | Per-file size cap ~5 MB, MIME allowlist as above; a per-post image-count cap (e.g. 10) is not enforceable by Storage rules alone (rules are per-object, not aggregate) — would need client + future backend enforcement |
| `portfolio_images/{uid}/{file}` | `freelancer_portfolio_screen.dart` | Same pattern as `job_images` (multi-pick, no count cap) | None | Same as `job_images`, plus the same aggregate-count caveat |
| `profiles/{uid}/*`, `portfolios/{uid}/*` | `storage_service.dart` only — **zero call-sites**, dead code | N/A | None | No action needed unless revived; if revived, apply the same limits as the live path it would replace |

**Caveat noted for the record**: even a rules-side `contentType` check trusts the `Content-Type` the uploading client declares — Storage doesn't inspect file bytes/magic numbers. A determined attacker using the REST API directly (not the Flutter app) can still declare an arbitrary `Content-Type` for arbitrary bytes. Real MIME enforcement (magic-byte sniffing) needs a backend/Cloud Function step, which doesn't exist yet (Phase 6/8) — rules-side `contentType`/`size` checks are still worth adding now as a meaningful baseline (they stop accidental oversized/wrong-type uploads from the app itself, which is the overwhelming majority of real-world cases), just not represented here as a complete defense.

**Tracked, not implemented here**: `docs/ROADMAP.md`'s Phase 8 section now carries an explicit "Immediate pre-beta interim hardening" checklist (size cap + MIME allowlist per live path above, tests for allowed/rejected cases, the client-declared-`contentType` caveat, and what's deferred to the full backend-mediated redesign) — tracked as required before public beta/release, independent of the Phase 6 backend dependency. Nothing in that checklist was implemented during this environment-isolation hygiene pass.

### Storage lifecycle assessment (dev/staging auto-deletion) — 2026-09-11

**Assessed, not created.** Both dev and staging buckets are currently empty (the smoke test's own object was deleted as part of cleanup; no other object has ever been written to either bucket). A Google Cloud Storage lifecycle rule (e.g., delete objects older than 30–60 days) is straightforward to apply to a Firebase-managed default bucket via the standard GCS bucket-lifecycle API, and is trivially disabled or edited later — but **the objects it deletes are not recoverable** (no versioning is configured on either bucket), so the *policy* is reversible while its *effects on future objects* are not. Given the buckets hold no data today and there's no established QA workflow yet that depends on long-lived fixtures, this doesn't clear the "obviously safe and reversible" bar for auto-creating a irreversible-by-object deletion policy without a decision on retention window and whether any team workflow expects files to persist longer. **Recommendation**: a 30–60 day auto-delete policy scoped to `gojobs-dev`/`gojobs-staging` only (never production) is reasonable cost hygiene once real usage patterns exist — revisit this once dev/staging see actual QA/test traffic, at which point the right retention window will be clearer.

### Rules/indexes parity — deployed 2026-09-11

Goal is **schema/security parity** with production's `firestore.rules`/`storage.rules`/`firestore.indexes.json` — never copying live production *data*, never weakening rules for convenience. Both rule files and the index file were inspected before deploying: neither contains any hardcoded project ID, UID, or other environment-specific literal — the rules operate purely on `request.auth`/`resource.data`/collection paths, so deploying them as-is doesn't weaken anything relative to production.

```
firebase deploy --only firestore:rules,firestore:indexes --project dev
firebase deploy --only firestore:rules,firestore:indexes --project staging
```
Both succeeded. **Independently verified, not just trusted from the deploy's exit code**: fetched the actual deployed ruleset content from each project via the Security Rules API and byte-compared it against the local `firestore.rules` — **exact match in both projects** (13,434 bytes each). All 8 composite indexes from `firestore.indexes.json` deployed to both; initially `CREATING` (asynchronous), polled and confirmed **`READY` (8/8) in both projects** before validation.

**Storage half**: deployed 2026-09-11, once the default buckets existed — see "Storage — provisioned 2026-09-11" above for the full byte-verification detail.
```
firebase deploy --only storage --project dev
firebase deploy --only storage --project staging
```

### Live smoke verification — 2026-09-11

A one-time, controlled, non-production verification against the real `gojobs-dev` and `gojobs-staging` projects (not the emulator), using a uniquely-named temporary Email/Password account per environment, cleaned up completely afterward:

| Step | dev | staging |
|---|---|---|
| Account creation | ✅ | ✅ |
| Sign-in (separate from creation) | ✅, uid matches | ✅, uid matches |
| Identity isolated to the named project | ✅ (`gojobs-dev`) | ✅ (`gojobs-staging`) |
| Authorized write (`users/{uid}/saved_jobs/{id}`, caller's own) | ✅ allowed | ✅ allowed |
| Unauthorized write (a different uid's `saved_jobs`) | ✅ denied, `permission-denied` | ✅ denied, `permission-denied` |
| Firestore cleanup, verified gone | ✅ | ✅ |
| Auth account deleted, verified via independent user-count check | ✅ (0 users) | ✅ (0 users) |

Note: the authorized-write test deliberately targets `users/{uid}/saved_jobs/{id}` (an existing app collection pattern with owner-scoped `read, write`), not the `users/{uid}` parent document — `firestore.rules` sets `allow delete: if false` on the parent doc by design (account deletion must go through a controlled backend flow, never a raw client delete), so a doc written there could never be cleaned back up by a client-only script. A first attempt using the parent doc surfaced exactly this and was corrected before any state was left behind — the resulting orphaned test doc/account were removed via direct, already-authorized IAM access (the same access used for the read-only audits throughout this phase), not a new credential.

Production (`gojobs-187af`) received zero write operations this turn — the smoke test was never run against it, and no live test account was created there.

### FCM

Android: automatically ready in all three projects once the app is registered (already done) — no separate "enable" step exists for FCM itself, the sender ID is the project number, already embedded in each flavor's `google-services.json`. iOS: requires an APNs authentication key or certificate uploaded to each Firebase project's Cloud Messaging settings, which requires an Apple Developer Program account and macOS/Apple Developer portal access — **not attempted, no Apple credential requested**, tracked as remaining iOS work alongside the Xcode scheme wiring below.

## iOS status (accurate as of 2026-09-11 — not claimed complete)

- ✅ Shared/Dart config prepared (`AppEnvironmentConfig` is platform-agnostic; works identically once iOS schemes exist).
- ✅ Firebase iOS apps registered (all three environments).
- ✅ Per-environment `GoogleService-Info.plist` files prepared and committed.
- ✅ Per-environment `.xcconfig` files prepared (bundle ID, product name).
- ❌ Xcode scheme/build-configuration wiring — **not done**. `project.pbxproj` was not hand-edited (see "iOS environment configuration" above for why).
- ❌ macOS/Xcode build verification — **not done**, not claimed done.
- ❌ APNs configuration for FCM — **not done**, requires Apple Developer access.
- Apple signing/provisioning/`DEVELOPMENT_TEAM` — **untouched**, per instruction.

This remains genuinely incomplete and is tracked as a separate remaining Phase 1B platform task, to be finished either in an actual macOS environment or explicitly deferred to a later phase. See "iOS legacy-config safety audit" above for the risk assessment and the explicit **DO NOT run iOS against live Firebase until this wiring is complete** constraint — not because a legacy config is currently at risk of being silently consumed (it isn't), but because none of this has ever been built or run.

## Web platform status (audited 2026-09-11 — unsupported/deferred, not environment-isolated)

**Not currently a supported GoJobs target.** No active CI/CD pipeline builds or deploys web: `ci.yml` (the only workflow) never invokes `flutter build web`. A `Dockerfile` in the repo still does (`flutter build web --release` → nginx), but it is not wired into any GitHub Actions workflow (the Docker Hub publishing step was removed in Phase 1A) — it would only run if someone manually built the image locally. Web is not part of this engagement's active development surface.

**`appFlavor` cannot select an environment on web today.** The Dart-side mechanism (`AppEnvironmentConfig.current` → `parseFlavor(appFlavor)`) is platform-agnostic in principle, but every per-environment options class (`DefaultFirebaseOptions{Dev,Staging,Prod}`) checks `kIsWeb` **first** and unconditionally throws `UnsupportedError` before ever reaching a real config — confirmed by reading all three files; no other `kIsWeb` branch exists anywhere in `lib/`. **Any** `flutter build web`/`flutter run -d chrome` today — regardless of flavor — crashes immediately at `Firebase.initializeApp()`. This is the same fail-loud, no-prod-fallback design already used elsewhere, just resulting in "web is completely non-functional" rather than "web is safe and usable."

**`web/firebase-messaging-sw.js` removed 2026-09-11.** It was a static JavaScript file (Firebase JS SDK compat, not Dart/Flutter output) that hardcoded production's Firebase config directly — `projectId: "gojobs-187af"`, production's API key and sender ID — with no relationship to `appFlavor` at all, since static files under `web/` are copied verbatim into `build/web/` by `flutter build web` regardless of `--flavor`. A repository-wide reference audit before removal found: no Dart code imports or registers it by name; `web/index.html` and `web/manifest.json` don't reference it; no CI workflow builds web at all; `NotificationService`'s `FirebaseMessaging.instance` usage never gets a chance to run its own web auto-registration convention, because `Firebase.initializeApp()` already throws first on any web build (see below) before any messaging setup code executes. Genuinely dead weight — a dormant, production-bound artifact for a platform that isn't supported, with no code path that needed it. Removed rather than left in place. **Web push/FCM is now disabled/deferred** — there is no service worker of any kind shipping with a web build until proper per-environment web FCM configuration is designed and implemented alongside the rest of web's environment isolation.

**Tracked Phase 1B platform follow-up**: design and implement real per-environment web support — (1) a per-environment `FirebaseOptions.web` for `AppEnvironmentConfig` (replacing the unconditional `kIsWeb` `UnsupportedError` in all three options classes) if/when web becomes an active target; (2) a build-time templating mechanism for a new, environment-aware `firebase-messaging-sw.js` (three versioned files selected/copied per flavor, or a post-build substitution step) if/when web push is needed — not simply restoring the removed file. Until then: **web is recorded as unsupported/deferred, not production-ready, and must not be treated as environment-isolated.** The three historical Phase 0 audit documents (`docs/architecture/EXISTING_SYSTEM.md`, `docs/operations/PRODUCTION_READINESS.md`, `docs/security/SECURITY_AUDIT.md`) still reference the removed file by name — left as-is deliberately, since they document the state of the repository *as found* at the time of that audit, not current living architecture.

## Platform completion status (2026-09-11)

| Platform | Status |
|---|---|
| **Firebase environment infrastructure** (dev/staging/prod project mapping — Firestore, Auth, Storage, rules, billing) | ✅ Complete for all three projects. |
| **Android** | ✅ Environment isolation implemented and validated — three flavors, distinct `applicationId`s, verified native/Dart Firebase mapping via built-APK inspection, no legacy fallback config remaining. |
| **iOS** | ⚠️ Firebase registrations and config artifacts (plists, xcconfigs) prepared for all three environments; fail-loud (no-prod-fallback) behavior confirmed safe via static analysis. Xcode scheme/build-configuration wiring, plist bundle wiring, APNs, signing, and any actual macOS build/run verification **remain fully deferred** — not attempted, not claimed done. **Do not run against live Firebase until this wiring is complete.** |
| **Web** | ❌ **Unsupported/deferred.** Not environment-isolated — `appFlavor` cannot select a web config today (unconditional throw). The production-hardcoded messaging service worker was removed 2026-09-11; no service worker of any kind ships with a web build now. Not part of any active CI/CD path. Not to be treated as production-ready or safe to deploy with real traffic until the tracked follow-up above is resolved. |

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

**Option 1 — promote in place.** `gojobs-187af` becomes `gojobs-production`, confirmed by the project owner. Fresh `gojobs-dev` and `gojobs-staging` projects are created alongside it; no data migration out of `gojobs-187af` is needed. **Update 2026-09-10**: `gojobs-dev` and `gojobs-staging` now exist (created via `firebase projects:create`, verified accessible via `firebase use <alias>` — note `firebase projects:list` itself lagged behind reality by several seconds after creation, a Firebase CLI listing-cache quirk, not a real absence). Both are empty — no Firestore/Storage data, no registered apps, default (unmodified) rules if any.

**Consequence for Phase 2/4 sequencing**: since `gojobs-187af` is being promoted rather than replaced, its live Firestore/Storage rules must be confirmed and hardened *before* it carries any traffic the team is relying on as "production" — this makes the rules-confirmation step (`SECURITY_AUDIT.md` C-3) a prerequisite for Phase 2 sign-off, not just a Phase 4 task. Until those rules are confirmed adequate (or tightened), treat `gojobs-187af` as exposed per the C-1/C-2/C-3 findings — do not treat "we chose to keep it as production" as evidence the current data is already safe.
