# GoJobs — Security Audit

Status: Phase 0 baseline audit. Read-only investigation of the repository as it exists on `main` (commit `f4ac9d9`). **No live penetration testing was performed against the running Firebase project or any deployed environment** — findings below are derived from static source review. Where a finding's real-world severity depends on Firestore/Storage Security Rules that are not present in this repository, that dependency is stated explicitly rather than assumed away.

This audit does not claim completeness or "zero vulnerabilities" — it documents what was found through a systematic pass and provides a starting risk register, not a final clearance.

## THIRD-PASS AUDIT — 2026-09-09 (read this first — supersedes the Second-Pass section below where they conflict)

Performed after the secret-remediation/history-rewrite incident was closed out. Eight independent read-only research passes covered all 28 areas the owner requested (repo/git history, Flutter architecture, auth/authz, Firestore/Storage rules content, backend/AI architecture, CI/CD/native release, testing/observability/logging, product/scalability/privacy), each explicitly instructed to re-derive every claim from current source rather than trust prior audit docs. Where a pass corrected or overturned an earlier claim, that's called out explicitly below rather than silently merged in.

**Correction to the Second-Pass section below**: it states the pre-rewrite backup at `C:\Users\ADMIN\Desktop\gp1_backup_2026-09-09\` "still exists" as a residual risk. **It has since been deleted at the owner's explicit instruction, and deletion was verified** (directory listing confirmed absent). That residual risk is closed.

### CRITICAL — do not deploy the local `firestore.rules` in its current form

**New finding: the `applications` collection has three incompatible field shapes in live app code; the local rules file only matches one of them, and that one is dead code.**

- `lib/services/application_service.dart` writes `{jobId, userId, userName, companyId, jobTitle, cvUrl, status:'pending', ...}` — this is what `firestore.rules` (lines ~108-123) was written against. **This service has zero call-sites anywhere in `lib/` — it is dead code.**
- `lib/screens/job_seeker/jobs/jobseeker_upload_cv_screen.dart:76-86` — the **real, live** "Apply for Job" flow (includes actual CV upload) — writes `applicantId` instead of `userId`, and is read back by `applicantId` in `jobseeker_my_application_screen.dart`, `jobseeker_application_success_screen.dart`, and `company_applicants_screen.dart`.
- `lib/screens/student/internships/student_upload_cv_screen.dart:41-51` — the live "Apply for Internship" flow — writes `userId` (matching the rule) but `status: 'Pending'` (capital P, the rule requires lowercase `'pending'`), and never writes a `companyId` field at all.

**Consequence, independently verified against the exact rule text**: the local `firestore.rules`'s `create` rule requires `request.resource.data.userId == request.auth.uid` — evaluating this against a Shape-B write (no `userId` field present) is an undefined-field access, which denies the whole create. The `update` rule (used for company accept/reject) similarly requires `request.resource.data.userId == resource.data.userId`, which fails the same way against Shape-B documents. Shape C fails create because of the `'Pending'` vs `'pending'` literal mismatch. **Deploying this rules file as-is would immediately and silently break "apply for a job" and "apply for an internship" for both roles that have those features** — the only shape the rule actually supports has no live caller. The existing 126-case emulator test suite did not catch this because its fixtures use the dead-code Shape A, not the real app's Shape B/C.

**This blocks deploying the rules fix prepared in the second-pass session (which was already pending your approval for other reasons — see below) until resolved.** Two ways to fix, either acceptable:
- (a) Recommended: unify the app code — make `jobseeker_upload_cv_screen.dart` write `userId` instead of `applicantId` (and update its 3 reader call-sites to match), and make `student_upload_cv_screen.dart` write lowercase `'pending'` plus a real `companyId`. This is a small, contained Dart change, not a rules change.
- (b) Alternative: widen the rule to tolerate `applicantId` as an alternate owner field (same pattern already used for `notifications`' `userId`/`recipientId` duality) and accept both status-casing variants — patches the symptom without fixing the underlying inconsistency.
Neither has been applied. **No further rules deploys should happen until one of these is done and re-verified against the emulator.**

### Medium — new gap in `freelancer_requests` rules

The `firestore.rules` update rule for `freelancer_requests` never received the same ownership-field-immutability treatment as `jobs`/`applications` (the C-9 fix). A party to their own request can currently rewrite `freelancerId` or `clientId` to an arbitrary third uid, or set `status` to any string, on update. Not currently exploited by the app's own UI (which only ever writes `{'status': status}`), reachable only via a direct SDK/REST call — same risk class and prerequisite as the original C-9. Fix: add `request.resource.data.freelancerId == resource.data.freelancerId && request.resource.data.clientId == resource.data.clientId` plus a status enum check to the update rule, mirroring `jobs`/`applications`. Not yet applied.

### High — security-critical work exists only in one uncommitted working tree

`firestore.rules`, `storage.rules`, `firestore.indexes.json`, the entire 126-case emulator test suite, and every audit/architecture doc (including this one) have never been committed to git — confirmed via `git status`/`git ls-files`. If this machine or directory were lost or a destructive git operation were run, all of this work — most importantly the rules that are supposed to be gating production data access — would be unrecoverable, with no version history and no code-review trail for what's actually deployed vs. what's on disk. Recommend committing at minimum `firestore.rules`/`storage.rules`/`firestore.indexes.json` once the applications-shape fix above is resolved, then the rest. **This requires your explicit go-ahead** (per your standing instruction that commits only happen when asked) — flagging it here as a decision needed, not doing it.

### High/Critical — email verification bypass, more precisely characterized

Confirmed exactly as before, with the full mechanism traced: `login()` (`auth_service.dart`, `auth_provider.dart`) never checks `emailVerified`; the only check exists on the post-signup "OTP" screens (a misnomer — they're email-verification-link screens, not numeric OTP), which have a "Back to login" link that skips it entirely. Compounded by a router-level finding: `app_router.dart` has zero `redirect:` logic anywhere, so this isn't just "verification is skippable" — **no route in the entire 91-route app enforces authentication state or role at all**, including on Flutter Web where a logged-out user could navigate directly to a URL. Severity: Critical.

### High — `userType` never checked before sensitive writes, confirmed with more precision

No client code anywhere checks `userType`/`userMode` before a privileged write (job posting, etc.) — confirmed by full-tree grep, zero matches. The rules layer doesn't backstop this either: `jobs` create only checks `companyId == auth.uid`, never the caller's role. A job-seeker or student account can post a real "job" listing under its own uid today, both before and after any rules deploy. Additionally confirmed: a settings-screen "Switch to Freelancer/JobSeeker mode" toggle lets any job-seeker or freelancer account jump into the other role's home screen and features via bare navigation, with zero eligibility check in either direction.

### High — Critical (store-blocking) — account deletion and ToS/Privacy Policy confirmed absent, with consequences quantified

Re-confirmed with zero ambiguity: no `deleteUser`/account-deletion code path anywhere, and `firestore.rules` explicitly denies `users/{uid}` delete outright (`allow delete: if false`) — deletion is blocked at both the missing-UI layer and the rules layer. No ToS/Privacy Policy screen or link anywhere, including at signup. **Both are explicit, binary App Store and Play Store submission blockers**, not just best-practice gaps — Apple has required in-app account deletion since 2022, Google Play has an equivalent policy.

A concrete PII inventory was compiled for Data Safety / privacy-nutrition-label purposes (see the full agent output for the complete list): email, DOB, gender, phone, self-reported location, resume/CV files (which themselves typically embed further PII), education/work history, skills, company license numbers, portfolio photos, and free-text chat content. Separately and materially: **`users/{uid}` document reads and CV/resume file reads are currently open to any signed-in user, not scoped to the specific parties who need them** (e.g. the specific company reviewing a specific application) — this is a deliberate, documented interim trade-off (Phase 4/Phase 8 deferral), not an oversight, but it means the practical privacy exposure today is broader than "no deletion flow" alone suggests: any authenticated user can currently read any other user's full profile and CV.

### Medium — no Firebase App Check, no rate limiting, no upload size/content-type limits anywhere

All three confirmed absent, independently, via full-tree grep (zero `AppCheck` references, zero throttle/CAPTCHA/debounce patterns) and via a full read of `storage.rules` (zero `request.resource.size`/`request.resource.contentType` checks in any of the 7 covered upload paths — client-side extension allowlists and `SettableMetadata(contentType:...)` are both trivially bypassable since neither is server-enforced). The size/content-type gap is not new (already documented as H-2's Phase 8 deferral); App Check and general rate limiting are re-confirmed absent, consistent with prior findings.

### Medium — `Dockerfile` can still bake a live AI key into the Flutter **web** build

`Dockerfile:18-19` decodes a base64 `API_CONFIG_DART` build arg directly into `lib/config/api_config.dart` at web-build time. Flutter web ships all client code to the browser as inspectable JS — there is no secret-hiding in a web build regardless of `.gitignore` status. If any future CI workflow sets this build arg with a real key, the exact H-1 incident reproduces via the web build path instead of git. No workflow currently does this (confirmed: no such secret is referenced with a real value in the current `.github/workflows/*.yml`), but the mechanism remains live in the Dockerfile. Recommend removing this build-arg-injection path entirely once AI calls move behind a backend (Phase 6), rather than patching it as a special case.

### Informational/Medium — dependency posture

No known CVEs in any pinned direct or transitive Flutter/Dart dependency, independently re-verified against OSV.dev (11 advisories exist for the entire Pub ecosystem; none apply to any package this app uses at its pinned version). However, all five Firebase SDKs and `file_picker` are a full major version behind latest, and `go_router` is four majors behind — not an active vulnerability, but a growing upgrade-risk/maintenance-debt gap. Separately, `firebase-emulator-tests/`'s devDependencies (test-only, never shipped, never touches production) have 10 known `npm audit` advisories rooted in a transitive `undici` version — low practical impact given the scope, but worth a follow-up bump before this test harness ever runs in a shared CI environment.

### Full severity-classified findings list from this pass

Everything below was independently re-derived from current source this session. Items marked "unchanged" were re-verified fresh, not copied from a prior pass.

| Finding | Severity | Status |
|---|---|---|
| `applications` collection field-shape mismatch blocks core apply flows if rules deployed as-is | **Critical** | NEW — blocks rules deploy |
| Zero route guards anywhere in the app (91 routes, no `redirect:`); only auth check is a one-time splash-screen redirect | Critical | Unchanged, re-confirmed |
| Login never checks `emailVerified`; bypass via "Back to login" | Critical | Unchanged, re-confirmed with full mechanism traced |
| No account-deletion flow (blocked by rules too) | Critical (store-blocking) | Unchanged, re-confirmed |
| No Terms of Service / Privacy Policy anywhere | Critical (store-blocking) | Unchanged, re-confirmed |
| Android release still signs with debug keystore | Critical | Unchanged, re-confirmed |
| iOS Info.plist still missing all camera/photo usage-description keys (will crash on first picker use) | Critical | Unchanged, re-confirmed |
| Uncommitted security-critical work (rules, tests, docs) exists in exactly one place, no backup, no version control | High | NEW |
| `userType` never checked before sensitive writes, client or rules layer; role-switch toggle has zero eligibility check | High | Unchanged, re-confirmed with more precision |
| `users`/CV/resume reads open to any signed-in user (not just involved parties) | High | Unchanged, documented deferral |
| No Firebase App Check anywhere | High | Unchanged, re-confirmed |
| No rate-limiting/CAPTCHA/throttling anywhere in client code | High | Unchanged, re-confirmed |
| No iOS `Podfile`/`Podfile.lock` — iOS has apparently never been built from this checkout | High | NEW |
| CI runs no lint/test gate at all before pushing an image; `flutter analyze` step was actively removed from an earlier version of the workflow | High | Unchanged, re-confirmed with git-history evidence |
| Single Firebase project for dev/staging/production, no flavors/schemes, no `.firebaserc` | High/Critical | Unchanged, re-confirmed |
| `freelancer_requests` rules missing ownership-field immutability (C-9 pattern not applied here) | Medium | NEW |
| No file-size/content-type enforcement on any Storage upload path | Medium | Unchanged, documented Phase 8 deferral |
| `Dockerfile` can still bake a live key into a Flutter web build via unused build-arg path | Medium | NEW |
| Two genuine N+1 read-amplification bugs (`company_applicants_screen.dart`, `freelancer_home_screen.dart`) — fresh Firestore `.get()` calls inside `itemBuilder` on unbounded lists | Medium/High | NEW |
| Job search screen fetches the entire active-jobs collection unfiltered and does all filtering client-side; only 1 of ~18 collection queries app-wide uses `.limit()` | High | NEW (quantified) |
| Two unguarded, business-critical Firestore writes with zero error handling (notification mark-read, applicant accept/reject) | High | NEW |
| 47 raw exception/error strings shown directly to end users across ~40 screens | Medium | NEW (quantified) |
| Zero Dart unit tests of business logic; the one file meant to hold validators is a 1-byte empty stub | Medium | NEW (quantified) |
| No Crashlytics/Sentry/centralized logging anywhere; 40 raw print/debugPrint call sites across 22 files | Medium | Unchanged, re-confirmed with fresh count |
| FCM token logged (paired with userId in one case) | Low/Medium | Unchanged, re-confirmed |
| Zero RTL/Arabic localization, zero Semantics/accessibility usage, compounded by 58 additional hardcoded `fontSize` literals beyond the known text-scale-lock HACK; one likely WCAG-AA-failing text color pair found | High | Unchanged, re-confirmed and quantified |
| Copy-paste duplication has produced a real, live navigation bug (`freelancer_bottom_nav.dart`'s search/saved tabs both dead-end at other tabs) | Medium | NEW |
| Company signup accepts any string as a "license number" with zero verification, immediately granting the elevated company role | Medium | NEW |
| App icons and iOS launch screen are still the unmodified default Flutter template (visually confirmed) | High/Medium | NEW |
| `pubspec.yaml` version still `1.0.0+1` | Low | Re-confirmed |
| Groq API key finding from the original audit is now resolved in current source | — (positive, re-confirmed) | Corrected/closed |
| No known CVEs in any pinned dependency | — (positive) | Re-confirmed via OSV.dev |
| No hardcoded credentials found anywhere in current source (independent re-scan) | — (positive) | Re-confirmed |
| HTTPS-only confirmed, no cleartext exceptions; no custom/hand-rolled crypto found | — (positive) | Re-confirmed |

### Verified facts vs. assumptions vs. recommendations vs. decisions needed (per explicit request)

- **Verified facts**: everything in the table above and its supporting detail — each was independently re-derived from current source this session (file:line evidence available in the underlying research), not copied from a prior pass.
- **Assumptions carried forward, not independently verifiable from this repo**: the exact current live Firestore/Storage rules on `gojobs-187af` (this repo can only see what was deployed as of the last confirmed CLI deploy and cannot query live state); whether `gojobs-187af` currently holds real user data (affects urgency framing, not correctness of findings); GitHub branch-protection settings (live in repo settings, not files, and not queryable without `gh` CLI access in this environment).
- **Recommendations**: fix the `applications` field-shape mismatch before any further rules deploy; commit the uncommitted security-critical work; add ownership-field immutability to `freelancer_requests`; add a global route guard; restore `flutter analyze` to CI; remove the Dockerfile's web-build key-injection path once AI moves behind a backend.
- **Decisions that need your explicit approval before any of this proceeds**: (1) whether to fix the `applications` shape mismatch via app-code change or rules-widening; (2) whether to commit the uncommitted work now; (3) whether/when to deploy the corrected rules (blocked on #1 regardless); (4) none of the above should happen without a separate go-ahead, consistent with "no Phase 1 yet."

## SECOND-PASS AUDIT — 2026-09-09 (read this first)

The owner asked for an independent re-verification of everything below, treating the original Phase 0 findings as a draft, not authoritative. This was done via 5 parallel independent read-only research passes plus direct hands-on testing against the Firebase Local Emulator Suite, none of which were told the prior conclusions in advance — each was asked to re-derive facts from source and explicitly confirm or contradict specific claims.

**Headline result: the original audit's core security conclusions (C-1 through C-6, H-1, H-2) all held up.** But the second pass found something the first pass did not: **the interim `firestore.rules`/`storage.rules` deployed on 2026-09-08 are incomplete, and that incompleteness is currently breaking live production features** — this is a functional regression I (the previous pass) introduced, not a pre-existing app bug. It also found several client-side gaps the first pass missed. All of it is detailed below, and none of the fixes for it have been deployed — they are prepared and tested locally only, per the standing instruction not to touch production during this audit.

### CRITICAL — currently live in production, not yet fixed

**C-10 (regression I introduced): three Storage upload paths are silently denied since the 2026-09-08 deploy.** The original `storage.rules` was derived only from `lib/services/storage_service.dart` (largely dead code — see below) and one resume screen. It missed three live, shipping upload flows entirely:
- `company_logos/{uid}.jpg` — `lib/screens/company/profile/company_edit_profile_screen.dart:107-110` (editing a company's profile logo)
- `job_images/{uid}/{fileName}` — `lib/screens/company/jobs/company_add_job_screen.dart:122-124` (attaching photos when posting a job)
- `portfolio_images/{uid}/{fileName}` — `lib/screens/freelancer/profile/freelancer_portfolio_screen.dart:103-104` (freelancer portfolio photo uploads)

Ironically, two of the four prefixes the original rules *did* cover (`profiles/`, `portfolios/`) turn out to be referenced only by dead code (`StorageService.pickAndUploadProfilePic`/`pickAndUploadPortfolioPhoto` — zero call-sites anywhere) — the real, live features use different literal path segments. Since the deployed rules deny-by-default, **all three of the above have been failing with `PERMISSION_DENIED` since the 2026-09-08 deploy**: company logo edits, job-listing photo uploads, and freelancer portfolio photo uploads are currently broken in production.

**Fix status**: corrected `storage.rules` adding the three missing prefixes is written locally, covered by new automated tests (`company_logos` describe block + extended prefix loop in `firebase-emulator-tests/storage.test.js`), and the full suite (126 cases total across all collections/paths, see below) passes. **Not deployed — awaiting approval.**

**C-11 (regression I introduced): `courses` and `course_enrollments` collections are silently denied since the 2026-09-08 deploy.** The original `firestore.rules` was derived from a collection list that missed the student "Courses & Workshops" feature entirely:
- `courses` — read by `lib/screens/student/courses/student_courses_screen.dart:158-160` (browse) and `lib/screens/student/home/student_home_screen.dart:70` (dashboard course count)
- `course_enrollments` — written by `lib/screens/student/courses/student_course_detail_screen.dart:32-38` (the "ENROLL NOW" button)

Both fail silently — the app wraps these calls in try/catch, so instead of a visible crash, course browsing shows "Error loading courses" and enrollment shows a "Failed to enroll" SnackBar. This is easy to miss without specifically exercising these two screens, which is exactly how it was missed the first time.

**Fix status**: corrected `firestore.rules` adding `match /courses/{courseId}` (read-only, any signed-in user; no write path exists in the app) and `match /course_enrollments/{enrollmentId}` (self-scoped by `studentId`, create-only) is written locally, covered by new `firebase-emulator-tests/courses.test.js` (9 cases), full suite passes. **Not deployed — awaiting approval.**

### New/refined findings from client-code re-verification (not rules issues — these were open both before and after the 2026-09-08 deploy)

**C-8**: the C-6/C-7 fix only locks `userType` from changing on an *existing* `users/{uid}` doc via `update`. Nothing constrains the *first* write. Anyone who authenticates via the Firebase Auth REST API directly (bypassing the app's signup screens, which is trivial — email/password signup is a public, unauthenticated Firebase Auth API call) can then call `users/{own uid}.set(...)` with **any fields at all**, including ones the app's UI never offers (tested concretely with `isAdmin: true`, `isVerified: true` in `firebase-emulator-tests/users.test.js`). Confirmed via emulator test — currently succeeds. Real fix needs either a create-time field allowlist in rules (`request.resource.data.keys().hasOnly([...])` plus explicit enum validation on `userType`) or moving account-document creation behind a backend. Severity: Medium today (no admin role exists yet for `isAdmin` to mean anything), but **will become Critical the moment Phase 10 introduces an admin role/claim if this isn't closed first** — flag for Phase 4/10 sequencing.

**C-9 — found and fixed locally this pass, not yet deployed**: on both `jobs` and `applications`, the update rule checked the *existing* owner field (`resource.data.companyId == request.auth.uid`, etc.) but did not stop that same write from *changing* the ownership field itself. Confirmed via emulator test (before the fix): the owning company could reassign a job's `companyId` to an arbitrary uid, and either party on an application could reassign its `userId`/`companyId` to an arbitrary uid, with `status` accepting any string (no enum validation). Lower severity than C-1/C-2 since it requires already legitimately owning the resource, but a real data-integrity/audit-trail gap (accidental or malicious "ownership transfer," unvalidated status values). **Fixed**: added `request.resource.data.companyId == resource.data.companyId` (jobs) and the equivalent for `userId`/`companyId` (applications) immutability checks on update, plus `request.resource.data.status in ['pending','accepted','rejected']` validation on both create and update. Retested — full 126-case suite passes, including new tests confirming reassignment and invalid-status attempts are now denied. **Not yet deployed — bundled with the C-10/C-11 fix, awaiting one combined approval.**

**Confirmed unchanged from the original audit** (re-verified independently, not just re-stated): zero route guards anywhere in `app_router.dart` (91 `GoRoute` entries, no `redirect`, no `ShellRoute`, confirmed via full re-read); no admin role/screens/service anywhere; no account-deletion flow anywhere; no Terms of Service/Privacy Policy screen or link anywhere; no rate-limiting/CAPTCHA/abuse-protection anywhere; Android release still signs with the debug keystore; both app/bundle IDs still default `com.example.*` (Android and iOS use *different* default strings — `com.example.gp1_mvp` vs `com.example.gp1Mvp` — both untouched, just independently auto-generated); iOS `Info.plist` still missing all camera/photo-library permission strings; no `.fvmrc`/version pin; pinned dependency versions (firebase_core 3.15.2, firebase_auth 5.7.0, cloud_firestore 5.6.12, firebase_storage 12.4.10, firebase_messaging 15.2.10, image_picker 1.2.2, file_picker 11.0.2) checked against OSV.dev directly — **zero disclosed advisories for any of them** (a web-search result suggesting a file_picker CVE was chased down and found to be a false lead — those CVEs are in an unrelated Java library called Apache Tika, not the Dart package).

**Newly discovered this pass** (missed entirely by the first audit):
- **Email verification bypass is more concrete than previously stated**: the app *does* have a post-signup "verify your email" screen (misleadingly named `*_otp_screen.dart` — it's a "click the emailed link, then press this button" screen, not a numeric OTP) that checks `emailVerified` — but it has a "Back to login" link that skips it entirely, and the actual `login()` path (`AuthProvider.login` → `AuthService.login`) never checks `emailVerified` at all. A user can sign up, ignore the verification email, log in directly, and reach the full app with an unverified email address.
- **Role-switch with no verification**: `jobseeker_settings_screen.dart:92-96` and `freelancer_settings_screen.dart:86-90` let any job-seeker/freelancer account navigate straight into the other role's home screen via a bare `context.go(...)`, with no check that the account actually has that role's profile data set up. Reinforces the "no per-role access control anywhere client-side" theme — not a new security boundary break (Firestore rules are what matter for data access) but a real UX/product inconsistency.
- **`ApiService` is confirmed genuinely dead** (independent re-verification): duplicates `AuthService`'s three signup methods near-verbatim, zero call-sites anywhere in `lib/`. Safe to delete in Phase 1.
- **CI security posture has actively regressed over time**, not merely "was always weak": diffing `.github/workflows/non-functional.yml`'s history shows an earlier version of this same workflow ran `flutter analyze --no-fatal-infos --no-fatal-warnings`; a later rename (to its current "security-audit" job) *removed* that step and replaced it with `flutter pub deps`/`flutter pub outdated`, neither of which is a lint or vulnerability check. Running `flutter analyze` fresh right now reports **52 issues** (11 `avoid_print`, 8 `unused_import`, plus deprecated-API and other warnings) — all `info`/`warning` severity, none blocking a build, and none currently caught by CI since the analyze step was removed.
- **`collectionGroup()` queries are not used anywhere today** — confirmed by direct grep. This matters because the nested subcollection rules (`saved_jobs` under `users`, `messages` under `chats`) only authorize queries scoped to a known parent; if a future feature adds a cross-parent `collectionGroup()` query (e.g. "search all messages"), it needs its own top-level rule and will not be covered by the current nested structure. Flag for whoever builds that feature.

### Verified facts vs. assumptions vs. recommendations (per explicit request to separate these)

- **Verified facts** (re-derived from source or emulator test output this pass): everything under "Confirmed unchanged" and "Newly discovered" above, plus C-8/C-9/C-10/C-11's existence and emulator-test-confirmed behavior.
- **Assumptions still standing, not independently verifiable from this repo**: whether `gojobs-187af` currently holds real user data (affects how urgently C-10/C-11 need fixing — if there are zero real companies/students using logo-upload/course-enrollment today, the practical urgency is lower even though the bug is real); the exact current IAM/API-key-restriction posture in Google Cloud Console (I-1, still unverifiable from source).
- **Recommendations** (not yet decided/approved): deploy the C-10/C-11 fixes (rules only, already tested); add the C-9 immutability/enum-validation rules; add a create-time field allowlist for C-8; restore `flutter analyze` to CI; delete confirmed-dead code (`ApiService`, unused `StorageService` methods) in Phase 1.
- **Decisions still needed from the owner**: approval to deploy the C-10/C-11 fix (recommended: yes, promptly, since real features are broken); whether to also fix C-9 in the same deploy or a follow-up; confirmation of whether `gojobs-187af` has real user data yet (affects urgency framing only, not whether to fix).

## Update — 2026-09-08: live rules obtained, findings confirmed

The project owner provided the actual deployed rules for `gojobs-187af` (confirmed production, per `docs/architecture/ENVIRONMENTS.md`). They are reproduced in full at the end of this document. Verbatim summary of what they actually allowed, as deployed:

- **Firestore**: `jobs`, `applications`, `freelancer_requests`, `notifications`, `chats` (and its `messages` subcollection) all had `allow read, write: if request.auth != null;` — **any signed-in account could read or write every document in every one of these collections, with no ownership check whatsoever.** `users/{userId}` read was similarly open to any signed-in user for the full document tree (`{document=**}`); write was at least uid-scoped, but with no restriction on *which fields* could be changed.
- **Storage**: `allow read, write: if request.auth != null;` on `/{allPaths=**}` — **any signed-in account could read, overwrite, or delete every file in the entire bucket**, including every other user's CV, profile picture, and portfolio photo.

This **confirms as live and actively exploitable**, not merely theoretical: C-1, C-2, C-3, H-2, M-2 below (all previously hedged as "contingent on unverified rules" are now CONFIRMED CRITICAL/HIGH). It also surfaces vulnerabilities the original code-only pass could not see, since `chats`, `notifications`, and `freelancer_requests` are collections the static audit didn't have full visibility into — see **C-4** and **C-5**, new in this update. It also confirms a **live self-role-escalation path** on `users/{uid}` writes — see **C-6**, new in this update — which was previously flagged only as a theoretical defense-in-depth gap (M-3) because no *client code path* exercised it; the rules never prevented a direct call from exercising it.

**Interim mitigation — DEPLOYED 2026-09-08.** Hardened `firestore.rules` and `storage.rules` were written into the repo root (plus `firebase.json` updated to reference them, and `firestore.indexes.json` reconciled against the project's actual existing indexes before deploy, so nothing live was dropped) and deployed to `gojobs-187af` via `firebase deploy --only firestore:rules,storage` followed by `firebase deploy --only firestore:indexes`, both confirmed successful (rules compiled without errors and were released; indexes deployed with no deletions). This closes every write-side hole below with high confidence based on the collections' actual field shapes as used in the app's code. Two things remain deliberately open pending later phases (documented in the rule files themselves): `users/{uid}` document reads (needs Phase 4 verification before narrowing — companies legitimately read applicant profiles and vice versa) and CV/resume file reads (needs Phase 8's backend-issued signed URLs — companies legitimately open applicant CVs, and there's no backend yet to scope that safely). **Not yet done: live functional verification.** This deploy could not be integration-tested against the live project beforehand — the chat/notification rules in particular rest on field-name conventions inferred from inconsistent code across screens. Exercise all four roles' messaging, notifications, job posting/deletion, and apply/accept/reject flows with real or test accounts as soon as possible to confirm nothing legitimate broke; report back immediately if anything now fails with a permission-denied error that used to work.

## How to read this document

Each finding lists: severity, location, explanation, exploitation scenario, recommended fix, and whether it blocks production launch.

Severity scale: **Critical** (direct data-integrity/confidentiality breach achievable today) → **High** (serious risk, may depend on an unverified external control) → **Medium** → **Low** → **Info**.

---

## Critical

### C-1: Application status can be changed with no ownership check — **CONFIRMED live in production, 2026-09-08**

- **Location**: `lib/screens/company/applicants/company_applicants_application.dart:46-55` (`_updateStatus`); the equivalent `updateApplicationStatus` in `lib/services/application_service.dart:66-73` has the same gap but is unused dead code.
- **Explanation**: Accepting/rejecting an applicant performs `applications/{docId}.update({status})` where `docId` comes from a `Map<String,dynamic>` passed through the router, with **no verification that the current user's uid matches the application's (or its parent job's) `companyId`.**
- **Exploitation scenario**: An authenticated user (any role) who obtains an `applicationId` — e.g. by observing their own applications, a compromised session, or (if Firestore rules don't scope reads) enumerating the collection — issues a direct Firestore SDK or REST call: `PATCH /applications/{id}` with `{status: "accepted"}`, changing the outcome of any applicant's application at any company, bypassing the UI entirely.
- **Recommended fix**: Move this write behind the new backend (Phase 4/6). The endpoint re-derives the application's parent job, checks `job.companyId === request.auth.uid` server-side inside a transaction, and only then writes `status`. Add a matching deny-by-default Firestore rule as defense-in-depth once direct client writes to this collection are removed.
- **Blocks production**: **Yes.**

### C-2: Any authenticated user can delete any company's job posting — **CONFIRMED live in production, 2026-09-08**

- **Location**: `lib/services/job_service.dart:95-101` (`deleteJob`).
- **Explanation**: `jobs/{jobId}.delete()` is called with a bare `jobId` parameter and no check that the caller owns the job. Job IDs are broadly discoverable — every active job is streamed to every signed-in user via `getActiveJobs()` (`job_service.dart:39-49`).
- **Exploitation scenario**: Any authenticated user calls the Firestore SDK/REST API directly with any job ID they've seen (e.g. from browsing) and deletes a competitor's, or any, job posting.
- **Recommended fix**: Move job deletion behind the backend, checking `job.companyId === request.auth.uid` server-side before deleting. Add a matching deny-by-default Firestore rule.
- **Blocks production**: **Yes.**

### C-3: No Firestore or Storage Security Rules existed in source control — **CONFIRMED, and confirmed permissive, 2026-09-08**

- **Location**: repository-wide — no `firestore.rules`, `storage.rules`, `firestore.indexes.json`, or `.firebaserc` existed anywhere prior to this update; `firebase.json` contained only FlutterFire platform-mapping metadata.
- **Explanation**: Since there is no backend (see `EXISTING_SYSTEM.md` §2), Security Rules were the *only* possible server-side authorization boundary for this app — and this repository could not confirm what rules were actually deployed. **Now confirmed** (owner-provided, reproduced at the end of this document): every collection except the `users` write path used `allow read, write: if request.auth != null;` with no ownership check, and Storage granted the same blanket access across the entire bucket.
- **Exploitation scenario**: confirmed — see the individual findings (C-1, C-2, C-4, C-5, C-6, H-2) for what this permissiveness enabled concretely. Not the worst possible case (fully public/unauthenticated access), but functionally close to it: the only bar was having *any* account, which is free and instant to create via the app's own signup flow.
- **Recommended fix**: `firestore.rules`, `storage.rules`, and a best-effort `firestore.indexes.json` have been drafted and committed to the repo root as an interim hardened stopgap (see the Update section above) — **these still need to be published** to take effect; drafting them does not by itself change the live project. `firebase.json` now references them so `firebase deploy --only firestore:rules,storage:rules` works once the Firebase CLI is authenticated against this project. The full Phase 4 rewrite (with emulator-based automated tests and backend-side enforcement) remains necessary — this interim patch is not a substitute for it.
- **Blocks production**: **Yes** — publishing the interim rules is the single highest-priority action remaining, ahead of any other Phase 1 work.

### C-4: Any authenticated user could read, write into, or impersonate a sender in any other two users' chat — **CONFIRMED live, discovered 2026-09-08**

- **Location**: `chats/{chatId}` and `chats/{chatId}/messages/{messageId}` in the live Firestore rules (`allow read, write: if request.auth != null;`, no participant check). Chat identity is carried by a `participants` array field (confirmed via `lib/screens/{student,job_seeker}/messages/*_messages_screen.dart` querying `.where('participants', arrayContains: currentUserId)`); individual messages carry `senderId`.
- **Explanation**: This collection was not fully visible to the original code-only audit pass (it's assembled ad hoc across four duplicated chat screens, not through a single service — see `EXISTING_SYSTEM.md` §1/§7). The live rules placed no restriction on it at all.
- **Exploitation scenario**: Any signed-in user could read the full contents of any conversation between any two other users (eavesdropping — includes whatever personal/negotiation content users discussed), or write a message into someone else's conversation with an arbitrary `senderId`, impersonating either party.
- **Recommended fix**: Interim `firestore.rules` (deployed 2026-09-08) restrict chat/message read and write to participants of that specific chat, and require `senderId` to match the caller on message creation. **Verify live** — chat participant scoping depends on an inferred `participants` field convention; test all four roles' chat flows.
- **Blocks production**: **Yes.**

### C-5: Any authenticated user could read or tamper with any other user's notifications and freelancer-service requests — **CONFIRMED live, discovered 2026-09-08**

- **Location**: `notifications/{notificationId}` and `freelancer_requests/{requestId}` in the live Firestore rules (both `allow read, write: if request.auth != null;`, no ownership check).
- **Explanation**: Notifications use two different owner-field conventions inconsistently across call-sites (`userId` in `company_add_job_screen.dart:154`, `recipientId` in `jobseeker_upload_cv_screen.dart:89`) — neither was checked by the live rules. Freelancer requests carry `freelancerId`/`clientId` (`lib/screens/{student,job_seeker}/freelancer_marketplace/*`, `lib/screens/freelancer/home/freelancer_home_screen.dart`) — also unchecked.
- **Exploitation scenario**: Any signed-in user could mark another user's notifications read, delete them outright (denial of an important status-change alert), or read someone else's notification feed; similarly for freelancer requests, any user could tamper with the accept/reject `status` of a request between two other people, or read requests not addressed to them.
- **Recommended fix**: Interim `firestore.rules` (deployed 2026-09-08) restrict read/update/delete on both collections to the parties named in their respective owner fields, while still allowing the legitimate cross-user *create* pattern (one user creating a notification/request addressed to another). **Verify live** — notifications use two owner-field conventions inferred from different screens; test notification read/mark-read across roles.
- **Blocks production**: **Yes.**

### C-6: Any user could change their own `userType` directly, bypassing the app's signup flow — **CONFIRMED live, discovered 2026-09-08**

- **Location**: `users/{userId}` write rule in the live Firestore rules — `allow write: if request.auth.uid == userId;` placed no restriction on *which fields* an owner-scoped write could change.
- **Explanation**: `EXISTING_SYSTEM.md`/original audit pass had already flagged this as a theoretical gap (see M-3 below) because no *client UI* exercised it — but the live rules never actually prevented it. A direct Firestore SDK/REST call from a signed-in job-seeker or student account could set its own `userType` to `'company'` (or any other value) at any time, gaining access to whatever the app's client-side role-based UI gates behind that string, with no admin/backend approval step.
- **Exploitation scenario**: A job-seeker account calls `users/{own uid}.update({userType: 'company'})` directly, then reloads the app — `splash_screen.dart`'s routing switch now sends them to the company dashboard, and `postJob()`/job-management screens (already unauthenticated at the rules layer per M-2, now confirmed C-2's sibling) become available to them.
- **Recommended fix**: Interim `firestore.rules` (deployed 2026-09-08) require `request.resource.data.userType == resource.data.userType` on every update — `userType` can only be set at document creation (signup) from then on, never changed by a direct client write. Full fix (Phase 4/6): role changes happen only through controlled backend/admin logic, using a Firebase custom claim as the authoritative source rather than the Firestore field.
- **Blocks production**: **Yes.**

---

## High

### H-1: Live third-party API key hardcoded and shipped in every client build — **UPDATED 2026-09-09, prior "never committed" claim was WRONG and materially understated the exposure**

- **Location**: `lib/config/api_config.dart:2-3` (present on disk, `.gitignore`d), consumed by `lib/services/ai_service.dart:7-9,13-27`.
- **Correction to the original finding**: the original audit checked `git log --all -p -- lib/config/api_config.dart` and `git rev-list --all | git grep`, both of which only walk **reachable** history (current branches/tags/remote-refs) and concluded "never committed." A second-pass, object-database-level scan (`git cat-file --batch-all-objects`, which enumerates every blob regardless of reachability) found this was **incomplete verification, not a wrong tool used correctly** — it missed history that was rewritten out of the branch tip but never garbage-collected. Independently re-verified against GitHub's live API (not just local git) with the following confirmed:
  1. **A Groq API key WAS committed and pushed to the public GitHub repo.** Commit `d9310d634258a21bea29da599cbeca8bed75001d` ("add api config", 2026-06-05, `smadizaid15@gmail.com`) added `lib/config/api_config.dart` containing a Groq key. It was later dropped from the branch tip via a force-push (visible in this machine's `git reflog show refs/remotes/origin/main`), which is why ordinary `git log --all` on this clone can't find it — but **the commit itself was already public before that force-push, and GitHub does not delete pushed objects on a force-push**. Confirmed via direct query: `https://api.github.com/repos/smadizaid15/GoJobs-gp/commits/d9310d634258a21bea29da599cbeca8bed75001d` → **HTTP 200**, right now, at the time of this audit. The repo is confirmed public (`"private": false`). **This key has been publicly fetchable for roughly 3 months and must be treated as compromised.**
  2. **A second, previously-undiscovered hardcoded secret was found**: a Google Gemini API key (`lib/services/ai_service.dart`, commit `8e6883a4c158b37e92be02b20b98823e5348e87d`, "ai features") — the original audit's secret scan only searched for the `gsk_` (Groq) pattern and never checked for a Gemini/Google-AI key pattern. **This one is worse than the Groq history issue**: `8e6883a` is a normal ancestor of the current branch tip (`git merge-base --is-ancestor 8e6883a HEAD` → yes) — it shows up in an ordinary `git log -p` on the public repo with **no forensics required at all**. It was "fixed forward" in a later commit (moved to `ApiConfig.geminiApiKey`, gitignored) but that does not remove it from history.
  3. The Groq key currently in `lib/config/api_config.dart` on disk (`gsk_5hN7...`, the one referenced elsewhere in this document) is a **third, different** key from the one in commit `d9310d6` above — it was committed locally once (`6b8f3ca...`, "workflow", 2026-06-13) but reset before push and confirmed **not** present on GitHub (422 from the API). It remains exposed only via compiled-build extraction (the original finding), not via git.
- **Exploitation scenario**: Anyone who finds `8e6883a` by browsing the repo's history (trivial) or `d9310d6` by scanning all objects/commits reachable via any URL (something automated secret-scanners, including GitHub's own, routinely do — do not assume it hasn't already been found) can use either key against the project owner's Gemini/Groq accounts. GitHub's own secret-scanning partner program may have already auto-flagged/revoked the Groq key at push-time in 2026-06 — this needs confirming, not assuming.
- **Recommended fix — three actions, all outside this repo's code, all yours to take**:
  1. **Rotate all three keys**: the Gemini key from commit `8e6883a`, the Groq key from commit `d9310d6`, and the current on-disk Groq key — in their respective provider consoles, immediately.
  2. **Decide on history remediation for the public repo.** Rotating the keys makes them useless to anyone who finds them, which is the actually-important fix — but the commits themselves will remain publicly visible/fetchable unless you rewrite history (`git filter-repo`/BFG) and force-push, which is a disruptive, hard-to-reverse action affecting anyone who has already cloned/forked the repo. This is a decision for you, not something to do unilaterally — flagging it here as a decision point, not doing it.
  3. Move all AI provider calls behind a backend endpoint (Phase 6) so no client-embedded key exists going forward, per the target architecture's AI provider abstraction.
- **Blocks production**: This part is now **resolved** — see remediation below. (H-2's file-upload issue, a separate finding, still blocks production.)

#### REMEDIATION — completed 2026-09-09

**1. Credential rotation** — performed by the project owner directly in the Gemini and Groq consoles (Claude never had access to, requested, or handled the actual key values). Owner confirmed all three keys rotated/revoked before any repository remediation began:
   - Gemini key from commit `8e6883a` — rotated
   - Groq key from commit `d9310d6` (the one publicly pushed) — rotated
   - Groq key from the local, never-pushed `lib/config/api_config.dart` — rotated

**2. Source remediation**:
   - `lib/config/api_config.dart` — key value cleared to an empty string (not replaced with another hardcoded key). This file remains gitignored and untracked, as before.
   - `lib/services/ai_service.dart` — `_generate()` now checks `_apiKey.isEmpty` and throws a clear "AI features are not configured" exception *before* attempting any network call, rather than sending a request with an empty/invalid bearer token. Every existing caller (`getChatResponse`, `getJobMatchScore`, `generateJobDescription`, `getInterviewQuestions`) already had its own try/catch with a graceful fallback (canned match score, fallback interview questions, "having trouble connecting" chat message, "please write one manually" for job descriptions) — so this degrades cleanly with zero UI changes needed.
   - Added `lib/config/api_config.dart.example` (tracked in git) — a template with an obvious placeholder (`'YOUR_GROQ_API_KEY_HERE'`), documenting local dev setup without ever committing a real key.
   - `.gitignore` — added an explanatory comment above the existing `lib/config/api_config.dart` exclusion, plus general secret-hygiene patterns (`.env`, `.env.*` with a `.env.example` carve-out, `*.pem`, `*.key` with a `*.example` carve-out).
   - Confirmed via fresh `flutter analyze` (0 issues on the changed files) and `flutter test` that this introduces no regressions (see Testing/verification below).
   - Target design for any future hosted-provider AI integration remains as specified in `docs/architecture/TARGET_ARCHITECTURE.md` ("AI architecture"): all provider calls move behind a backend endpoint; the Flutter client never holds a provider credential of any kind, ever, regardless of which provider (Groq/OpenAI/self-hosted/future fine-tuned model) is active.

**3. Git history rewrite** — explicit authorization given by the project owner. Full detail:
   - **Safety backup taken first**: a raw copy of the pre-rewrite `.git` directory (all 1,430 objects, nothing pruned) plus a `--all` bundle, stored locally outside the repo at `C:\Users\ADMIN\Desktop\gp1_backup_2026-09-09\`. This backup necessarily contained the old secrets — it was a deliberate safety net in case anything needed recovering. **Since deleted at the owner's explicit instruction, with deletion verified** (directory listing confirmed absent); it no longer exists anywhere.
   - **Ref/branch/tag inventory**: this repo has exactly one branch (`main`, local + remote-tracking), no tags, no stashes at the time of inventory. Confirmed the two Groq-key-bearing commits (`d9310d6`/`233bf3d`, `31efefb`/`6b8f3ca`) were reachable from **zero** current refs even before any rewrite — they were already dropped from published history by an earlier (pre-existing, unrelated to this session) force-push. Only the Gemini-key commit (`8e6883a`) was reachable from `main`.
   - **Tool used**: BFG Repo-Cleaner 1.14.0 (git-filter-repo requires Python, which is not installed on this machine; BFG is the well-established, GitHub-recommended equivalent and runs on the JRE already present here). Used `--replace-text` with an exact-string-literal replacement list (all three known secret values, each replaced with a distinct `***REMOVED-...-KEY***` marker) — a surgical text-substitution approach, not path/file deletion, specifically so no legitimate code or file history was removed, only the exact secret substrings wherever they appeared.
   - **Procedure**: created an isolated `--mirror` clone (never operated on the live working directory directly); ran BFG against the mirror; ran `git reflog expire --expire=now --all && git gc --prune=now --aggressive` on the mirror; force-pushed only `refs/heads/main` (explicitly, not a blanket mirror-push, so no local-only refs like the working stash were ever published).
   - **Result**: 45 objects changed; the only content actually altered was `lib/services/ai_service.dart`'s blob in the one commit that still had the literal secret text (`8e6883a`) — confirming the redaction was precise and did not touch unrelated commits/files. Rewritten `main` tip: `1a9f93aac1455ca13918a42b6f124c515f30ce79` (previously `f4ac9d9f`).
   - **What this did and did not fix**: the Gemini-key commit (on `main`) is genuinely gone from published history — verified below. The two Groq-key commits were **already** unreachable from any ref before this session touched the repo, so a history rewrite of `main` cannot "reach" them; `d9310d634258a21bea29da599cbeca8bed75001d` was independently confirmed (via direct GitHub API query) to still be fetchable by exact SHA even after this remediation, because it's an orphaned object on GitHub's servers, not part of any ref-reachable history. **Fully purging that specific orphaned object requires a request to GitHub Support** — this is a known, documented limitation of client-side history rewrites (GitHub's own "removing sensitive data" guidance says the same), not something `git push --force` can accomplish. Flagged as a manual follow-up for the owner; the rotated key itself is inert regardless.
   - **Local cleanup**: this working copy's own `main` was reset to the rewritten `origin/main`, and `git reflog expire --expire=now --all && git gc --prune=now --aggressive` was also run locally, removing the now-orphaned pre-rewrite objects from this machine's object database too (the safety backup directory is the only place they now still exist, deliberately, per above).

**4. Verification performed**:
   - Full object-database scan (every blob, `git cat-file --batch-all-objects`, not just reachable history) of the rewritten mirror, and separately of this local repo post-cleanup: **zero** occurrences of any of the three known secret strings, both times.
   - Independent, from-scratch verification against the live public repo: a completely fresh `git clone` of `https://github.com/smadizaid15/gp1.git` (which GitHub redirects to `smadizaid15/GoJobs-gp`) confirms `main` is at the new rewritten tip; `git merge-base --is-ancestor 8e6883a... HEAD` fails with "not a valid commit name" (the object isn't even transferred to a fresh clone, the strongest possible confirmation); `grep` for the Gemini key in the fresh clone's `ai_service.dart` returns zero matches; a full `git log --all -p` search across the fresh clone for all three secrets returns zero matches.
   - `flutter analyze` on the changed files: 0 issues. Full-project `flutter analyze`: 52 issues, identical count to the pre-remediation baseline (confirms no new issues introduced).
   - `flutter test`: the existing smoke test (`test/widget_test.dart`) fails with a `ProviderNotFoundException` for `ThemeProvider` — **confirmed pre-existing and unrelated** by temporarily stashing all changes (including this remediation) and re-running: identical failure occurs on the unmodified tree. This is a pre-existing gap in the test's own setup (it doesn't wrap `GoJobsApp` in the `MultiProvider` that `main()` normally provides), not a regression from this remediation. Worth fixing in Phase 11, out of scope for this remediation.
   - Working tree confirmed clean of anything unexpected after the stash/reset/pop sequence — all prior Phase 0 audit deliverables (docs, rules, emulator tests) survived intact.

**Residual risk**: the pre-rewrite local backup (`C:\Users\ADMIN\Desktop\gp1_backup_2026-09-09\`) has been deleted and its deletion verified — it is no longer a residual risk. The orphaned GitHub object for `d9310d6` remains fetchable by direct SHA pending a GitHub Support request. This is now low-severity given the underlying credential is rotated and inert, but is flagged for the owner's awareness and follow-up.

### H-2: Unrestricted, unvalidated file uploads — write-side **CONFIRMED live** (severity effectively Critical until the interim Storage rules are published)

- **Location**: `lib/services/storage_service.dart` (`pickAndUploadCV`, `pickAndUploadProfilePic`, `pickAndUploadPortfolioPhoto`, `deleteFile`); `lib/screens/job_seeker/jobs/jobseeker_upload_cv_screen.dart`; `lib/screens/job_seeker/profile/jobseeker_resume_screen.dart`.
- **Explanation**: File-type restriction (`allowedExtensions: ['pdf','doc','docx']`) exists only in the client's `FilePicker` UI — trivially bypassed by any direct Storage SDK/REST upload. No file-size limit is enforced anywhere. No MIME-type verification. `userId` in the Storage path (`cvs/$userId/...` etc.) is a caller-supplied parameter, not derived from `FirebaseAuth.currentUser` inside the service. `deleteFile(url)` deletes whatever URL is passed with no ownership check. **Confirmed 2026-09-08**: the live Storage rules were `allow read, write: if request.auth != null;` on the entire bucket — not a hedge, this was actually deployed, meaning any signed-in user could already overwrite or delete any other user's CV/profile picture/portfolio photo.
- **Exploitation scenario**: A malicious or compromised client uploads arbitrarily large files (storage cost abuse / quota exhaustion) or arbitrary file types to a predictable per-user path, or overwrites/deletes another user's file by supplying their `userId` in the path — confirmed unblocked by rules until the interim patch is published.
- **Recommended fix**: Interim — `storage.rules` (deployed 2026-09-08) scopes write to path-owner for the four known upload prefixes; read is deliberately left open pending Phase 8's signed-URL work (see the Update section above for why). Full fix — move uploads behind the backend (signed URLs with enforced size/content-type constraints), derive the storage path segment from the verified ID token's uid server-side, never trust a client-supplied `userId`.
- **Blocks production**: **Yes.**

---

## Medium

### M-1: Zero route guards — every screen is reachable regardless of auth state or role

- **Location**: `lib/router/app_router.dart` (entire file — no `redirect`, no `ShellRoute`, no per-route guard); the only auth-aware logic anywhere is the one-shot check in `lib/screens/splash/splash_screen.dart:21-53`.
- **Explanation**: Not a data-security hole by itself (data safety is a function of rules/backend, not client-side routing), but it means the UI will render company-only forms and actions to any user who navigates there directly, increasing the surface for a user to stumble into — or a modified client to deliberately invoke — the privileged write paths in C-1/C-2.
- **Exploitation scenario**: A `jobSeeker`-typed account navigates directly to `/company/add-job` or `/company/applicants` (no redirect stops them) and, combined with C-1/C-2/M-2, can act on data they shouldn't see.
- **Recommended fix**: Add a `redirect` callback (or a `ShellRoute`-based guard) to `GoRouter` checking `AuthProvider`'s auth state and role before allowing navigation into role-scoped route trees. This is necessary UX/defense-in-depth even though it is not the actual security boundary (the backend/rules are).
- **Blocks production**: No (not itself the security boundary), but should ship alongside the backend-authorization work in the same phase.

### M-2: A non-company account can call `postJob()` directly — **CONFIRMED live in production, 2026-09-08** (rules never checked role either)

- **Location**: `lib/services/job_service.dart:7-37` (`postJob`) — takes `companyId` as a plain parameter with no `userType`/role check anywhere in the call path.
- **Explanation**: Nothing prevents a `student`/`jobSeeker`-typed account from calling `JobService().postJob(companyId: <their own uid>, ...)` directly, since the function itself has no role gate and the client never checks `userType` before invoking it (only the UI hides the "Post a Job" button from non-company users).
- **Recommended fix**: Enforce role at the backend (custom-claim check: only `EMPLOYER`-role tokens may call the job-creation endpoint).
- **Blocks production**: No — subsumed by the general "move writes behind an authorizing backend" fix, but worth tracking separately since it's a distinct role-check gap, not just an ownership gap.

### M-3: Generic unrestricted user-document updater — client-code gap; the matching rules gap is now tracked as **C-6** (confirmed live)

- **Location**: `lib/services/user_service.dart:17-19` (`updateUser`).
- **Explanation**: `_firestore.collection('users').doc(uid).update(data)` accepts an arbitrary caller-supplied map with no field allowlist/blocklist. Every current call-site passes only legitimate profile fields (verified across all edit-profile screens for all four roles) — so there is no exploitable path *through the app's own UI* — but the primitive itself would allow a future or careless call to include `userType`/role-shaped fields, and nothing in the client code stops it. **Update 2026-09-08**: the live Firestore rules didn't stop it either (see C-6) — this was reachable via any direct SDK/REST call all along, not just a hypothetical future gap.
- **Recommended fix**: Add an explicit field allowlist to `updateUser` (defense-in-depth even after the backend takes over authoritative writes) in addition to the rules-level fix already drafted for C-6.
- **Blocks production**: The rules-level fix (C-6) blocks production and is drafted/pending publish; this client-code allowlist is a should-fix hardening layer on top, not itself blocking.

---

## Low / Info

### L-1: Sensitive-ish data logged via `debugPrint`

- **Location**: `lib/services/notification_service.dart:13` (raw FCM token), `:17-20` (full push payload), `:38` (uid + FCM token together); `lib/services/ai_service.dart:29-30` (full raw AI API response body, which can include resume/CV/job-description text sent as prompts).
- **Explanation**: `debugPrint` is a no-op in release builds by default, so the practical risk is limited to development/QA machines where `adb logcat`/device console access could expose this data — still worth removing since it's easy to leave enabled accidentally (e.g. via a custom `debugPrintCallback`).
- **Recommended fix**: Remove or gate behind `kDebugMode` explicitly; never log tokens, uids together with tokens, or full third-party API payloads that may contain user-submitted content.
- **Blocks production**: No.

### L-2: `print()` calls leak into release builds

- **Location**: 11 occurrences across 6 files, e.g. `lib/screens/job_seeker/profile/jobseeker_resume_screen.dart:63,85,129,158`, `lib/screens/company/applicants/company_applicants_screen.dart:216`, `lib/screens/job_seeker/jobs/jobseeker_upload_cv_screen.dart:45,104`.
- **Explanation**: Unlike `debugPrint`, `print()` is **not** stripped from release builds. These are also already-flagged violations of the project's own default `flutter_lints` config (`avoid_print` is active and uncommented in `analysis_options.yaml`).
- **Recommended fix**: Replace with a structured logger (or remove); enforce `avoid_print` as a CI-blocking lint failure going forward (Phase 11/13).
- **Blocks production**: No, but trivial and should be part of the same cleanup pass as L-1.

### I-1: Committed Firebase client config (API keys)

- **Location**: `android/app/google-services.json`, `lib/firebase_options.dart` — both git-tracked (the README's claim that these are gitignored is inaccurate; only `lib/config/api_config.dart` actually is, per `.gitignore:47`).
- **Explanation**: These contain Firebase Web/Android/iOS API keys, which per Firebase's documented security model are expected to be public/client-embedded — their safety depends entirely on Firestore/Storage Security Rules and Google Cloud API-key restriction settings (HTTP referrer / app-restriction / API-restriction on each key in GCP Console), neither of which this repo can verify (see C-3).
- **Recommended fix**: No code change required for the keys themselves; verify in Google Cloud Console that each API key has appropriate application/API restrictions configured, and correct the README's inaccurate gitignore claim.
- **Blocks production**: No, contingent entirely on C-3 being resolved.

### I-2: `web/firebase-messaging-sw.js` uses the wrong platform's Firebase App ID

- **Location**: `web/firebase-messaging-sw.js:11` — uses the iOS app's `appId` instead of the web app's (compare `lib/firebase_options.dart:33-34`).
- **Explanation**: Likely copy/paste error; can cause FCM web-push/analytics misattribution.
- **Recommended fix**: Swap to the correct web `appId`.
- **Blocks production**: No.

---

## Summary table

| ID | Severity | Status (2026-09-08) | Blocks production | One-line fix |
|---|---|---|---|---|
| C-1 | Critical | **Confirmed live** | Yes | Publish interim `firestore.rules`; full fix moves the write behind a backend |
| C-2 | Critical | **Confirmed live** | Yes | Publish interim `firestore.rules`; full fix moves the write behind a backend |
| C-3 | Critical | **Confirmed — rules were permissive** | Yes | Publish the interim `firestore.rules`/`storage.rules` already drafted in the repo root |
| C-4 | Critical | **Confirmed live** (new) | Yes | Publish interim `firestore.rules` (chat participant scoping) |
| C-5 | Critical | **Confirmed live** (new) | Yes | Publish interim `firestore.rules` (notification/freelancer-request owner scoping) |
| C-6 | Critical | **Confirmed live** (new) | Yes | Publish interim `firestore.rules` (`userType` immutable on update) |
| C-7 | Critical | **Found and fixed 2026-09-09 via automated tests; corrected rules deployed same day** | No (resolved) | Deployed — nested subcollection rule so it no longer shadows the parent-document rules |
| H-1 | High | Unaffected by rules — client-embedded secret regardless | Yes | Remove client-embedded Groq key; proxy via backend; rotate the key |
| H-2 | Effectively Critical | **Confirmed live** (write-side) | Yes | Publish interim `storage.rules` (owner-scoped writes) |
| M-1 | Medium | Unchanged | No | Add router-level auth/role guards |
| M-2 | Medium | **Confirmed live** (rules never checked role) | No (subsumed by C-2's fix) | Enforce EMPLOYER role server-side for job creation |
| M-3 | Medium | Superseded by C-6 for the rules-level risk | No | Add field allowlist to `updateUser` as defense-in-depth on top of C-6 |
| L-1 | Low | Unchanged | No | Remove/gate sensitive `debugPrint` calls |
| L-2 | Low | Unchanged | No | Remove `print()` calls; enforce `avoid_print` in CI |
| I-1 | Info | Unchanged | No | Verify GCP API key restrictions; fix README |
| I-2 | Info | Unchanged | No | Fix wrong `appId` in service worker |

**Current status (updated 2026-09-09)**: all of C-1 through C-7 and H-2's write side are now confirmed fixed and deployed to `gojobs-187af`. The interim rules deployed 2026-09-08 closed C-1 through C-5 and H-2; a 94-case automated test suite against the Firebase Local Emulator Suite (see the Update section above) then found that the C-6 fix (`userType` immutability / delete block on `users/{uid}`) was not actually effective due to a separate rules bug (C-7). The corrected rule was retested (94/94, three consecutive clean runs) and deployed (`firestore:rules` only) on 2026-09-09, with the deployed file's checksum confirmed identical to the tested one. Remaining open items are all previously-documented, deliberate scope limits of this interim patch (not bugs): `users/{uid}` profile reads and CV/resume reads stay open to any signed-in user pending Phase 4/Phase 8 respectively, and M-2 (no role check on job creation) remains deferred to the Phase 6 backend. No further production changes are planned without explicit approval.

---

## Update — 2026-09-09: automated emulator test suite built, ran, found and fixed a bug in the interim patch itself

Per the project owner's instruction to verify programmatically rather than via manual QA, a full automated test suite was built against the **Firebase Local Emulator Suite** (never against the live project) at `firebase-emulator-tests/` (Node's built-in test runner + `@firebase/rules-unit-testing`). It covers every collection/path touched by the interim patch: `jobs`, `applications`, `chats` (+ `messages` subcollection), `notifications`, `freelancer_requests`, `users` (+ `saved_jobs` subcollection), and all four Storage prefixes (`cvs`, `profiles`, `portfolios`, `user_resumes`) — 94 test cases total, covering both allowed and denied operations, ownership boundaries, and (where applicable) role boundaries.

**First run: 86/94 passed, 8 failed.** Investigation of the failures:

- 6 failures were a Storage-emulator warm-up race (the very first request issued against a freshly-initialized test project intermittently failed regardless of whether the operation should have been allowed) — not a rules defect. Fixed by adding a rules-bypassed warm-up write before real assertions run; confirmed not a security issue since every other prefix using the identical rule shape passed immediately.
- **2 failures were a real bug**, found only because this test suite exists — see **C-7** below.

### C-7: The `users/{uid}` subcollection rule also matched the parent document itself, silently re-opening C-6 and the delete block — **found and fixed 2026-09-09, deployed same day**

- **Location**: `firestore.rules`, the `match /users/{userId}/{subcollection=**}` block as originally written (deployed 2026-09-08).
- **Explanation**: Firestore's recursive wildcard (`{name=**}`) at the top level of a match path was empirically confirmed — via this test suite, not documentation — to also match the *parent* document path with zero additional segments, not just genuine subcollection documents. Firestore evaluates all matching `match` blocks for a path and grants the operation if **any** of them allows it (rules are OR'd, not AND'd). This meant the broad "self read/write" subcollection rule also applied to `users/{uid}` itself, layering on top of — and silently overriding the intent of — the more restrictive top-level rule that was supposed to lock `userType` on update and block delete entirely.
- **Practical impact**: the C-6 fix (blocking self-role-escalation via `users/{uid}.update({userType: ...})`) and the `allow delete: if false` block were **not actually effective in the version deployed to production on 2026-09-08**, despite deploying without error at the time (the deploy succeeded syntactically; the logic gap only surfaces when you attempt the specific operations these tests exercise). Between 2026-09-08 and 2026-09-09, production likely allowed a user to change their own `userType` and delete their own user document directly. **This window is now closed** — the corrected rule was deployed 2026-09-09 (see Status below).
- **Fix**: nest the subcollection rule one non-recursive level inside the `users/{userId}` match block (`match /{subcollection}/{docId} { ... }` instead of a top-level `match /users/{userId}/{subcollection=**}`), which only matches genuinely-nested documents. Applied in the local `firestore.rules`; retested — all 94 tests, including the two that previously failed, now pass.
- **Status**: **fixed and DEPLOYED to `gojobs-187af`, 2026-09-09** (approved deploy, scoped to `firestore:rules` only — `firebase deploy --only firestore:rules --project gojobs-187af`, confirmed successful: "rules file firestore.rules compiled successfully" / "released rules firestore.rules to cloud.firestore"). Verification performed: the deployed file's sha256 (`618e29445b6c16d5567c1ea50a910b15ff6820a4964693093826bca1aa238703`) was checksummed immediately before and after the deploy and matches exactly, confirming the deployed content is byte-identical to the file that passed all 94 emulator tests (run three consecutive times immediately prior, after also hardening a flaky Storage-emulator warm-up in the test harness itself — a test-infra fix, not a rules change). The CLI does not expose a way to read back live ruleset content for an independent diff; the release confirmation from Firebase's own servers plus checksum identity is the verification trail.
- **Blocks production**: Yes — this is functionally a live regression of C-6.

### Other results

- All C-1 through C-5 regression tests (application status IDOR, job deletion IDOR, chat participant scoping, notification/freelancer-request owner scoping) **passed** — the fixes deployed 2026-09-08 for those are confirmed working as intended, independent of the unrelated C-7 bug above.
- H-2 (storage write scoping) **passed** for all four prefixes once the warm-up race was addressed — confirmed a non-owner cannot upload into, overwrite, or delete another user's file in any of the four known prefixes.
- M-2 (no role check on job creation) was tested and **confirmed still an open, intentional gap** — a non-company account can still create a `jobs` document under its own uid. This was already documented as deferred/out-of-scope for the interim patch (ownership fix only, not role enforcement) and is not treated as a new bug; flagged again here for visibility since the owner asked specifically about role-boundary testing.
- The "legitimate cross-user create" pattern for `notifications` (one user creating a notification addressed to another) was explicitly tested and confirmed **not broken** by the ownership restrictions on read/update/delete.

To re-run this suite: from the repo root, with a JDK on `PATH` (the emulators require Java; Android Studio's bundled JBR at `Program Files/Android/Android Studio/jbr/bin` works if no standalone JDK is installed), run `firebase emulators:exec "cd firebase-emulator-tests && npm test"`. It never touches the live project — the emulator only reads local `firestore.rules`/`storage.rules` and runs entirely on `localhost`.

## Appendix: live rules as provided by the project owner, 2026-09-08

Reproduced verbatim for audit-trail purposes — this is what was actually deployed on `gojobs-187af` at the time of this audit, before the interim patch above.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can read/write their own data AND their sub-collections (like saved jobs)
    match /users/{userId}/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Anyone logged in can read jobs, only companies can write
    match /jobs/{jobId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Applications
    match /applications/{appId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Freelancer Requests
    match /freelancer_requests/{requestId} {
      allow read, write: if request.auth != null;
    }

    // Notifications
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null;
    }

    // Chats
    match /chats/{chatId} {
      allow read, write: if request.auth != null;

      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Note the `jobs`/`applications` comments in the original ("only companies can write") describe *intent* that the rule text itself never enforced — the condition is `request.auth != null` with no role or ownership check, so the comment did not match the actual behavior. This is a useful, if accidental, illustration of why rules need automated tests (Phase 4) rather than being trusted by their comments.
