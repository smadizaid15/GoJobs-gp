import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';

const __dirname = dirname(fileURLToPath(import.meta.url));

const FIRESTORE_RULES = readFileSync(join(__dirname, '..', 'firestore.rules'), 'utf8');
const STORAGE_RULES = readFileSync(join(__dirname, '..', 'storage.rules'), 'utf8');

// Each test file passes its own unique projectId so parallel test files
// (Node's test runner may run separate files concurrently) never share
// emulator state and never need to coordinate clearFirestore() calls.
export async function makeTestEnv(projectId) {
  return initializeTestEnvironment({
    projectId,
    firestore: {
      rules: FIRESTORE_RULES,
      host: '127.0.0.1',
      port: 8080,
    },
    storage: {
      rules: STORAGE_RULES,
      host: '127.0.0.1',
      port: 9199,
    },
  });
}
