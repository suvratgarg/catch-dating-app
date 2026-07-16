import {onCall, CallableRequest} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireAuth} from "../shared/auth";
import {eventBroadcastDeliveryKey} from "../shared/eventBroadcasts";
import {
  ProfilePhoto,
  ClubMembershipDocument,
  EventParticipationDocument,
} from "../shared/generated/firestoreAdminTypes";

type StorageBucket = ReturnType<ReturnType<typeof admin.storage>["bucket"]>;

interface AccountDeletionDeps {
  auth: () => admin.auth.Auth;
  firestore: () => FirebaseFirestore.Firestore;
  storageBucket: () => StorageBucket;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: AccountDeletionDeps = {
  auth: () => admin.auth(),
  firestore: () => admin.firestore(),
  storageBucket: () => admin.storage().bucket(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
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
  const uid = requireAuth(request);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, uid, "requestAccountDeletion");

  const deletedUserRef = db.collection("deletedUsers").doc(uid);
  const now = deps.serverTimestamp();

  // A legacy tombstone without status is treated as completed. A processing
  // tombstone is deliberately resumed: edge cleanup is status-aware, so a
  // retry does not double-decrement counters.
  const existingTombstone = await deletedUserRef.get();
  if (existingTombstone.exists &&
      existingTombstone.data()?.status !== "processing") {
    await deleteAuthUserIfPresent(deps.auth(), uid);
    return {deleted: true};
  }
  await deletedUserRef.set({
    uid,
    deletedAt: existingTombstone.data()?.deletedAt ?? now,
    status: "processing",
    updatedAt: now,
    retainedFor: ["safety", "payments", "fraud"],
  }, {merge: true});

  const userSnap = await db.collection("users").doc(uid).get();
  const userData = userSnap.data() ?? {};

  await deleteStoragePaths(
    profilePhotoDeletionStoragePaths(uid, userData),
    deps.storageBucket()
  );

  const writer = new BatchQueue(db);
  writer.delete(db.collection("publicProfiles").doc(uid));

  await queueRelationshipCleanup({
    db,
    uid,
    now,
    writer,
  });

  writer.set(db.collection("users").doc(uid), {
    deleted: true,
    deletedAt: now,
    email: "",
    name: "Deleted user",
    firstName: "",
    lastName: "",
    displayName: "Deleted user",
    dateOfBirth: admin.firestore.Timestamp.fromMillis(0),
    profilePrompts: [],
    gender: "other",
    phoneNumber: "",
    profileComplete: false,
    profilePhotos: [],
    city: admin.firestore.FieldValue.delete(),
    interestedInGenders: [],
    minAgePreference: 18,
    maxAgePreference: 99,
    height: admin.firestore.FieldValue.delete(),
    occupation: admin.firestore.FieldValue.delete(),
    company: admin.firestore.FieldValue.delete(),
    education: admin.firestore.FieldValue.delete(),
    religion: admin.firestore.FieldValue.delete(),
    languages: [],
    relationshipGoal: admin.firestore.FieldValue.delete(),
    drinking: admin.firestore.FieldValue.delete(),
    smoking: admin.firestore.FieldValue.delete(),
    workout: admin.firestore.FieldValue.delete(),
    diet: admin.firestore.FieldValue.delete(),
    children: admin.firestore.FieldValue.delete(),
    activityPreferences: {
      running: {
        paceMinSecsPerKm: 300,
        paceMaxSecsPerKm: 420,
        preferredDistances: [],
        runningReasons: [],
        preferredRunTimes: [],
        version: 1,
      },
    },
    paceMinSecsPerKm: admin.firestore.FieldValue.delete(),
    paceMaxSecsPerKm: admin.firestore.FieldValue.delete(),
    preferredDistances: admin.firestore.FieldValue.delete(),
    runningReasons: admin.firestore.FieldValue.delete(),
    preferredRunTimes: admin.firestore.FieldValue.delete(),
    runPreferencesVersion: admin.firestore.FieldValue.delete(),
    fcmToken: admin.firestore.FieldValue.delete(),
  }, {merge: true});

  await writer.commit();

  // Mark the already-present deletion guard complete only after cleanup.
  await deletedUserRef.set({
    uid,
    status: "completed",
    updatedAt: now,
    completedAt: now,
    retainedFor: ["safety", "payments", "fraud"],
  }, {merge: true});
  await deleteAuthUserIfPresent(deps.auth(), uid);

  return {deleted: true};
}

/**
 * Deletes the Auth user, treating an already-removed user as success so the
 * deletion flow is safe to retry.
 * @param {admin.auth.Auth} auth Firebase Auth instance.
 * @param {string} uid User id to remove.
 * @return {Promise<void>}
 */
async function deleteAuthUserIfPresent(
  auth: admin.auth.Auth,
  uid: string
): Promise<void> {
  try {
    await auth.deleteUser(uid);
  } catch (error) {
    if ((error as {code?: string}).code === "auth/user-not-found") {
      return;
    }
    throw error;
  }
}

/**
 * Queues all relationship documents that can still expose a deleted account.
 * The operation is query-driven so new edge collections can be added without
 * scanning canonical parent documents.
 */
async function queueRelationshipCleanup(params: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  now: FirebaseFirestore.FieldValue;
  writer: BatchQueue;
}) {
  const {db, uid, now, writer} = params;
  await Promise.all([
    queueClubMembershipCleanup(db, uid, now, writer),
    queueEventParticipationCleanup(db, uid, now, writer),
    queueSavedEventCleanup(db, uid, writer),
    queueSwipeCleanup(db, uid, writer),
    queueMatchCleanup(db, uid, now, writer),
    queueReviewCleanup(db, uid, now, writer),
    queuePaymentCleanup(db, uid, now, writer),
    queueNotificationCleanup(db, uid, writer),
    queueEventBroadcastCleanup(db, uid, writer),
    queueHostAnalyticsSnapshotCleanup(db, uid, writer),
    queueBlockCleanup(db, uid, writer),
    queueReportCleanup(db, uid, now, writer),
  ]);
}

