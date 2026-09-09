import { before, beforeEach, after, describe, it } from 'node:test';
import { assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, deleteDoc, getDoc } from 'firebase/firestore';
import { makeTestEnv } from './helpers.js';

// Covers SECURITY_AUDIT.md C-1 (any authenticated user could change any
// applicant's application status) — the single highest-severity finding
// in the original audit.

const APPLICANT = 'applicant-uid';
const OWNING_COMPANY = 'owning-company-uid';
const OTHER_APPLICANT = 'other-applicant-uid';
const UNRELATED_USER = 'unrelated-uid'; // neither the applicant nor the owning company

let testEnv;

before(async () => {
  testEnv = await makeTestEnv('demo-gojobs-applications-test');
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'applications', 'app-1'), {
      jobId: 'job-1',
      userId: APPLICANT,
      companyId: OWNING_COMPANY,
      jobTitle: 'Backend Engineer',
      status: 'pending',
    });
  });
});

describe('applications/{appId}', () => {
  it('allows the applicant to read their own application', async () => {
    const db = testEnv.authenticatedContext(APPLICANT).firestore();
    await assertSucceeds(getDoc(doc(db, 'applications', 'app-1')));
  });

  it('allows the owning company to read the application', async () => {
    const db = testEnv.authenticatedContext(OWNING_COMPANY).firestore();
    await assertSucceeds(getDoc(doc(db, 'applications', 'app-1')));
  });

  it('[C-1 regression] denies an unrelated user from reading someone else\'s application', async () => {
    const db = testEnv.authenticatedContext(UNRELATED_USER).firestore();
    await assertFails(getDoc(doc(db, 'applications', 'app-1')));
  });

  it('allows a user to create an application as themselves', async () => {
    const db = testEnv.authenticatedContext(OTHER_APPLICANT).firestore();
    await assertSucceeds(
      setDoc(doc(db, 'applications', 'app-2'), {
        jobId: 'job-1',
        userId: OTHER_APPLICANT,
        companyId: OWNING_COMPANY,
        jobTitle: 'Backend Engineer',
        status: 'pending',
      })
    );
  });

  it('denies creating an application impersonating a different applicant', async () => {
    const db = testEnv.authenticatedContext(UNRELATED_USER).firestore();
    await assertFails(
      setDoc(doc(db, 'applications', 'app-3'), {
        jobId: 'job-1',
        userId: OTHER_APPLICANT, // spoofed — not the caller
        companyId: OWNING_COMPANY,
        jobTitle: 'Backend Engineer',
        status: 'pending',
      })
    );
  });

  it('[C-1 regression] allows the owning company to accept/reject the application', async () => {
    const db = testEnv.authenticatedContext(OWNING_COMPANY).firestore();
    await assertSucceeds(updateDoc(doc(db, 'applications', 'app-1'), { status: 'accepted' }));
  });

  it('[C-9, fixed] denies reassigning userId/companyId on update', async () => {
    // Originally either party could rewrite userId or companyId to an
    // arbitrary uid post-hoc. Fixed by requiring both to stay equal to
    // their existing values on every update.
    const db = testEnv.authenticatedContext(OWNING_COMPANY).firestore();
    await assertFails(updateDoc(doc(db, 'applications', 'app-1'), { companyId: UNRELATED_USER }));
  });

  it('[C-9, fixed] denies an arbitrary status value not in the known enum', async () => {
    // Fixed by requiring status to be one of 'pending'|'accepted'|'rejected'.
    const db = testEnv.authenticatedContext(OWNING_COMPANY).firestore();
    await assertFails(updateDoc(doc(db, 'applications', 'app-1'), { status: 'not-a-real-status' }));
  });

  it('[C-9, fixed] denies creating an application with a non-pending status', async () => {
    const db = testEnv.authenticatedContext(OTHER_APPLICANT).firestore();
    await assertFails(
      setDoc(doc(db, 'applications', 'app-sneaky'), {
        jobId: 'job-1',
        userId: OTHER_APPLICANT,
        companyId: OWNING_COMPANY,
        status: 'accepted', // trying to self-approve at creation time
      })
    );
  });

  it('[C-1 regression] denies an unrelated authenticated user from changing the application status', async () => {
    // This is the exact exploit path from the original finding: any
    // signed-in account calling applications/{id}.update({status:'accepted'}).
    const db = testEnv.authenticatedContext(UNRELATED_USER).firestore();
    await assertFails(updateDoc(doc(db, 'applications', 'app-1'), { status: 'accepted' }));

    await testEnv.withSecurityRulesDisabled(async (context) => {
      const snap = await getDoc(doc(context.firestore(), 'applications', 'app-1'));
      if (snap.data().status !== 'pending') {
        throw new Error('Application status was changed despite an expected permission-denied result');
      }
    });
  });

  it('denies a different (non-owning) company from changing the application status', async () => {
    const db = testEnv.authenticatedContext('some-other-company-uid').firestore();
    await assertFails(updateDoc(doc(db, 'applications', 'app-1'), { status: 'rejected' }));
  });

  it('allows the applicant to withdraw (delete) their own application', async () => {
    const db = testEnv.authenticatedContext(APPLICANT).firestore();
    await assertSucceeds(deleteDoc(doc(db, 'applications', 'app-1')));
  });

  it('denies the owning company from deleting the application', async () => {
    const db = testEnv.authenticatedContext(OWNING_COMPANY).firestore();
    await assertFails(deleteDoc(doc(db, 'applications', 'app-1')));
  });

  it('denies an unauthenticated user from reading, creating, or updating applications', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'applications', 'app-1')));
    await assertFails(
      setDoc(doc(db, 'applications', 'anon-app'), { jobId: 'j', userId: 'x', companyId: 'y', status: 'pending' })
    );
    await assertFails(updateDoc(doc(db, 'applications', 'app-1'), { status: 'accepted' }));
  });
});
