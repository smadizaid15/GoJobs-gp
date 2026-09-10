# GoJobs — Existing System Architecture

Status: **Audit document — describes the repository as found, pre-transformation.**
Last verified: 2026-09-08, against `main` branch, commit `f4ac9d9`.

This document is factual, not aspirational — it records what actually exists in the repository today, verified by reading source files directly (not inferred from filenames, READMEs, or comments). Where the README or in-code comments make a claim that the source contradicts, both are noted.

---

## 1. Existing Flutter architecture

- **Framework**: Flutter (Dart SDK `^3.10.4`, `pubspec.yaml`). No Flutter SDK version is pinned anywhere (no `.fvmrc`, `.tool-versions`, or equivalent) — `.metadata` only records a git revision from the last `flutter create`/`flutter migrate` run, which is not build-enforced.
- **Entry point**: `lib/main.dart`. Initializes Flutter bindings, overrides `ErrorWidget.builder` to hide overflow errors app-wide (`main.dart:14-17`, commented `// HACK 1`), calls `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`, best-effort-initializes `NotificationService` (FCM) in a try/catch, and wraps the app in `MultiProvider` registering exactly two providers: `ThemeProvider` and `AuthProvider` (`main.dart:31-34`). `MaterialApp.router` is configured with `routerConfig: AppRouter.router`; text scaling is force-locked to `1.0` (`main.dart:57-65`, commented `// HACK 2`), overriding the OS accessibility setting.
- **State management**: the `provider` package (`^6.1.2`) is a declared dependency, but only 2 of the 9 files in `lib/providers/` contain any code:
  - `auth_provider.dart` (249 lines) — holds auth status, error message, current `User`, and `userType`; delegates all Firebase calls to `AuthService`.
  - `theme_provider.dart` (28 lines) — theme mode, persisted via `SharedPreferences`.
  - `job_provider.dart`, `application_provider.dart`, `chat_provider.dart`, `course_provider.dart`, `freelancer_provider.dart`, `notification_provider.dart`, `user_provider.dart` — **all empty (1 line each), never imported anywhere.**
  - In practice, most screens bypass the provider layer and call Firestore/Storage directly — either through the `lib/services/` classes, or with inline `FirebaseFirestore.instance.collection(...)` calls embedded straight in `StatefulWidget` code.
- **Routing**: `go_router` (`^14.0.0`), configured in `lib/router/app_router.dart` — one flat `GoRouter` with **~90 `GoRoute` entries** and **no `redirect` callback, no `ShellRoute`, no route guards of any kind.** The only auth-aware navigation in the entire app is a one-shot check performed once in `lib/screens/splash/splash_screen.dart` at cold start (waits ~2s, checks `AuthProvider.user`, fetches `userType` via `AuthService.getUserType`, and does a single `switch`-based redirect to the matching role home or `/welcome`). After that initial redirect, every route — including company-only and (nonexistent) admin-shaped screens — is reachable by direct `context.go('/whatever')` navigation from anywhere, with no re-check of auth state or role.
- **Directory layout** (`lib/`):
  ```
  lib/
    config/          — api_config.dart (tracked, safe, empty AI-key placeholder as of 2026-09-10; see SECURITY_AUDIT.md H-1)
    core/
      constants/       — mostly empty stubs; app_enums.dart is the one real file
      theme/           — app_colors.dart, app_dimensions.dart, app_text_styles.dart, app_theme.dart
      utils/           — all empty stubs (app_assets, app_routes, app_strings, extensions, helpers, validators)
    firebase_options.dart
    main.dart
    models/          — 4 of 8 files implemented (JobModel, ApplicationModel, UserModel, MessageModel); 4 empty stubs
    providers/       — 2 of 9 files implemented (see above)
    router/          — app_router.dart
    screens/         — see role breakdown below
    services/        — see §7 below
    widgets/         — bottom-nav widgets are real (4, one per role); everything else is an empty stub
  ```
