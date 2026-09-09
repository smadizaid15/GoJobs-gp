import { before, beforeEach, after, describe, it } from 'node:test';
import { assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, deleteDoc, getDoc, getDocs, collection } from 'firebase/firestore';
import { makeTestEnv } from './helpers.js';

// Covers SECURITY_AUDIT.md C-2 (any authenticated user could delete/edit
// any company's job) and M-2 (no role check on job creation).

const ALICE = 'alice-company-uid';
const BOB = 'bob-company-uid'; // a different company
const EVE = 'eve-jobseeker-uid'; // a non-company account

let testEnv;

before(async () => {
  testEnv = await makeTestEnv('demo-gojobs-jobs-test');
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  // Seed one job owned by Alice, bypassing rules.
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'jobs', 'alice-job-1'), {
      companyId: ALICE,
      companyName: 'Alice Co',
      title: 'Backend Engineer',
      isActive: true,
    });
  });
});

describe('jobs/{jobId}', () => {
  it('allows any authenticated user to read jobs', async () => {
    const db = testEnv.authenticatedContext(EVE).firestore();
    await assertSucceeds(getDoc(doc(db, 'jobs', 'alice-job-1')));
  });

  it('denies reads to an unauthenticated user', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'jobs', 'alice-job-1')));
  });

  it('allows a user to create a job with their own uid as companyId', async () => {
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertSucceeds(
      setDoc(doc(db, 'jobs', 'alice-job-2'), {
        companyId: ALICE,
        title: 'Frontend Engineer',
        isActive: true,
      })
    );
  });

  it('denies creating a job with someone else\'s uid as companyId (spoofed ownership)', async () => {
    const db = testEnv.authenticatedContext(EVE).firestore();
    await assertFails(
      setDoc(doc(db, 'jobs', 'eve-spoofed-job'), {
        companyId: ALICE,
        title: 'Spoofed job',
        isActive: true,
      })
    );
  });

  it('[KNOWN GAP, M-2] does not currently block a non-company account from creating a job under its own uid', async () => {
    // Documents an intentional scope limit of the interim patch: it fixes
    // ownership (you can't touch someone ELSE's job) but does not yet
    // enforce role (a jobSeeker/student account can still create a job
    // under their own uid, since there is no custom-claim/role check in
    // the deployed rules). This is expected to currently SUCCEED — if it
    // ever starts failing, the rules changed to add role enforcement and
    // this test (and the audit doc) should be updated together.
    const db = testEnv.authenticatedContext(EVE).firestore();
    await assertSucceeds(
      setDoc(doc(db, 'jobs', 'eve-self-job'), {
        companyId: EVE,
        title: 'Job posted by a non-company account',
        isActive: true,
      })
    );
  });

  it('allows the owning company to update its own job', async () => {
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertSucceeds(updateDoc(doc(db, 'jobs', 'alice-job-1'), { title: 'Updated title' }));
  });

  it('[C-9, fixed] denies the owning company from reassigning companyId to someone else', async () => {
    // Originally the update rule only checked `resource.data.companyId ==
    // request.auth.uid` (the EXISTING owner) with nothing requiring
    // companyId to stay the same in the write itself — a company could
    // "donate"/hijack-transfer a job to an arbitrary uid. Fixed by also
    // requiring `request.resource.data.companyId == resource.data.companyId`.
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertFails(updateDoc(doc(db, 'jobs', 'alice-job-1'), { companyId: BOB }));
  });

  it('denies a different company from updating another company\'s job', async () => {
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertFails(updateDoc(doc(db, 'jobs', 'alice-job-1'), { title: 'Hijacked title' }));
  });

  it('denies a non-company account from updating another company\'s job', async () => {
    const db = testEnv.authenticatedContext(EVE).firestore();
    await assertFails(updateDoc(doc(db, 'jobs', 'alice-job-1'), { title: 'Hijacked title' }));
  });

  it('allows the owning company to delete its own job', async () => {
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertSucceeds(deleteDoc(doc(db, 'jobs', 'alice-job-1')));
  });

  it('[C-2 regression] denies a different account from deleting another company\'s job', async () => {
    const bobDb = testEnv.authenticatedContext(BOB).firestore();
    await assertFails(deleteDoc(doc(bobDb, 'jobs', 'alice-job-1')));

    const eveDb = testEnv.authenticatedContext(EVE).firestore();
    await assertFails(deleteDoc(doc(eveDb, 'jobs', 'alice-job-1')));

    // Confirm the job actually still exists (the delete really was blocked,
    // not just that the write returned an error while still going through).
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const snap = await getDoc(doc(context.firestore(), 'jobs', 'alice-job-1'));
      if (!snap.exists()) {
        throw new Error('Job was deleted despite an expected permission-denied result');
      }
    });
  });

  it('denies an unauthenticated user from creating, updating, or deleting a job', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(setDoc(doc(db, 'jobs', 'anon-job'), { companyId: 'x', title: 'x', isActive: true }));
    await assertFails(updateDoc(doc(db, 'jobs', 'alice-job-1'), { title: 'x' }));
    await assertFails(deleteDoc(doc(db, 'jobs', 'alice-job-1')));
  });
});
