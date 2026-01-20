import admin from 'firebase-admin';

let initialized = false;

export function initFirebase() {
  if (initialized) return admin;

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const credsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

  if (!projectId || !credsPath) {
    // Lazy init: allow running without Firebase for local dev.
    return admin;
  }

  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId,
  });

  initialized = true;
  return admin;
}

export function firestore() {
  initFirebase();
  return admin.firestore();
}