/** Deletes short-lived host analytics responses owned by the account. */
async function queueHostAnalyticsSnapshotCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  writer: BatchQueue
) {
  const snapshots = await db.collection("hostAnalyticsSnapshots")
    .where("uid", "==", uid)
    .get();
  snapshots.forEach((doc) => writer.delete(doc.ref));
}

/**
 * Marks the user's club membership edges deleted and updates aggregate
 * projections for active memberships.
 */
async function queueClubMembershipCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  now: FirebaseFirestore.FieldValue,
  writer: BatchQueue
) {
  const memberships = await db
    .collection("clubMemberships")
    .where("uid", "==", uid)
    .get();
  memberships.forEach((doc) => {
    const membership = doc.data() as ClubMembershipDocument;
    writer.set(doc.ref, {
      status: "deleted",
      deletedAt: now,
      leftAt: now,
      pushNotificationsEnabled: false,
    }, {merge: true});
    if (membership.status === "active") {
      writer.update(db.collection("clubs").doc(membership.clubId), {
        memberCount: admin.firestore.FieldValue.increment(-1),
      });
    }
  });
}

/**
 * Marks event participation edges deleted and removes active roster/count
 * projections from the event document.
 */
async function queueEventParticipationCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  now: FirebaseFirestore.FieldValue,
  writer: BatchQueue
) {
  const participations = await db
    .collection("eventParticipations")
    .where("uid", "==", uid)
    .get();
  participations.forEach((doc) => {
    const participation = doc.data() as EventParticipationDocument;
    writer.set(doc.ref, {
      status: "deleted",
      updatedAt: now,
      deletedAt: now,
    }, {merge: true});
    const eventPatch = eventParticipationDeletionEventPatch(uid, participation);
    if (Object.keys(eventPatch).length > 0) {
      writer.update(
        db.collection("events").doc(participation.eventId),
        eventPatch
      );
    }
  });
}