- **Screens by role** (file counts, `.dart` files under each subtree):

  | Role folder | Files | Subfolders |
  |---|---|---|
  | `job_seeker/` | 25 | freelancer_marketplace, home, jobs, messages, notifications, profile, saved, search, settings |
  | `student/` | 21 | courses, freelancer_marketplace, home, internships, messages, notifications, profile, saved, search, settings |
  | `company/` | 17 | applicants, home, jobs, messages, notifications, profile, settings |
  | `freelancer/` | 12 | home, messages, notifications, profile, settings (no auth subfolder — freelancers log in via the job-seeker login screen; freelancer is a UI *mode*, not a stored role) |
  | `auth/` | 15 | 5 screens × 3 flows (company / job_seeker / student) |

  The three "applicant" archetypes (job_seeker / freelancer / student) are heavily copy-pasted rather than shared: e.g. `class _Tag` is a byte-for-byte identical private widget duplicated between `jobseeker_home_screen.dart:508-532` and `student_home_screen.dart:564-588`; `student_login_screen.dart` is `jobseeker_login_screen.dart` with the class name, one route string, and a hint-text email changed (both otherwise ~440-566 lines). `lib/widgets/job_card.dart`, `applicant_card.dart`, `course_card.dart`, `message_tile.dart`, `notification_tile.dart`, and everything in `lib/widgets/common/` are literal 1-byte empty files, never imported anywhere — this is the direct cause of the duplication, since every screen had to invent its own private card/tile widget inline instead of importing a shared one. The 4 per-role bottom-navigation widgets (`jobseeker_bottom_nav.dart`, `freelancer_bottom_nav.dart`, `student_bottom_nav.dart`, `company_bottom_nav.dart`) are real but similarly triplicated (near-identical structure, differing route strings); `freelancer_bottom_nav.dart:37-46` has an apparent copy-paste bug where two distinct nav items both route to `/freelancer/profile`.
- **Loading/empty/error state handling**: genuinely applied, not happy-path-only. 50 `StreamBuilder`/`FutureBuilder` usages across 33 screen files; 30 explicitly branch on `ConnectionState.waiting`, and the rest use an equivalent `!snapshot.hasData` check. Most screens show a spinner while loading, an error message (sometimes the raw exception text) on failure, and a proper empty-state message/icon when a collection is empty. Polish is inconsistent (some nested/secondary `FutureBuilder`s inside list items skip error handling; one screen shows a stray debug `print` alongside its error UI).
- **Accessibility**: no `Semantics` usage anywhere in the codebase (0 matches). `main.dart` actively works against accessibility (see HACK 1/2 above) rather than fixing underlying issues.
- **Localization**: **not implemented.** No `.arb` files, no `l10n.yaml`, no `AppLocalizations`, no `flutter_localizations` import, no `Directionality`/`TextDirection.rtl` usage, and zero Arabic Unicode characters anywhere in `lib/`. `MaterialApp.router` in `main.dart` has no `locale`/`supportedLocales`/`localizationsDelegates`. Every UI string is a hardcoded English literal. The README's own Roadmap section (`README.md:155-158`) already lists "Arabic / RTL support" as unchecked — confirmed accurate; this is a from-scratch build, not a wiring task.

## 2. Existing backend architecture

**There is no backend.** This is the single most important architectural fact about the current system. No `package.json`, no `server/` directory, no `functions/` (Firebase Cloud Functions), and no Express/Node code exist anywhere in the repository. The Flutter app — on every platform it targets, including its **web build** — talks directly to Firebase client SDKs (`firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`).

Two things in the repo are easy to mistake for a backend and are not:
- `Dockerfile` (repo root) and `.github/workflows/main.yml` (titled "Backend CI/CD (Docker Hub)") — these build the **Flutter web output** (`flutter build web --release`) and serve the static files through **nginx** (`nginx.conf`). This is a web-frontend deployment pipeline, not an API server.
- `lib/services/` — a client-side service layer (see §7) that wraps Firebase SDK calls. These run inside the Flutter app process, not on a server; they have no independent trust boundary from the rest of the client.

Every operation the brief's target architecture expects a backend to authorize — job creation, job deletion, application status changes, profile updates — is today performed as a direct, unmediated write from the Flutter client to Firestore/Storage.

## 3. Existing Firebase architecture

