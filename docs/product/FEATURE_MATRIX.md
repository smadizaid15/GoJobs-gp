# GoJobs — Feature Matrix

Status: maps every feature found in the existing codebase against production requirements and a keep/rewrite/remove call. Preserves product behavior wherever it doesn't conflict with security, scalability, correctness, or maintainability, per the brief's explicit instruction not to remove functionality just to fit a preferred architecture.

| Feature | Existing | Required for production | Keep | Rewrite | Remove | Notes |
|---|---|---|---|---|---|---|
| Email/password signup (job seeker / company / student) | Yes | Yes | ✅ | | | Client Auth SDK calls are sound; the *Firestore write* that follows (`userType` assignment) needs to move server-side |
| Email verification | Yes (sent, not enforced) | Yes | | ✅ | | Currently a notification only — nothing gates feature access on verified status; add enforcement |
| Login / logout | Yes | Yes | ✅ | | | |
| Forgot / reset password | Yes | Yes | ✅ | | | Standard Firebase Auth flow |
| Update password (in-app) | Yes | Yes | ✅ | | | Reauthentication flow present and correct |
| Role-based home routing | Yes (client-side only) | Yes | | ✅ | | Currently a one-shot splash check with zero persistent guard (SECURITY_AUDIT.md M-1) — needs router guards |
| Job browsing (active jobs list) | Yes | Yes | ✅ | | | Add pagination before this becomes a cost/perf problem (DATABASE_DESIGN.md) |
| Job detail view | Yes | Yes | ✅ | | | |
| Job search | Yes | Yes | ✅ | | | Firestore-native filtering sufficient at current scale; revisit only if advanced search/typo-tolerance becomes a real requirement |
| Job posting (company) | Yes, insecure write | Yes | | ✅ | | Move write behind backend (SECURITY_AUDIT.md M-2); UI stays |
| Job editing | **Does not exist** | Yes (implied — companies will need to fix typos/update postings) | | ✅ (new) | | No `updateJob` function exists anywhere today — this is a genuine feature gap, not just a security gap |
| Job deletion/closing (company) | Yes, insecure write | Yes | | ✅ | | Move write behind backend (SECURITY_AUDIT.md C-2); prefer soft-close (`isActive:false`) over hard delete to preserve application referential integrity |
| Save/unsave a job | Yes, weakly-scoped write | Yes | | ✅ | | `toggleSavedJob` takes `userId` as a bare param (SECURITY_AUDIT.md finding, low severity) — trivial backend/rules fix |
| Apply to a job (with CV) | Yes | Yes | ✅ | | | Core flow is sound; CV upload path needs H-2 fix |
| Duplicate-application prevention | Yes | Yes | ✅ | | | Keep the pre-check; add a backend-side transaction to close the race-condition window a pure client-side check has |
| View own applications | Yes | Yes | ✅ | | | |
| View job's applicants (company) | Yes | Yes | ✅ (read path) | | | Read path is correctly scoped by `companyId`; only the *write* (status change) is the problem |
| Accept / reject applicant | Yes, critical insecure write | Yes | | ✅ | | SECURITY_AUDIT.md C-1 — highest-priority rewrite |
| CV upload | Yes, insecure | Yes | | ✅ | | SECURITY_AUDIT.md H-2 |
| Profile picture upload | Yes, insecure | Yes | | ✅ | | Same H-2 fix pattern |
| Portfolio photo upload (freelancer) | Yes, insecure | Yes | | ✅ | | Same H-2 fix pattern |
| Profile editing (all roles) | Yes | Yes | ✅ mostly | ⚠️ | | Keep the UI/fields; add a field allowlist server-side (SECURITY_AUDIT.md M-3) so role fields can never be included |
| Company profile / logo management | Yes | Yes | ✅ | | | |
| In-app chat | Yes, duplicated 4× | Yes | | ✅ | | Consolidate into one implementation; `message_service.dart` already has the right shape, just needs to actually be used and the `chatId`/`receiverId` model fields added |
| Push notifications (FCM) | Partial — token persistence non-functional | Yes | | ✅ | | `saveTokenToFirestore()` stub needs to actually persist; fan-out needs to move to a backend/background job |
| AI chat assistant | Yes, insecure (client-side key) | Optional/nice-to-have — not core to the job-marketplace product but already built and functional | | ✅ | | Proxy through backend (SECURITY_AUDIT.md H-1); keep the feature, fix the execution |
| AI job-match score | Yes, insecure (same key) | Optional | | ✅ | | Same fix |
| AI job-description generator | Yes, insecure (same key) | Optional | | ✅ | | Same fix |
| AI interview-question prep | Yes, insecure (same key) | Optional | | ✅ | | Same fix |
| Freelancer marketplace browsing | Yes | Yes (stated product feature) | ✅ | | | |
| Freelancer service requests (client→freelancer, accept/decline) | Yes | Yes | ✅ | | | Second-pass discovery — `freelancer_requests` collection, missed by the original audit's collection inventory; ownership scoping now fixed |
| Student courses (browse) | Yes, **currently broken in production** | Yes | | ✅ | | Second-pass discovery — `courses` collection was omitted from the deployed Firestore rules, silently denying every read since 2026-09-08; fix drafted, awaiting deploy approval |
| Student course enrollment | Yes, **currently broken in production** | Yes | | ✅ | | Second-pass discovery — same root cause, `course_enrollments` collection omitted; fix drafted, awaiting deploy approval |
| Student internships | Yes (filtered view of `jobs`, not a separate collection) | Yes | ✅ | | | Corrected from the original audit, which didn't explicitly confirm this — internships are `jobs` docs with `jobType == 'Internship'`, no separate storage |
| Company logo upload/edit | Yes, **currently broken in production** | Yes | | ✅ | | Second-pass discovery — uploads to `company_logos/{uid}.jpg`, a path the deployed Storage rules never covered; fix drafted, awaiting deploy approval |
| Job listing image upload (when posting a job) | Yes, **currently broken in production** | Optional | | ✅ | | Second-pass discovery — uploads to `job_images/{uid}/...`, not covered by deployed rules; fix drafted, awaiting deploy approval |
| Freelancer portfolio photo upload | Yes, **currently broken in production** | Yes | | ✅ | | Second-pass discovery — uploads to `portfolio_images/{uid}/...`; the original audit's "portfolios/" Storage rule covers a *different, dead-code-only* path. Fix drafted, awaiting deploy approval |
| Bilingual UI (Arabic + English) | **Does not exist** | Yes (explicitly stated requirement) | | ✅ (new) | | Zero implementation found — build from scratch (EXISTING_SYSTEM.md §1); sequence before the screen-consolidation pass so strings aren't touched twice |
| RTL layout support | **Does not exist** | Yes (paired with above) | | ✅ (new) | | Same as above |
| Admin platform (moderation, verification, suspension, audit logs) | **Does not exist** | Yes (brief §40) | | ✅ (new) | | Build from scratch, Phase 10 |
| Automated tests (unit/integration/security/e2e) | Effectively none | Yes | | ✅ (new) | | Build from scratch, Phase 11 |
| CI/CD with staging/production gating | Minimal, unlabeled correctly, no gating | Yes | | ✅ | | Phase 13 |
| Environment separation (dev/staging/prod) | **Does not exist** (one Firebase project for everything) | Yes | | ✅ (new) | | Phase 2 |
| Rate limiting / abuse protection | **Does not exist** (no backend to rate-limit) | Yes | | ✅ (new) | | Phase 6/12 |
| Crash reporting / monitoring | **Does not exist** | Yes | | ✅ (new) | | Phase 15 |
| App Store / Play Store readiness (signing, bundle ID, permissions) | Not ready — debug-signed, default bundle IDs, missing iOS permission strings | Yes | | ✅ | | See PRODUCTION_READINESS.md — several of these are quick, low-risk fixes that don't need to wait for the backend work |
| Shared UI component library (`lib/widgets/`) | Scaffolded, all empty stubs | Not itself a product requirement, but a prerequisite for de-duplicating the screen layer | | ✅ (new) | | Root cause of the job_seeker/freelancer/student screen duplication |
| Duplicate/dead code (`api_service.dart`, `chat_service.dart`, unused `message_service.dart`, non-functional notification stub) | Yes | N/A | | | ✅ | Safe to remove once functionality is consolidated into the real implementations |

## Summary

Nothing found in this audit is recommended for outright removal except genuinely dead/duplicate code (`lib/services/api_service.dart`, the empty `chat_service.dart` stub, and the unused parts of the widget scaffold once real components replace them) — every real product feature the current app exposes is marked Keep or Rewrite, never Remove, consistent with the brief's instruction to preserve product behavior. The "Rewrite" column is dominated by one root cause repeated across many rows: **security-sensitive writes currently performed directly from the client need to move behind the new backend** — the UI/UX for nearly every one of those features can stay as-is.
