# GoJobs — Production Readiness

Status: Phase 0 baseline, updated after a third-pass audit (2026-09-09). Tracks what must be true before a public launch, beyond the security findings in `docs/security/SECURITY_AUDIT.md`. Organized as blockers (must fix before any store submission or public traffic) vs. should-fix (quality/robustness, not launch-blocking on their own).

## Store-readiness blockers

| Item | Location | Impact if unaddressed |
|---|---|---|
| Android release build signs with the **debug keystore** | `android/app/build.gradle.kts:36-42` — `signingConfig = signingConfigs.getByName("debug")`, no `signingConfigs { release {...} }` block, no keystore/`key.properties` present | **Google Play Console rejects the upload outright.** Must create a real release keystore, store it via GitHub Actions secrets / Secret Manager (never committed), and wire a proper `signingConfigs.release` block before any Play Store submission. |
| **App icons and iOS launch screen are still the unmodified default Flutter template** (third-pass finding, visually confirmed) | `android/app/src/main/res/mipmap-*/ic_launcher.png` (default blue Flutter "F" mark); `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` (same); `ios/Runner/Assets.xcassets/LaunchImage.imageset/*` (68-byte blank placeholder images) | Not a hard store rejection by itself, but unmistakably unbranded — must be replaced with real GoJobs assets before any store listing. |
| **No account-deletion flow exists, and Firestore rules explicitly block it too** (`allow delete: if false` on `users/{uid}`) | No UI entry point anywhere in 4 settings screens; `firestore.rules` | **Explicit, binary Apple App Store and Google Play submission blocker** since 2022/Play's account-deletion policy — not a best-practice suggestion. |
| **No Terms of Service / Privacy Policy screen or link anywhere** | Confirmed absent from all 3 signup flows and all 4 settings screens | Same submission-blocker category as account deletion; also a baseline legal-compliance gap given the PII collected (see `SECURITY_AUDIT.md` third-pass PII inventory). |
| **No `ios/Podfile`/`Podfile.lock` exists** — iOS has apparently never been built from this checkout (third-pass finding) | `ios/` directory | iOS build is unverified end-to-end; `pod install`/`flutter build ios` needs to succeed at least once before any iOS work can be trusted, and CocoaPods must be installed on whatever machine does it. |
| Android `applicationId` is still the default template value | `android/app/build.gradle.kts:27` (`com.example.gp1_mvp`, with the original `// TODO: Specify your own unique Application ID` comment still present); matches `android/app/google-services.json:12` | Must be changed to a real, owned reverse-domain ID (e.g. `com.gojobs.app`) before Play Console upload — and regenerated in Firebase (new Android app registration) since `google-services.json` is keyed to the package name. |
| iOS bundle identifier is still the default template value | `ios/Runner.xcodeproj/project.pbxproj:371,550,572` and `lib/firebase_options.dart:55` (`com.example.gp1Mvp`) | Must be changed to a real bundle ID before App Store Connect / TestFlight setup, and the corresponding iOS app re-registered in Firebase. |
| iOS `Info.plist` is missing all camera/photo-library usage-description keys | `ios/Runner/Info.plist` (entire file — no `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription`) despite `image_picker`/`file_picker` being dependencies | **Hard runtime crash** the first time any picker flow (CV upload, profile pic, portfolio photo) is invoked on a real iOS device — this is worse than an App Store rejection, it breaks core functionality immediately. Must add proper, meaningful usage-description strings. |
| No `firestore.rules`/`storage.rules` in source control | repo-wide | See `SECURITY_AUDIT.md` C-3 — also a production blocker from the security side; listed here too because it's launch-blocking from an operational-readiness angle as well (nothing to deploy/version for a release). |
| No environment separation | one Firebase project for dev/staging/prod | Cannot safely test destructive changes or verify a release candidate without risking real data. See `docs/architecture/ENVIRONMENTS.md`. |
| No backups configured (unverifiable from repo — Console-only) | N/A | See `docs/operations/DISASTER_RECOVERY.md` — must be confirmed/configured before production traffic is trusted with real user data. |

