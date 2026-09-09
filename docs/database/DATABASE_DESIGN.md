# GoJobs — Database Design (Cloud Firestore)

Status: current-state schema (reverse-engineered from client code, since no schema file exists in the repo) plus the target rules/indexes model.

## Why Firestore (not a relational DB)

The brief asks us to evaluate this rather than assume it. GoJobs' actual access patterns — fetch active jobs, fetch a company's own jobs, fetch a user's own applications, fetch a job's applicants, toggle a saved-job flag, per-user chat threads — are all single-collection, owner-scoped, or simple-filter queries. None of the flows found in the codebase require multi-table joins, cross-entity transactions beyond single-document updates, or complex relational integrity constraints. Firestore's document model fits this shape well, and its client SDKs already directly support the read-heavy, real-time-update patterns the app uses (`StreamBuilder` over `snapshots()`). **Conclusion: keep Firestore.** Migrating to PostgreSQL/MySQL would add operational overhead (a database to run, connection pooling, migrations) without solving a problem GoJobs actually has. Revisit only if a future requirement genuinely needs relational integrity or complex joins that Firestore denormalization can't reasonably express.

## Current collections (as implemented today)

### `users/{uid}`

| Field | Type | Notes |
|---|---|---|
| `uid` | string | Firebase Auth uid, duplicated onto the doc |
| `email` | string | |
| `userType` | string | `jobSeeker` \| `company` \| `student` — **the authorization-relevant field; currently unenforced by any rule** |
| `userMode` | string | `jobSeeker` (only value seen) — vestigial toward a `freelancer` mode that has no distinct signup flow |
| `firstName`, `lastName` | string | job seeker / student only |
| `companyName`, `category`, `licenseNumber` | string | company only |
| `createdAt` | timestamp | `FieldValue.serverTimestamp()` |
| (profile-edit fields) | various | skills, bio, experience, portfolio, etc. — written by role-specific edit screens via `UserService.updateUser`'s unrestricted map update |

**Subcollection** `users/{uid}/saved_jobs/{jobId}`: `{jobId, savedAt}` — a simple per-user toggle set.

### `jobs/{jobId}`

| Field | Type | Notes |
|---|---|---|
| `companyId` | string | **ownership field** — should equal the creating company's uid |
| `companyName` | string | denormalized for display without a join |
| `title`, `location`, `workplaceType`, `employmentType`, `description`, `salary` | string | |
| `companyLogo`, `jobImages` | string / array | Storage URLs |
| `isActive` | bool | drives `getActiveJobs()` visibility |
| `createdAt` | timestamp | |

No `updatedAt`, no edit history, no soft-delete flag — `deleteJob()` performs a hard delete. No `updateJob`/edit function exists at all in the current codebase.

### `applications/{applicationId}`

| Field | Type | Notes |
|---|---|---|
| `jobId` | string | |
| `userId` | string | **ownership field for the applicant** |
| `userName` | string | denormalized |
| `companyId` | string | **ownership field for the job owner** — denormalized from the job at apply-time so applicant lists can be queried without a join |
| `jobTitle` | string | denormalized |
| `cvUrl` | string | Storage download URL |
| `additionalInfo` | string, optional | |
| `status` | string | `pending` \| `accepted` \| `rejected` — drives the accept/reject workflow; **not validated against the enum anywhere server-side** |
| `createdAt` | timestamp | |

### Chats / messages (no dedicated collection schema — ad hoc per screen)

Four separate screens (job_seeker/freelancer/student/company chat) each implement their own read/write logic inline against a `chats`-shaped structure (sender/receiver/text/timestamp). `lib/models/message_model.dart` exists (`id`, `senderId`, `text`, `timestamp`) but has no `chatId`/`receiverId` field — thread identity is passed ad hoc through router `extra` maps rather than modeled. This is flagged in the Feature Matrix as a consolidation target, not just a documentation gap.

