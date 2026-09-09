# GoJobs — Development Workflow & Toolchain

Status: Phase 1 foundation design. Proposed, not yet implemented (branch protection rules, version-pin files, and CI enforcement all require separate, explicit follow-up actions — this document defines what they should be).

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
| Flutter | 3.44.2 (stable channel, revision `c9a6c48423`) | No — no `.fvmrc`, no version file anywhere |
| Dart | 3.12.2 (bundled with the above Flutter) | No — `pubspec.yaml` only has a loose lower-bound (`sdk: ^3.10.4`) |
| Java | OpenJDK 21.0.10 (Android Studio's bundled JBR — no standalone JDK on `PATH`) | No |
| Gradle | 8.14 (via `android/gradle/wrapper/gradle-wrapper.properties`) | **Yes** — the wrapper already pins this correctly |
| Android Gradle Plugin (AGP) | 8.11.1 (`android/settings.gradle.kts`) | Yes |
| Kotlin Gradle plugin | 2.2.20 (`android/settings.gradle.kts`) | Yes |
| `com.google.gms.google-services` | 4.3.15 (`android/settings.gradle.kts`) | Yes |
| Android `compileSdk`/`minSdk`/`targetSdk` | 36 / 24 / 36 — resolved from the installed Flutter SDK's own defaults (`flutter.compileSdkVersion` etc. in `android/app/build.gradle.kts`), confirmed by reading `FlutterExtension.kt` in the installed Flutter SDK | **No** — these are implicit, would silently change if a different Flutter version builds this project |
| NDK | `28.2.13676358` (same implicit-default mechanism) | No |
| Node.js | v25.2.1 (installed on this machine; **not the proposed target** — Node 25 is a Current/non-LTS release line, not suitable to pin a backend to) | No — no `.nvmrc`, no `engines` field anywhere |
| npm | 11.6.2 (bundled with the above Node) | No |
| Firebase CLI | 15.29.0 | No |
| Docker | 29.1.3 | N/A (used only for the Flutter-web-in-nginx image today; not version-sensitive for that use) |
| Python | **Not installed** on this machine (confirmed during the secret-remediation phase — `git-filter-repo` couldn't run, BFG Repo-Cleaner was used instead) | N/A — not currently a project dependency, but relevant if any future tooling assumes Python is present |
| git | 2.51.2.windows.1 | N/A |

CI (`non-functional.yml`) uses `flutter-version: '3.x'` — a **floating** version selector, independently confirmed to not match whatever pin this document proposes unless CI is updated too (see the CI/CD design doc).

## Proposed pinning

Goal: local development and CI resolve to the *same* Flutter/Dart/Node versions, and Android SDK levels stop drifting silently with whatever Flutter happens to be installed.

1. **Flutter/Dart**: add `.fvmrc` pinning Flutter `3.44.2` (the version already in use — pin what's proven working, not a fresh upgrade bundled into this same change). Requires installing [FVM](https://fvm.app/) as the standard local dev tool going forward; document the setup step in a future `docs/DEVELOPMENT_SETUP.md` (not created this phase — out of scope, this document only proposes the pin, not the full onboarding guide).
2. **Node.js**: **corrected 2026-09-09** — target **Node 24 LTS** (codename "Krypton," currently `24.21.0`), not the `25.2.1` installed on this dev machine. Node 25.x is a Current release line, not LTS — it does not receive the long-term support/security-maintenance guarantee a backend should be pinned to, and reaches end-of-life well before a production service built on it should have to force an upgrade. Node 24 entered LTS in October 2025 and is supported into 2028, which is the right target for both the future `services/api/` backend and `firebase-emulator-tests/` (currently developed against whatever Node happens to be installed, i.e. 25.2.1 — that tooling should move to 24 LTS too for consistency, even though it's dev/test-only and lower-risk than the backend). **`.nvmrc` is not created yet** — this is a target correction to the proposal, not an implementation step; creating the file and switching the local Node install to match is still a separate, future action requiring its own go-ahead. [Node.js 24.21.0 (LTS)](https://nodejs.org/en/blog/release/v24.21.0), [endoflife.date/nodejs](https://endoflife.date/nodejs)
3. **Android SDK levels**: replace the implicit `flutter.compileSdkVersion`/`flutter.minSdkVersion`/`flutter.targetSdkVersion` references in `android/app/build.gradle.kts` with explicit integers (`compileSdk = 36`, `minSdk = 24`, `targetSdk = 36`) matching today's resolved values, so a future Flutter upgrade can't silently change the Android build target without a deliberate, reviewed change to this file.
4. **Firebase CLI**: no per-repo pin mechanism exists (it's a global npm/standalone install, not a project dependency) — recommend documenting the tested-against version (15.29.0) in the same future setup doc rather than a repo file, and re-verifying after any CLI upgrade before it's used for a rules/indexes deploy.
5. **CI**: change `non-functional.yml`'s `flutter-version: '3.x'` to the exact pinned version once `.fvmrc` exists, so CI and local dev are provably the same toolchain rather than coincidentally similar.

None of the above is implemented in this pass — per this phase's scope, this section is the proposal; creating `.fvmrc`/`.nvmrc` and editing `build.gradle.kts`'s SDK-level lines are small, mechanical follow-ups that need your explicit go-ahead (listed in the Decisions section of the Phase 1 report).
