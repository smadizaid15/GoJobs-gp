# GoJobs — Development Workflow & Toolchain

Status: Phase 1 foundation. Toolchain pins and CI enforcement are **implemented** on branch `feature/phase1-engineering-foundation` (2026-09-09), not yet merged or pushed. Branch protection rules are still proposed only — that's a GitHub repository setting, not a file this repo can commit.

## Branch strategy

Using the brief's intended model — no evidence in this repo suggests a reason to deviate:

| Branch | Purpose | Deploys to | Protection |
|---|---|---|---|
| `main` | Production | `gojobs-187af` | No direct pushes once protected (currently unprotected — see Decisions below); merges only via reviewed PR from `develop` or a `hotfix/*` branch |
| `develop` | Staging / integration | `gojobs-staging` (once it exists — Phase 2, not this phase) | Merges via PR from `feature/*`/`fix/*` branches |
| `feature/*` | New work | `gojobs-dev` (once it exists) / local + emulator | No restrictions — this is where day-to-day work happens |
| `fix/*` | Non-urgent bug fixes | Same as `feature/*` | Same |
| `hotfix/*` | Urgent production fixes | Branches from `main`, merges back to both `main` and `develop` | Same review requirement as any `main` merge |

**Current reality this replaces**: this repo has exactly one branch, `main` (confirmed via `git branch -a` — no `develop`, no feature branches, ever, per the full 87-commit history reviewed across this engagement). Every commit in this repo's history was made directly to `main`. `develop` does not exist yet and is not created by this phase — per your constraint not to create new Firebase projects, and since a `develop` branch with nowhere to deploy to is premature, creating the branch is deferred to whenever `gojobs-staging` is actually stood up (Phase 2), so the branch's existence and its deploy target land together.

**What Phase 1 actually proposes doing now** (documentation only, per this phase's scope):
1. Document the model (this file).
2. Recommend enabling branch protection on `main` in GitHub's repository settings (requires a required-review rule, no force-push, no direct push) — **this is a GitHub repository-settings change, not a file in this repo, and needs your explicit action or approval to configure**, since it's not something committable.
3. Defer creating `develop` until `gojobs-staging` exists (Phase 2), so there's never a branch that deploys nowhere.

## Toolchain — current state (audited live on this machine, 2026-09-09)

| Tool | Version found | Pinned in repo today? |
|---|---|---|
| Flutter | 3.44.2 (stable channel, revision `c9a6c48423`) | **Yes** — `.fvmrc` (2026-09-09) |
| Dart | 3.12.2 (bundled with the above Flutter) | Tracks the Flutter pin; `pubspec.yaml`'s lower-bound (`sdk: ^3.10.4`) is unchanged |
| Java | OpenJDK 21.0.10 (Android Studio's bundled JBR — no standalone JDK on `PATH`) | No — documented here as the tested-against version; CI pins `temurin` 21 separately (see `docs/operations/CI_CD.md`) |
| Gradle | 8.14 (via `android/gradle/wrapper/gradle-wrapper.properties`) | **Yes** — the wrapper already pins this correctly |
| Android Gradle Plugin (AGP) | 8.11.1 (`android/settings.gradle.kts`) | Yes |
| Kotlin Gradle plugin | 2.2.20 (`android/settings.gradle.kts`) | Yes |
| `com.google.gms.google-services` | 4.3.15 (`android/settings.gradle.kts`) | Yes |
| Android `compileSdk`/`minSdk`/`targetSdk` | 36 / 24 / 36 | **Yes** — explicit integers in `android/app/build.gradle.kts` (2026-09-09), replacing the implicit `flutter.xxxSdkVersion` references |
| NDK | `28.2.13676358` (implicit-default mechanism, unchanged) | No — out of scope for this pass, only `compileSdk`/`minSdk`/`targetSdk` were requested |
| Node.js | v25.2.1 installed on this dev machine; **`.nvmrc` pins the project to 24.21.0 LTS** instead (see below) | **Yes** — `.nvmrc` (2026-09-09) |
| npm | Bundled with whichever Node satisfies `.nvmrc` | No — not pinned separately this pass, by instruction; a backend `package.json` will carry its own `engines` constraint when `services/api/` is scaffolded |
| Firebase CLI | 15.29.0 | No — no per-repo pin mechanism exists; CI installs this exact version explicitly (`docs/operations/CI_CD.md`) rather than floating |
| Docker | 29.1.3 | N/A (used only for the Flutter-web-in-nginx image today; not version-sensitive for that use) |
| Python | **Not installed** on this machine (confirmed during the secret-remediation phase — `git-filter-repo` couldn't run, BFG Repo-Cleaner was used instead) | N/A — not currently a project dependency, but relevant if any future tooling assumes Python is present |
| git | 2.51.2.windows.1 | N/A |

CI (`ci.yml`, renamed from `non-functional.yml`) now pins Flutter to the exact `3.44.2` version below rather than floating `3.x` — see `docs/operations/CI_CD.md`.

## Pinning (implemented 2026-09-09)

Goal: local development and CI resolve to the *same* Flutter/Dart/Node versions, and Android SDK levels stop drifting silently with whatever Flutter happens to be installed.

1. **Flutter/Dart**: `.fvmrc` pins Flutter `3.44.2` (the version already in use — pinning what's proven working, not a fresh upgrade bundled into this same change). Using the pin locally requires installing [FVM](https://fvm.app/) as the standard local dev tool going forward; a full onboarding guide (`docs/DEVELOPMENT_SETUP.md`) is still not created — out of scope for this pass, which only creates the pin file itself.
2. **Node.js**: `.nvmrc` pins **Node 24 LTS** (codename "Krypton," `24.21.0`), not the `25.2.1` installed on this dev machine. Node 25.x is a Current release line, not LTS — it does not receive the long-term support/security-maintenance guarantee a backend should be pinned to, and reaches end-of-life well before a production service built on it should have to force an upgrade. Node 24 entered LTS in October 2025 and is supported into 2028, which is the right target for both the future `services/api/` backend and `firebase-emulator-tests/` (previously developed against whatever Node happened to be installed, i.e. 25.2.1). [Node.js 24.21.0 (LTS)](https://nodejs.org/en/blog/release/v24.21.0), [endoflife.date/nodejs](https://endoflife.date/nodejs)
3. **Android SDK levels**: the implicit `flutter.compileSdkVersion`/`flutter.minSdkVersion`/`flutter.targetSdkVersion` references in `android/app/build.gradle.kts` are replaced with explicit integers (`compileSdk = 36`, `minSdk = 24`, `targetSdk = 36`) matching the values they previously resolved to, so a future Flutter upgrade can't silently change the Android build target without a deliberate, reviewed change to this file. `ndkVersion` is left on its implicit default — not part of this pass's requested scope.
4. **Firebase CLI**: still no per-repo pin mechanism (it's a global npm/standalone install, not a project dependency) — CI installs the audited version (15.29.0) explicitly rather than floating; local developers should verify their installed version matches before running a rules/indexes deploy.
5. **npm**: intentionally not pinned separately this pass — it tracks whatever ships bundled with the pinned Node version. A `services/api/` backend `package.json` will carry its own `engines` constraint once that's scaffolded, per the same reasoning that applies to Flutter/Dart above.