### Notifications (implied, not modeled)

Read by notification screens; FCM token persistence (`NotificationService.saveTokenToFirestore()`) is currently a non-functional stub, so there is no reliable `users/{uid}.fcmTokens` (or similar) field being written today despite the notification screens expecting one to exist eventually.

## Denormalization decisions (current, to be made intentional going forward)

- `ApplicationModel.companyId` is denormalized from the parent job at application-creation time specifically so `getJobApplications`/company-side queries can filter `applications` directly by `companyId` without a join — this is a reasonable, Firestore-idiomatic choice and should be **kept** in the target design, just validated server-side going forward (the backend re-derives `companyId` from the job document at write time rather than trusting whatever the client sends).
- `jobTitle`/`companyName`/`userName` are denormalized onto `applications`/`jobs` purely for list-display convenience (avoids a second read per list item). Acceptable Firestore practice; the target design keeps this but adds a plan for keeping denormalized copies in sync if the source (e.g. company name) changes — currently no such sync exists (a company renaming itself would leave stale `companyName` strings on old job/application docs). This is a known, documented tradeoff, not an oversight to "fix" blindly — full consistency would require either a Cloud Function trigger to cascade the rename, or accepting the staleness as a documented limitation. Recommend the latter for v1 (company renames are rare; staleness is cosmetic) and revisit only if it becomes a real product complaint.

## Query patterns in use today

| Query | Collection | Filter | Used by |
|---|---|---|---|
| Active job listing | `jobs` | `isActive == true` | Job browse screens (all roles) |
| Company's own jobs | `jobs` | `companyId == :uid` | Company job-management screen |
| Single job detail | `jobs/{jobId}` | doc read | Job detail screens |
| Saved jobs | `users/{uid}/saved_jobs` | subcollection read, `orderBy savedAt desc` | Saved-jobs screens |
| User's own applications | `applications` | `userId == :uid`, `orderBy createdAt desc` | "My applications" screens |
| A job's applicants | `applications` | `jobId == :jobId`, `orderBy createdAt desc` | (defined, used for per-job applicant views) |
| Company's applicants (all jobs) | `applications` | `companyId == :uid` | Company applicants screen |
| Duplicate-application check | `applications` | `jobId == :jobId AND userId == :uid` | `applyForJob` pre-check |

All of these are simple equality/range filters Firestore handles natively; none require the app to fetch-then-filter client-side at scale.

## Indexes

**No `firestore.indexes.json` exists in the repo today** — any composite indexes currently backing the two-field queries above (e.g. the duplicate-application check, which filters on both `jobId` and `userId`) were created ad hoc via the Firebase Console or Firestore's auto-index-creation prompt, and are therefore unversioned and unreproducible across environments. **Target: `firestore.indexes.json` is added to the repo and deployed via `firebase deploy --only firestore:indexes`**, covering at minimum:
- `applications`: composite index on (`jobId` asc, `userId` asc) — duplicate-check query.
- `applications`: composite index on (`companyId` asc, `createdAt` desc) — company applicants list ordering.
- `applications`: composite index on (`userId` asc, `createdAt` desc) — user's own applications ordering.
- `jobs`: composite index on (`companyId` asc, `createdAt` desc) — company job list, if ordering is added.

## Transactions

No multi-document transactions are used anywhere in the current codebase (every write is a single-document `.set()`/`.update()`/`.delete()` or an `.add()`). This is appropriate for the current write patterns; the one place a transaction *should* be introduced going forward is the future backend's application-status-change endpoint, to atomically verify-and-write (read the application + its parent job's `companyId` inside a transaction, then write `status`) rather than the current pattern of trusting a pre-fetched `companyId` field.

## Data ownership, retention, deletion, archival