## Should-fix before launch (not individually blocking, but expected of a serious release)

| Item | Location | Notes |
|---|---|---|
| No Flutter/Dart version pin | no `.fvmrc`/`.tool-versions`; Dockerfile clones Flutter `stable` HEAD on every build | Reproducibility risk — a CI build today could use a different Flutter version than a build run tomorrow. Pin via FVM or an explicit version in CI. |
| **CI security posture has regressed, not just always been weak** (second-pass finding, 2026-09-09) | `.github/workflows/non-functional.yml` history | An earlier version of this same workflow ran `flutter analyze --no-fatal-infos --no-fatal-warnings`; a later rename to today's "security-audit" job **removed** that step and replaced it with `flutter pub deps`/`flutter pub outdated`, neither of which lints or scans for vulnerabilities. Running `flutter analyze` fresh today reports 52 issues (11 `avoid_print`, 8 `unused_import`, plus deprecated-API warnings) that CI no longer catches. Restore the analyze step in Phase 1/13, don't just add new checks on top. |
| Android manifest doesn't explicitly declare `POST_NOTIFICATIONS` | `android/app/src/main/AndroidManifest.xml` | Required (as a declared permission, on top of the runtime prompt) for FCM push to work on Android 13+; currently relies entirely on an unverified plugin manifest merge. Verify explicitly, don't assume. |
| iOS `DEVELOPMENT_TEAM` unset, `CODE_SIGN_STYLE` unset on the main Runner target | `ios/Runner.xcodeproj/project.pbxproj` | Needs a real Apple Developer account/team wired up before any archive/TestFlight build. |
| `web/firebase-messaging-sw.js` uses the wrong platform's Firebase `appId` | `web/firebase-messaging-sw.js:11` | Cosmetic/functional bug (possible FCM web-push/analytics misattribution), not security. |
| Placeholder metadata text | `web/index.html:21` (`"A new Flutter project."`), `web/manifest.json:8` (same) | App/SEO metadata should reflect the real product before any public web deploy. |
| README inaccuracy | `README.md:128` claims `firebase_options.dart`/`google-services.json` are gitignored — they are not, and as of 2026-09-10 neither is `lib/config/api_config.dart` (now a tracked, safe, empty placeholder — see `docs/security/SECURITY_AUDIT.md` H-1 follow-up), so the claim is fully inaccurate rather than partially | Fix the claim; decide deliberately whether these files *should* be gitignored per-environment once the dev/staging/prod split lands (Phase 2), since each environment will need its own. |
| No CHANGELOG/CONTRIBUTING/LICENSE | repo root | Not launch-blocking, but expected of a project moving toward "production platform" framing; add once the team/contribution model is decided. |

## App Store / Google Play submission checklist (tracked here, executed in Phase 17/18)

Not yet started — listed for visibility, per the brief's instruction not to leave store compliance until the final day:

**Apple**: real bundle ID (see blocker above), signing certificates + provisioning profiles, App Store Connect app record, TestFlight setup, privacy-nutrition-label info (what data GoJobs collects — ties to the Privacy section still to be written in a later phase), screenshots, support URL, privacy policy URL, account-deletion flow (required by Apple — does not exist yet, see `DATABASE_DESIGN.md`'s data-deletion section), review notes (test account credentials for each role).

**Android**: real application ID (see blocker above), release signing (see blocker above), AAB build, Play Console app record, internal/closed/open testing tracks, Data Safety form, privacy policy URL, account-deletion flow (same requirement as Apple, and now also a Play Console policy requirement), screenshots, content rating questionnaire.

## Explicit non-claim

This document reflects what a static, read-only repository audit can determine. Items marked "unverifiable from repo" (backups, live Firestore/Storage rules, Android manifest merge outcome) require direct access to the Firebase/Google Cloud Console or a running build to confirm — they are not resolved by this document, only flagged for follow-up.
