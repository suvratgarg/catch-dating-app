import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {BlockDoc, MatchDoc} from "../shared/firestore";
import {appCheckCallableOptions} from "../shared/callableOptions";

const BLOCKS_COLLECTION = "blocks";
const MATCHES_COLLECTION = "matches";

type BlockSource = BlockDoc["source"];

interface BlockUserData {
  targetUserId: string;
  source?: BlockSource;
  reasonCode?: string;
}

interface UnblockUserData {
  targetUserId: string;
}

interface BlockingDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
}

const defaultDeps: BlockingDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
};

/**
 * Builds the deterministic document ID for a directed block edge.
 * @param {string} blockerUserId User creating the block.
 * @param {string} blockedUserId User being blocked.
 * @return {string} Block document ID.
 */
export function blockDocId(
  blockerUserId: string,
  blockedUserId: string
): string {
  return `${blockerUserId}__${blockedUserId}`;
}

/**
 * Returns every directed block document ID needed to check one user against
 * multiple peers.
 * @param {string} userId User being checked.
 * @param {string[]} peerIds Peers in the surface.
 * @return {string[]} Directed block document IDs.
 */
export function blockDocIdsForPairs(
  userId: string,
  peerIds: string[]
): string[] {
  return [...new Set(peerIds.filter((id) => id !== userId))].flatMap((peerId) =>
    [blockDocId(userId, peerId), blockDocId(peerId, userId)]
  );
}

/**
 * Returns true if any block exists between [userId] and [peerIds].
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} userId User being checked.
 * @param {string[]} peerIds Peers to check.
 * @return {Promise<boolean>} Whether a block exists in either direction.
 */
export async function hasBlockingRelationship(
  db: FirebaseFirestore.Firestore,
  userId: string,
  peerIds: string[]
): Promise<boolean> {
  const ids = blockDocIdsForPairs(userId, peerIds);
  if (ids.length === 0) return false;

  const refs = ids.map((id) => db.collection(BLOCKS_COLLECTION).doc(id));
  const snaps = await Promise.all(refs.map((ref) => ref.get()));
  return snaps.some((snap) => snap.exists);
}

/**
 * Transaction-safe block check for booking and waitlist promotion paths.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} userId User being checked.
 * @param {string[]} peerIds Peers to check.
 * @return {Promise<boolean>} Whether a block exists in either direction.
 */
export async function hasBlockingRelationshipInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  userId: string,
  peerIds: string[]
): Promise<boolean> {
  const ids = blockDocIdsForPairs(userId, peerIds);
  if (ids.length === 0) return false;

  const refs = ids.map((id) => db.collection(BLOCKS_COLLECTION).doc(id));
  const snaps = await Promise.all(refs.map((ref) => tx.get(ref)));
  return snaps.some((snap) => snap.exists);
}

/**
 * Throws a generic error if any block edge exists between a user and peers.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} userId User being checked.
 * @param {string[]} peerIds Peers to check.
 */
export async function assertNoBlockingRelationshipInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  userId: string,
  peerIds: string[]
): Promise<void> {
  if (await hasBlockingRelationshipInTransaction(tx, db, userId, peerIds)) {
    throw new HttpsError(
      "failed-precondition",
      "This run is unavailable."
    );
  }
}

/**
 * Callable implementation for creating a directed block edge.
 * @param {CallableRequest<Partial<BlockUserData> | null>} request Callable.
 * @param {BlockingDeps} deps Injectable service dependencies.
 * @return {Promise<{blocked: boolean}>} Operation result.
 */
export async function blockUserHandler(
  request: CallableRequest<Partial<BlockUserData> | null>,
  deps: BlockingDeps = defaultDeps
): Promise<{blocked: boolean}> {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in to block.");
  }

  const blockerUserId = request.auth.uid;
  const blockedUserId = request.data?.targetUserId;
  if (!blockedUserId || blockedUserId === blockerUserId) {
    throw new HttpsError("invalid-argument", "targetUserId is invalid.");
  }

  const db = deps.firestore();
  await db
    .collection(BLOCKS_COLLECTION)
    .doc(blockDocId(blockerUserId, blockedUserId))
    .set({
      blockerUserId,
      blockedUserId,
      createdAt: deps.serverTimestamp(),
      source: request.data?.source ?? "profile",
      ...(request.data?.reasonCode && {reasonCode: request.data.reasonCode}),
    });

  await closeMatchesForBlockedPair({
    db,
    userAId: blockerUserId,
    userBId: blockedUserId,
    blockedBy: blockerUserId,
    serverTimestamp: deps.serverTimestamp,
  });

  return {blocked: true};
}

/**
 * Callable implementation for removing a directed block edge.
 * @param {CallableRequest<Partial<UnblockUserData> | null>} request Callable.
 * @param {BlockingDeps} deps Injectable service dependencies.
 * @return {Promise<{unblocked: boolean}>} Operation result.
 */
export async function unblockUserHandler(
  request: CallableRequest<Partial<UnblockUserData> | null>,
  deps: BlockingDeps = defaultDeps
): Promise<{unblocked: boolean}> {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in to unblock.");
  }

  const blockerUserId = request.auth.uid;
  const blockedUserId = request.data?.targetUserId;
  if (!blockedUserId || blockedUserId === blockerUserId) {
    throw new HttpsError("invalid-argument", "targetUserId is invalid.");
  }

  await deps.firestore()
    .collection(BLOCKS_COLLECTION)
    .doc(blockDocId(blockerUserId, blockedUserId))
    .delete();

  return {unblocked: true};
}

/**
 * Closes existing matches between users after a block.
 * @param {object} params Dependencies and pair IDs.
 * @return {Promise<void>} Resolves after matching docs update.
 */
async function closeMatchesForBlockedPair({
  db,
  userAId,
  userBId,
  blockedBy,
  serverTimestamp,
}: {
  db: FirebaseFirestore.Firestore;
  userAId: string;
  userBId: string;
  blockedBy: string;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
}): Promise<void> {
  const snap = await db
    .collection(MATCHES_COLLECTION)
    .where("participantIds", "array-contains", userAId)
    .get();

  const batch = db.batch();
  let updates = 0;
  for (const doc of snap.docs) {
    const match = doc.data() as MatchDoc;
    if (!match.participantIds?.includes(userBId)) continue;

    batch.update(doc.ref, {
      status: "blocked",
      blockedBy,
      blockedAt: serverTimestamp(),
      unreadCounts: {
        [match.user1Id]: 0,
        [match.user2Id]: 0,
      },
    });
    updates++;
  }

  if (updates > 0) {
    await batch.commit();
  }
}

export const blockUser = onCall(appCheckCallableOptions, (request) =>
  blockUserHandler(request)
);

export const unblockUser = onCall(appCheckCallableOptions, (request) =>
  unblockUserHandler(request)
);

export const onBlockCreated = onDocumentCreated(
  "blocks/{blockId}",
  async (event) => {
    const block = event.data?.data() as BlockDoc | undefined;
    if (!block) return;

    logger.info("Block created", {
      blockerUserId: block.blockerUserId,
      blockedUserId: block.blockedUserId,
    });

    await closeMatchesForBlockedPair({
      db: admin.firestore(),
      userAId: block.blockerUserId,
      userBId: block.blockedUserId,
      blockedBy: block.blockerUserId,
      serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
    });
  }
);
