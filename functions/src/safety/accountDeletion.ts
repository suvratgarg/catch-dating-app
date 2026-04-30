import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";

type StorageBucket = ReturnType<ReturnType<typeof admin.storage>["bucket"]>;

interface AccountDeletionDeps {
  auth: () => admin.auth.Auth;
  firestore: () => FirebaseFirestore.Firestore;
  storageBucket: () => StorageBucket;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
}

const defaultDeps: AccountDeletionDeps = {
  auth: () => admin.auth(),
  firestore: () => admin.firestore(),
  storageBucket: () => admin.storage().bucket(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
};

/**
 * Callable implementation for deleting a user's account-facing data.
 * @param {CallableRequest<null>} request Callable request.
 * @param {AccountDeletionDeps} deps Injectable dependencies.
 * @return {Promise<{deleted: boolean}>} Operation result.
 */
export async function requestAccountDeletionHandler(
  request: CallableRequest<null>,
  deps: AccountDeletionDeps = defaultDeps
): Promise<{deleted: boolean}> {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Must be signed in to delete an account."
    );
  }

  const uid = request.auth.uid;
  const db = deps.firestore();
  const now = deps.serverTimestamp();
  const userSnap = await db.collection("users").doc(uid).get();
  const photoUrls = (userSnap.data()?.photoUrls ?? []) as string[];

  await deleteStorageUrls(photoUrls, deps.storageBucket());

  const batch = db.batch();
  batch.set(db.collection("deletedUsers").doc(uid), {
    uid,
    deletedAt: now,
    retainedFor: ["safety", "payments", "fraud"],
  });
  batch.delete(db.collection("publicProfiles").doc(uid));
  batch.set(db.collection("users").doc(uid), {
    deleted: true,
    deletedAt: now,
    email: "",
    name: "Deleted user",
    bio: "",
    gender: "other",
    sexualOrientation: "other",
    phoneNumber: "",
    profileComplete: false,
    photoUrls: [],
    joinedRunClubIds: [],
    interestedInGenders: [],
    minAgePreference: 18,
    maxAgePreference: 80,
    fcmToken: admin.firestore.FieldValue.delete(),
  }, {merge: true});

  await batch.commit();
  await deps.auth().deleteUser(uid);

  return {deleted: true};
}

/**
 * Deletes Firebase Storage objects represented by download URLs.
 * @param {string[]} urls Public download URLs from user profile docs.
 * @param {StorageBucket} bucket Default Firebase Storage bucket.
 */
async function deleteStorageUrls(
  urls: string[],
  bucket: StorageBucket
): Promise<void> {
  await Promise.all(
    urls
      .map(storagePathFromDownloadUrl)
      .filter((path): path is string => path !== null)
      .map((path) => bucket.file(path).delete({ignoreNotFound: true}))
  );
}

/**
 * Extracts the object path from Firebase Storage download URLs.
 * @param {string} url Download URL.
 * @return {string | null} Decoded Storage object path.
 */
export function storagePathFromDownloadUrl(url: string): string | null {
  try {
    const parsed = new URL(url);
    const marker = "/o/";
    const markerIndex = parsed.pathname.indexOf(marker);
    if (markerIndex === -1) return null;

    const encodedPath = parsed.pathname.substring(markerIndex + marker.length);
    return decodeURIComponent(encodedPath);
  } catch {
    return null;
  }
}

export const requestAccountDeletion = onCall({enforceAppCheck: true}, (
  request
) =>
  requestAccountDeletionHandler(request as CallableRequest<null>)
);
