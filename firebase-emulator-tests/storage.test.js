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
  // Warm-up: the Storage emulator needs a variable amount of time to
  // finish registering a brand-new project id after
  // initializeTestEnvironment() resolves — observed anywhere from
  // instant to 1500ms+ across runs. A single warm-up attempt was not
  // reliable (it can itself fail with the same transient
  // "storage/unauthorized" while the emulator is still catching up), so
  // retry the throwaway admin (rules-bypassed) write until it succeeds
  // or a generous timeout elapses, before any real assertion runs.
  const deadline = Date.now() + 20_000;
  let lastError;
  while (Date.now() < deadline) {
    try {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await uploadBytes(ref(context.storage(), '_warmup/ping.bin'), new Uint8Array([0]));
      });
      lastError = undefined;
      break;
    } catch (err) {
      lastError = err;
      await new Promise((resolve) => setTimeout(resolve, 250));
    }
  }
  if (lastError) throw lastError;
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