/**
 * Builds the event aggregate cleanup for a deleted participation.
 */
function eventParticipationDeletionEventPatch(
  uid: string,
  participation: EventParticipationDocument
): Record<string, unknown> {
  switch (participation.status) {
  case "signedUp": {
    const patch: Record<string, unknown> = {
      bookedCount: admin.firestore.FieldValue.increment(-1),
    };
    if (participation.genderAtSignup) {
      patch[`genderCounts.${participation.genderAtSignup}`] =
        admin.firestore.FieldValue.increment(-1);
    }
    return patch;
  }
  case "waitlisted":
    return {
      waitlistedCount: admin.firestore.FieldValue.increment(-1),
    };
  case "attended":
    return {
      checkedInCount: admin.firestore.FieldValue.increment(-1),
    };
  default:
    return {};
  }
}

/**
 * Deletes direct saved-event edges for the account.
 */
async function queueSavedEventCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  writer: BatchQueue
) {
  const savedEvents = await db
    .collection("savedEvents")
    .where("uid", "==", uid)
    .get();
  savedEvents.forEach((doc) => writer.delete(doc.ref));
}

/**
 * Deletes swipe edges where the account is either actor or target.
 */
async function queueSwipeCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  writer: BatchQueue
) {
  const [outgoing, incoming] = await Promise.all([
    db.collectionGroup("outgoing").where("swiperId", "==", uid).get(),
    db.collectionGroup("outgoing").where("targetId", "==", uid).get(),
  ]);
  const seen = new Set<string>();
  [...outgoing.docs, ...incoming.docs].forEach((doc) => {
    if (seen.has(doc.ref.path)) return;
    seen.add(doc.ref.path);
    writer.delete(doc.ref);
  });
}

/**
 * Closes active matches involving the account and suppresses unread badges.
 */
async function queueMatchCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  now: FirebaseFirestore.FieldValue,
  writer: BatchQueue
) {
  const [participantMatches, user1Matches, user2Matches] = await Promise.all([
    db.collection("matches").where("participantIds", "array-contains", uid)
      .get(),
    db.collection("matches").where("user1Id", "==", uid).get(),
    db.collection("matches").where("user2Id", "==", uid).get(),
  ]);
  const seen = new Set<string>();
  [...participantMatches.docs, ...user1Matches.docs, ...user2Matches.docs]
    .forEach((doc) => {
      if (seen.has(doc.ref.path)) return;
      seen.add(doc.ref.path);
      writer.set(doc.ref, {
        status: "blocked",
        blockedBy: uid,
        blockedAt: now,
        unreadCounts: {},
      }, {merge: true});
    });
}

/**
 * Anonymizes retained reviews so rating history remains intact.
 */
async function queueReviewCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  now: FirebaseFirestore.FieldValue,
  writer: BatchQueue
) {
  const reviews = await db
    .collection("reviews")
    .where("reviewerUserId", "==", uid)
    .get();
  reviews.forEach((doc) => writer.set(doc.ref, {
    reviewerName: "Deleted user",
    reviewerDeleted: true,
    reviewerDeletedAt: now,
    updatedAt: now,
  }, {merge: true}));
}

/**
 * Keeps payment records but removes them from active user-facing ownership.
 */
async function queuePaymentCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  now: FirebaseFirestore.FieldValue,
  writer: BatchQueue
) {
  const payments = await db
    .collection("payments")
    .where("userId", "==", uid)
    .get();
  payments.forEach((doc) => writer.set(doc.ref, {
    userDeleted: true,
    userDeletedAt: now,
  }, {merge: true}));
}

/**
 * Deletes the user's notification timeline items.
 */
async function queueNotificationCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  writer: BatchQueue
) {
  const notifications = await db
    .collection("notifications")
    .doc(uid)
    .collection("items")
    .get();
  notifications.forEach((doc) => writer.delete(doc.ref));
}

