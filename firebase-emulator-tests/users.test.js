import { before, beforeEach, after, describe, it } from 'node:test';
import { assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, deleteDoc, getDoc } from 'firebase/firestore';
import { makeTestEnv } from './helpers.js';

// Covers SECURITY_AUDIT.md C-6 (any user could self-escalate their role
// by writing userType directly) and confirms the intentionally-preserved
// cross-user read behavior (see docs/architecture/... notes: narrowing
// `users` reads is deferred to Phase 4, not a bug in this interim patch).

const ALICE = 'alice-uid';
const BOB = 'bob-uid';

let testEnv;

before(async () => {
  testEnv = await makeTestEnv('demo-gojobs-users-test');
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users', ALICE), {
      uid: ALICE,
      email: 'alice@example.com',
      userType: 'jobSeeker',
      firstName: 'Alice',
    });
    await setDoc(doc(db, 'users', ALICE, 'saved_jobs', 'job-1'), { jobId: 'job-1' });
  });
});

describe('users/{uid} — document', () => {
  it('[by design, deferred to Phase 4] allows any signed-in user to read any profile', async () => {
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertSucceeds(getDoc(doc(db, 'users', ALICE)));
  });

  it('denies an unauthenticated user from reading a profile', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'users', ALICE)));
  });

  it('allows a user to create their own document at signup', async () => {
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertSucceeds(setDoc(doc(db, 'users', BOB), { uid: BOB, email: 'bob@example.com', userType: 'company' }));
  });

  it('[C-8, second-pass finding] does NOT block a create with arbitrary/privileged fields, only updates are locked', async () => {
    // The C-6/C-7 fix only locks `userType` from changing on an EXISTING
    // doc via `update`. It does nothing to constrain the FIRST write. In
    // the app's own UI this is masked because AuthService only ever
    // calls .set() with one of three fixed literal userType values right
    // after Firebase Auth signup — but nothing server-side enforces that
    // sequencing. Anyone who authenticates directly via the Firebase Auth
    // REST API (bypassing the app's signup screens entirely, e.g. a
    // fresh account with no users/{uid} doc yet) can call
    // users/{own uid}.set(...) themselves with ANY fields at all,
    // including ones the app's UI never offers, before the app ever gets
    // a chance to write its own expected shape. This is expected to
    // CURRENTLY SUCCEED — it is a real, currently-open gap (documented as
    // C-8), not a false alarm. A production fix needs either a
    // schema/field allowlist in rules (`request.resource.data.keys()
    // .hasOnly([...])`) restricting what create is allowed to set, or
    // moving user-document creation behind the backend entirely.
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertSucceeds(
      setDoc(doc(db, 'users', BOB), {
        uid: BOB,
        email: 'bob@example.com',
        userType: 'company',
        isAdmin: true, // a field the app's UI never sets, but rules don't block it
        isVerified: true,
      })
    );
  });

  it('denies a user from creating a document under someone else\'s uid', async () => {
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertFails(setDoc(doc(db, 'users', ALICE), { uid: ALICE, email: 'hijacked@example.com', userType: 'company' }));
  });

  it('allows a user to update their own non-role profile fields', async () => {
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertSucceeds(updateDoc(doc(db, 'users', ALICE), { firstName: 'Alicia' }));
  });

  it('[C-6 regression] denies a user from changing their own userType via a direct write', async () => {
    // This is the exact live self-escalation path that was found: any
    // signed-in job-seeker/student account calling
    // users/{own uid}.update({userType: 'company'}) directly, bypassing
    // the app's signup flow entirely.
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertFails(updateDoc(doc(db, 'users', ALICE), { userType: 'company' }));

    await testEnv.withSecurityRulesDisabled(async (context) => {
      const snap = await getDoc(doc(context.firestore(), 'users', ALICE));
      if (snap.data().userType !== 'jobSeeker') {
        throw new Error('userType changed despite an expected permission-denied result');
      }
    });
  });

  it('denies a different user from updating someone else\'s profile at all', async () => {
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertFails(updateDoc(doc(db, 'users', ALICE), { firstName: 'Hijacked' }));
  });

  it('denies deleting a user document directly (must go through a backend flow)', async () => {
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertFails(deleteDoc(doc(db, 'users', ALICE)));
  });
});

describe('users/{uid}/saved_jobs/{jobId} — subcollection', () => {
  it('allows the owner to read their own saved jobs', async () => {
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertSucceeds(getDoc(doc(db, 'users', ALICE, 'saved_jobs', 'job-1')));
  });

  it('[tightened beyond the original live rules] denies another user from reading someone else\'s saved jobs', async () => {
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertFails(getDoc(doc(db, 'users', ALICE, 'saved_jobs', 'job-1')));
  });

  it('allows the owner to toggle their own saved job', async () => {
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertSucceeds(setDoc(doc(db, 'users', ALICE, 'saved_jobs', 'job-2'), { jobId: 'job-2' }));
    await assertSucceeds(deleteDoc(doc(db, 'users', ALICE, 'saved_jobs', 'job-1')));
  });

  it('denies another user from writing into someone else\'s saved_jobs subcollection', async () => {
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertFails(setDoc(doc(db, 'users', ALICE, 'saved_jobs', 'job-3'), { jobId: 'job-3' }));
  });
});
