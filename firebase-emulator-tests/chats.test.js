import { before, beforeEach, after, describe, it } from 'node:test';
import { assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, deleteDoc, getDoc, collection, addDoc } from 'firebase/firestore';
import { makeTestEnv } from './helpers.js';

// Covers SECURITY_AUDIT.md C-4 (any authenticated user could read/write
// into, or impersonate a sender in, any other two users' chat).

const ALICE = 'alice-uid';
const BOB = 'bob-uid';
const STRANGER = 'stranger-uid'; // not a participant in alice/bob's chat

let testEnv;

before(async () => {
  testEnv = await makeTestEnv('demo-gojobs-chats-test');
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'chats', 'alice_bob'), {
      participants: [ALICE, BOB],
      lastMessage: 'hello',
    });
    await setDoc(doc(db, 'chats', 'alice_bob', 'messages', 'm1'), {
      senderId: ALICE,
      text: 'hi bob',
      timestamp: 1,
    });
  });
});

describe('chats/{chatId}', () => {
  it('allows a participant to read the chat', async () => {
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertSucceeds(getDoc(doc(db, 'chats', 'alice_bob')));
  });

  it('[C-4 regression] denies a non-participant from reading the chat', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(getDoc(doc(db, 'chats', 'alice_bob')));
  });

  it('allows a participant to create a new chat that includes themselves', async () => {
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertSucceeds(
      setDoc(doc(db, 'chats', 'alice_stranger'), { participants: [ALICE, STRANGER], lastMessage: 'hey' })
    );
  });

  it('denies creating a chat that does not include the caller as a participant', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(
      setDoc(doc(db, 'chats', 'fake_chat'), { participants: [ALICE, BOB], lastMessage: 'inserted by stranger' })
    );
  });

  it('allows a participant to update the chat (e.g. unread counters)', async () => {
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertSucceeds(updateDoc(doc(db, 'chats', 'alice_bob'), { [`unread_${BOB}`]: 0 }));
  });

  it('[C-4 regression] denies a non-participant from updating the chat', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(updateDoc(doc(db, 'chats', 'alice_bob'), { lastMessage: 'tampered' }));
  });
});

describe('chats/{chatId}/messages/{messageId}', () => {
  it('allows a participant to read messages in their chat', async () => {
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertSucceeds(getDoc(doc(db, 'chats', 'alice_bob', 'messages', 'm1')));
  });

  it('[C-4 regression] denies a non-participant from reading messages', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(getDoc(doc(db, 'chats', 'alice_bob', 'messages', 'm1')));
  });

  it('allows a participant to send a message as themselves', async () => {
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertSucceeds(addDoc(collection(db, 'chats', 'alice_bob', 'messages'), { senderId: BOB, text: 'hi alice', timestamp: 2 }));
  });

  it('[C-4 regression] denies a participant from sending a message with a spoofed senderId', async () => {
    const db = testEnv.authenticatedContext(BOB).firestore();
    await assertFails(
      addDoc(collection(db, 'chats', 'alice_bob', 'messages'), { senderId: ALICE, text: 'impersonating alice', timestamp: 3 })
    );
  });

  it('[C-4 regression] denies a non-participant from posting into the chat at all', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(
      addDoc(collection(db, 'chats', 'alice_bob', 'messages'), { senderId: STRANGER, text: 'eavesdropper message', timestamp: 4 })
    );
  });

  it('denies editing or deleting an existing message (immutable message log)', async () => {
    const db = testEnv.authenticatedContext(ALICE).firestore();
    await assertFails(updateDoc(doc(db, 'chats', 'alice_bob', 'messages', 'm1'), { text: 'edited' }));
    await assertFails(deleteDoc(doc(db, 'chats', 'alice_bob', 'messages', 'm1')));
  });

  it('denies an unauthenticated user from reading or writing chats/messages', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'chats', 'alice_bob')));
    await assertFails(getDoc(doc(db, 'chats', 'alice_bob', 'messages', 'm1')));
    await assertFails(addDoc(collection(db, 'chats', 'alice_bob', 'messages'), { senderId: 'x', text: 'x', timestamp: 5 }));
  });
});