Not currently implemented anywhere (no account-deletion flow, no data-retention policy, no archival strategy for old/expired job postings or rejected applications). Target design (Phase 4/5):
- **User data deletion**: a backend endpoint that, on account deletion, removes/anonymizes the `users/{uid}` doc, the user's own applications (or anonymizes the `userName`/personal fields while preserving aggregate stats the company side may still need), and revokes their Firebase Auth account — required for basic privacy compliance (see the brief's Privacy section) and for Apple/Play Store account-deletion requirements.
- **Job archival**: expired/closed jobs should move to `isActive: false` (already supported) rather than being deleted, preserving `applications` referential integrity (an application pointing at a deleted job doc would otherwise dangle).
- **Retention**: not yet defined pending a product/legal decision on how long to keep rejected applications and inactive job postings — flagged as an open decision for Phase 4/5, not resolved by this audit.

## Expected hot documents / scalability concerns

- `jobs` collection with `isActive == true`: as the platform grows, this becomes a wide fan-out read for every user's home/browse screen. Fine at current and near-term scale via Firestore's native index; if the collection grows very large, pagination (not currently implemented — `getActiveJobs()` streams the *entire* active-jobs result set with no `limit()`) becomes necessary. **Flagged as a Phase 5/6 requirement: add `.limit()` + cursor-based pagination to all list queries before this becomes a real cost/performance problem**, since Firestore bills per document read and an unbounded stream re-reads the whole result set on every snapshot change.
- No document in the current schema is expected to receive extremely high write concurrency (no single "hot" counter-style document exists) — no sharded-counter pattern is needed yet.

## Target Security Rules model (deny-by-default)

Full rule text is authored in Phase 4, but the model is specified here so downstream phases can build against it:

- **Default**: `allow read, write: if false;` for every collection unless explicitly overridden below.
- **`users/{uid}`**: `read` — self or any authenticated user for public-profile fields only (consider a separate `publicProfiles` denormalized collection if full-document public reads are needed, rather than exposing the whole `users` doc); `write` — self only, and **only** through the backend service account for role-relevant fields (client-direct writes to `userType`/role are denied even for the owner — role changes go through backend logic only, e.g. an admin action or a controlled onboarding flow).
- **`jobs/{jobId}`**: `read` — any authenticated user (or public, if job browsing should work pre-login — product decision) where `isActive == true`; company-owner read of their own inactive jobs too. `write` — denied to direct client writes entirely once the backend owns job mutations; if direct client writes are kept for anything, they must check `request.auth.uid == resource.data.companyId` (existing doc) or `request.auth.uid == request.resource.data.companyId` (new doc) plus a `request.auth.token.role == 'EMPLOYER'` custom-claim check.
- **`applications/{applicationId}`**: `read` — `request.auth.uid == resource.data.userId OR request.auth.uid == resource.data.companyId`. `write` (status changes) — denied to direct client writes; status transitions go through the backend only, which re-derives `companyId` from the job doc rather than trusting the denormalized field on the application itself.
- **`users/{uid}/saved_jobs/{jobId}`**: `read, write` — `request.auth.uid == uid` only (the path segment, not a body field, so this is easy to lock down correctly, unlike the current client-side `toggleSavedJob(userId, jobId)` which accepts `userId` as a bare parameter).
- **Storage** (`cvs/{uid}/*`, `profiles/{uid}/*`, `portfolios/{uid}/*`): `read` — owner only (or owner + the company reviewing their application, via a signed URL issued by the backend rather than a rules-level cross-user grant, which Storage rules can't easily express safely); `write` — owner only, **and** only via backend-issued signed URLs once uploads move server-side (Phase 8), with rules as the defense-in-depth backstop enforcing path-prefix-matches-uid plus a `resource.size < X MB` / content-type check for any writes rules still permit directly.

All of the above must be accompanied by **automated rule tests** (Phase 4) run against the Firebase Local Emulator Suite in CI — asserting both the positive cases (owner can read/write their own data) and negative cases (a different authenticated user is denied) for every rule.