/** Deletes authored broadcasts and removes recipient evidence for this user. */
async function queueEventBroadcastCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  writer: BatchQueue
) {
  const [authored, targeted] = await Promise.all([
    db.collection("eventBroadcasts").where("actorUid", "==", uid).get(),
    db.collection("eventBroadcasts")
      .where("targetUids", "array-contains", uid).get(),
  ]);
  const authoredPaths = new Set(authored.docs.map((doc) => doc.ref.path));
  authored.forEach((doc) => writer.delete(doc.ref));
  const deliveryKey = eventBroadcastDeliveryKey(uid);
  targeted.forEach((doc) => {
    if (authoredPaths.has(doc.ref.path)) return;
    writer.update(
      doc.ref,
      eventBroadcastRecipientDeletionPatch(doc.data(), uid, deliveryKey)
    );
  });
}

function eventBroadcastRecipientDeletionPatch(
  receipt: FirebaseFirestore.DocumentData,
  uid: string,
  deliveryKey: string
): Record<string, unknown> {
  const targetUids = Array.isArray(receipt.targetUids) ?
    [...new Set(receipt.targetUids.filter((value: unknown) =>
      typeof value === "string" && value.length > 0 && value !== uid
    ))] :
    [];
  const sourceDeliveries =
    typeof receipt.deliveries === "object" && receipt.deliveries !== null ?
      receipt.deliveries as Record<string, Record<string, unknown>> :
      {};
  const deliveries: Record<string, Record<string, unknown>> = {};
  for (const targetUid of targetUids) {
    const key = eventBroadcastDeliveryKey(targetUid);
    if (key === deliveryKey) continue;
    const delivery = sourceDeliveries[key];
    if (delivery) deliveries[key] = delivery;
  }
  const evidence = Object.values(deliveries)
    .filter((delivery) => delivery.excluded !== true);
  const activityAvailableCount = evidence.filter((delivery) =>
    delivery.activityStatus === "created" ||
    delivery.activityStatus === "existing"
  ).length;
  const pushAcceptedCount = evidence.filter((delivery) =>
    delivery.pushStatus === "accepted"
  ).length;
  const pushFailedCount = evidence.filter((delivery) =>
    delivery.pushStatus === "failed"
  ).length;
  const pushUnknownCount = evidence.filter((delivery) =>
    delivery.pushStatus === "unknown"
  ).length;
  return {
    targetUids,
    deliveries,
    recipientCount: evidence.length,
    excludedCount: targetUids.length - evidence.length,
    activityAvailableCount,
    pushAttemptedCount:
      pushAcceptedCount + pushFailedCount + pushUnknownCount,
    pushAcceptedCount,
    pushFailedCount,
    pushUnknownCount,
  };
}

/**
 * Deletes directed block edges involving the account.
 */
async function queueBlockCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  writer: BatchQueue
) {
  const [blockedByUser, blockingUser] = await Promise.all([
    db.collection("blocks").where("blockerUserId", "==", uid).get(),
    db.collection("blocks").where("blockedUserId", "==", uid).get(),
  ]);
  const seen = new Set<string>();
  [...blockedByUser.docs, ...blockingUser.docs].forEach((doc) => {
    if (seen.has(doc.ref.path)) return;
    seen.add(doc.ref.path);
    writer.delete(doc.ref);
  });
}

/**
 * Marks safety reports involving the deleted account for reviewer context.
 */
async function queueReportCleanup(
  db: FirebaseFirestore.Firestore,
  uid: string,
  now: FirebaseFirestore.FieldValue,
  writer: BatchQueue
) {
  const [reportsByUser, reportsAgainstUser] = await Promise.all([
    db.collection("reports").where("reporterUserId", "==", uid).get(),
    db.collection("reports").where("reportedUserId", "==", uid).get(),
  ]);
  const seen = new Set<string>();
  [...reportsByUser.docs, ...reportsAgainstUser.docs].forEach((doc) => {
    if (seen.has(doc.ref.path)) return;
    seen.add(doc.ref.path);
    writer.set(doc.ref, {
      hasDeletedUser: true,
      deletedUserId: uid,
      deletedUserMarkedAt: now,
    }, {merge: true});
  });
}