- **Project**: `gojobs-187af` (single project — see §9, no dev/staging/prod split exists).
- **Products in use**: Firebase Authentication (Email/Password provider only), Cloud Firestore, Cloud Storage, Firebase Cloud Messaging. No Firebase Cloud Functions, no Firebase Hosting (web is served via the standalone nginx/Docker path instead), no Firebase App Check, no Remote Config.
- **`firebase.json`** (repo root) contains only FlutterFire CLI platform/app-ID mapping metadata (which `google-services.json`/`firebase_options.dart` to generate for which app IDs) — it has **no `firestore`, `storage`, `hosting`, or `emulators` keys.**
- **No `.firebaserc`, no `firestore.rules`, no `storage.rules`, no `firestore.indexes.json` exist anywhere in the repository.** Whatever security rules and composite indexes currently protect/serve the live project are configured entirely outside of source control (Firebase Console only) — unversioned, uncode-reviewed, and untestable via the Local Emulator Suite from this repo.
- **Client Firebase config is committed to git**: `android/app/google-services.json` and `lib/firebase_options.dart` are both git-tracked (the README incorrectly states they're gitignored — only `lib/config/api_config.dart` actually is, per `.gitignore:47`). This exposes Firebase Web/Android/iOS API keys in the repository. Per Firebase's own security model this is expected/acceptable *provided* Firestore/Storage rules and Google Cloud API-key restrictions are correctly configured — which, per the previous point, cannot be verified from this repo.
- **Web service worker mismatch**: `web/firebase-messaging-sw.js:11` uses the **iOS** app's Firebase `appId` instead of the web app's `appId` (compare against `lib/firebase_options.dart:33-34`) — a copy/paste artifact that can cause FCM web-push/analytics misattribution.

## 4. Existing database structure

Cloud Firestore, inferred entirely from client code (no schema file exists). Full field-level detail is in `docs/database/DATABASE_DESIGN.md`; summary:

| Collection | Purpose | Key fields | Written by |
|---|---|---|---|
| `users/{uid}` | One doc per account, all roles | `uid`, `email`, `userType` (`jobSeeker`\|`company`\|`student`), role-specific fields (`companyName`, `licenseNumber`, `firstName`/`lastName`, `userMode`, etc.) | `AuthService` at signup; `UserService.updateUser` thereafter (generic unrestricted map update) |
| `users/{uid}/saved_jobs/{jobId}` | Subcollection, per-user saved-job toggle | `jobId`, `savedAt` | `JobService.toggleSavedJob` |
| `jobs/{jobId}` | Job postings | `companyId` (owner), `companyName`, `title`, `location`, `workplaceType`, `employmentType`, `description`, `salary`, `isActive`, `createdAt` | `JobService.postJob`; deleted via `JobService.deleteJob` (no update/edit path exists) |
| `applications/{applicationId}` | Job applications | `jobId`, `userId` (applicant/owner), `companyId` (job owner, denormalized), `jobTitle`, `cvUrl`, `status` (`pending`\|`accepted`\|`rejected`), `createdAt` | `ApplicationService.applyForJob`; status updated via an **unguarded inline write** in `company_applicants_application.dart` (bypasses the service layer's `updateApplicationStatus`, which is defined but dead/unused) |
| `chats` / messages | Ad hoc, no dedicated model | sender/receiver/text/timestamp-shaped, handled inline per-screen | 4 separate chat screens each reimplement this independently; `lib/services/chat_service.dart` is an empty stub, `lib/services/message_service.dart` is fully implemented but never called |
| notifications (implied) | Read by notification screens | — | `NotificationService.saveTokenToFirestore()` is a stub that never actually writes — FCM token persistence is non-functional today |

No composite indexes are declared anywhere in the repo (no `firestore.indexes.json`); any composite queries in the app depend on indexes created ad hoc via the Firebase Console (or Firestore's auto-suggested-index-creation UI), again unversioned.

## 5. Existing authentication flow

1. Client calls `FirebaseAuth.createUserWithEmailAndPassword` (signup) or `signInWithEmailAndPassword` (login) via `AuthService` (`lib/services/auth_service.dart`).
2. On signup, immediately after Auth account creation, the client writes a `users/{uid}` document directly (`.set({...})`) with a `userType` field hardcoded per which signup method was called (`signUpJobSeeker` → `'jobSeeker'`, `signUpCompany` → `'company'`, `signUpStudent` → `'student'`) — no server ever sees or validates this write.
3. `sendEmailVerification()` is called at signup, but nothing in the app enforces that the email was actually verified before granting access to protected features — it's a notification only, not a gate.
4. `AuthProvider` listens to `FirebaseAuth.authStateChanges()` and, on every change, calls `AuthService.getUserType(uid)` to read the `userType` field back for client-side routing/UI purposes.
5. Password reset (`sendPasswordResetEmail`) and password update (`reauthenticateWithCredential` + `updatePassword`) both go through Firebase Auth's standard client SDK flows — no backend involvement, none needed for these specific operations.
6. **No backend ever verifies a Firebase ID token.** There is no server-side session; every subsequent Firestore/Storage operation is authorized (if at all) only by whatever Firestore/Storage Security Rules exist in the Firebase Console (unverified — see §3).
7. `lib/services/api_service.dart` is a near-verbatim **duplicate** of `auth_service.dart` (same class name `AuthService`, same three signup methods) that is not imported/used anywhere — dead code with silent-drift risk if one copy is edited without the other.

## 6. Existing authorization flow

There effectively isn't one, beyond what may exist in unversioned Firebase Console rules:

- **No role-based access control on writes.** `userType` is read only for client-side navigation/UI purposes (which home screen to route to, which nav items to show) — it is never checked before a write like `postJob()` or an application-status update. A `student`-typed account could call `JobService().postJob(...)` directly (setting `companyId` to its own uid) with nothing in the client or (as far as this repo can show) any server stopping it.
- **No ownership verification before mutating writes.** `JobService.deleteJob(jobId)` and the inline `applications/{id}.update({status})` call in `company_applicants_application.dart` both take a bare document ID and perform the write with no check that the caller's uid matches the resource's owner field (`companyId`/`userId`). See `SECURITY_AUDIT.md` findings #1 and #2 for full detail.
- **No admin role or concept exists anywhere** — no admin service, screen, claim check, or `isAdmin` flag. The only match for the string "admin" in the codebase is an unrelated job-title dropdown option (`'Administrative Assistant'`).
- **Router-level "authorization"** is limited to the one-shot splash-screen redirect (§1) — not a persistent guard, and it checks auth state only, not role, for most of the app.
- Whatever real authorization exists today is therefore either (a) enforced entirely by Firestore/Storage Security Rules that are not visible to this audit, or (b) does not exist at all. This cannot be resolved from source alone — see Open Question in the Phase 0 plan about pulling the live rules from the Firebase Console.

## 7. Existing API endpoints

None — there is no backend, so there are no HTTP API endpoints. What exists instead is a client-side "service layer" (`lib/services/*.dart`) that wraps direct Firebase SDK calls, functioning as a thin client-side data-access layer rather than an API:

| Service | Status | Notes |
|---|---|---|
| `auth_service.dart` | Active, used | Signup (×3 roles), login, logout, reset/update password, `getUserType` |
| `api_service.dart` | **Dead code** | Verbatim duplicate of `auth_service.dart`, unused |
| `job_service.dart` | Active, used | `postJob`, `getActiveJobs`, `toggleSavedJob`, `getSavedJobIds`, `getLiveJobStream`, `getCompanyJobs`, `deleteJob` — no update/edit-job function exists |
| `application_service.dart` | Partially used | `applyForJob`, `getUserApplications`, `getJobApplications` are used; `updateApplicationStatus` is defined but **never called** (the real status-update code path bypasses this service entirely — see §6) |
| `storage_service.dart` | Active, used | CV/profile-pic/portfolio upload + delete; no size/MIME enforcement (see `SECURITY_AUDIT.md` #5) |
| `user_service.dart` | Active, used | `getUser`, generic unrestricted `updateUser(uid, Map)` |
| `chat_service.dart` | **Dead code** | Empty file (1 line) |
| `message_service.dart` | **Dead code** | Fully implemented, never called — every chat screen reimplements the same logic inline instead, 4× |
| `notification_service.dart` | Partially functional | FCM init/listeners work; `saveTokenToFirestore()` is a stub that only logs, never persists — token-based targeted push is non-functional |
| `ai_service.dart` | Active, used, insecure | Calls Groq's chat-completions API **directly from the client** using a hardcoded API key (see `SECURITY_AUDIT.md` #4) |

## 8. Existing dependencies

From `pubspec.yaml` / `pubspec.lock` (all resolved versions current, no major-version lag detected):

| Package | Constraint | Resolved | Purpose |
|---|---|---|---|
| `go_router` | `^14.0.0` | — | Routing |
| `provider` | `^6.1.2` | — | State management (barely used, see §1) |
| `firebase_core` | `^3.0.0` | `3.15.2` | Firebase bootstrap |
| `firebase_auth` | `^5.0.0` | `5.7.0` | Auth |
| `cloud_firestore` | `^5.0.0` | `5.6.12` | Database |
| `firebase_storage` | `^12.0.0` | `12.4.10` | File storage |
| `firebase_messaging` | `^15.2.10` | `15.2.10` | Push notifications |
| `image_picker` | `^1.1.2` | — | Photo selection |
| `file_picker` | `^11.0.2` | — | CV/document selection |
| `url_launcher` | `^6.3.2` | — | Open CV links etc. |
| `intl` | `^0.20.2` | — | Date formatting only (not used for i18n despite being the standard package for it) |
| `google_fonts` | `^8.1.0` | — | Poppins font |
| `shared_preferences` | `^2.5.5` | — | Local key-value (theme persistence) |
| `http` | `^1.6.0` | — | Direct Groq API calls from `ai_service.dart` |
| `flutter_lints` (dev) | `^6.0.0` | — | Default lint set, unmodified |

`web/firebase-messaging-sw.js` separately loads the Firebase JS **compat SDK v10.7.1** from a CDN — one major version behind the current JS SDK line, not itself a blocker but worth bumping opportunistically.

No dependency-vulnerability scanning tool is configured (see §12 — `non-functional.yml`'s "security audit" job does not actually check for known CVEs).

## 9. Existing deployment method

- **Mobile (Android/iOS)**: no automated release pipeline exists. No signing configuration for release builds is present (see §14/`PRODUCTION_READINESS.md`) — deployment today is presumably manual/local (`flutter build apk`/`flutter build ipa` run by hand), and any such build would currently be signed with the Android **debug** keystore, which Play Console rejects on upload.
- **Web**: `.github/workflows/main.yml` ("Backend CI/CD (Docker Hub)") triggers on every push to `main`, builds a Docker image via the repo's `Dockerfile` (clones Flutter from git at `stable` HEAD, injects `FIREBASE_OPTIONS_DART`/`API_CONFIG_DART` secrets as base64-decoded build args, runs `flutter build web --release`), copies the output into an `nginx:1.21.1-alpine` image, and pushes the image to Docker Hub (`zaidsmadii/gp1-app:latest`) — no deploy step to any actual hosting target follows; the workflow's job is purely to produce and publish the image. No tests, lint, or approval gate precede this push.
- **No staging or production distinction exists anywhere** — one Firebase project, one Docker Hub tag (`:latest`, unversioned), one branch (`main`) triggering the same pipeline every time.
- **No rollback mechanism** — overwriting the `:latest` tag on every push means the previous image reference is only recoverable via Docker Hub's tag history/digest, not a deliberate rollback flow.

## 10. Existing security model

Summarized here; full ranked findings with severity, exploitation scenarios, and remediation are in `docs/security/SECURITY_AUDIT.md`. In one sentence: **the current security model is "whatever Firestore/Storage rules exist in the Firebase Console" — a set of rules this repository cannot see, version, review, or test**, layered under a client that performs zero ownership checks before its most sensitive writes (job deletion, application status changes) and ships a live third-party API key inside every build artifact.

## 11. Existing testing

`test/widget_test.dart` — a 9-line smoke test that constructs `GoJobsApp` and asserts nothing (`testWidgets('GoJobs smoke test', ...) { await tester.pumpWidget(const GoJobsApp()); }`). No `expect()` calls. No other test files exist anywhere (`**/*_test.dart`, `**/test/**`, and `integration_test/` were all searched — this is the only match). **Effectively zero test coverage**: no unit tests for services/validators/business logic, no widget tests beyond this smoke test, no integration tests, no security tests, no e2e tests.

## 12. Existing CI/CD

Two GitHub Actions workflows, both triggered on push (and PR, for one) to `main`:

- **`main.yml`** ("Backend CI/CD (Docker Hub)") — see §9. Builds and pushes the web Docker image unconditionally on every push to `main`, with no test/lint gate beforehand.
- **`non-functional.yml`** ("Non-Functional - Security & Health") — runs on push and PR to `main`. Steps: checkout, `subosito/flutter-action@v2` setup, `flutter pub get`, then `flutter pub deps` (labeled "Dependency Tree Security Check") and `flutter pub outdated` (labeled "Vulnerability & Health Audit"). **Neither command performs actual vulnerability/CVE scanning** — `flutter pub deps` prints the dependency tree, `flutter pub outdated` reports version staleness. There is no secret scanning, no SAST, no `flutter analyze` step even for lint enforcement, and no Firestore/Storage rules testing (moot today since no rules file exists to test).

No branch protection, required-status-check, or PR-approval configuration is visible from the repository content (GitHub branch protection settings live outside the repo and were not part of this file-based audit).

## 13. Existing infrastructure

- **Compute**: none dedicated to a backend (none exists). The only infrastructure artifact is the web-serving Docker image (Flutter web build + nginx), pushed to Docker Hub with no deploy target wired up in-repo.
- **`nginx.conf`** — minimal SPA config: listens on port 80, serves `/usr/share/nginx/html`, falls back to `index.html` for client-side routing (`try_files $uri $uri/ /index.html`). No HTTPS termination, security headers (CSP, HSTS, X-Frame-Options), or rate limiting configured at this layer.
- **No IaC** (Terraform, Pulumi, gcloud deployment scripts) exists anywhere in the repo.
- **No environment/project separation** (§9 of the audit's parent plan) — a single Firebase project (`gojobs-187af`) backs everything.

## 14. Existing technical debt

Consolidated list (see `docs/product/FEATURE_MATRIX.md` and `SECURITY_AUDIT.md` for the security-flavored subset):

- No backend at all — the foundational gap.
- No Firestore/Storage rules in source control.
- Massive screen-level duplication across job_seeker/freelancer/student (~58 files with heavy structural overlap).
- Dead shared-widget scaffold (`lib/widgets/` mostly empty stubs), which is the direct cause of the above.
- Provider layer 7/9 empty and unregistered; inconsistent data-access pattern (services vs. inline Firestore calls in screens).
- Duplicate dead code: `api_service.dart` ≈ `auth_service.dart`; empty `chat_service.dart`; unused `message_service.dart` (chat reimplemented 4× inline instead); non-functional `NotificationService.saveTokenToFirestore()` stub.
- Zero localization/RTL despite being a stated product requirement.
- Zero accessibility (`Semantics` usage: 0; text-scaling actively disabled).
- Zero real test coverage.
- Not store-ready: debug-signed Android release builds, default `com.example.*` bundle/application IDs on both platforms, missing iOS picker permission-description keys (will crash at runtime, not just fail review).
- No environment separation (dev/staging/prod all the same Firebase project).
- No Flutter/Dart version pin; Docker build floats to Flutter `stable` HEAD on every build.
- No structured logging, crash reporting, or monitoring anywhere.
- Minor: README's Firebase-config-gitignore claim is inaccurate; `web/firebase-messaging-sw.js` uses the wrong platform's Firebase `appId`; placeholder "A new Flutter project." text left in `web/index.html`/`web/manifest.json`; two `// HACK` comments in `main.dart` documenting intentional shortcuts (hidden overflow errors, disabled text scaling) rather than fixes.
