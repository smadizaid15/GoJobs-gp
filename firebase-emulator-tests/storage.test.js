import { before, after, describe, it } from 'node:test';
import { assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { ref, uploadBytes, getBytes, deleteObject } from 'firebase/storage';
import { makeTestEnv } from './helpers.js';

// Covers SECURITY_AUDIT.md H-2 write side — the live rules previously
// granted `allow read, write: if request.auth != null;` on the ENTIRE
// bucket (`/{allPaths=**}`), meaning any signed-in user could overwrite
// or delete any other user's CV, profile picture, or portfolio photo.
// Read is intentionally left open for cvs/profiles/portfolios/user_resumes
// (documented in storage.rules) pending Phase 8's signed-URL work — these
// tests confirm that intentional read-openness AND the new write scoping.

const OWNER = 'owner-uid';
const OTHER = 'other-uid';
const PAYLOAD = new Uint8Array([1, 2, 3, 4]);

let testEnv;

// Seeding storage objects for tests that need a PRE-EXISTING file (to test
// overwrite/delete-by-another-user) is done via an authenticated write as
// the OWNER themselves (not a rules-bypass), since that's already a
// legitimate, rules-permitted write and keeps setup simple.
async function seed(path) {
  const db = testEnv.authenticatedContext(OWNER).storage();
  await uploadBytes(ref(db, path), PAYLOAD);
}

before(async () => {
  testEnv = await makeTestEnv('demo-gojobs-storage-test');
  // Readiness probe: the Storage emulator can accept connections before it
  // has finished loading storage.rules — observed as a real, not
  // theoretical, flake on a cold GitHub Actions runner (two spuriously
  // failing tests, "no Storage ruleset is currently loaded", even though
  // every later test in the same run passed). A rules-*bypassed* warm-up
  // write (the previous approach, via withSecurityRulesDisabled) only
  // proves the emulator process itself is responding — it can succeed
  // before the ruleset is active, which is exactly the false-ready signal
  // that let this race through locally without ever reproducing it.
  //
  // Instead, retry a real rules-ENFORCED write to a path storage.rules
  // explicitly allows the OWNER to write (cvs/{userId}/{fileName}, see
  // storage.rules:60-63) until it succeeds or a generous deadline elapses.
  // This can only succeed once the real ruleset is loaded and evaluating
  // correctly — the actual condition every test below depends on — so it
  // is a direct readiness check, not a proxy for one.
  //
  // Deadline is 90s, not 20s: observed in CI (not locally) that a fully
  // cold GitHub Actions runner — no cached emulator binaries, forced to
  // download cloud-storage-rules-runtime-*.jar fresh — can take longer
  // than 20s just to finish loading the ruleset, which made this same
  // deterministic probe correctly report "not ready yet" for the entire
  // 20s window and fail loudly (as designed) rather than silently race.
  // 90s is a maximum cold-start allowance, not an intended wait: the loop
  // still returns the moment the real condition is met, same as before.
  const readinessPath = `cvs/${OWNER}/_warmup.bin`;
  const ownerDb = testEnv.authenticatedContext(OWNER).storage();
  const deadline = Date.now() + 90_000;
  let lastError;
  while (Date.now() < deadline) {
    try {
      await uploadBytes(ref(ownerDb, readinessPath), new Uint8Array([0]));
      lastError = undefined;
      break;
    } catch (err) {
      lastError = err;
      await new Promise((resolve) => setTimeout(resolve, 250));
    }
  }
  if (lastError) {
    throw new Error(
      `Storage emulator readiness probe never succeeded within the deadline ` +
        `(the rules-enforced warm-up write to "${readinessPath}" kept failing): ` +
        `${lastError.message}`,
    );
  }
  // Remove the warm-up object via the same authorized owner context, so it
  // can never be mistaken for real test data by anything below — every
  // other test in this file uses its own distinct file name, but cleaning
  // up explicitly (rather than relying on that) keeps warm-up state from
  // ever being able to affect a real assertion.
  //
  // This delete gets its own short bounded retry and is intentionally
  // best-effort, not fatal: a CI run diagnosed the readiness *write*
  // above succeeding quickly every time, but this unprotected delete
  // still throwing "storage/unauthorized" and crashing the whole
  // before() hook — evidently the same class of just-loaded-ruleset
  // propagation lag, one write/delete evaluation behind. A failed delete
  // here can never affect a real test (readinessPath is never reused,
  // and the emulator's in-memory state disappears with the process), so
  // rather than let cleanup flakiness cascade into failing all 49 real
  // Storage tests, retry briefly and fall back to a clear console
  // warning instead of throwing.
  const cleanupDeadline = Date.now() + 10_000;
  let cleanupError;
  while (Date.now() < cleanupDeadline) {
    try {
      await deleteObject(ref(ownerDb, readinessPath));
      cleanupError = undefined;
      break;
    } catch (err) {
      cleanupError = err;
      await new Promise((resolve) => setTimeout(resolve, 250));
    }
  }
  if (cleanupError) {
    console.warn(
      `[storage.test.js] Could not clean up the warm-up object at "${readinessPath}" ` +
        `after the readiness probe succeeded — leaving it in place, this does not ` +
        `affect any test below: ${cleanupError.message}`,
    );
  }
});

after(async () => {
  await testEnv.cleanup();
});

for (const prefix of ['cvs', 'profiles', 'portfolios', 'user_resumes', 'job_images', 'portfolio_images']) {
  describe(`storage: ${prefix}/{uid}/{fileName}`, () => {
    it('allows the owner to upload their own file', async () => {
      const db = testEnv.authenticatedContext(OWNER).storage();
      await assertSucceeds(uploadBytes(ref(db, `${prefix}/${OWNER}/file-${prefix}-a.bin`), PAYLOAD));
    });

    it('[H-2 regression] denies a different user from uploading into someone else\'s folder', async () => {
      const db = testEnv.authenticatedContext(OTHER).storage();
      await assertFails(uploadBytes(ref(db, `${prefix}/${OWNER}/file-${prefix}-b.bin`), PAYLOAD));
    });

    it('[H-2 regression] denies a different user from overwriting an existing file', async () => {
      await seed(`${prefix}/${OWNER}/existing-${prefix}.bin`);
      const otherDb = testEnv.authenticatedContext(OTHER).storage();
      await assertFails(uploadBytes(ref(otherDb, `${prefix}/${OWNER}/existing-${prefix}.bin`), new Uint8Array([9, 9])));
    });

    it('[H-2 regression] denies a different user from deleting the owner\'s file', async () => {
      await seed(`${prefix}/${OWNER}/to-delete-${prefix}.bin`);
      const otherDb = testEnv.authenticatedContext(OTHER).storage();
      await assertFails(deleteObject(ref(otherDb, `${prefix}/${OWNER}/to-delete-${prefix}.bin`)));
    });

    it('allows the owner to delete their own file', async () => {
      await seed(`${prefix}/${OWNER}/to-delete-self-${prefix}.bin`);
      const ownerDb = testEnv.authenticatedContext(OWNER).storage();
      await assertSucceeds(deleteObject(ref(ownerDb, `${prefix}/${OWNER}/to-delete-self-${prefix}.bin`)));
    });

    it('[intentional, deferred to Phase 8] allows any signed-in user to read the file', async () => {
      await seed(`${prefix}/${OWNER}/readable-${prefix}.bin`);
      const otherDb = testEnv.authenticatedContext(OTHER).storage();
      await assertSucceeds(getBytes(ref(otherDb, `${prefix}/${OWNER}/readable-${prefix}.bin`)));
    });

    it('denies an unauthenticated user from reading or writing', async () => {
      await seed(`${prefix}/${OWNER}/anon-check-${prefix}.bin`);
      const anonDb = testEnv.unauthenticatedContext().storage();
      await assertFails(getBytes(ref(anonDb, `${prefix}/${OWNER}/anon-check-${prefix}.bin`)));
      await assertFails(uploadBytes(ref(anonDb, `${prefix}/${OWNER}/anon-upload-${prefix}.bin`), PAYLOAD));
    });
  });
}

describe('storage: company_logos/{uid}.jpg — second-pass fix, not yet deployed', () => {
  // Flat filename (uid IS the filename), not a uid/{fileName} subfolder
  // like the other prefixes — confirmed via
  // lib/screens/company/profile/company_edit_profile_screen.dart:107-110.
  // Missing from the original deploy; this was silently breaking company
  // logo edits in production.

  it('allows the owner to upload their own logo (named exactly {uid}.jpg)', async () => {
    const db = testEnv.authenticatedContext(OWNER).storage();
    await assertSucceeds(uploadBytes(ref(db, `company_logos/${OWNER}.jpg`), PAYLOAD));
  });

  it('denies uploading a logo file named after a different uid', async () => {
    const db = testEnv.authenticatedContext(OTHER).storage();
    await assertFails(uploadBytes(ref(db, `company_logos/${OWNER}.jpg`), PAYLOAD));
  });

  it('allows any signed-in user to read a company logo', async () => {
    // Seed via the OWNER's own legitimate write — the filename MUST be
    // exactly "{uid}.jpg" per the write rule, unlike the other prefixes'
    // tests which can use arbitrary filenames under a uid subfolder.
    const seedDb = testEnv.authenticatedContext(OWNER).storage();
    await uploadBytes(ref(seedDb, `company_logos/${OWNER}.jpg`), PAYLOAD);
    const otherDb = testEnv.authenticatedContext(OTHER).storage();
    // Note: read rule only checks auth, not filename-matches-uid, matching
    // the write rule's narrower scope intentionally (anyone can read any
    // logo; only the owner can write their own).
    await assertSucceeds(getBytes(ref(otherDb, `company_logos/${OWNER}.jpg`)));
  });

  it('denies an unauthenticated user from uploading or reading a logo', async () => {
    const db = testEnv.unauthenticatedContext().storage();
    await assertFails(uploadBytes(ref(db, `company_logos/${OWNER}.jpg`), PAYLOAD));
    await assertFails(getBytes(ref(db, `company_logos/${OWNER}.jpg`)));
  });

  // Phase 1 Storage-rules review (2026-09-09): company_logos previously had
  // no delete coverage at all, unlike every other prefix (which gets
  // delete-by-owner and delete-by-stranger for free via the parameterized
  // loop above). The write rule covers create/update/delete uniformly in
  // Storage, so this was a real, if likely low-risk, coverage gap rather
  // than an actual behavior difference — closing it explicitly.

  it('[Phase 1 review] allows the owner to delete their own logo', async () => {
    const seedDb = testEnv.authenticatedContext(OWNER).storage();
    await uploadBytes(ref(seedDb, `company_logos/${OWNER}.jpg`), PAYLOAD);
    const ownerDb = testEnv.authenticatedContext(OWNER).storage();
    await assertSucceeds(deleteObject(ref(ownerDb, `company_logos/${OWNER}.jpg`)));
  });

  it('[Phase 1 review] denies a different user from deleting the owner\'s logo', async () => {
    const seedDb = testEnv.authenticatedContext(OWNER).storage();
    await uploadBytes(ref(seedDb, `company_logos/${OWNER}.jpg`), PAYLOAD);
    const otherDb = testEnv.authenticatedContext(OTHER).storage();
    await assertFails(deleteObject(ref(otherDb, `company_logos/${OWNER}.jpg`)));
  });
});

describe('storage: paths outside the known prefixes', () => {
  it('denies read/write to an unrecognized path by default (deny-by-default, no bucket-wide catch-all anymore)', async () => {
    const db = testEnv.authenticatedContext(OWNER).storage();
    await assertFails(uploadBytes(ref(db, `some_other_path/${OWNER}/file.bin`), PAYLOAD));
    await assertFails(getBytes(ref(db, `some_other_path/${OWNER}/file.bin`)));
  });
});
