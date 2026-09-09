import { before, beforeEach, after, describe, it } from 'node:test';
import { assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, deleteDoc, getDoc, collection, addDoc } from 'firebase/firestore';
import { makeTestEnv } from './helpers.js';

// Covers SECURITY_AUDIT.md C-5 (freelancer_requests half) — any
// authenticated user could read/tamper with any freelancer service
// request between any two other people.

const FREELANCER = 'freelancer-uid';
const CLIENT = 'client-uid';
const STRANGER = 'stranger-uid';

let testEnv;

before(async () => {
  testEnv = await makeTestEnv('demo-gojobs-freelancer-requests-test');
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'freelancer_requests', 'req-1'), {
      freelancerId: FREELANCER,
      clientId: CLIENT,
      status: 'pending',
    });
  });
});

describe('freelancer_requests/{requestId}', () => {
  it('allows the freelancer to read the request', async () => {
    const db = testEnv.authenticatedContext(FREELANCER).firestore();
    await assertSucceeds(getDoc(doc(db, 'freelancer_requests', 'req-1')));
  });

  it('allows the client to read the request', async () => {
    const db = testEnv.authenticatedContext(CLIENT).firestore();
    await assertSucceeds(getDoc(doc(db, 'freelancer_requests', 'req-1')));
  });

  it('[C-5 regression] denies an unrelated user from reading the request', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(getDoc(doc(db, 'freelancer_requests', 'req-1')));
  });

  it('allows a client to create a request naming themselves as clientId', async () => {
    const db = testEnv.authenticatedContext(CLIENT).firestore();
    await assertSucceeds(
      addDoc(collection(db, 'freelancer_requests'), { freelancerId: FREELANCER, clientId: CLIENT, status: 'pending' })
    );
  });

  it('denies creating a request with a spoofed clientId', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(
      addDoc(collection(db, 'freelancer_requests'), { freelancerId: FREELANCER, clientId: CLIENT, status: 'pending' })
    );
  });

  it('allows the freelancer to accept/decline (update status)', async () => {
    const db = testEnv.authenticatedContext(FREELANCER).firestore();
    await assertSucceeds(updateDoc(doc(db, 'freelancer_requests', 'req-1'), { status: 'accepted' }));
  });

  // Third-pass audit fix regression tests — the update rule previously had
  // no ownership-field immutability or status validation (same class of
  // bug already fixed for jobs/applications as C-9, but missed here).

  it('[freelancer_requests fix] denies changing freelancerId on update', async () => {
    const db = testEnv.authenticatedContext(FREELANCER).firestore();
    await assertFails(updateDoc(doc(db, 'freelancer_requests', 'req-1'), { freelancerId: STRANGER }));
  });

  it('[freelancer_requests fix] denies changing clientId on update', async () => {
    const db = testEnv.authenticatedContext(CLIENT).firestore();
    await assertFails(updateDoc(doc(db, 'freelancer_requests', 'req-1'), { clientId: STRANGER }));
  });

  it('[freelancer_requests fix] denies an invalid status value on update', async () => {
    const db = testEnv.authenticatedContext(FREELANCER).firestore();
    await assertFails(updateDoc(doc(db, 'freelancer_requests', 'req-1'), { status: 'not-a-real-status' }));
  });

  it('[freelancer_requests fix] denies creating a request with a non-pending status', async () => {
    const db = testEnv.authenticatedContext(CLIENT).firestore();
    await assertFails(
      addDoc(collection(db, 'freelancer_requests'), { freelancerId: FREELANCER, clientId: CLIENT, status: 'accepted' })
    );
  });

  it('[freelancer_requests fix] allows a valid update that leaves freelancerId/clientId unchanged and sets an allowed status', async () => {
    const db = testEnv.authenticatedContext(CLIENT).firestore();
    await assertSucceeds(updateDoc(doc(db, 'freelancer_requests', 'req-1'), { status: 'declined' }));

    await testEnv.withSecurityRulesDisabled(async (context) => {
      const snap = await getDoc(doc(context.firestore(), 'freelancer_requests', 'req-1'));
      if (snap.data().freelancerId !== FREELANCER || snap.data().clientId !== CLIENT || snap.data().status !== 'declined') {
        throw new Error('Valid update did not apply as expected');
      }
    });
  });

  it('[C-5 regression] denies an unrelated user from changing the request status', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(updateDoc(doc(db, 'freelancer_requests', 'req-1'), { status: 'accepted' }));

    await testEnv.withSecurityRulesDisabled(async (context) => {
      const snap = await getDoc(doc(context.firestore(), 'freelancer_requests', 'req-1'));
      if (snap.data().status !== 'pending') {
        throw new Error('Request status was changed despite an expected permission-denied result');
      }
    });
  });

  it('allows the client to cancel (delete) their own request', async () => {
    const db = testEnv.authenticatedContext(CLIENT).firestore();
    await assertSucceeds(deleteDoc(doc(db, 'freelancer_requests', 'req-1')));
  });

  it('denies an unrelated user from deleting the request', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(deleteDoc(doc(db, 'freelancer_requests', 'req-1')));
  });
});
