import { before, beforeEach, after, describe, it } from 'node:test';
import { assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, deleteDoc, getDoc, collection, addDoc } from 'firebase/firestore';
import { makeTestEnv } from './helpers.js';

// Covers SECURITY_AUDIT.md C-5 (notifications half) — any authenticated
// user could read/mark-read/delete any other user's notifications. The
// app uses two different owner-field conventions (`userId` in some
// call-sites, `recipientId` in others) — both must be honored.

const RECIPIENT_VIA_USERID = 'user-a-uid';
const RECIPIENT_VIA_RECIPIENTID = 'user-b-uid';
const STRANGER = 'stranger-uid';

let testEnv;

before(async () => {
  testEnv = await makeTestEnv('demo-gojobs-notifications-test');
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'notifications', 'notif-userId-style'), {
      userId: RECIPIENT_VIA_USERID,
      type: 'job',
      title: 'Your job is live',
      isRead: false,
    });
    await setDoc(doc(db, 'notifications', 'notif-recipientId-style'), {
      recipientId: RECIPIENT_VIA_RECIPIENTID,
      type: 'application',
      title: 'New application',
      isRead: false,
    });
  });
});

describe('notifications/{notificationId} — userId convention', () => {
  it('allows the owner (matched via userId) to read their notification', async () => {
    const db = testEnv.authenticatedContext(RECIPIENT_VIA_USERID).firestore();
    await assertSucceeds(getDoc(doc(db, 'notifications', 'notif-userId-style')));
  });

  it('[C-5 regression] denies a stranger from reading it', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(getDoc(doc(db, 'notifications', 'notif-userId-style')));
  });

  it('allows the owner to mark it read', async () => {
    const db = testEnv.authenticatedContext(RECIPIENT_VIA_USERID).firestore();
    await assertSucceeds(updateDoc(doc(db, 'notifications', 'notif-userId-style'), { isRead: true }));
  });

  it('[C-5 regression] denies a stranger from marking it read or deleting it', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(updateDoc(doc(db, 'notifications', 'notif-userId-style'), { isRead: true }));
    await assertFails(deleteDoc(doc(db, 'notifications', 'notif-userId-style')));
  });
});

describe('notifications/{notificationId} — recipientId convention', () => {
  it('allows the owner (matched via recipientId) to read their notification', async () => {
    const db = testEnv.authenticatedContext(RECIPIENT_VIA_RECIPIENTID).firestore();
    await assertSucceeds(getDoc(doc(db, 'notifications', 'notif-recipientId-style')));
  });

  it('[C-5 regression] denies a stranger from reading it', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(getDoc(doc(db, 'notifications', 'notif-recipientId-style')));
  });

  it('allows the owner to mark it read', async () => {
    const db = testEnv.authenticatedContext(RECIPIENT_VIA_RECIPIENTID).firestore();
    await assertSucceeds(updateDoc(doc(db, 'notifications', 'notif-recipientId-style'), { isRead: true }));
  });
});

describe('notifications/{notificationId} — legitimate cross-user create', () => {
  it('allows any signed-in user to create a notification addressed to someone else', async () => {
    // This is the normal app flow: a job seeker applying creates a
    // notification FOR the company (recipientId = the company's uid, not
    // the caller's). This must keep working — it is not the vulnerability.
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertSucceeds(
      addDoc(collection(db, 'notifications'), {
        recipientId: RECIPIENT_VIA_RECIPIENTID,
        type: 'application',
        title: 'New application from stranger',
        isRead: false,
      })
    );
  });

  it('denies an unauthenticated user from creating a notification', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      addDoc(collection(db, 'notifications'), { recipientId: 'x', type: 'job', title: 'x', isRead: false })
    );
  });
});
