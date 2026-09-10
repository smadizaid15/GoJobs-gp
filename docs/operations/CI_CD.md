# GoJobs — CI/CD

Status: Phase 1 foundation — **implemented** on branch `feature/phase1-engineering-foundation` (2026-09-09), not yet merged or pushed. The "current state" section below is now historical (describes what existed before this branch); the "Phase 1 minimal foundation" section describes what was proposed and has since been built, with exact differences noted inline.

## Current state (audited fresh, both workflow files read in full — historical, see Implementation below)

**`.github/workflows/main.yml`** ("Backend CI/CD (Docker Hub)")
- Triggers on every push to `main`, plus manual dispatch. No PR trigger.
- Single job: checkout → Docker Hub login → build and **unconditionally push** `zaidsmadii/gp1-app:latest` — the same floating tag every time, no per-commit/per-branch tag.
- No test, lint, or build-verification step precedes the push. A prior `test-and-build` job existed and was deleted from this workflow's history along with its `needs:` dependency (confirmed via `git log -p` on this file during the earlier third-pass audit) — this is a real regression, not just a gap that was never filled.
- Builds and ships the **Flutter web** output via the repo's `Dockerfile` + `nginx.conf` — this workflow is mislabeled; there is no backend for it to build yet.
- Passes `FIREBASE_OPTIONS_DART` and `API_CONFIG_DART` as Docker build args; the Dockerfile only consumes the latter — the former is silently dropped (a real, if low-severity, misconfiguration, unrelated to security).

**`.github/workflows/non-functional.yml`** ("Non-Functional - Security & Health")
- Triggers on push and PR to `main`.
- Steps: checkout → Flutter setup (**`flutter-version: '3.x'`, a floating selector**, not pinned) → `flutter pub get` → `flutter pub deps` → `flutter pub outdated`.
- Neither `pub deps` nor `pub outdated` performs real dependency vulnerability scanning — the first prints the dependency tree, the second reports version staleness. An earlier version of this same workflow (before a rename) ran `flutter analyze` and `dart format --set-exit-if-changed`; both were removed when the job was renamed to "security-audit," meaning current CI provides **strictly less** static-analysis coverage than an earlier version of itself, not just historically-always-weak coverage.
- No `flutter test` step exists or has ever existed in this workflow.

**Net assessment**: today's CI provides no quality gate and no security gate. Every push to `main` — the only branch that exists — triggers an unconditional Docker Hub publish with nothing standing in front of it.

## Phase 1 minimal CI foundation (implemented, 2026-09-09, branch `feature/phase1-engineering-foundation`)

Scope discipline: this is the smallest CI setup that actually gates something, matching this phase's "foundation only" constraint — not the full staging/production pipeline from `docs/architecture/ENVIRONMENTS.md`'s CI/CD → environment mapping table, which depends on `gojobs-dev`/`gojobs-staging` existing (Phase 2) and is out of scope here.

`.github/workflows/non-functional.yml` was renamed to `.github/workflows/ci.yml` and rewritten (not left alongside a new file — one workflow, converted in place), triggered on every PR and every push to `main`:

```
jobs:
  flutter-checks:
    - actions/checkout@v4
    - subosito/flutter-action@v2, flutter-version: '3.44.2' (exact, not '3.x')
    - flutter pub get
    - dart format --output=none --set-exit-if-changed .     # formatting gate
    - flutter analyze                                         # restores what was removed
    - flutter test                                              # now passes — see note below
    - flutter build apk --debug                                  # build-verification only, not a release build

  rules-tests:
    - actions/checkout@v4
    - actions/setup-node@v4, node-version: '24.21.0'
    - actions/setup-java@v4, temurin 21 (matches the JBR OpenJDK 21.0.10 used
      locally throughout this engagement; ubuntu-latest ships a JDK anyway,
      but this pins the version explicitly rather than floating with
      whatever the runner image happens to include)
    - npm ci (working-directory: firebase-emulator-tests)
    - npm install -g firebase-tools@15.29.0 (matches DEVELOPMENT_WORKFLOW.md's
      audited CLI version; not added as a project devDependency)
    - firebase emulators:exec "cd firebase-emulator-tests && npm test"
```

No `backend-checks` job was added — `services/api/` does not exist yet, and an empty placeholder job would run nothing and verify nothing, which is noise rather than foundation. It will be added in the phase that scaffolds the backend.

Explicitly **not** part of this foundation, by design:
- **No production deployment step of any kind.** Every deploy performed so far in this engagement (the interim Firestore/Storage rules) was run manually, once, with explicit per-action approval — that discipline continues; CI does not get deploy credentials in this phase.
- **No Docker Hub push anywhere in CI.** `main.yml` was removed outright (not disabled, not left running) rather than "left alone" as originally proposed — it unconditionally published a Flutter-web image with `API_CONFIG_DART` baked in on every push to `main`, gated by nothing, which is incompatible with "no CI workflow automatically deploys or publishes anything." See "Legacy Docker Hub workflow removal" below. A real deploy/publish pipeline is separate, later, explicitly-approved work — not created by this batch.
- **No staging/production environment targeting** — there's nowhere to target yet (Phase 2).

