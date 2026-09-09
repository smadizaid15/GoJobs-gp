# GoJobs — CI/CD

Status: Phase 1 foundation design. The "current state" section is a fresh audit as of 2026-09-09; the "Phase 1 minimal foundation" section is proposed, not implemented — no workflow files have been changed by this document.

## Current state (audited fresh, both workflow files read in full)

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

## Phase 1 minimal CI foundation (proposed — not implemented this pass)

Scope discipline: this is the smallest CI setup that actually gates something, matching this phase's "foundation only" constraint — not the full staging/production pipeline from `docs/architecture/ENVIRONMENTS.md`'s CI/CD → environment mapping table, which depends on `gojobs-dev`/`gojobs-staging` existing (Phase 2) and is out of scope here.

Proposed single workflow, `.github/workflows/ci.yml`, triggered on every PR and every push to `main`:

```
jobs:
  flutter-checks:
    - actions/checkout
    - subosito/flutter-action, pinned to the exact version from
      docs/architecture/DEVELOPMENT_WORKFLOW.md (not '3.x')
    - flutter pub get
    - dart format --output=none --set-exit-if-changed .     # formatting gate
    - flutter analyze                                         # restores what was removed
    - flutter test                                              # currently 1 failing test — see note below
    - flutter build apk --debug                                  # build-verification only, not a release build

  rules-tests:
    - actions/checkout
    - actions/setup-node, pinned per DEVELOPMENT_WORKFLOW.md
    - npm ci --prefix firebase-emulator-tests
    - firebase emulators:exec "cd firebase-emulator-tests && npm test"
      # requires a JDK on the runner — ubuntu-latest ships one; document
      # the exact version expectation once this is actually implemented

  backend-checks:
    # does not exist yet — added once services/api/ is scaffolded in a
    # later, separately-approved phase. Listed here now so the CI file's
    # eventual shape is agreed, not so it runs today.
    - lint / typecheck / unit tests / build, same pattern as flutter-checks
```

Explicitly **not** part of this foundation, by design:
- **No production deployment step of any kind.** Every deploy performed so far in this engagement (the interim Firestore rules) was run manually, once, with your explicit per-action approval — that discipline continues; CI does not get deploy credentials in this phase.
- **No Docker Hub push tied to this workflow.** `main.yml`'s existing behavior is left alone by this proposal (not modified, not removed) — folding it into a reasoned CI/CD story is Phase 13 scope, not Phase 1 foundation. Flagging, not fixing: it will keep firing on every push to `main` unless/until you ask for it to be changed.
- **No staging/production environment targeting** — there's nowhere to target yet (Phase 2).

**Known blocker to enabling `flutter test` as a hard gate**: `test/widget_test.dart` currently fails (`ProviderNotFoundException` — doesn't wrap `GoJobsApp` in the `MultiProvider` `main()` normally provides), independently confirmed pre-existing and unrelated to any of this engagement's changes. Turning on `flutter test` as a blocking CI step today would make every PR red from the start. Two options, both requiring your decision before this workflow is implemented: (a) fix the one test first (small, isolated, arguably still "foundation" not "feature migration"), or (b) mark it `expected failure`/skip it explicitly with a tracked follow-up, so CI is honest about a known gap rather than silently green. Recommend (a) given the fix is a few lines in the test file itself, not app code — but this is listed as a decision, not assumed.

## What this explicitly does not change

- `main.yml` is not modified by this document — flagged above as inconsistent with a real CI/CD story, left alone per this phase's "foundation only" scope.
- No GitHub repository settings (branch protection, required status checks) are changed — those are configured outside this repo and require your action, noted in `docs/architecture/DEVELOPMENT_WORKFLOW.md`.
- No Firestore/Storage rules test result gates a deploy yet — the rules-tests job above is a CI check, not a deploy trigger, since there is no automated deploy pipeline in this phase at all.
