# GoJobs — OWASP Baseline Checklist (ASVS + MASVS)

Status: mapping of relevant OWASP requirements to GoJobs' current state and target plan. This is a working checklist, not a certification — items are marked against what the Phase 0 audit could verify from source; several require a completed backend (Phase 6) or live-environment testing (Phase 12/16) to actually verify, not just plan.

Legend: ✅ met · ⚠️ partial/planned · ❌ not met · ❓ unverifiable from source (depends on live Firebase Console config)

## OWASP ASVS (backend / API) — target state, since no backend exists yet

| ASVS area | Current | Target (Phase) |
|---|---|---|
| V2 Authentication — server-side session/token verification | ❌ (no backend to verify tokens) | ✅ Phase 3: Express middleware verifies Firebase ID tokens via Admin SDK on every protected route |
| V3 Session management | ❌ N/A today | ✅ Phase 3: stateless (ID-token-per-request), no server session state to manage — reduces this category's risk surface by design |
| V4 Access control — server-side authorization | ❌ (see SECURITY_AUDIT.md C-1, C-2, M-2) | ✅ Phase 4: ownership + role checks server-side on every mutating endpoint |
| V5 Validation, sanitization, encoding | ❌ (no server; client-side validation only, easily bypassed) | ✅ Phase 6: Zod schemas on every endpoint (body/query/path), explicit max-lengths |
| V7 Error handling & logging | ❌ (no structured logging exists anywhere) | ✅ Phase 6/15: consistent `{success:false, error:{code,message,requestId}}` shape, no stack traces/internals in responses; structured logs excluding secrets |
| V8 Data protection | ❓ (depends on unverified Firestore/Storage rules — SECURITY_AUDIT.md C-3) | ✅ Phase 4: deny-by-default rules as defense-in-depth behind the backend |
| V9 Communications security | ✅ (Firebase SDKs and `http` package use HTTPS by default; no cleartext exceptions found in native config) | ✅ Cloud Run enforces HTTPS by default |
| V10 Malicious code / dependency risk | ⚠️ (`non-functional.yml` checks staleness, not CVEs — see EXISTING_SYSTEM.md §12) | ✅ Phase 13: real dependency + secret scanning in CI |
| V12 File & resource handling | ❌ (SECURITY_AUDIT.md H-2 — no size/MIME enforcement) | ✅ Phase 8: backend-mediated uploads with server-side validation |
| V13 API design | ❌ (no API exists) | ✅ Phase 6: versioned `/api/v1`, consistent error shape, rate limiting |
| V14 Configuration — secrets management | ❌ (SECURITY_AUDIT.md H-1 — client-embedded API key) | ✅ Phase 1/6: Google Secret Manager + GitHub Actions secrets, `.env.example` with placeholders only |

## OWASP MASVS / MASTG (mobile — Flutter app)

| MASVS area | Current | Target (Phase) |
|---|---|---|
| MASVS-STORAGE — no secrets in local storage | ⚠️ theme preference only in `SharedPreferences` (non-sensitive); Firebase Auth SDK manages its own token storage internally (not directly inspected by this audit — Firebase's default is Keychain/Keystore-backed, considered acceptable) | ✅ continue relying on Firebase Auth's managed token storage; audit any future custom token/credential storage before adding it |
| MASVS-CRYPTO — no cryptographic code implemented | N/A (app implements no custom crypto — relies entirely on Firebase/TLS) | N/A — keep it that way; do not hand-roll crypto |
| MASVS-AUTH — authentication & session | ⚠️ Firebase Auth (email/password) client-side; no backend-side re-verification today | ✅ Phase 3: backend re-verifies every ID token; consider adding stronger controls for company/admin-sensitive actions (Phase 4/10) |
| MASVS-NETWORK — secure network communication | ✅ No ATS exceptions in `Info.plist` (no `NSAllowsArbitraryLoads`); no `usesCleartextTraffic` override in Android manifest — HTTPS-only by platform default | ✅ maintain; add certificate/network-security-config review once the custom backend domain is live |
| MASVS-PLATFORM — platform interaction / permissions | ❌ iOS: `Info.plist` is missing all camera/photo-library usage-description strings required by `image_picker`/`file_picker` (will crash at runtime, not just fail review — see PRODUCTION_READINESS.md) | ✅ Phase 1 (quick fix, can happen ahead of the rest of the roadmap): add proper usage-description strings |
| MASVS-CODE — build config, no debug artifacts in release | ❌ Android release build signs with the **debug keystore** (`android/app/build.gradle.kts:40`) | ✅ Phase 1/14: real release signing config, keystore managed via Secret Manager/CI secrets, never committed |
| MASVS-RESILIENCE — anti-tampering/App Check | ❌ No Firebase App Check configured | ✅ Phase 12: App Check enforced client + API-edge |
| Client holds no secrets | ❌ Groq API key hardcoded client-side (SECURITY_AUDIT.md H-1) | ✅ Phase 1/6: removed, proxied via backend |
| Logging hygiene | ⚠️ `debugPrint`/`print` leak tokens/payloads/errors (SECURITY_AUDIT.md L-1, L-2) | ✅ Phase 11/13: structured logger, `avoid_print` enforced in CI |

## Explicit non-claims

Per the brief's own instruction: **this checklist does not claim "zero vulnerabilities" or full ASVS/MASVS compliance.** It is a starting risk register mapped against a codebase that currently has no backend and no version-controlled security rules. Re-assess this checklist at the end of Phase 12 (Security) and again before Phase 18 (Production Launch), and update the ✅/⚠️/❌/❓ markers based on actual verification (rule emulator tests, live-rules confirmation, a real security-testing pass) rather than plan intent alone.