**The `flutter test` blocker is resolved, not routed around.** `test/widget_test.dart` (the stock template smoke test that pumped `GoJobsApp` directly) is replaced by `test/theme_provider_test.dart`. Investigation (empirical, not assumed) showed the failure had two layers: (1) `GoJobsApp` requires a `MultiProvider([ThemeProvider, AuthProvider])` ancestor that the original test never supplied — fixable by wrapping it; but (2) `SplashScreen` (the app's initial route) reads `AuthProvider` after a 2-second `Future.delayed`, and `AuthProvider`'s constructor eagerly calls `FirebaseAuth.instance`, which throws `FirebaseException([core/no-app])` in a plain `flutter test` run (confirmed by advancing the fake test clock past the delay) because `Firebase.initializeApp()` is never called and there's no emulator to talk to. Pumping the full app is therefore inherently non-hermetic without a Firebase-mocking dependency this batch was not scoped to add. `ThemeProvider` — the one provider with no Firebase dependency — is exercised directly instead, as a real regression test of production logic (default theme, stored-preference load, toggle + persistence) rather than an assertion-free smoke test. `flutter test` now passes cleanly (3/3) and can be a real, unconditional CI gate.

## Legacy Docker Hub workflow removal

`.github/workflows/main.yml` ("Backend CI/CD (Docker Hub)") is **deleted**, not modified or disabled-in-place, as the cleanest reviewable form of removal — git history retains the full file if a real deploy pipeline design later wants to reference or resurrect parts of it. Rationale: it triggered on every push to `main` with no path filter and no test/lint gate of any kind, and unconditionally built and published `zaidsmadii/gp1-app:latest` to Docker Hub using the `API_CONFIG_DART` GitHub Actions secret as a Dockerfile build arg — i.e., it could republish a client-side AI API key on every ordinary push, through a channel this engagement's secret remediation (H-1) never touched (that work covered the Groq key hardcoded in `lib/config/api_config.dart` on disk and in git history; it did not and could not inspect or rotate the separate `API_CONFIG_DART` value stored as a GitHub Actions secret). No replacement production-deployment workflow was created — per instruction, that is separate, later work.

**The Dockerfile's `ARG API_CONFIG_DART` injection mechanism has since been removed (2026-09-10), not merely deprecated.** It was initially left in place on 2026-09-09 because `lib/services/ai_service.dart` imports `lib/config/api_config.dart` directly and that file was gitignored — absent from a fresh checkout entirely, which meant the Dockerfile's `flutter build web` step needed *something* to create the file first. A follow-up fresh-checkout verification confirmed this was a real, not theoretical, break: a clean checkout without the ignored file produced 3 compile errors from `flutter analyze` and an outright `flutter build` failure. The correct fix was not to have CI (or the Dockerfile) manufacture the file at build time — that's just a different-shaped secret-injection mechanism — but to make the repository itself fresh-clone buildable: `lib/config/api_config.dart` is now **tracked**, containing only `static const String groqApiKey = '';`, no real credential ever. With the file present via the ordinary `COPY . /app` step, the Dockerfile's `ARG`/base64-decode block became not just unnecessary but actively harmful to keep — with the build-arg unset, decoding an empty string would silently overwrite the good tracked file with a zero-byte one, reintroducing the same failure. It has been deleted from the Dockerfile entirely. **This is the concrete manifestation of the architectural rule going forward: AI provider secrets must never be compiled into a Flutter client, mobile or web** — this Dockerfile now has no mechanism to accept one at all, and none should be reintroduced. The structural end-state is unchanged: the backend AI proxy already designed in `docs/architecture/TARGET_ARCHITECTURE.md` (Flutter → backend route → `AIProvider` → Groq/OpenAI/etc., key held server-side in Secret Manager, per `docs/architecture/ENVIRONMENTS.md`) is what eventually lets the client drop `api_config.dart` altogether, not just keep it empty.

## What this explicitly does not change

- No GitHub repository settings (branch protection, required status checks) are changed — those are configured outside this repo and require explicit action, noted in `docs/architecture/DEVELOPMENT_WORKFLOW.md`.
- No Firestore/Storage rules test result gates a deploy yet — the rules-tests job above is a CI check, not a deploy trigger, since there is no automated deploy pipeline in this phase at all.
- No secret is read, written, or consumed by `ci.yml` — every step in both jobs runs against public inputs (the repo checkout, public package registries, and the local Firebase Emulator Suite, which never touches the live `gojobs-187af` project).