/**
 * Small write-batch queue that chunks account deletion work under Firestore's
 * 500-write batch limit.
 */
class BatchQueue {
  private batches: FirebaseFirestore.WriteBatch[] = [];
  private current: FirebaseFirestore.WriteBatch;
  private operationCount = 0;
  private currentOperationCount = 0;

  constructor(private readonly db: FirebaseFirestore.Firestore) {
    this.current = db.batch();
    this.batches.push(this.current);
  }

  set(
    ref: FirebaseFirestore.DocumentReference,
    data: FirebaseFirestore.DocumentData,
    options?: FirebaseFirestore.SetOptions
  ) {
    this.ensureCapacity();
    if (options) {
      this.current.set(ref, data, options);
    } else {
      this.current.set(ref, data);
    }
    this.trackWrite();
  }

  update(
    ref: FirebaseFirestore.DocumentReference,
    data: FirebaseFirestore.UpdateData<FirebaseFirestore.DocumentData>
  ) {
    this.ensureCapacity();
    this.current.update(ref, data);
    this.trackWrite();
  }

  delete(ref: FirebaseFirestore.DocumentReference) {
    this.ensureCapacity();
    this.current.delete(ref);
    this.trackWrite();
  }

  async commit() {
    if (this.operationCount === 0) return;
    await Promise.all(this.batches.map((batch) => batch.commit()));
  }

  private trackWrite() {
    this.operationCount += 1;
    this.currentOperationCount += 1;
  }

  private ensureCapacity() {
    if (this.currentOperationCount >= 450) {
      this.current = this.db.batch();
      this.batches.push(this.current);
      this.currentOperationCount = 0;
    }
  }
}

/**
 * Extracts grouped and legacy profile photo object paths.
 * @param {FirebaseFirestore.DocumentData} user User profile data.
 * @return {string[]} Storage object paths to delete.
 */
function profilePhotoDeletionStoragePaths(
  uid: string,
  user: FirebaseFirestore.DocumentData
): string[] {
  const paths = new Set<string>();
  // storagePath/url are client-supplied (via updateUserProfile), so only delete
  // objects the account actually owns — never a path targeting another user.
  const ownsPath = (value: string): boolean =>
    value.startsWith(`users/${uid}/`);
  const addPath = (value: unknown) => {
    if (typeof value !== "string") return;
    const trimmed = value.trim();
    if (trimmed.length > 0 && ownsPath(trimmed)) paths.add(trimmed);
  };
  const addUrl = (value: unknown) => {
    if (typeof value !== "string") return;
    addPath(storagePathFromDownloadUrl(value));
  };

  const profilePhotos = Array.isArray(user.profilePhotos) ?
    user.profilePhotos as Partial<ProfilePhoto>[] :
    [];
  for (const photo of profilePhotos) {
    if (photo === null || typeof photo !== "object") continue;
    addPath(photo.storagePath);
    addPath(photo.thumbnailStoragePath);
    addUrl(photo.url);
    addUrl(photo.thumbnailUrl);
  }

  return [...paths];
}


/**
 * Deletes Firebase Storage objects represented by object paths.
 * @param {string[]} paths Firebase Storage object paths.
 * @param {StorageBucket} bucket Default Firebase Storage bucket.
 */
async function deleteStoragePaths(
  paths: string[],
  bucket: StorageBucket
): Promise<void> {
  await Promise.all(
    paths.map((path) => bucket.file(path).delete({ignoreNotFound: true}))
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

export const requestAccountDeletion = onCall(appCheckCallableOptions, (
  request
) =>
  requestAccountDeletionHandler(request as CallableRequest<null>)
);
