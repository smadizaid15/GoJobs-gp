import { before, beforeEach, after, describe, it } from 'node:test';
import { assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, deleteDoc, getDoc, collection, addDoc } from 'firebase/firestore';
import { makeTestEnv } from './helpers.js';

// Second-pass audit fix, NOT YET DEPLOYED. `courses` and
// `course_enrollments` were completely missing from the version of
// firestore.rules deployed 2026-09-08 — the original audit pass only
// grepped lib/services/, not the student screens where this feature
// lives (lib/screens/student/courses/*, lib/screens/student/home/*).
// Since the rules deny by default, this has been silently breaking
// course browsing and enrollment in production since that deploy.

const STUDENT = 'student-uid';
const OTHER_STUDENT = 'other-student-uid';

let testEnv;

before(async () => {
  testEnv = await makeTestEnv('demo-gojobs-courses-test');
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'courses', 'course-1'), { title: 'Intro to Flutter' });
    await setDoc(doc(db, 'course_enrollments', 'enrollment-1'), {
      studentId: STUDENT,
      courseId: 'course-1',
      courseTitle: 'Intro to Flutter',
      status: 'enrolled',
    });
  });
});

describe('courses/{courseId}', () => {
  it('[production-regression fix] allows any signed-in user to browse courses', async () => {
    const db = testEnv.authenticatedContext(STUDENT).firestore();
    await assertSucceeds(getDoc(doc(db, 'courses', 'course-1')));
  });

  it('denies an unauthenticated user from reading courses', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'courses', 'course-1')));
  });

  it('denies any client write (no write path exists in the app; course management is out-of-band today)', async () => {
    const db = testEnv.authenticatedContext(STUDENT).firestore();
    await assertFails(setDoc(doc(db, 'courses', 'course-2'), { title: 'Hijacked course' }));
    await assertFails(updateDoc(doc(db, 'courses', 'course-1'), { title: 'Tampered' }));
    await assertFails(deleteDoc(doc(db, 'courses', 'course-1')));
  });
});

describe('course_enrollments/{enrollmentId}', () => {
  it('[production-regression fix] allows a student to enroll themselves', async () => {
    const db = testEnv.authenticatedContext(OTHER_STUDENT).firestore();
    await assertSucceeds(
      addDoc(collection(db, 'course_enrollments'), {
        studentId: OTHER_STUDENT,
        courseId: 'course-1',
        courseTitle: 'Intro to Flutter',
        status: 'enrolled',
      })
    );
  });

  it('denies enrolling with a spoofed studentId', async () => {
    const db = testEnv.authenticatedContext(OTHER_STUDENT).firestore();
    await assertFails(
      addDoc(collection(db, 'course_enrollments'), {
        studentId: STUDENT, // spoofed — not the caller
        courseId: 'course-1',
        courseTitle: 'Intro to Flutter',
        status: 'enrolled',
      })
    );
  });

  it('allows a student to read their own enrollment', async () => {
    const db = testEnv.authenticatedContext(STUDENT).firestore();
    await assertSucceeds(getDoc(doc(db, 'course_enrollments', 'enrollment-1')));
  });

  it('denies a different student from reading someone else\'s enrollment', async () => {
    const db = testEnv.authenticatedContext(OTHER_STUDENT).firestore();
    await assertFails(getDoc(doc(db, 'course_enrollments', 'enrollment-1')));
  });

  it('denies update/delete (no unenroll path exists in the app today)', async () => {
    const db = testEnv.authenticatedContext(STUDENT).firestore();
    await assertFails(updateDoc(doc(db, 'course_enrollments', 'enrollment-1'), { status: 'cancelled' }));
    await assertFails(deleteDoc(doc(db, 'course_enrollments', 'enrollment-1')));
  });

  it('denies an unauthenticated user from reading or creating enrollments', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'course_enrollments', 'enrollment-1')));
    await assertFails(
      addDoc(collection(db, 'course_enrollments'), { studentId: 'x', courseId: 'course-1', status: 'enrolled' })
    );
  });
});
